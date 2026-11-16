// Colector de tasas: BCV + Binance P2P.
// Invocado por `pg_cron` con `x-collector-secret`. Ver ADR 0007.
import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import { collectBcv } from "./bcv.ts";
import { collectBinance } from "./binance.ts";
import {
  type RateWriter,
  SOURCE_BINANCE,
  SOURCE_BCV,
  type SnapshotInput,
} from "./shared.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const COLLECTOR_SECRET = Deno.env.get("COLLECTOR_SECRET") ?? "";

type RunResult = {
  source: string;
  status: "ok" | "error";
  rows: number;
  error?: string;
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}

/** Compara el secreto en tiempo constante, sin filtrar la longitud. */
async function secretMatches(provided: string | null): Promise<boolean> {
  if (!provided || !COLLECTOR_SECRET) return false;

  const encoder = new TextEncoder();
  const [a, b] = await Promise.all([
    crypto.subtle.digest("SHA-256", encoder.encode(provided)),
    crypto.subtle.digest("SHA-256", encoder.encode(COLLECTOR_SECRET)),
  ]);

  const left = new Uint8Array(a);
  const right = new Uint8Array(b);
  let diff = 0;
  for (let i = 0; i < left.length; i++) {
    diff |= left[i] ^ right[i];
  }
  return diff === 0;
}

function writer(supabase: SupabaseClient): RateWriter {
  return async (snapshot: SnapshotInput) => {
    const { data, error } = await supabase.rpc("record_rate_snapshot", {
      p_currency_code: snapshot.currency_code,
      p_source_code: snapshot.source_code,
      p_type: snapshot.type,
      p_rate_value: snapshot.rate_value,
      p_effective_from: snapshot.effective_from,
      p_published_at: snapshot.published_at,
    });

    if (error) {
      throw new Error(`record_rate_snapshot: ${error.message}`);
    }

    // NULL significa que la publicación ya existía (idempotencia).
    return data !== null;
  };
}

/**
 * Abre una corrida `running`, ejecuta la fuente y la cierra en `ok` o `error`.
 * Una fila por fuente: la salud agregada se lee mirando la corrida completa.
 */
async function withRun(
  supabase: SupabaseClient,
  source: string,
  run: () => Promise<number>,
): Promise<RunResult> {
  const { data, error } = await supabase
    .from("collector_runs")
    .insert({ source_code: source, status: "running" })
    .select("id")
    .single();

  if (error || !data) {
    return {
      source,
      status: "error",
      rows: 0,
      error: `collector_runs: ${error?.message ?? "sin id"}`,
    };
  }

  const id = data.id as number;

  try {
    const rows = await run();
    await supabase
      .from("collector_runs")
      .update({
        status: "ok",
        finished_at: new Date().toISOString(),
        rows_written: rows,
        error_message: null,
      })
      .eq("id", id);
    return { source, status: "ok", rows };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    await supabase
      .from("collector_runs")
      .update({
        status: "error",
        finished_at: new Date().toISOString(),
        error_message: message.slice(0, 1000),
      })
      .eq("id", id);
    return { source, status: "error", rows: 0, error: message };
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  if (!(await secretMatches(req.headers.get("x-collector-secret")))) {
    return json({ error: "unauthorized" }, 401);
  }

  if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
    return json({ error: "missing_supabase_env" }, 500);
  }

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const write = writer(supabase);

  const results: RunResult[] = [];
  results.push(await withRun(supabase, SOURCE_BCV, () => collectBcv(write)));
  results.push(
    await withRun(supabase, SOURCE_BINANCE, () => collectBinance(write)),
  );

  const ok = results.every((r) => r.status === "ok");
  return json({ ok, results }, ok ? 200 : 207);
});

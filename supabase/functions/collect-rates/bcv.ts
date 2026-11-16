// Colector del BCV. Ver ADR 0007 §3 y §5.
import { SECTIGO_INTERMEDIATE_PEM } from "./certs/intermediate.ts";
import {
  parseEsVe,
  type RateWriter,
  SOURCE_BCV,
  withTimeout,
} from "./shared.ts";

const BCV_URL = "https://www.bcv.org.ve/";
const TIMEOUT_MS = 10_000;

type Block = { value: number; date: string | null };

/** Extrae el valor y la fecha valor de un bloque `id="dolar"` o `id="euro"`. */
function extractBlock(html: string, id: string): Block {
  const start = html.indexOf(`id="${id}"`);
  if (start === -1) {
    throw new Error(`BCV: no se encontró el bloque id="${id}"`);
  }
  const block = html.slice(start, start + 2000);

  const valueMatch = block.match(/<strong class="strong-tb">([^<]+)<\/strong>/);
  if (!valueMatch) {
    throw new Error(`BCV: no se encontró el valor de ${id}`);
  }

  const dateMatch = block.match(/property="dc:date"[^>]*content="([^"]+)"/);

  return {
    value: parseEsVe(valueMatch[1]),
    date: dateMatch ? dateMatch[1] : null,
  };
}

async function fetchHtml(): Promise<string> {
  return await withTimeout(TIMEOUT_MS, async (signal) => {
    // @ts-ignore: createHttpClient existe en el runtime de Edge Functions.
    const client = Deno.createHttpClient({
      caCerts: [SECTIGO_INTERMEDIATE_PEM],
    });
    const res = await fetch(BCV_URL, {
      // @ts-ignore: la opción `client` la entiende el runtime de Edge Functions.
      client,
      signal,
      headers: { "user-agent": "Cambiami collector (+https://cambiami.app)" },
    });
    if (!res.ok) {
      throw new Error(`BCV respondió ${res.status}`);
    }
    return await res.text();
  });
}

export async function collectBcv(write: RateWriter): Promise<number> {
  const html = await fetchHtml();

  const usd = extractBlock(html, "dolar");
  const eur = extractBlock(html, "euro");

  if (usd.value <= 0) throw new Error("BCV: tasa del dólar no positiva");
  if (eur.value <= 0) throw new Error("BCV: tasa del euro no positiva");

  // El BCV publica una fecha valor por día. Si el euro no trae la suya, se usa
  // la del dólar (S-05). `published_at` = `effective_from` (ADR 0007 §5).
  const effectiveFrom = usd.date ?? eur.date;
  if (!effectiveFrom) {
    throw new Error("BCV: no se encontró la fecha valor");
  }

  let written = 0;

  const usdWritten = await write({
    currency_code: "USD",
    source_code: SOURCE_BCV,
    type: "oficial",
    rate_value: usd.value,
    effective_from: effectiveFrom,
    published_at: effectiveFrom,
  });
  if (usdWritten) written++;

  const eurDate = eur.date ?? effectiveFrom;
  const eurWritten = await write({
    currency_code: "EUR",
    source_code: SOURCE_BCV,
    type: "oficial",
    rate_value: eur.value,
    effective_from: eurDate,
    published_at: eurDate,
  });
  if (eurWritten) written++;

  return written;
}

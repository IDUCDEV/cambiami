// Tipos y utilidades compartidas por las fuentes del colector.

export type SnapshotInput = {
  currency_code: string;
  source_code: string;
  type: "oficial" | "p2p_buy" | "p2p_sell" | "p2p_avg";
  rate_value: number;
  effective_from: string;
  published_at: string | null;
};

/** Escribe un snapshot. Devuelve `true` si insertó y `false` si ya existía. */
export type RateWriter = (snapshot: SnapshotInput) => Promise<boolean>;

export const SOURCE_BCV = "bcv";
export const SOURCE_BINANCE = "binance_p2p";

/** Convierte un número es-VE (`1.010,56`) a `number`. */
export function parseEsVe(raw: string): number {
  const normalized = raw.trim().replace(/\./g, "").replace(",", ".");
  const value = Number(normalized);
  if (!Number.isFinite(value)) {
    throw new Error(`Valor no numérico: ${raw}`);
  }
  return value;
}

/** Redondea a los 6 decimales de `numeric(18,6)`. */
export function round6(value: number): number {
  return Math.round(value * 1e6) / 1e6;
}

/** Instante de la corrida truncado al minuto, en ISO UTC. */
export function runMinute(now: Date = new Date()): string {
  const d = new Date(now.getTime());
  d.setUTCSeconds(0, 0);
  return d.toISOString();
}

/** Ejecuta `fn` y aborta si tarda más de `ms`. */
export async function withTimeout<T>(
  ms: number,
  fn: (signal: AbortSignal) => Promise<T>,
): Promise<T> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), ms);
  try {
    return await fn(controller.signal);
  } catch (error) {
    if (controller.signal.aborted) {
      throw new Error(`Tiempo límite de ${ms} ms excedido`);
    }
    throw error;
  } finally {
    clearTimeout(timer);
  }
}

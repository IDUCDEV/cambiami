// Colector del mercado P2P de Binance. Ver ADR 0007 §4.
import {
  type RateWriter,
  round6,
  runMinute,
  SOURCE_BINANCE,
  withTimeout,
} from "./shared.ts";

const BINANCE_URL =
  "https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search";
const TIMEOUT_MS = 10_000;
const ROWS = 10;

type Side = "BUY" | "SELL";

/**
 * `BUY` son anuncios que compran USDT (el usuario vende) y `SELL` los que
 * venden (el usuario compra). El nombre describe al anunciante, no al usuario.
 */
async function fetchSide(side: Side): Promise<number> {
  return await withTimeout(TIMEOUT_MS, async (signal) => {
    const res = await fetch(BINANCE_URL, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "user-agent": "Cambiami collector (+https://cambiami.app)",
      },
      body: JSON.stringify({
        page: 1,
        rows: ROWS,
        payTypes: [],
        countries: [],
        publisherType: null,
        asset: "USDT",
        fiat: "VES",
        tradeType: side,
      }),
      signal,
    });

    if (!res.ok) {
      throw new Error(`Binance ${side} respondió ${res.status}`);
    }

    const payload = await res.json();
    const ads = Array.isArray(payload?.data) ? payload.data : [];

    const prices = ads
      .map((ad: { adv?: { price?: string } }) => Number(ad?.adv?.price))
      .filter((price: number) => Number.isFinite(price) && price > 0);

    if (prices.length === 0) {
      throw new Error(`Binance ${side}: sin anuncios válidos`);
    }

    return prices.reduce((sum: number, price: number) => sum + price, 0) /
      prices.length;
  });
}

export async function collectBinance(write: RateWriter): Promise<number> {
  const [buyResult, sellResult] = await Promise.allSettled([
    fetchSide("BUY"),
    fetchSide("SELL"),
  ]);

  const buy = buyResult.status === "fulfilled" ? buyResult.value : null;
  const sell = sellResult.status === "fulfilled" ? sellResult.value : null;

  if (buy === null && sell === null) {
    const reasons = [buyResult, sellResult]
      .filter((r): r is PromiseRejectedResult => r.status === "rejected")
      .map((r) => String(r.reason));
    throw new Error(reasons.join(" · ") || "Binance: sin datos");
  }

  const effectiveFrom = runMinute();
  let written = 0;

  if (buy !== null) {
    const ok = await write({
      currency_code: "USDT",
      source_code: SOURCE_BINANCE,
      type: "p2p_buy",
      rate_value: round6(buy),
      effective_from: effectiveFrom,
      published_at: effectiveFrom,
    });
    if (ok) written++;
  }

  if (sell !== null) {
    const ok = await write({
      currency_code: "USDT",
      source_code: SOURCE_BINANCE,
      type: "p2p_sell",
      rate_value: round6(sell),
      effective_from: effectiveFrom,
      published_at: effectiveFrom,
    });
    if (ok) written++;
  }

  // I-04: el promedio solo existe si ambos lados son positivos.
  if (buy !== null && sell !== null) {
    const ok = await write({
      currency_code: "USDT",
      source_code: SOURCE_BINANCE,
      type: "p2p_avg",
      rate_value: round6((buy + sell) / 2),
      effective_from: effectiveFrom,
      published_at: effectiveFrom,
    });
    if (ok) written++;
  }

  return written;
}

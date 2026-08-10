import { jsonResponse } from './_json-response.js';
// @ts-expect-error — JS module, no declaration file
import { readJsonFromUpstash } from './_upstash-json.js';

export const config = { runtime: 'edge' };

// Minimal, standalone endpoint for scripts/run-seeders.sh's own run-level
// summary (seed-meta:seeder-run-summary:v1) — deliberately not routed
// through api/health.js or api/seed-health.js. Those track per-domain
// data freshness; this answers a different, simpler question ("did the
// last scheduled seeder run come back clean or degraded") without adding
// surface area to either of those already-large files.
export default async function handler() {
  const summary = await readJsonFromUpstash('seed-meta:seeder-run-summary:v1');
  if (!summary) {
    return jsonResponse(
      { status: 'no_data', message: 'No seeder run recorded yet.' },
      200,
      { 'Cache-Control': 'no-store' },
    );
  }
  return jsonResponse(summary, 200, { 'Cache-Control': 'no-store' });
}

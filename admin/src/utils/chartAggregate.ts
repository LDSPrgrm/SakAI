export const WEEKDAY_ORDER = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] as const;
type Weekday = (typeof WEEKDAY_ORDER)[number];

export function aggregateByWeekday<K extends string>(
  rows: Array<{ name: string } & Partial<Record<K, number | null>>>,
  keys: readonly K[],
): Array<{ name: string } & Record<K, number | null>> {
  const buckets: Record<string, { sum: Record<K, number>; count: Record<K, number> }> = {};
  for (const r of rows) {
    if (!(WEEKDAY_ORDER as readonly string[]).includes(r.name)) continue;
    if (!buckets[r.name]) {
      const zero = keys.reduce((acc, k) => ({ ...acc, [k]: 0 }), {} as Record<K, number>);
      buckets[r.name] = { sum: { ...zero }, count: { ...zero } };
    }
    const b = buckets[r.name];
    for (const k of keys) {
      const v = r[k];
      if (v == null) continue;
      b.sum[k] += v;
      b.count[k] += 1;
    }
  }
  return WEEKDAY_ORDER.map((wd: Weekday) => {
    const b = buckets[wd];
    const result: Record<string, string | number | null> = { name: wd };
    for (const k of keys) {
      result[k as string] = b && b.count[k] > 0 ? b.sum[k] / b.count[k] : null;
    }
    return result as { name: string } & Record<K, number | null>;
  });
}

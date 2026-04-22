import React, { useState } from 'react';
import { Plus, Trash2, Map as MapIcon } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { activeMapProvider, type Bounds, type SurgeZone } from '@/lib/maps';
import { METRO_MANILA_BOUNDS } from '@/types/super-admin/heatmap';

export interface SurgeZoneEditorProps {
  value: SurgeZone[];
  onChange: (zones: SurgeZone[]) => void;
  bounds?: Bounds;
  disabled?: boolean;
}

// Zone-level editor backed by the active MapProvider (SVG by default).
// Parent form owns the canonical SurgeZone[] and submits it to
// `/admin/surge` alongside the other surge fields.
export function SurgeZoneEditor({ value, onChange, bounds, disabled }: SurgeZoneEditorProps) {
  const [selected, setSelected] = useState<number | null>(value.length ? 0 : null);
  const Editor = activeMapProvider.PolygonEditor;
  const effectiveBounds = bounds ?? METRO_MANILA_BOUNDS;

  function addZone() {
    const next: SurgeZone[] = [
      ...value,
      { name: `Zone ${value.length + 1}`, multiplier: 1.5, polygon: [] },
    ];
    onChange(next);
    setSelected(next.length - 1);
  }

  function removeZone(idx: number) {
    const next = value.filter((_, i) => i !== idx);
    onChange(next);
    if (selected === idx) setSelected(next.length ? 0 : null);
    else if (selected != null && selected > idx) setSelected(selected - 1);
  }

  function updateZone(idx: number, patch: Partial<SurgeZone>) {
    onChange(value.map((z, i) => (i === idx ? { ...z, ...patch } : z)));
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <MapIcon className="w-5 h-5 text-primary" />
          Surge Zones
          <span className="ml-auto text-xs text-text-muted font-normal">
            Provider: {activeMapProvider.label}
          </span>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_16rem] gap-4">
          <div className="relative rounded-lg overflow-hidden border border-border bg-background min-h-[320px]">
            <Editor
              value={value}
              bounds={effectiveBounds}
              onChange={onChange}
              selectedIndex={selected}
              onSelect={setSelected}
            />
            {value.length === 0 && (
              <div className="absolute inset-0 flex items-center justify-center text-xs text-text-muted pointer-events-none">
                Add a zone, then click inside the canvas to drop vertices.
              </div>
            )}
          </div>

          <div className="space-y-2">
            <div className="flex items-center gap-2">
              <p className="text-sm font-medium text-text-main flex-1">Zones ({value.length})</p>
              <Button size="sm" variant="outline" onClick={addZone} disabled={disabled}>
                <Plus className="w-4 h-4" />
              </Button>
            </div>
            <ul className="space-y-1.5 max-h-[280px] overflow-y-auto pr-1">
              {value.map((z, idx) => (
                <li
                  key={idx}
                  className={`p-2 rounded-lg border text-sm cursor-pointer transition-colors ${
                    selected === idx
                      ? 'border-primary bg-primary/10'
                      : 'border-border bg-surface-hover/40 hover:border-border/60'
                  }`}
                  onClick={() => setSelected(idx)}
                >
                  <div className="flex items-center gap-2 mb-1.5">
                    <Input
                      value={z.name}
                      onChange={(e) => updateZone(idx, { name: e.target.value })}
                      onClick={(e) => e.stopPropagation()}
                      className="h-7 text-sm"
                      disabled={disabled}
                    />
                    <button
                      type="button"
                      className="text-danger hover:text-danger/80"
                      onClick={(e) => {
                        e.stopPropagation();
                        removeZone(idx);
                      }}
                      disabled={disabled}
                      aria-label={`Remove ${z.name}`}
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-text-muted">×</span>
                    <Input
                      type="number"
                      step="0.1"
                      min={1}
                      max={5}
                      value={z.multiplier}
                      onChange={(e) => updateZone(idx, { multiplier: parseFloat(e.target.value) || 1 })}
                      onClick={(e) => e.stopPropagation()}
                      className="h-7 text-sm"
                      disabled={disabled}
                    />
                  </div>
                  <p className="text-[10px] text-text-muted mt-1">
                    {z.polygon.length} vertices
                  </p>
                </li>
              ))}
              {value.length === 0 && (
                <li className="p-3 text-xs text-text-muted text-center border border-dashed border-border rounded-lg">
                  No zones configured.
                </li>
              )}
            </ul>
          </div>
        </div>

        <p className="text-xs text-text-muted">
          Click "+" to add a zone, then click inside the canvas to drop vertices (min 3).
          Click a vertex to remove it. Origin-in-zone uses ray-casting on the backend.
        </p>
      </CardContent>
    </Card>
  );
}

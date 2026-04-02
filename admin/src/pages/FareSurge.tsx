import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Settings2, Zap, Calculator, CheckCircle } from 'lucide-react';
import { formatPHP } from '@/lib/utils';

interface FareConfig {
  baseFare: number;
  minFare: number;
  perKm: number;
  perMin: number;
}

const defaultConfigs: Record<string, FareConfig> = {
  motorcycle: { baseFare: 50, minFare: 50, perKm: 10, perMin: 2 },
  tricycle: { baseFare: 40, minFare: 40, perKm: 8, perMin: 1.5 },
  car: { baseFare: 80, minFare: 80, perKm: 15, perMin: 3 },
};

interface FareFormProps {
  vehicle: string;
  config: FareConfig;
  onChange: (vehicle: string, field: keyof FareConfig, value: number) => void;
  errors: Partial<Record<keyof FareConfig, string>>;
}

function FareForm({ vehicle, config, onChange, errors }: FareFormProps) {
  const fields: { key: keyof FareConfig; label: string }[] = [
    { key: 'baseFare', label: 'Base Fare (PHP)' },
    { key: 'minFare', label: 'Minimum Fare (PHP)' },
    { key: 'perKm', label: 'Per Kilometer Rate (PHP)' },
    { key: 'perMin', label: 'Per Minute Rate (PHP)' },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
      {fields.map(({ key, label }) => (
        <div key={key}>
          <label className="block text-sm font-medium text-text-muted mb-1">{label}</label>
          <Input
            type="number"
            min={0}
            step={0.5}
            value={config[key]}
            onChange={(e) => onChange(vehicle, key, parseFloat(e.target.value) || 0)}
            className={errors[key] ? 'border-danger' : ''}
          />
          {errors[key] && <p className="text-xs text-danger mt-1">{errors[key]}</p>}
        </div>
      ))}
    </div>
  );
}

function validateConfig(config: FareConfig): Partial<Record<keyof FareConfig, string>> {
  const errs: Partial<Record<keyof FareConfig, string>> = {};
  if (config.baseFare <= 0) errs.baseFare = 'Must be greater than 0';
  if (config.minFare <= 0) errs.minFare = 'Must be greater than 0';
  if (config.minFare > config.baseFare) errs.minFare = 'Cannot exceed base fare';
  if (config.perKm <= 0) errs.perKm = 'Must be greater than 0';
  if (config.perMin < 0) errs.perMin = 'Cannot be negative';
  return errs;
}

export function FareSurge() {
  const [surgeEnabled, setSurgeEnabled] = useState(true);
  const [configs, setConfigs] = useState<Record<string, FareConfig>>(defaultConfigs);
  const [validationErrors, setValidationErrors] = useState<Record<string, Partial<Record<keyof FareConfig, string>>>>({});
  const [saved, setSaved] = useState(false);

  const [simDistance, setSimDistance] = useState('');
  const [simTime, setSimTime] = useState('');
  const [simVehicle, setSimVehicle] = useState<'motorcycle' | 'tricycle' | 'car'>('motorcycle');
  const [simResult, setSimResult] = useState<number | null>(null);
  const [simError, setSimError] = useState('');

  const handleConfigChange = (vehicle: string, field: keyof FareConfig, value: number) => {
    setConfigs(prev => ({ ...prev, [vehicle]: { ...prev[vehicle], [field]: value } }));
    setSaved(false);
    if (validationErrors[vehicle]?.[field]) {
      setValidationErrors(prev => ({
        ...prev,
        [vehicle]: { ...prev[vehicle], [field]: undefined },
      }));
    }
  };

  const handleSave = () => {
    const allErrors: Record<string, Partial<Record<keyof FareConfig, string>>> = {};
    let hasErrors = false;
    for (const [vehicle, config] of Object.entries(configs)) {
      const errs = validateConfig(config);
      if (Object.keys(errs).length > 0) {
        allErrors[vehicle] = errs;
        hasErrors = true;
      }
    }
    if (hasErrors) {
      setValidationErrors(allErrors);
      return;
    }
    setValidationErrors({});
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const handleCalculate = () => {
    setSimError('');
    setSimResult(null);
    const dist = parseFloat(simDistance);
    const time = parseFloat(simTime);
    if (!simDistance || isNaN(dist) || dist <= 0) {
      setSimError('Enter a valid distance.');
      return;
    }
    if (!simTime || isNaN(time) || time < 0) {
      setSimError('Enter a valid time.');
      return;
    }
    const cfg = configs[simVehicle];
    const fare = Math.max(cfg.minFare, cfg.baseFare + dist * cfg.perKm + time * cfg.perMin);
    setSimResult(fare);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap justify-between items-center gap-3">
        <h1 className="text-2xl font-bold text-text-main">Fare & Surge Management</h1>
        <div className="flex items-center gap-3">
          {saved && (
            <span className="flex items-center gap-1.5 text-sm text-success">
              <CheckCircle className="w-4 h-4" /> Changes saved
            </span>
          )}
          <Button onClick={handleSave}>Save Changes</Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Settings2 className="w-5 h-5 text-primary" />
              Base Fare Configuration
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="motorcycle" className="w-full">
              <TabsList className="mb-4">
                <TabsTrigger value="motorcycle">Motorcycle</TabsTrigger>
                <TabsTrigger value="tricycle">Tricycle</TabsTrigger>
                <TabsTrigger value="car">Car (4-seater)</TabsTrigger>
              </TabsList>

              {(['motorcycle', 'tricycle', 'car'] as const).map((v) => (
                <TabsContent key={v} value={v} className="space-y-4">
                  <FareForm
                    vehicle={v}
                    config={configs[v]}
                    onChange={handleConfigChange}
                    errors={validationErrors[v] ?? {}}
                  />
                </TabsContent>
              ))}
            </Tabs>
          </CardContent>
        </Card>

        <div className="space-y-6 lg:sticky lg:top-6 h-fit">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-warning" />
                Surge Pricing
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between p-3 bg-surface-hover rounded-lg border border-border">
                <div>
                  <p className="font-medium">Enable Auto-Surge</p>
                  <p className="text-xs text-text-muted">Based on demand/supply ratio</p>
                </div>
                <button
                  aria-label={surgeEnabled ? 'Disable auto-surge' : 'Enable auto-surge'}
                  aria-checked={surgeEnabled}
                  role="switch"
                  onClick={() => setSurgeEnabled(!surgeEnabled)}
                  className={`w-11 h-6 rounded-full transition-colors relative ${surgeEnabled ? 'bg-primary' : 'bg-border'}`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-transform ${surgeEnabled ? 'translate-x-6' : 'translate-x-1'}`} />
                </button>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">Max Surge Multiplier</label>
                <div className="flex items-center gap-2">
                  <Input type="number" defaultValue={2.5} step={0.1} min={1} max={5} className="w-full" disabled={!surgeEnabled} />
                  <span className="text-text-muted">x</span>
                </div>
              </div>

              <Button variant="outline" className="w-full">Manage Surge Zones</Button>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Calculator className="w-5 h-5 text-success" />
                Fare Simulator
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <Input
                  placeholder="Distance (km)"
                  type="number"
                  min={0}
                  value={simDistance}
                  onChange={(e) => { setSimDistance(e.target.value); setSimError(''); setSimResult(null); }}
                />
              </div>
              <div>
                <Input
                  placeholder="Estimated Time (mins)"
                  type="number"
                  min={0}
                  value={simTime}
                  onChange={(e) => { setSimTime(e.target.value); setSimError(''); setSimResult(null); }}
                />
              </div>
              <select
                aria-label="Vehicle type"
                value={simVehicle}
                onChange={(e) => { setSimVehicle(e.target.value as typeof simVehicle); setSimResult(null); }}
                className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="motorcycle">Motorcycle</option>
                <option value="tricycle">Tricycle</option>
                <option value="car">Car (4-seater)</option>
              </select>
              {simError && <p className="text-xs text-danger">{simError}</p>}
              <Button className="w-full" onClick={handleCalculate}>Calculate Estimate</Button>

              <div className="mt-4 p-3 bg-surface-hover rounded-lg border border-border text-center">
                <p className="text-xs text-text-muted">Estimated Fare</p>
                <p className="text-2xl font-bold text-text-main">
                  {simResult !== null ? formatPHP(simResult) : '—'}
                </p>
                {simResult !== null && (
                  <p className="text-xs text-text-muted mt-1">
                    Base {formatPHP(configs[simVehicle].baseFare)} + {simDistance}km + {simTime}min
                  </p>
                )}
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}

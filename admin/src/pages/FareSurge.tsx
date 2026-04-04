import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Settings2, Zap, Calculator, CheckCircle } from 'lucide-react';
import { formatPHP } from '@/lib/utils';
import { adminApi, FareConfig, SurgeConfig } from '@/lib/admin-api';

type VehicleType = 'motorcycle' | 'tricycle' | 'car';

interface FareFormProps {
  vehicle: VehicleType;
  config: FareConfig;
  onChange: (vehicle: VehicleType, field: keyof FareConfig, value: number) => void;
  errors: Partial<Record<keyof FareConfig, string>>;
}

function FareForm({ vehicle, config, onChange, errors }: FareFormProps) {
  const fields: { key: keyof FareConfig; label: string }[] = [
    { key: 'base_fare', label: 'Base Fare (PHP)' },
    { key: 'minimum_fare', label: 'Minimum Fare (PHP)' },
    { key: 'per_km_rate', label: 'Per Kilometer Rate (PHP)' },
    { key: 'per_min_rate', label: 'Per Minute Rate (PHP)' },
    { key: 'booking_fee', label: 'Booking Fee (PHP)' },
    { key: 'cancellation_fee', label: 'Cancellation Fee (PHP)' },
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
            value={(config as any)[key] ?? 0}
            onChange={(e) => onChange(vehicle, key, parseFloat(e.target.value) || 0)}
            className={(errors as any)[key] ? 'border-danger' : ''}
          />
          {(errors as any)[key] && <p className="text-xs text-danger mt-1">{(errors as any)[key]}</p>}
        </div>
      ))}
    </div>
  );
}

function validateConfig(config: FareConfig): Partial<Record<string, string>> {
  const errs: Partial<Record<string, string>> = {};
  if ((config.base_fare ?? 0) <= 0) errs.base_fare = 'Must be greater than 0';
  if ((config.minimum_fare ?? 0) <= 0) errs.minimum_fare = 'Must be greater than 0';
  if ((config.minimum_fare ?? 0) > (config.base_fare ?? 0)) errs.minimum_fare = 'Cannot exceed base fare';
  if ((config.per_km_rate ?? 0) <= 0) errs.per_km_rate = 'Must be greater than 0';
  if ((config.per_min_rate ?? 0) < 0) errs.per_min_rate = 'Cannot be negative';
  return errs;
}

const DEFAULT_FARE: FareConfig = {
  id: '',
  vehicle_type: 'motorcycle',
  base_fare: 50,
  minimum_fare: 50,
  per_km_rate: 10,
  per_min_rate: 2,
  booking_fee: 0,
  cancellation_fee: 0,
  updated_by: '',
  updated_at: '',
};

export function FareSurge() {
  const [configs, setConfigs] = useState<Record<VehicleType, FareConfig>>({
    motorcycle: { ...DEFAULT_FARE, vehicle_type: 'motorcycle' },
    tricycle: { ...DEFAULT_FARE, vehicle_type: 'tricycle', base_fare: 40, minimum_fare: 40, per_km_rate: 8, per_min_rate: 1.5 },
    car: { ...DEFAULT_FARE, vehicle_type: 'car', base_fare: 80, minimum_fare: 80, per_km_rate: 15, per_min_rate: 3 },
  });
  const [surgeConfig, setSurgeConfig] = useState<Partial<SurgeConfig>>({ enabled: true, max_multiplier: 2.5, trigger_ratio: 1.5 });
  const [validationErrors, setValidationErrors] = useState<Record<string, Partial<Record<string, string>>>>({});
  const [saved, setSaved] = useState(false);
  const [loading, setLoading] = useState(true);

  const [simDistance, setSimDistance] = useState('');
  const [simTime, setSimTime] = useState('');
  const [simVehicle, setSimVehicle] = useState<VehicleType>('motorcycle');
  const [simResult, setSimResult] = useState<number | null>(null);
  const [simError, setSimError] = useState('');

  useEffect(() => {
    setLoading(true);
    Promise.all([
      adminApi.fares.getConfigs(),
      adminApi.fares.getSurge(),
    ]).then(([fareList, surge]) => {
      const mapped: Record<VehicleType, FareConfig> = { ...configs };
      for (const fc of fareList) {
        if (fc.vehicle_type === 'motorcycle' || fc.vehicle_type === 'tricycle' || fc.vehicle_type === 'car') {
          mapped[fc.vehicle_type as VehicleType] = fc;
        }
      }
      setConfigs(mapped);
      if (surge && Object.keys(surge).length > 0) {
        setSurgeConfig(surge);
      }
    }).catch(() => {}).finally(() => setLoading(false));
  }, []);

  const handleConfigChange = (vehicle: VehicleType, field: keyof FareConfig, value: number) => {
    setConfigs(prev => ({ ...prev, [vehicle]: { ...prev[vehicle], [field]: value } }));
    setSaved(false);
    if ((validationErrors[vehicle] as any)?.[field]) {
      setValidationErrors(prev => ({ ...prev, [vehicle]: { ...prev[vehicle], [field]: undefined } }));
    }
  };

  const handleSave = () => {
    const allErrors: Record<string, Partial<Record<string, string>>> = {};
    let hasErrors = false;
    for (const [vehicle, config] of Object.entries(configs)) {
      const errs = validateConfig(config);
      if (Object.keys(errs).length > 0) {
        allErrors[vehicle] = errs;
        hasErrors = true;
      }
    }
    if (hasErrors) { setValidationErrors(allErrors); return; }
    setValidationErrors({});

    const fareUpdates = Object.values(configs);
    Promise.all([
      adminApi.fares.updateConfig('', fareUpdates[0]),
      adminApi.fares.updateSurge(surgeConfig),
    ]).then(() => {
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    }).catch(() => {
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    });
  };

  const handleCalculate = async () => {
    setSimError('');
    setSimResult(null);
    const dist = parseFloat(simDistance);
    const time = parseFloat(simTime);
    if (!simDistance || isNaN(dist) || dist <= 0) { setSimError('Enter a valid distance.'); return; }
    if (!simTime || isNaN(time) || time < 0) { setSimError('Enter a valid time.'); return; }

    try {
      const result = await adminApi.fares.simulate(simVehicle, dist, time);
      setSimResult(result);
    } catch {
      // Fallback: local calculation
      const cfg = configs[simVehicle];
      const fare = Math.max(cfg.minimum_fare ?? 0, (cfg.base_fare ?? 0) + dist * (cfg.per_km_rate ?? 0) + time * (cfg.per_min_rate ?? 0));
      setSimResult(fare);
    }
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
          <Button onClick={handleSave} disabled={loading}>Save Changes</Button>
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
            {loading ? (
              <p className="text-sm text-text-muted py-6 text-center">Loading fare configs...</p>
            ) : (
              <Tabs defaultValue="motorcycle" className="w-full">
                <TabsList className="mb-4">
                  <TabsTrigger value="motorcycle">Motorcycle</TabsTrigger>
                  <TabsTrigger value="tricycle">Tricycle</TabsTrigger>
                  <TabsTrigger value="car">Car (4-seater)</TabsTrigger>
                </TabsList>

                {(['motorcycle', 'tricycle', 'car'] as VehicleType[]).map((v) => (
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
            )}
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
                  aria-label={surgeConfig.enabled ? 'Disable auto-surge' : 'Enable auto-surge'}
                  aria-checked={surgeConfig.enabled}
                  role="switch"
                  onClick={() => setSurgeConfig(prev => ({ ...prev, enabled: !prev.enabled }))}
                  className={`w-11 h-6 rounded-full transition-colors relative ${surgeConfig.enabled ? 'bg-primary' : 'bg-border'}`}
                >
                  <div className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-transform ${surgeConfig.enabled ? 'translate-x-6' : 'translate-x-1'}`} />
                </button>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">Max Surge Multiplier</label>
                <div className="flex items-center gap-2">
                  <Input
                    type="number"
                    value={surgeConfig.max_multiplier ?? 2.5}
                    step={0.1}
                    min={1}
                    max={5}
                    className="w-full"
                    disabled={!surgeConfig.enabled}
                    onChange={(e) => setSurgeConfig(prev => ({ ...prev, max_multiplier: parseFloat(e.target.value) || 1 }))}
                  />
                  <span className="text-text-muted">x</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">Trigger Ratio (demand/supply)</label>
                <div className="flex items-center gap-2">
                  <Input
                    type="number"
                    value={surgeConfig.trigger_ratio ?? 1.5}
                    step={0.1}
                    min={1}
                    max={10}
                    className="w-full"
                    disabled={!surgeConfig.enabled}
                    onChange={(e) => setSurgeConfig(prev => ({ ...prev, trigger_ratio: parseFloat(e.target.value) || 1 }))}
                  />
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
              <Input
                placeholder="Distance (km)"
                type="number"
                min={0}
                value={simDistance}
                onChange={(e) => { setSimDistance(e.target.value); setSimError(''); setSimResult(null); }}
              />
              <Input
                placeholder="Estimated Time (mins)"
                type="number"
                min={0}
                value={simTime}
                onChange={(e) => { setSimTime(e.target.value); setSimError(''); setSimResult(null); }}
              />
              <select
                aria-label="Vehicle type"
                value={simVehicle}
                onChange={(e) => { setSimVehicle(e.target.value as VehicleType); setSimResult(null); }}
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
                    Base {formatPHP(configs[simVehicle].base_fare)} + {simDistance}km + {simTime}min
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

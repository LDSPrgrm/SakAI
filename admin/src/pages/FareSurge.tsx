import React, { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/Tabs';
import { Zap, Calculator, CheckCircle } from 'lucide-react';
import { usePermissions } from '@/hooks/usePermissions';
import {
  useFareConfigs, useSurgeConfig,
  useUpdateFareConfig, useUpdateSurgeConfig, useSimulateFare,
} from '@/hooks/useFareConfig';
import { FareSimulatorForm } from '@/components/forms/FareSimulatorForm';
import type { FareConfig, SurgeConfig } from '@/types/super-admin';
import { DEFAULT_FARE_BY_VEHICLE, type VehicleType } from '@/constants/fareDefaults';
type NumericFareField = Exclude<keyof FareConfig, 'vehicle_type'>;

const FARE_FIELDS: { key: NumericFareField; label: string; unit: string }[] = [
  { key: 'base_fare', label: 'Base Fare', unit: 'PHP' },
  { key: 'minimum_fare', label: 'Minimum Fare', unit: 'PHP' },
  { key: 'per_km_rate', label: 'Per-KM Rate', unit: 'PHP/km' },
  { key: 'per_min_rate', label: 'Per-Min Rate', unit: 'PHP/min' },
  { key: 'booking_fee', label: 'Booking Fee', unit: 'PHP' },
  { key: 'cancellation_fee', label: 'Cancellation Fee', unit: 'PHP' },
];

interface FareFormProps {
  vehicle: VehicleType;
  config: FareConfig;
  onChange: (vehicle: VehicleType, field: NumericFareField, value: number) => void;
  errors: Partial<Record<NumericFareField, string>>;
}

function FareForm({ vehicle, config, onChange, errors }: FareFormProps) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {FARE_FIELDS.map(({ key, label, unit }) => (
        <div key={key}>
          <label className="block text-sm font-medium text-text-muted mb-1">
            {label}{' '}
            <span className="text-xs text-text-muted/60">({unit})</span>
          </label>
          <Input
            type="number"
            min={0}
            step={0.5}
            value={config[key] ?? 0}
            onChange={(e) => onChange(vehicle, key, parseFloat(e.target.value) || 0)}
            className={errors[key] ? 'border-danger' : ''}
          />
          {errors[key] && <p className="text-xs text-danger mt-1">{errors[key]}</p>}
        </div>
      ))}
    </div>
  );
}

function validateConfig(config: FareConfig): Partial<Record<NumericFareField, string>> {
  const errs: Partial<Record<NumericFareField, string>> = {};
  if ((config.base_fare ?? 0) <= 0) errs.base_fare = 'Must be greater than 0';
  if ((config.minimum_fare ?? 0) <= 0) errs.minimum_fare = 'Must be greater than 0';
  if ((config.minimum_fare ?? 0) > (config.base_fare ?? 0)) errs.minimum_fare = 'Cannot exceed base fare';
  if ((config.per_km_rate ?? 0) <= 0) errs.per_km_rate = 'Must be greater than 0';
  if ((config.per_min_rate ?? 0) < 0) errs.per_min_rate = 'Cannot be negative';
  return errs;
}

export function FareSurge() {
  const { can } = usePermissions();
  const canWrite = can('fare_config', 'write');
  const writeDisabledTitle = canWrite ? undefined : 'You do not have write access';
  const fareQuery = useFareConfigs();
  const surgeQuery = useSurgeConfig();
  const updateFares = useUpdateFareConfig();
  const updateSurge = useUpdateSurgeConfig();
  const simulateFare = useSimulateFare();

  const [configs, setConfigs] = useState<Record<VehicleType, FareConfig>>({
    motorcycle: { ...DEFAULT_FARE_BY_VEHICLE.motorcycle },
    tricycle: { ...DEFAULT_FARE_BY_VEHICLE.tricycle },
    car: { ...DEFAULT_FARE_BY_VEHICLE.car },
  });
  const [surgeConfig, setSurgeConfig] = useState<Partial<SurgeConfig>>({ enabled: true, max_multiplier: 2.5, trigger_ratio: 1.5 });
  const [validationErrors, setValidationErrors] = useState<Record<VehicleType, Partial<Record<NumericFareField, string>>>>({
    motorcycle: {}, tricycle: {}, car: {},
  });
  const [saved, setSaved] = useState(false);
  const loading = fareQuery.isPending || surgeQuery.isPending;

  useEffect(() => {
    const fareList = fareQuery.data as FareConfig[] | undefined;
    if (!fareList) return;
    setConfigs(prev => {
      const next = { ...prev };
      for (const fc of fareList) {
        if (fc.vehicle_type === 'motorcycle' || fc.vehicle_type === 'tricycle' || fc.vehicle_type === 'car') {
          next[fc.vehicle_type as VehicleType] = fc;
        }
      }
      return next;
    });
  }, [fareQuery.data]);

  useEffect(() => {
    const surge = surgeQuery.data as SurgeConfig | undefined;
    if (surge && Object.keys(surge).length > 0) setSurgeConfig(surge);
  }, [surgeQuery.data]);

  const handleConfigChange = (vehicle: VehicleType, field: NumericFareField, value: number) => {
    setConfigs(prev => ({ ...prev, [vehicle]: { ...prev[vehicle], [field]: value } }));
    setSaved(false);
    if (validationErrors[vehicle]?.[field]) {
      setValidationErrors(prev => ({ ...prev, [vehicle]: { ...prev[vehicle], [field]: undefined } }));
    }
  };

  const handleSave = () => {
    const allErrors: Record<VehicleType, Partial<Record<NumericFareField, string>>> = {
      motorcycle: {}, tricycle: {}, car: {},
    };
    let hasErrors = false;
    (Object.keys(configs) as VehicleType[]).forEach((vehicle) => {
      const errs = validateConfig(configs[vehicle]);
      if (Object.keys(errs).length > 0) {
        allErrors[vehicle] = errs;
        hasErrors = true;
      }
    });
    if (hasErrors) { setValidationErrors(allErrors); return; }
    setValidationErrors({ motorcycle: {}, tricycle: {}, car: {} });

    Promise.all([
      updateFares.mutateAsync(Object.values(configs)),
      updateSurge.mutateAsync(surgeConfig as SurgeConfig),
    ]).finally(() => {
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    });
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
          <Button
            onClick={handleSave}
            disabled={loading || !canWrite}
            title={writeDisabledTitle}
          >
            Save Changes
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 items-start">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Base Fare Configuration</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <p className="text-sm text-text-muted py-6 text-center">Loading fare configs...</p>
            ) : (
              <Tabs defaultValue="motorcycle" className="w-full">
                <TabsList className="mb-6">
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
                      errors={validationErrors[v]}
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
                  type="button"
                  role="switch"
                  aria-checked={!!surgeConfig.enabled}
                  aria-label={surgeConfig.enabled ? 'Disable auto-surge' : 'Enable auto-surge'}
                  onClick={() => { setSurgeConfig(prev => ({ ...prev, enabled: !prev.enabled })); setSaved(false); }}
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
                    onChange={(e) => { setSurgeConfig(prev => ({ ...prev, max_multiplier: parseFloat(e.target.value) || 1 })); setSaved(false); }}
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
                    onChange={(e) => { setSurgeConfig(prev => ({ ...prev, trigger_ratio: parseFloat(e.target.value) || 1 })); setSaved(false); }}
                  />
                  <span className="text-text-muted">x</span>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Calculator className="w-5 h-5 text-success" />
                Fare Simulator
              </CardTitle>
            </CardHeader>
            <CardContent>
              <FareSimulatorForm
                configs={configs}
                simulate={(args) => simulateFare.mutateAsync(args)}
              />
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}

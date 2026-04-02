import React, { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Zap, Calculator } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/Tabs';
import { ConfirmModal } from '@/components/shared/ConfirmModal';
import { SaveBanner } from '@/components/shared/SaveBanner';
import { adminApi, FareConfig, SurgeConfig } from '@/lib/admin-api';
import { formatPHP } from '@/lib/utils';

// ── Zod schema ───────────────────────────────────────────────────────────────

const fareSchema = z.object({
  base_fare: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
  per_km_rate: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
  per_min_rate: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
  minimum_fare: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
  booking_fee: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
  cancellation_fee: z.number({ error: 'Required' }).min(0, 'Must be ≥ 0'),
});

type FareFormValues = z.infer<typeof fareSchema>;

type VehicleTab = 'motorcycle' | 'tricycle' | 'car';

const VEHICLE_TABS: { value: VehicleTab; label: string }[] = [
  { value: 'motorcycle', label: 'Motorcycle' },
  { value: 'tricycle', label: 'Tricycle' },
  { value: 'car', label: 'Car (4-seater)' },
];

const FARE_FIELDS: { key: keyof FareFormValues; label: string; unit: string }[] = [
  { key: 'base_fare', label: 'Base Fare', unit: 'PHP' },
  { key: 'per_km_rate', label: 'Per-KM Rate', unit: 'PHP/km' },
  { key: 'per_min_rate', label: 'Per-Min Rate', unit: 'PHP/min' },
  { key: 'minimum_fare', label: 'Minimum Fare', unit: 'PHP' },
  { key: 'booking_fee', label: 'Booking Fee', unit: 'PHP' },
  { key: 'cancellation_fee', label: 'Cancellation Fee', unit: 'PHP' },
];

// ── Fare Tab Form ─────────────────────────────────────────────────────────────

interface FareTabFormProps {
  config: FareConfig;
  onSaved: () => void;
  onBannerShow: () => void;
}

function FareTabForm({ config, onSaved, onBannerShow }: FareTabFormProps) {
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [pendingValues, setPendingValues] = useState<FareFormValues | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FareFormValues>({
    resolver: zodResolver(fareSchema),
    defaultValues: {
      base_fare: config.base_fare,
      per_km_rate: config.per_km_rate,
      per_min_rate: config.per_min_rate,
      minimum_fare: config.minimum_fare,
      booking_fee: config.booking_fee,
      cancellation_fee: config.cancellation_fee,
    },
  });

  // Intercept submit — show confirm first
  function onSubmit(values: FareFormValues) {
    setPendingValues(values);
    setConfirmOpen(true);
  }

  async function handleConfirm() {
    if (!pendingValues) return;
    await adminApi.fares.updateConfig(config.id, pendingValues);
    setConfirmOpen(false);
    setPendingValues(null);
    onSaved();
    onBannerShow();
  }

  const vehicleLabel = VEHICLE_TABS.find((v) => v.value === config.vehicle_type)?.label ?? config.vehicle_type;

  return (
    <>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {FARE_FIELDS.map(({ key, label, unit }) => (
            <div key={key}>
              <label className="block text-sm font-medium text-text-muted mb-1">
                {label}{' '}
                <span className="text-xs text-text-muted/60">({unit})</span>
              </label>
              <Input
                type="number"
                step="0.5"
                min={0}
                {...register(key, { valueAsNumber: true })}
                className={errors[key] ? 'border-danger' : ''}
              />
              {errors[key] && (
                <p className="text-xs text-danger mt-1">{errors[key]?.message}</p>
              )}
            </div>
          ))}
        </div>

        <div className="flex items-center justify-between pt-2 border-t border-border">
          <p className="text-xs text-text-muted">
            Last updated by{' '}
            <span className="text-text-main">{config.updated_by}</span>
          </p>
          <Button type="submit" size="sm" disabled={isSubmitting}>
            {isSubmitting ? 'Saving…' : 'Save Changes'}
          </Button>
        </div>
      </form>

      <ConfirmModal
        open={confirmOpen}
        title="Confirm Fare Update"
        message={`This will affect all new bookings for ${vehicleLabel}. Continue?`}
        variant="danger"
        confirmLabel="Yes, Save"
        onConfirm={handleConfirm}
        onClose={() => { setConfirmOpen(false); setPendingValues(null); }}
      />
    </>
  );
}

// ── Main Component ────────────────────────────────────────────────────────────

export function SAFareConfig() {
  const [fareConfigs, setFareConfigs] = useState<FareConfig[]>([]);
  const [surgeConfig, setSurgeConfig] = useState<SurgeConfig | null>(null);
  const [bannerVisible, setBannerVisible] = useState(false);

  // Surge local state (controlled)
  const [surgeEnabled, setSurgeEnabled] = useState(false);
  const [maxMultiplier, setMaxMultiplier] = useState('2.5');
  const [triggerRatio, setTriggerRatio] = useState('1.5');
  const [surgeSaving, setSurgeSaving] = useState(false);

  // Simulator
  const [simDistance, setSimDistance] = useState('');
  const [simTime, setSimTime] = useState('');
  const [simVehicle, setSimVehicle] = useState<VehicleTab>('motorcycle');
  const [simResult, setSimResult] = useState<number | null>(null);
  const [simError, setSimError] = useState('');
  const [simLoading, setSimLoading] = useState(false);

  // Data loading state
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const [configs, surge] = await Promise.all([
          adminApi.fares.getConfigs(),
          adminApi.fares.getSurge(),
        ]);
        setFareConfigs(configs || []);
        setSurgeConfig(surge || { enabled: false, max_multiplier: 1, trigger_ratio: 1 } as SurgeConfig);
        setSurgeEnabled(surge?.enabled ?? false);
        setMaxMultiplier(String(surge?.max_multiplier ?? 2.5));
        setTriggerRatio(String(surge?.trigger_ratio ?? 1.5));
      } catch (err) {
        console.error('Failed to load fare configs', err);
      } finally {
        setIsLoading(false);
      }
    }
    load();
  }, []);

  function showBanner() {
    setBannerVisible(true);
    setTimeout(() => setBannerVisible(false), 3000);
  }

  async function saveSurge() {
    if (!surgeConfig) return;
    setSurgeSaving(true);
    const updated = await adminApi.fares.updateSurge({
      enabled: surgeEnabled,
      max_multiplier: parseFloat(maxMultiplier) || surgeConfig.max_multiplier,
      trigger_ratio: parseFloat(triggerRatio) || surgeConfig.trigger_ratio,
    });
    setSurgeConfig(updated);
    setSurgeSaving(false);
    showBanner();
  }

  async function handleSimulate() {
    setSimError('');
    setSimResult(null);
    const dist = parseFloat(simDistance);
    const time = parseFloat(simTime);
    if (!simDistance || isNaN(dist) || dist <= 0) {
      setSimError('Enter a valid distance (km).');
      return;
    }
    if (!simTime || isNaN(time) || time < 0) {
      setSimError('Enter a valid time (minutes).');
      return;
    }
    setSimLoading(true);
    const result = await adminApi.fares.simulate(simVehicle, dist, time);
    setSimResult(result);
    setSimLoading(false);
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64 text-text-muted text-sm">
        Loading…
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="text-2xl font-bold text-text-main">Fare Configuration</h1>
        <SaveBanner visible={bannerVisible} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* ── Left: Base Fare Config ─────────────────────────────────────── */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Base Fare Configuration</CardTitle>
          </CardHeader>
          <CardContent>
            <Tabs defaultValue="motorcycle" className="w-full">
              <TabsList className="mb-6">
                {VEHICLE_TABS.map((tab) => (
                  <TabsTrigger key={tab.value} value={tab.value}>
                    {tab.label}
                  </TabsTrigger>
                ))}
              </TabsList>

              {VEHICLE_TABS.map(({ value }) => {
                const config = fareConfigs.find((f) => f.vehicle_type === value) || {
                  id: 'new',
                  vehicle_type: value,
                  base_fare: 0,
                  per_km_rate: 0,
                  per_min_rate: 0,
                  minimum_fare: 0,
                  booking_fee: 0,
                  cancellation_fee: 0,
                  updated_by: '—',
                  updated_at: new Date().toISOString(),
                };
                return (
                  <TabsContent key={value} value={value}>
                    <FareTabForm
                      config={config as FareConfig}
                      onSaved={() => {
                        adminApi.fares.getConfigs().then((res) => setFareConfigs(res || []));
                      }}
                      onBannerShow={showBanner}
                    />
                  </TabsContent>
                );
              })}
            </Tabs>
          </CardContent>
        </Card>

        {/* ── Right column ──────────────────────────────────────────────── */}
        <div className="space-y-6">
          {/* Surge Pricing Card */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-warning" />
                Surge Pricing
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* Auto-surge toggle */}
              <div className="flex items-center justify-between p-3 bg-surface-hover rounded-lg border border-border">
                <div>
                  <p className="font-medium text-text-main">Enable Auto-Surge</p>
                  <p className="text-xs text-text-muted">Based on demand/supply ratio</p>
                </div>
                <button
                  aria-label={surgeEnabled ? 'Disable auto-surge' : 'Enable auto-surge'}
                  aria-checked={surgeEnabled}
                  role="switch"
                  onClick={() => setSurgeEnabled((v) => !v)}
                  className={`w-11 h-6 rounded-full transition-colors relative flex-shrink-0 ${surgeEnabled ? 'bg-primary' : 'bg-border'
                    }`}
                >
                  <div
                    className={`w-4 h-4 bg-white rounded-full absolute top-1 transition-transform ${surgeEnabled ? 'translate-x-6' : 'translate-x-1'
                      }`}
                  />
                </button>
              </div>

              {/* Max Multiplier */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Max Multiplier
                </label>
                <div className="flex items-center gap-2">
                  <Input
                    type="number"
                    step="0.1"
                    min={1}
                    max={5}
                    value={maxMultiplier}
                    onChange={(e) => setMaxMultiplier(e.target.value)}
                    disabled={!surgeEnabled}
                    className="w-full"
                  />
                  <span className="text-text-muted text-sm">x</span>
                </div>
              </div>

              {/* Trigger Ratio */}
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Trigger Ratio
                  <span className="text-xs text-text-muted/60 ml-1">(demand/supply)</span>
                </label>
                <Input
                  type="number"
                  step="0.1"
                  min={1}
                  value={triggerRatio}
                  onChange={(e) => setTriggerRatio(e.target.value)}
                  disabled={!surgeEnabled}
                />
              </div>

              <Button
                variant="primary"
                size="sm"
                className="w-full"
                onClick={saveSurge}
                disabled={surgeSaving}
              >
                {surgeSaving ? 'Saving…' : 'Save Surge Settings'}
              </Button>

              <Button variant="outline" className="w-full">
                Manage Surge Zones
              </Button>
            </CardContent>
          </Card>

          {/* Fare Simulator Card */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Calculator className="w-5 h-5 text-success" />
                Fare Simulator
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Distance (km)
                </label>
                <Input
                  type="number"
                  step="0.1"
                  min={0}
                  placeholder="e.g. 5.5"
                  value={simDistance}
                  onChange={(e) => {
                    setSimDistance(e.target.value);
                    setSimError('');
                    setSimResult(null);
                  }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Time (minutes)
                </label>
                <Input
                  type="number"
                  step="1"
                  min={0}
                  placeholder="e.g. 20"
                  value={simTime}
                  onChange={(e) => {
                    setSimTime(e.target.value);
                    setSimError('');
                    setSimResult(null);
                  }}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-text-muted mb-1">
                  Vehicle Type
                </label>
                <select
                  aria-label="Vehicle type"
                  value={simVehicle}
                  onChange={(e) => {
                    setSimVehicle(e.target.value as VehicleTab);
                    setSimResult(null);
                  }}
                  className="w-full bg-background border border-border rounded-lg px-3 py-2 text-sm text-text-main focus:outline-none focus:ring-2 focus:ring-primary"
                >
                  <option value="motorcycle">Motorcycle</option>
                  <option value="tricycle">Tricycle</option>
                  <option value="car">Car (4-seater)</option>
                </select>
              </div>

              {simError && <p className="text-xs text-danger">{simError}</p>}

              <Button
                className="w-full"
                onClick={handleSimulate}
                disabled={simLoading}
              >
                {simLoading ? 'Calculating…' : 'Calculate Estimate'}
              </Button>

              <div className="p-4 bg-surface-hover rounded-lg border border-border text-center">
                <p className="text-xs text-text-muted mb-1">Estimated Fare</p>
                <p className="text-3xl font-bold text-text-main">
                  {simResult !== null ? formatPHP(simResult) : '—'}
                </p>
                {simResult !== null && (
                  <p className="text-xs text-text-muted mt-1.5">
                    {simDistance} km &middot; {simTime} min &middot;{' '}
                    {VEHICLE_TABS.find((v) => v.value === simVehicle)?.label}
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

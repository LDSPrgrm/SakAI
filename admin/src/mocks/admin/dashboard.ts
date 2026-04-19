import type { DashboardMetrics } from '@/types/super-admin';

export const metrics: DashboardMetrics = {
  total_riders: 24592,
  riders_trend: '+12%',
  total_drivers: 3842,
  drivers_trend: '+5%',
  rides_today: 12403,
  rides_trend: '+18%',
  revenue_today: 1245000,
  revenue_trend: '+8%',
  avg_wait_minutes: 4.2,
  wait_trend: '-1.5%',
  platform_uptime: 99.97,
};

export const ridesChart = [
  { name: 'Week 1', rides: 38200 },
  { name: 'Week 2', rides: 41500 },
  { name: 'Week 3', rides: 39800 },
  { name: 'Week 4', rides: 44100 },
  { name: 'Week 5', rides: 46700 },
  { name: 'Week 6', rides: 43200 },
  { name: 'Week 7', rides: 48900 },
];

export const revenueChart = [
  { name: 'Week 1', revenue: 400000, gcash: 180000, cash: 120000, paymaya: 60000, card: 40000 },
  { name: 'Week 2', revenue: 520000, gcash: 240000, cash: 150000, paymaya: 85000, card: 45000 },
  { name: 'Week 3', revenue: 480000, gcash: 210000, cash: 145000, paymaya: 80000, card: 45000 },
  { name: 'Week 4', revenue: 610000, gcash: 290000, cash: 170000, paymaya: 95000, card: 55000 },
];

export const vehicleDistribution = [
  { name: 'Motorcycle', value: 65 },
  { name: 'Tricycle', value: 20 },
  { name: 'Car', value: 15 },
];

export interface ActivityItem {
  id: number;
  type: 'booking' | 'signup' | 'incident' | 'payment' | 'alert';
  message: string;
  time: string;
  isAlert: boolean;
}

export const activityFeed: ActivityItem[] = [
  { id: 1, type: 'booking', message: 'New ride booked in Makati CBD', time: '2 mins ago', isAlert: false },
  { id: 2, type: 'signup', message: 'Driver Carlo Reyes completed KYC', time: '8 mins ago', isAlert: false },
  { id: 3, type: 'incident', message: 'SOS activated — Ride #RD-99421 in Taguig', time: '15 mins ago', isAlert: true },
  { id: 4, type: 'payment', message: 'GCash gateway timeout — 3 retries', time: '22 mins ago', isAlert: true },
  { id: 5, type: 'booking', message: 'New ride booked in BGC', time: '31 mins ago', isAlert: false },
  { id: 6, type: 'signup', message: 'New rider Maria Bautista registered', time: '45 mins ago', isAlert: false },
];

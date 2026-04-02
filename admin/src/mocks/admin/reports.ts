export const reportList = [
  { id: 'weekly-financial', title: 'Weekly Financial Summary', description: 'Revenue, payouts, commissions, and payment method breakdown.' },
  { id: 'driver-performance', title: 'Driver Performance', description: 'Ratings, acceptance rate, completion rate, earnings per driver.' },
  { id: 'rider-retention', title: 'Rider Retention', description: 'MAU, churn rate, retention rate (target: 75%).' },
  { id: 'ride-volume', title: 'Ride Volume by Area', description: 'Rides per city/barangay with heatmap data.' },
  { id: 'vehicle-analysis', title: 'Vehicle Type Analysis', description: 'Rides per type, revenue per type, demand trends.' },
  { id: 'safety-incidents', title: 'Safety Incident Report', description: 'Count by type, resolution times, escalation rate.' },
  { id: 'kyc-processing', title: 'KYC Processing Report', description: 'Submissions, approval/rejection rates, avg review time.' },
];

export function getChartData(type: string) {
  switch (type) {
    case 'rides-by-vehicle':
      return [
        { name: 'Motorcycle', value: 65 },
        { name: 'Tricycle', value: 20 },
        { name: 'Car', value: 15 },
      ];
    case 'payment-method':
      return [
        { name: 'GCash', value: 50 },
        { name: 'Cash', value: 30 },
        { name: 'PayMaya', value: 15 },
        { name: 'Card', value: 5 },
      ];
    case 'peak-hours':
      return Array.from({ length: 24 }, (_, h) => ({
        hour: `${String(h).padStart(2, '0')}:00`,
        rides: Math.round(200 + Math.sin((h - 8) * 0.5) * 150 + Math.random() * 50),
      }));
    case 'wait-time':
      return [
        { name: 'Mon', wait: 4.2 },
        { name: 'Tue', wait: 4.8 },
        { name: 'Wed', wait: 5.1 },
        { name: 'Thu', wait: 4.5 },
        { name: 'Fri', wait: 6.2 },
        { name: 'Sat', wait: 7.1 },
        { name: 'Sun', wait: 5.8 },
      ];
    case 'ratings':
      return [
        { name: 'Week 1', driver: 4.7, rider: 4.8 },
        { name: 'Week 2', driver: 4.6, rider: 4.7 },
        { name: 'Week 3', driver: 4.8, rider: 4.9 },
        { name: 'Week 4', driver: 4.7, rider: 4.8 },
      ];
    default:
      return [];
  }
}

export function generateCsv(type: string): string {
  const data = getChartData(type);
  if (data.length === 0) return 'No data';
  const headers = Object.keys(data[0]).join(',');
  const rows = data.map(row => Object.values(row).join(','));
  return [headers, ...rows].join('\n');
}

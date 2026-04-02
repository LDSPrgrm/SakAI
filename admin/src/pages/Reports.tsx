import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Download, Calendar } from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip as RechartsTooltip, Legend } from 'recharts';

const vehicleData = [
  { name: 'Motorcycle', value: 65 },
  { name: 'Tricycle', value: 20 },
  { name: 'Car (4-seater)', value: 15 },
];

const paymentData = [
  { name: 'GCash', value: 50 },
  { name: 'Cash', value: 30 },
  { name: 'PayMaya', value: 15 },
  { name: 'Card', value: 5 },
];

const COLORS = ['#1A73E8', '#34A853', '#FBBC05', '#EA4335'];

export function Reports() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-text-main">Reports & Analytics</h1>
        <div className="flex gap-3">
          <div className="flex items-center gap-2 bg-surface border border-border rounded-lg px-3 py-2">
            <Calendar className="w-4 h-4 text-text-muted" />
            <span className="text-sm text-text-main">Last 30 Days</span>
          </div>
          <Button className="gap-2">
            <Download className="w-4 h-4" /> Export All
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Rides by Vehicle Type</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={vehicleData}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={90}
                    paddingAngle={5}
                    dataKey="value"
                    label
                  >
                    {vehicleData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <RechartsTooltip
                    contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                    itemStyle={{ color: '#FFF' }}
                  />
                  <Legend verticalAlign="bottom" height={36} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Payment Method Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={paymentData}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={90}
                    paddingAngle={5}
                    dataKey="value"
                    label
                  >
                    {paymentData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <RechartsTooltip
                    contentStyle={{ backgroundColor: '#1E1E1E', borderColor: '#333', color: '#FFF' }}
                    itemStyle={{ color: '#FFF' }}
                  />
                  <Legend verticalAlign="bottom" height={36} />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader>
            <CardTitle>Available Reports</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <ReportCard title="Weekly Financial Summary" description="Revenue, payouts, and commissions breakdown." />
              <ReportCard title="Driver Performance" description="Ratings, completion rates, and earnings by driver." />
              <ReportCard title="Rider Retention" description="New vs returning riders, churn rate analysis." />
              <ReportCard title="Ride Volume by Area" description="Heatmap data for Metro Manila and provinces." />
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function ReportCard({ title, description }: { title: string, description: string }) {
  return (
    <div className="p-4 bg-surface-hover border border-border rounded-lg flex flex-col h-full">
      <h4 className="font-medium text-text-main mb-2">{title}</h4>
      <p className="text-sm text-text-muted flex-1">{description}</p>
      <Button variant="outline" size="sm" className="w-full mt-4 gap-2">
        <Download className="w-4 h-4" /> Download CSV
      </Button>
    </div>
  );
}

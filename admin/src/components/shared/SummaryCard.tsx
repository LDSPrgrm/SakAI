import React from 'react';
import { Card, CardContent } from '@/components/ui/Card';

interface SummaryCardProps {
  title: string;
  value: string;
  icon: React.ReactNode;
  trend?: string;
  trendDownIsGood?: boolean;
}

export function SummaryCard({ title, value, icon, trend, trendDownIsGood = false }: SummaryCardProps) {
  const isPositive = trend?.startsWith('+');
  const isGood = trend ? (trendDownIsGood ? !isPositive : isPositive) : null;

  return (
    <Card>
      <CardContent className="p-5 flex flex-col justify-between h-full">
        <div className="flex justify-between items-start mb-4">
          <p className="text-sm font-medium text-text-muted">{title}</p>
          <div className="p-2 bg-surface-hover rounded-lg flex items-center justify-center flex-shrink-0">
            {icon}
          </div>
        </div>

        <div>
          <h4 className="text-2xl sm:text-3xl font-bold text-text-main tracking-tight break-words">
            {value}
          </h4>

          {trend && isGood !== null && (
            <div className="mt-2 flex items-center text-sm">
              <span className={`font-medium ${isGood ? 'text-success' : 'text-danger'}`}>{trend}</span>
              <span className="text-text-muted ml-2">vs last period</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

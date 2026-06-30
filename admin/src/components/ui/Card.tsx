import React from 'react';
import { cn } from '@/lib/utils';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  interactive?: boolean;
  surface?: 'flat' | 'raised';
}

export function Card({ className, children, interactive, surface = 'flat', ...props }: CardProps) {
  return (
    <div
      className={cn(
        'relative bg-surface border border-border rounded-xl shadow-sm',
        // Only `raised` variant needs clipping — its `before:` pseudo edge would
        // otherwise bleed past the rounded corners. Flat cards stay
        // overflow-visible so popovers / tooltips inside them are not clipped.
        surface === 'raised' &&
          'overflow-hidden bg-gradient-to-b from-white/[0.025] to-transparent before:pointer-events-none before:absolute before:inset-x-0 before:top-0 before:h-px before:bg-gradient-to-r before:from-transparent before:via-white/10 before:to-transparent',
        interactive && 'transition-colors duration-200 hover:border-primary/40 hover:shadow-md',
        className,
      )}
      {...props}
    >
      {children}
    </div>
  );
}

export function CardHeader({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn("px-6 py-4 border-b border-border", className)} {...props}>
      {children}
    </div>
  );
}

export function CardTitle({ className, children, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
  return (
    <h3 className={cn("text-lg font-semibold text-text-main", className)} {...props}>
      {children}
    </h3>
  );
}

export function CardContent({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div className={cn("p-6", className)} {...props}>
      {children}
    </div>
  );
}

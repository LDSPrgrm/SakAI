import React from 'react';
import { cn } from '@/lib/utils';

export interface SelectOption {
  label: string;
  value: string;
  disabled?: boolean;
}

export interface SelectProps
  extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'onChange' | 'value'> {
  value: string;
  onValueChange: (value: string) => void;
  options: readonly SelectOption[];
  placeholder?: string;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, value, onValueChange, options, placeholder, disabled, ...props }, ref) => {
    return (
      <select
        ref={ref}
        value={value}
        disabled={disabled}
        onChange={(e) => onValueChange(e.target.value)}
        className={cn(
          'flex h-10 w-full rounded-lg border border-border bg-background px-3 text-sm text-text-main',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary',
          'disabled:cursor-not-allowed disabled:opacity-50',
          className,
        )}
        {...props}
      >
        {placeholder !== undefined && (
          <option value="" disabled hidden>
            {placeholder}
          </option>
        )}
        {options.map((opt) => (
          <option key={opt.value} value={opt.value} disabled={opt.disabled}>
            {opt.label}
          </option>
        ))}
      </select>
    );
  },
);
Select.displayName = 'Select';

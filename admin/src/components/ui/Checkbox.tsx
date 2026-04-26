import React, { useEffect, useRef } from 'react';
import { cn } from '@/lib/utils';

interface CheckboxProps {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  indeterminate?: boolean;
  disabled?: boolean;
  id?: string;
  className?: string;
  'aria-label'?: string;
  'aria-labelledby'?: string;
}

// Wraps a real <input type="checkbox"> so indeterminate, native form
// participation, and screen-reader semantics work. Differs intentionally from
// Switch (a button-based control) — don't pattern-copy that here.
export function Checkbox({
  checked,
  onCheckedChange,
  indeterminate,
  disabled,
  id,
  className,
  ...aria
}: CheckboxProps) {
  const ref = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (ref.current) ref.current.indeterminate = !!indeterminate;
  }, [indeterminate]);

  return (
    <input
      ref={ref}
      type="checkbox"
      id={id}
      checked={checked}
      disabled={disabled}
      onChange={(e) => onCheckedChange(e.target.checked)}
      aria-label={aria['aria-label']}
      aria-labelledby={aria['aria-labelledby']}
      className={cn(
        'w-4 h-4 rounded border-border accent-primary',
        'focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-background',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        className,
      )}
    />
  );
}

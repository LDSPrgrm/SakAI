import React from 'react';
import { CheckCircle } from 'lucide-react';

export function SaveBanner({ visible }: { visible: boolean }) {
  if (!visible) return null;
  return (
    <span className="flex items-center gap-1.5 text-sm text-success">
      <CheckCircle className="w-4 h-4" /> Saved successfully
    </span>
  );
}

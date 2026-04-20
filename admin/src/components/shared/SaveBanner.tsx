import React from 'react';
import { CheckCircle } from 'lucide-react';

interface SaveBannerProps {
  visible: boolean;
  message?: string;
}

export function SaveBanner({ visible, message = 'Saved successfully' }: SaveBannerProps) {
  if (!visible) return null;
  return (
    <span className="flex items-center gap-1.5 text-sm text-success">
      <CheckCircle className="w-4 h-4" /> {message}
    </span>
  );
}

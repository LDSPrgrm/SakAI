import React, { useState } from 'react';
import { CheckCircle, Copy } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export interface PasswordResetResultModalProps {
  adminName: string;
  password: string;
  onClose: () => void;
}

export function PasswordResetResultModal({
  adminName,
  password,
  onClose,
}: PasswordResetResultModalProps) {
  const [copied, setCopied] = useState(false);

  async function copyToClipboard() {
    try {
      await navigator.clipboard.writeText(password);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // clipboard unavailable (non-secure context / older browsers); user can still select+copy manually
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4" role="dialog" aria-modal="true">
      <div className="bg-surface border border-border rounded-xl w-full max-w-sm shadow-xl p-6 text-center space-y-4">
        <div className="mx-auto bg-success/20 text-success rounded-full w-12 h-12 flex items-center justify-center mb-2">
          <CheckCircle className="w-6 h-6" />
        </div>
        <h2 className="text-lg font-semibold text-text-main">Password Reset</h2>
        <p className="text-sm text-text-muted">
          The password for <strong>{adminName}</strong> has been reset. Share this temporary password securely:
        </p>
        <div className="bg-background border border-border rounded p-3 font-mono text-center text-lg select-all">
          {password}
        </div>
        <div className="flex flex-col gap-2 pt-2">
          <Button
            type="button"
            variant="outline"
            className="w-full"
            onClick={copyToClipboard}
            disabled={!password}
          >
            <Copy className="w-4 h-4 mr-2" />
            {copied ? 'Copied!' : 'Copy password'}
          </Button>
          <Button className="w-full" onClick={onClose}>
            Close
          </Button>
        </div>
      </div>
    </div>
  );
}

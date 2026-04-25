import React, { useEffect, useState } from 'react';
import { AlertTriangle, CheckCircle, Copy, Eye, EyeOff, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { cn } from '@/lib/utils';

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
  const [reveal, setReveal] = useState(true);

  useEffect(() => {
    function onKey(event: KeyboardEvent) {
      if (event.key === 'Escape') onClose();
    }
    document.addEventListener('keydown', onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      document.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [onClose]);

  async function copyToClipboard() {
    try {
      await navigator.clipboard.writeText(password);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      // clipboard unavailable (non-secure context / older browsers); user can still select+copy manually
    }
  }

  const masked = '•'.repeat(Math.max(8, password.length));

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="pw-reset-title"
    >
      <div
        className="absolute inset-0 bg-black/60 animate-[pwreset-fade_120ms_ease-out]"
        onClick={onClose}
      />

      <div className="relative bg-surface border border-border rounded-2xl shadow-2xl w-full max-w-md p-6 flex flex-col gap-5 animate-[pwreset-pop_150ms_ease-out]">
        <button
          onClick={onClose}
          aria-label="Close"
          className="absolute top-4 right-4 text-text-muted hover:text-text-main transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        <div className="flex items-start gap-4">
          <div className="w-10 h-10 rounded-full bg-success/10 flex items-center justify-center flex-shrink-0">
            <CheckCircle className="w-5 h-5 text-success" />
          </div>
          <div className="flex-1">
            <h3 id="pw-reset-title" className="text-base font-semibold text-text-main">
              Password reset
            </h3>
            <p className="text-sm text-text-muted mt-1 leading-relaxed">
              A new temporary password was generated for <strong className="text-text-main">{adminName}</strong>. Share it securely — it will not be shown again.
            </p>
          </div>
        </div>

        <div className="space-y-2">
          <div className="text-xs uppercase tracking-wide text-text-muted font-medium">
            Temporary password
          </div>
          <div className="flex items-stretch gap-2">
            <div
              className={cn(
                'flex-1 bg-background border border-border rounded-lg px-3 py-2.5 font-mono text-base text-text-main select-all',
                'flex items-center justify-between gap-2',
              )}
            >
              <span className="truncate">{reveal ? password : masked}</span>
              <button
                type="button"
                onClick={() => setReveal((v) => !v)}
                aria-label={reveal ? 'Hide password' : 'Show password'}
                title={reveal ? 'Hide password' : 'Show password'}
                className="text-text-muted hover:text-text-main transition-colors"
              >
                {reveal ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            <button
              type="button"
              onClick={copyToClipboard}
              disabled={!password}
              aria-label="Copy password"
              className={cn(
                'inline-flex items-center gap-2 px-3 rounded-lg border text-sm font-medium transition-colors',
                copied
                  ? 'bg-success/10 border-success/30 text-success'
                  : 'bg-transparent border-border text-text-main hover:bg-surface-hover',
              )}
            >
              <Copy className="w-4 h-4" />
              {copied ? 'Copied' : 'Copy'}
            </button>
          </div>
        </div>

        <div className="flex items-start gap-2 rounded-lg border border-warning/20 bg-warning/5 px-3 py-2 text-xs text-warning">
          <AlertTriangle className="w-4 h-4 mt-0.5 flex-shrink-0" />
          <p className="leading-relaxed">
            Share this password through a secure channel. Once you close this dialog the password cannot be retrieved again.
          </p>
        </div>

        <div className="flex justify-end">
          <Button onClick={onClose}>Done</Button>
        </div>
      </div>

      <style>{`
        @keyframes pwreset-fade { from { opacity: 0; } to { opacity: 1; } }
        @keyframes pwreset-pop {
          from { opacity: 0; transform: scale(0.97); }
          to   { opacity: 1; transform: scale(1); }
        }
      `}</style>
    </div>
  );
}

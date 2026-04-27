import React, { useEffect, useRef, useState } from 'react';
import { X, ImageOff } from 'lucide-react';
import { useFocusTrap } from '@/hooks/useFocusTrap';
import type { KycDocument } from '@/types/super-admin';

type DocInput = KycDocument | string;

interface KycDocPreviewProps {
  docs: DocInput[];
}

function normalizeDoc(input: DocInput): KycDocument {
  if (typeof input === 'string') {
    return { label: input, type: input };
  }
  return input;
}

export function KycDocPreview({ docs }: KycDocPreviewProps) {
  const normalized = docs.map(normalizeDoc);
  const [active, setActive] = useState<KycDocument | null>(null);
  const panelRef = useRef<HTMLDivElement>(null);
  const isOpen = active !== null;

  useEffect(() => {
    if (!isOpen) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setActive(null);
    };
    window.addEventListener('keydown', onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [isOpen]);

  useEffect(() => {
    if (isOpen) panelRef.current?.focus();
  }, [isOpen]);

  useFocusTrap(panelRef, isOpen);

  if (!normalized.length) {
    return <p className="text-xs text-text-muted">No documents submitted.</p>;
  }

  return (
    <>
      <div className="flex flex-wrap gap-2">
        {normalized.map((doc, idx) => (
          <DocThumb key={`${doc.type ?? 'doc'}-${idx}`} doc={doc} onClick={() => setActive(doc)} />
        ))}
      </div>

      {active && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-4"
          role="dialog"
          aria-modal="true"
          aria-label={active.label ?? 'Document preview'}
          onClick={() => setActive(null)}
        >
          <div
            ref={panelRef}
            tabIndex={-1}
            className="relative max-h-[90vh] max-w-[90vw] bg-surface border border-border rounded-xl overflow-hidden flex flex-col focus:outline-none"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between gap-3 px-4 py-2.5 border-b border-border">
              <p className="font-medium text-text-main truncate">
                {active.label ?? active.type ?? 'Document'}
              </p>
              <button
                onClick={() => setActive(null)}
                className="text-text-muted hover:text-text-main transition-colors"
                aria-label="Close preview"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            <div className="flex-1 overflow-auto bg-black/40 flex items-center justify-center min-w-[320px] min-h-[240px]">
              {active.url ? (
                <img
                  src={active.url}
                  alt={active.label ?? 'Document'}
                  className="max-h-[80vh] max-w-[85vw] object-contain"
                />
              ) : (
                <div className="flex flex-col items-center justify-center text-text-muted gap-2 p-8">
                  <ImageOff className="w-10 h-10" />
                  <p className="text-sm">Image not yet uploaded for this document.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}

function DocThumb({ doc, onClick }: { doc: KycDocument; onClick: () => void }) {
  const label = doc.label ?? doc.type ?? 'Document';

  return (
    <button
      type="button"
      onClick={onClick}
      className="w-28 group relative rounded-md border border-border overflow-hidden hover:border-primary transition-colors"
      aria-label={`View ${label}`}
    >
      {doc.url ? (
        <img
          src={doc.url}
          alt={label}
          loading="lazy"
          className="w-28 h-20 object-cover bg-surface-hover"
        />
      ) : (
        <div className="w-28 h-20 bg-surface-hover flex items-center justify-center text-text-muted">
          <ImageOff className="w-4 h-4" />
        </div>
      )}
      <span className="block px-1.5 py-1 text-[10px] leading-tight text-text-main bg-surface-hover border-t border-border line-clamp-1 text-left">
        {label}
      </span>
    </button>
  );
}

import React from 'react';

export function PhpIcon({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
    >
      {/* Vertical stem */}
      <line x1="8" y1="3" x2="8" y2="21" />
      {/* P bowl — open path so the stem serves as the left edge */}
      <path d="M8 4h5a4 4 0 0 1 0 8H8" />
      {/* Two horizontal stripes through the bowl */}
      <line x1="5" y1="9" x2="17" y2="9" />
      <line x1="5" y1="13" x2="17" y2="13" />
    </svg>
  );
}

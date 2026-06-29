import { useEffect } from 'react';

const FOCUSABLE_SELECTOR = [
  'a[href]',
  'button:not([disabled])',
  'input:not([disabled])',
  'select:not([disabled])',
  'textarea:not([disabled])',
  '[tabindex]:not([tabindex="-1"])',
].join(',');

// Trap Tab focus inside the element referenced by `ref` while `open` is true.
// Tab from the last focusable cycles to the first; Shift+Tab from the first
// cycles to the last. Pairs with Escape-handling effects in modal components.
export function useFocusTrap(
  ref: React.RefObject<HTMLElement | null>,
  open: boolean,
): void {
  useEffect(() => {
    if (!open) return;
    const node = ref.current;
    if (!node) return;

    function onKeyDown(event: KeyboardEvent) {
      if (event.key !== 'Tab') return;
      if (!node) return;
      const focusable = Array.from(
        node.querySelectorAll<HTMLElement>(FOCUSABLE_SELECTOR),
      ).filter((el) => !el.hasAttribute('aria-hidden'));
      if (focusable.length === 0) {
        event.preventDefault();
        return;
      }
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      const active = document.activeElement as HTMLElement | null;
      if (event.shiftKey) {
        if (active === first || !node.contains(active)) {
          event.preventDefault();
          last.focus();
        }
      } else {
        if (active === last || !node.contains(active)) {
          event.preventDefault();
          first.focus();
        }
      }
    }

    node.addEventListener('keydown', onKeyDown);
    return () => node.removeEventListener('keydown', onKeyDown);
  }, [ref, open]);
}

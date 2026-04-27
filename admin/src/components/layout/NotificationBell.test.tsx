import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import React from 'react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { NotificationBell } from './NotificationBell';

vi.mock('@/api/super-admin/metrics', () => ({
  metricsApi: {
    getActivityFeed: vi.fn().mockResolvedValue([
      { id: '1', type: 'login', message: 'Alice logged in', time: '10:00', isAlert: false },
      { id: '2', type: 'delete', message: 'Bob deleted rider', time: '10:05', isAlert: true },
    ]),
  },
}));

function renderBell() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <MemoryRouter>
        <NotificationBell />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('NotificationBell', () => {
  beforeEach(() => {
    window.localStorage.clear();
    vi.clearAllMocks();
  });

  it('renders bell button', () => {
    renderBell();
    expect(screen.getByLabelText(/notifications/i)).toBeTruthy();
  });

  it('opens dropdown on click and lists events', async () => {
    renderBell();
    const button = screen.getByLabelText(/notifications/i);
    await waitFor(() => {
      expect(button.getAttribute('aria-label')).toMatch(/\d/);
    });
    fireEvent.click(button);
    await waitFor(() => {
      expect(screen.getByText('Alice logged in')).toBeTruthy();
      expect(screen.getByText('Bob deleted rider')).toBeTruthy();
    });
  });

  it('clears unread badge after opening', async () => {
    renderBell();
    const button = screen.getByLabelText(/notifications/i);
    await waitFor(() => {
      expect(button.getAttribute('aria-label')).toMatch(/\d unread/);
    });
    fireEvent.click(button);
    fireEvent.click(button);
    expect(button.getAttribute('aria-label')).toBe('Notifications');
  });
});

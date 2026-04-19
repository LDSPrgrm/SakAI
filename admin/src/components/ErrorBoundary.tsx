import React from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';

interface Props {
  children: React.ReactNode;
}

interface State {
  error: Error | null;
}

export class ErrorBoundary extends React.Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State {
    return { error };
  }

  render() {
    if (!this.state.error) return this.props.children;

    return (
      <div className="min-h-screen flex items-center justify-center bg-background p-6">
        <div className="max-w-md w-full bg-surface border border-border rounded-2xl p-8 flex flex-col items-center gap-5 text-center">
          <div className="w-14 h-14 rounded-full bg-danger/10 flex items-center justify-center">
            <AlertTriangle className="w-7 h-7 text-danger" />
          </div>
          <div>
            <h2 className="text-lg font-semibold text-text-main">Something went wrong</h2>
            <p className="text-sm text-text-muted mt-1 leading-relaxed">
              An unexpected error occurred. Reload the page to continue.
            </p>
            {import.meta.env.DEV && (
              <pre className="mt-3 text-left text-xs text-danger bg-danger/5 border border-danger/20 rounded-lg p-3 overflow-auto max-h-40">
                {this.state.error.message}
              </pre>
            )}
          </div>
          <button
            onClick={() => window.location.reload()}
            className="flex items-center gap-2 px-4 py-2 bg-primary hover:bg-primary-hover text-white text-sm font-medium rounded-lg transition-colors"
          >
            <RefreshCw className="w-4 h-4" />
            Reload page
          </button>
        </div>
      </div>
    );
  }
}

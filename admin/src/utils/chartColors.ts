// Shared recharts palette + tooltip styling.
// Spec: index.css CSS variables (--color-primary etc.) — we mirror them here
// as hex literals because recharts accepts string props at render time.

export const CHART_COLORS = ['#1A73E8', '#34A853', '#FBBC05', '#EA4335', '#9C27B0'] as const;

export const AXIS_COLOR          = '#A0A0A0';
export const GRID_COLOR          = '#333';
export const PRIMARY_LINE_COLOR  = '#1A73E8';
export const TOOLTIP_BG          = '#1E1E1E';
export const TOOLTIP_CURSOR_FILL = '#2A2A2A';

export const DARK_TOOLTIP_STYLE = {
  contentStyle: {
    backgroundColor: TOOLTIP_BG,
    borderColor: GRID_COLOR,
    color: '#FFF',
  },
} as const;

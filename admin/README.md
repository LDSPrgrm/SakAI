# SakAI Admin Panel

A modern, responsive admin dashboard for SakAI — a ride-hailing platform operating in the Philippines.

## Tech Stack

- React 19 + TypeScript
- Vite
- Tailwind CSS v4
- Recharts, Lucide React

## Run Locally

**Prerequisites:** Node.js

1. Install dependencies:
   ```
   npm install
   ```
2. Run the app:
   ```
   npm run dev
   ```

The app starts on [http://localhost:3000](http://localhost:3000).

## Project Structure

```
src/
├── components/
│   ├── ui/          # Reusable UI primitives
│   ├── Header.tsx
│   └── Sidebar.tsx
├── pages/           # One file per admin section
├── lib/
│   └── utils.ts     # cn(), formatPHP()
└── index.css        # Tailwind theme + CSS variables
```

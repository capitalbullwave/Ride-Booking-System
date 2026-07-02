# WaveGo Admin Panel

Production-ready admin dashboard for the WaveGo ride-booking platform.

## Tech Stack

- **Next.js 15+** (App Router)
- **TypeScript**
- **Tailwind CSS v4**
- **Shadcn UI**
- **Lucide React Icons**
- **Recharts** (analytics)
- **next-themes** (light/dark mode)

## Getting Started

```bash
cd wavego-admin
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Modules

| Module | Route | Description |
|--------|-------|-------------|
| Dashboard | `/` | Stats, charts, live activity, quick actions |
| Users | `/users` | User list, search, filter, detail pages |
| Drivers | `/drivers` | Driver management, document verification |
| Rides | `/rides` | Ride listing, timeline, fare breakdown |
| Vehicles | `/vehicles` | Category pricing, surge settings |
| Finance | `/finance` | Revenue, transactions, payouts, refunds |
| Coupons | `/coupons` | Create and manage promotional coupons |
| Support | `/support` | Ticket management with chat threads |
| Notifications | `/notifications` | Push, SMS, email campaigns |
| Reports | `/reports` | Analytics with PDF/Excel export |
| Settings | `/settings` | App, maps, OTP, payment, commission config |

## Project Structure

```
src/
├── app/(dashboard)/     # All admin routes with shared layout
├── components/
│   ├── dashboard/       # Charts, live activity, quick actions
│   ├── layout/          # Sidebar, header, breadcrumbs
│   ├── shared/          # Reusable tables, cards, badges
│   └── ui/              # Shadcn UI components
├── config/              # Navigation configuration
├── data/                # Mock API data
├── lib/                 # Utilities and formatters
└── types/               # TypeScript interfaces
```

## Brand Colors

- Primary: `#0F766E` (Teal)
- Secondary: `#14B8A6`
- Accent: `#2DD4BF`
- Background: `#F8FAFC`
- Text: `#0F172A`

## Build

```bash
npm run build
npm start
```

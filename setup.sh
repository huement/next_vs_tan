#!/usr/bin/env bash
set -e

echo "🚀 Creating type-safety-demo workspace..."
mkdir -p type-safety-demo
cd type-safety-demo

# ==========================================
# 1. SETUP NEXT.JS APP (PORT 3000)
# ==========================================
echo "📦 Building nextjs-app..."
mkdir -p nextjs-app/app/dashboard

cat << 'EOF' > nextjs-app/package.json
{
  "name": "nextjs-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000"
  },
  "dependencies": {
    "next": "15.1.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "typescript": "^5"
  }
}
EOF

cat << 'EOF' > nextjs-app/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "paths": { "@/*": ["./*"] }
  },
  "include": ["**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOF

cat << 'EOF' > nextjs-app/app/dashboard/page.tsx
import { z } from 'zod'

const searchSchema = z.object({
  page: z.coerce.number().default(1),
  filter: z.string().default('all'),
})

export default async function DashboardPage({
  searchParams,
}: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>
}) {
  const rawParams = await searchParams
  const parsed = searchSchema.safeParse(rawParams)
  const data = parsed.success ? parsed.data : { page: 1, filter: 'all' }

  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>Next.js App Router (Port 3000)</h1>
      <p>Manual validation required inside view layer:</p>
      <pre>{JSON.stringify({ raw: rawParams, parsed: data }, null, 2)}</pre>
    </div>
  )
}
EOF

# ==========================================
# 2. SETUP TANSTACK APP (PORT 3001)
# ==========================================
echo "📦 Building tanstack-app..."
mkdir -p tanstack-app/src/routes

cat << 'EOF' > tanstack-app/package.json
{
  "name": "tanstack-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite --port 3001"
  },
  "dependencies": {
    "@tanstack/react-router": "^1.88.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@tanstack/router-plugin": "^1.88.0",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "@vitejs/plugin-react": "^4.3.4",
    "typescript": "^5",
    "vite": "^6.0.0"
  }
}
EOF

cat << 'EOF' > tanstack-app/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true
  },
  "include": ["src"]
}
EOF

cat << 'EOF' > tanstack-app/vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'

export default defineConfig({
  plugins: [TanStackRouterVite(), react()],
})
EOF

cat << 'EOF' > tanstack-app/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>TanStack Router Demo</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

cat << 'EOF' > tanstack-app/src/main.tsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>
)
EOF

cat << 'EOF' > tanstack-app/src/routes/__root.tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'

export const Route = createRootRoute({
  component: () => <Outlet />,
})
EOF

cat << 'EOF' > tanstack-app/src/routes/dashboard.tsx
import { createFileRoute } from '@tanstack/react-router'
import { z } from 'zod'

const searchSchema = z.object({
  page: z.number().default(1),
  filter: z.string().default('all'),
})

export const Route = createFileRoute('/dashboard')({
  validateSearch: searchSchema,
  component: DashboardComponent,
})

function DashboardComponent() {
  const { page, filter } = Route.useSearch()

  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>TanStack Start / Router (Port 3001)</h1>
      <p>Native route boundary schema validation with auto-inferred types:</p>
      <pre>{JSON.stringify({ page, filter }, null, 2)}</pre>
    </div>
  )
}
EOF

# ==========================================
# 3. INSTALLATION & FINISH
# ==========================================
echo "📥 Installing Next.js dependencies..."
(cd nextjs-app && npm install)

echo "📥 Installing TanStack dependencies..."
(cd tanstack-app && npm install)

echo ""
echo "✨ All set up! To run both projects:"
echo "  1. Terminal 1: cd type-safety-demo/nextjs-app && npm run dev"
echo "  2. Terminal 2: cd type-safety-demo/tanstack-app && npm run dev"

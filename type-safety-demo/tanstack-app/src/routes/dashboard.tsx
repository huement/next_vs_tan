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

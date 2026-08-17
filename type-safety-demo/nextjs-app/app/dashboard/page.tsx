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

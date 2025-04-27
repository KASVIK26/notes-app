import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  return new Response(JSON.stringify({
    message: "Working!",
    method: req.method,
    headers: Object.fromEntries(req.headers.entries())
  }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
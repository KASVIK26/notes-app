import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Set CORS headers
  const headers = new Headers({
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  })

  try {
    // Only handle POST requests
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { headers, status: 405 }
      )
    }

    // Parse request body
    const { title, content, is_public } = await req.json()
    if (!title) {
      return new Response(
        JSON.stringify({ error: 'Title is required' }),
        { headers, status: 400 }
      )
    }

    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: {
            Authorization: req.headers.get('Authorization') ?? '',
          },
        },
      }
    )

    // Get user from token
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { headers, status: 401 }
      )
    }

    // Insert note
    const { data, error } = await supabaseClient
      .from('notes')
      .insert({
        title,
        content: content || null,
        user_id: user.id,
        is_public: is_public || false
      })
      .select()

    if (error) throw error

    return new Response(
      JSON.stringify(data[0]),
      { headers, status: 201 }
    )

  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { headers, status: 400 }
    )
  }
})
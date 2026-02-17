import { createClient, SupabaseClient } from "@supabase/supabase-js";

// Create supabase client with default options
export function create_client(url: string, key: string): SupabaseClient {
    return createClient(url, key)
}
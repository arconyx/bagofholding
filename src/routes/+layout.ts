import { PUBLIC_SUPABASE_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";
import { createClient } from "@supabase/supabase-js";
import type { LayoutLoad } from "./$types";
import type { Database } from "$lib/supabase";
import { userState } from "$lib/state.svelte";

export const prerender = true;



export const load: LayoutLoad = async ({ fetch }) => {
    console.log("Load called")

    const supabase = createClient<Database>(
        PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_KEY,
        {
            auth: {
                autoRefreshToken: true
            },
            global: {
                fetch: fetch
            }
        }
    )
    const { data } = await supabase.auth.getUser()
    userState.user = data.user

    return { supabase }
}
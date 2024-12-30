import { PUBLIC_SUPABASE_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";
import { createClient } from "@supabase/supabase-js";
import type { LayoutLoad } from "./$types";
import type { Database } from "$lib/supabase";
import { userState } from "$lib/state.svelte";

export const prerender = true;

export const load: LayoutLoad = async () => {
    const supabase = createClient<Database>(
        PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_KEY,
        {
            auth: {
                autoRefreshToken: true
            }
        }
    )
    const { data } = await supabase.auth.getUser()

    userState.user = data.user

    supabase.auth.onAuthStateChange((event, session) => {
        if (event == 'SIGNED_IN') {
            userState.user = session?.user ?? null
        } else if (event === 'SIGNED_OUT') {
            // clear local and session storage
            [window.localStorage, window.sessionStorage].forEach((storage) => {
                Object.entries(storage).forEach(([key]) => {
                    storage.removeItem(key);
                });
            });
            userState.user = null
        }
    });

    return { supabase }
}
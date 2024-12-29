import { PUBLIC_SUPABASE_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";
import { createClient } from "@supabase/supabase-js";
import type { LayoutLoad } from "./$types";
import type { Database } from "$lib/supabase";

export const prerender = true;

export const load: LayoutLoad = async () => {
    const supabase = createClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_KEY)
    const { data } = await supabase.auth.getSession()

    return {
        supabase: supabase,
        loggedIn: data.session != null
    }
}
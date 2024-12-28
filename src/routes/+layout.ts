import { PUBLIC_SUPABASE_KEY, PUBLIC_SUPABASE_URL } from "$env/static/public";
import { createClient } from "@supabase/supabase-js";
import type { LayoutLoad } from "./$types";

export const prerender = true;

const supabase = createClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_KEY)

export const load: LayoutLoad = async () => {
    return {
        supabase: supabase
    }
}
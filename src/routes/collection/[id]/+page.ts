import type { PageLoad } from "./$types";
import { error } from "@sveltejs/kit";

export const ssr = true; // needs to be false for vite dev

export const load: PageLoad = async ({ parent, params }) => {
    console.log("Running load")
    const { supabase } = await parent();
    console.log("Supabase is", supabase)
    const { data, error: sb_error } = await supabase
        .from("collections")
        .select()
        .eq('id', params.id)
        .single()

    if (sb_error != null) {
        console.error(`Error fetching collection ${params.id}`, sb_error, data)
        error(404, "Collection not found")
    }

    console.log("Loaded collection", data)
    return { supabase: supabase, collection: data }
};
import { error } from "@sveltejs/kit";
import type { LayoutLoad } from "./$types";

export const prerender = false;
export const ssr = false; // needs to be false for vite dev

export const load: LayoutLoad = async ({ parent, params }) => {
    const { supabase } = await parent();

    const { data, error: db_error } = await supabase
        .from("collections")
        .select()
        .eq('id', params.id)
        .single()

    if (db_error || data == null) {
        // TODO: Error handling
        console.error(`Error fetching collection ${params.id}`, db_error, data)
        error(404, "Collection not found")
    }

    return { supabase: supabase, collection: data }
};
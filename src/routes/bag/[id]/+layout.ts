import { error } from "@sveltejs/kit";

export const prerender = false;
export const ssr = false;

export const load = async ({ parent, params }) => {
    const { supabase } = await parent();

    const { data, error: db_error } = await supabase
        .from("bags")
        .select()
        .eq('id', params.id)
        .single()

    if (db_error || data == null) {
        // TODO: Error handling
        console.error(`Error fetching bag ${params.id}`, db_error, data)
        error(404, "Bag not found")
    }

    return { supabase, bag: data }
};
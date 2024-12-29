import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ parent }) => {
    const { supabase } = await parent();
    const { data, error } = await supabase.from("collections").select()

    if (!error) {
        console.log("Loaded collections", data)
        return { supabase: supabase, collections: data }
    }

    // TODO: Handle error
    console.error("Error loading collection", error)
    throw new Error("Unable to load collections");
};
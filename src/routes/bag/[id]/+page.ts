import type { FilledBag } from "$lib/schema/FilledBag.js";
import { error } from "@sveltejs/kit";

export const load = async ({ parent, params }) => {
    const { supabase, bag } = await parent();

    const { data, error: db_error } = await supabase
        .from("items")
        .select()
        .eq('bag_id', bag.id)

    if (db_error || data == null) {
        // TODO: Error handling
        console.error(`Error fetching items for bag ${params.id}`, db_error, data)
        error(404, "Bag items not found")
    }

    const filledBag = bag as FilledBag
    filledBag.items = data

    return { supabase, bag: filledBag }
};
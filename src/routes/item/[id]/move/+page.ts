import { error } from '@sveltejs/kit';

export const load = async ({ parent }) => {
    const { supabase, item } = await parent();

    const { data: collection_ids, error: col_error } = await supabase.from("bags").select("collection_id").eq("id", item.bag_id).single()
    const col_id = collection_ids?.collection_id

    if (col_error || col_id == null) {
        error(400, "Unable to fetch parent bag")
    }

    const { data, error: bags_error } = await supabase.from("bags").select("id, name").eq("collection_id", col_id)

    if (bags_error) {
        error(400, "Unable to find other bags")
    }

    return { item, supabase, bags: data }
};
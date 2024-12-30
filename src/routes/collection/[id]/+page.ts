import type { SupabaseClient } from "@supabase/supabase-js";
import type { PageLoad } from "./$types";
import { error } from "@sveltejs/kit";
import type { Database } from "$lib/supabase";
import type { FilledBag } from "$lib/schema/FilledBag";

async function getBagItems(supabase: SupabaseClient<Database>, bag: { id: string }) {
    const { data, error } = await supabase.from("items").select().eq("bag_id", bag.id)
    if (error != null) {
        throw new Error("Unable to load bag for items");
    }
    return { bag_id: bag.id, items: data }
}

export const load: PageLoad = async ({ parent, params }) => {
    const { supabase, collection } = await parent();

    const { data: bags, error: bags_error } = await supabase
        .from("bags")
        .select()
        .eq("collection_id", params.id)

    if (bags_error || bags == null) {
        console.error(`Error fetching bags for collection ${params.id}`, bags_error, collection)
        error(404, "Collection not found")
    }

    const getItems = (bag: { id: string }) => { return getBagItems(supabase, bag) }

    const filledBags: FilledBag[] = new Array()

    for await (let items of bags.map(getItems)) {
        let bag = bags.find(({ id }) => { return id == items.bag_id }) ?? null
        if (bag == null) {
            console.error("Bag not found", items, bags)
            continue
        }
        let fbag = bag as FilledBag
        fbag['items'] = items.items
        filledBags.push(fbag)
    }

    return { collection, filledBags }
};
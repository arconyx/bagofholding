import type { SupabaseClient } from "@supabase/supabase-js";
import type { PageLoad } from "./$types";
import { error } from "@sveltejs/kit";
import type { Database } from "$lib/supabase";
import type { FilledBag } from "$lib/schema/FilledBag";

export const ssr = false; // needs to be false for vite dev

async function getBagItems(supabase: SupabaseClient<Database>, bag: { id: string }) {
    const { data, error } = await supabase.from("items").select()
    if (error != null) {
        throw new Error("Unable to load bag for items");
    }
    return { bag_id: bag.id, items: data }
}

export const load: PageLoad = async ({ parent, params }) => {
    console.log("Running load")
    const { supabase } = await parent();
    console.log("Supabase is", supabase)

    const colandbags = await Promise.all(
        [
            supabase
                .from("collections")
                .select()
                .eq('id', params.id)
                .single(),
            supabase
                .from("bags")
                .select()
                .eq("collection_id", params.id)
        ]
    )

    const { data: collection, error: col_error } = colandbags[0]
    const { data: bags, error: bags_error } = colandbags[1]

    if (col_error != null || bags_error != null) {
        console.error(`Error fetching collection ${params.id}`, col_error, collection)
        error(404, "Collection not found")
    }

    const getItems = (bag: { id: string }) => { return getBagItems(supabase, bag) }
    const items = await Promise.all(bags.map(getItems))

    const filledBags: FilledBag[] = new Array()

    for await (let items of bags.map(getItems)) {
        let bag = bags.find(i => { i.id == items.bag_id }) ?? null
        if (bag == null) { continue }
        let fbag = bag as FilledBag
        fbag['items'] = items.items
        filledBags.push(fbag)
    }

    console.log("Loaded collection", collection)
    return { supabase, collection, filledBags }
};
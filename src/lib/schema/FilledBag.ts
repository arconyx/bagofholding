import type { Tables } from "$lib/supabase";

export interface FilledBag extends Tables<"bags"> {
    items: Tables<'items'>[];
}

export function convertBagToFilledBag(bag: Tables<"bags">, items: Tables<"items">[]) {
    const filledBag = bag as FilledBag
    const itemsInBag = items.filter(i => i.bag_id === bag.id)

    // const standardItems = itemsInBag.filter(i => i.type === "standard")
    filledBag.items = itemsInBag

    return filledBag
}
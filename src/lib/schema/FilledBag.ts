import type { Tables } from "$lib/supabase";
import type { Purse } from "./Purse";

export interface FilledBag extends Tables<"bags"> {
    items: Tables<'items'>[];
    purse: Purse
}

export function convertBagToFilledBag(bag: Tables<"bags">, items: Tables<"items">[]) {
    const filledBag = bag as FilledBag
    const itemsInBag = items.filter(i => i.bag_id === bag.id)

    const standardItems = itemsInBag.filter(i => i.type === "standard")
    filledBag.items = standardItems

    const platinumItems = itemsInBag.filter(i => i.type === "coin_platinum")
    const goldItems = itemsInBag.filter(i => i.type === "coin_gold")
    const silverItems = itemsInBag.filter(i => i.type === "coin_silver")
    const copperItems = itemsInBag.filter(i => i.type === "coin_copper")

    const platinum = platinumItems.reduce((sum, i) => sum + i.quantity, 0)
    const gold = goldItems.reduce((sum, i) => sum + i.quantity, 0)
    const silver = silverItems.reduce((sum, i) => sum + i.quantity, 0)
    const copper = copperItems.reduce((sum, i) => sum + i.quantity, 0)

    filledBag.purse = {
        platinum, gold, silver, copper
    }

    return filledBag
}
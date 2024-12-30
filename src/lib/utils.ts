import type { FilledBag } from "./schema/FilledBag";

export function usedCapacity(bag: FilledBag) {
    let items = bag.items;
    return Math.floor(items.reduce((sum, i) => sum + i.quantity * i.unit_bulk, 0));
}
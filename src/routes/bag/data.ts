import type { Item } from '$lib/schema/Item';

export const items: Item[] = [
    {
        id: 1,
        name: "Item One",
        quantity: 1,
        unit_bulk: 0.1,
        notes: "Item description",
        bag_id: 1
    },
    {
        id: 2,
        name: "Item Two",
        quantity: 1,
        unit_bulk: 0.1,
        notes: "Longer item description",
        bag_id: 1
    },
    {
        id: 3,
        name: "Item Three",
        quantity: 1,
        unit_bulk: 0.1,
        notes: "Even longer item description",
        bag_id: 1
    }
];
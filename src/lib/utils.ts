import type { FilledBag } from "./schema/FilledBag";
import type { SupabaseClient } from '@supabase/supabase-js';
import { goto } from '$app/navigation';
import { base } from '$app/paths';
import { userState } from '$lib/state.svelte';
import type { Database, Tables } from "./supabase";

export function purseGpEquivalent(bag: Tables<"bags">) {
    return 10 * bag.coin_platinum + bag.coin_gold + 0.1 * bag.coin_silver + 0.01 * bag.coin_copper
}

export function usedCapacity(bag: FilledBag) {
    const items = bag.items;
    var bulk = Math.floor(items.reduce((sum, i) => sum + i.quantity * i.unit_bulk, 0))
    bulk += Math.floor((bag.coin_platinum + bag.coin_gold + bag.coin_silver + bag.coin_copper) / 1000)

    return bulk;
}

export async function getUsername(supabase: SupabaseClient<Database>) {
    console.log("Getting username")

    if (!userState.user) {
        console.warn("User is null")
        return true
    }

    const { data: self, error: self_error } = await supabase
        .from('players')
        .select()
        .eq('id', userState.user.id);

    console.log("Retrieved username")

    if (self_error) {
        console.error('Something went wrong with getting player info');
        return true
    } else if (self.length == 1) {
        console.log('This is an existing user');
        return true
    } else if (self.length == 0) {
        console.log('New user detected, onboarding');
        goto(base + '/user/onboard');
        return false
    } else {
        console.error('Something went badly wrong with getting player info');
        return true
    }
}
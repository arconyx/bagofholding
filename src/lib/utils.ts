import type { FilledBag } from "./schema/FilledBag";
import type { SupabaseClient } from '@supabase/supabase-js';
import { error } from '@sveltejs/kit';
import { goto } from '$app/navigation';
import { base } from '$app/paths';
import { userState } from '$lib/state.svelte';
import type { Database } from "./supabase";

export function usedCapacity(bag: FilledBag) {
    let items = bag.items;
    return Math.floor(items.reduce((sum, i) => sum + i.quantity * i.unit_bulk, 0));
}

export async function getUsername(supabase: SupabaseClient<Database>) {
    console.log("Getting username")

    if (!userState.user) {
        error(500, 'User is still null after login');
    }

    const { data: self, error: self_error } = await supabase
        .from('players')
        .select()
        .eq('id', userState.user.id);

    if (self_error) {
        console.error('Something went wrong with getting player info');
        return true
    } else if (self.length == 1) {
        console.log('This is an existing user', self);
        userState.name = self[0].name;
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
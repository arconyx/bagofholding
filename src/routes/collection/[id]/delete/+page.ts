import { error } from "@sveltejs/kit";
import type { PageLoad } from "./$types";
import { userState } from "$lib/state.svelte";

export const load: PageLoad = async ({ parent }) => {
    const { collection, supabase } = await parent();

    if (userState.user?.id !== collection.owner_id) {
        error(403, "Only the owner can delete a collection.")
    }

    return { collection, supabase }
};
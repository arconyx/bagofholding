import { error } from "@sveltejs/kit";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ parent }) => {
    const { collection, supabase } = await parent();

    const { data } = await supabase.auth.getSession();

    if (data?.session?.user?.id !== collection.owner_id) {
        error(403, "Only the owner can delete a collection.")
    }

    return { collection, supabase }
};
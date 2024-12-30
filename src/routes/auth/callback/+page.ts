import { goto } from "$app/navigation";
import { base } from "$app/paths";
import { getUsername } from "$lib/utils";

export const ssr = false;
export const load = async ({ parent }) => {
    console.log("Running auth callback")
    const { supabase } = await parent();
    const hasName = await getUsername(supabase)
    if (hasName) { goto(base + "/collections") }
};

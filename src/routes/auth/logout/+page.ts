import { redirect } from "@sveltejs/kit";
import type { PageLoad } from "./$types";
import { base } from "$app/paths";

export const load: PageLoad = async ({ parent }) => {
    const { supabase } = await parent();
    await supabase.auth.signOut()
    redirect(303, `${base}/`)
};
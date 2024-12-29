import { redirect } from "@sveltejs/kit";
import type { PageLoad } from "./$types";

export const load: PageLoad = async ({ parent }) => {
    const { supabase } = await parent();
    await supabase.auth.signOut()
    redirect(303, "/")
};
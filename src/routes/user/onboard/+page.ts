import { goto } from "$app/navigation";
import { base } from "$app/paths";
import { error } from "@sveltejs/kit";

export const ssr = false;

export const load = async ({ parent }) => {
    const { supabase } = await parent();
    const { data: user_data, error: db_error } = await supabase.auth.getUser()

    if (db_error || user_data.user == null) {
        error(403, 'Not signed in');
    }

    const { user } = user_data
    // const { data, error: player_error } = await supabase.from("players").select().eq("id", user.id)

    // if (!player_error && data.length == 1) {
    //     goto(base + "/collections")
    // }

    return { supabase, user }
};
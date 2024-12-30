import { userState } from '$lib/state.svelte';
import { error } from '@sveltejs/kit';

export const load = async ({ parent }) => {
    const { supabase, collection } = await parent();

    if (userState?.user?.id != collection.owner_id) {
        error(403, "Only the owner can view collection members")
    }

    // this is a hack because I couldn't find a way to join
    // on the user ID from the client and I didn't
    // want to implment a postgres function or view for it right now
    const { data: members, error: members_error } = await supabase
        .from("members")
        .select('user_id')
        .eq('collection_id', collection.id)

    if (members_error || !members) {
        console.error("Unable to load members", members_error, members)
        error(500, "Unable to load members")
    }

    const member_ids = members.map(i => i.user_id)

    const { data: players, error: players_error } = await supabase.from("players")
        .select("id, name")
        .in('id', member_ids)

    if (players_error) {
        console.error("Unable to load names from players", players_error, players)
        error(500, "Unable to resolve usernames")
    }
    const player_ids = players.map(i => i.id)

    member_ids.forEach(id => {
        if (!player_ids.includes(id)) {
            players.push({ id: id, name: `Unnamed User ${id}` })
        }
    });

    return { supabase, collection, players }
};
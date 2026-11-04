import { PUBLIC_SUPABASE_KEY, PUBLIC_SUPABASE_URL } from '$app/env/public';
import { createClient } from '@supabase/supabase-js';
import type { LayoutLoad } from './$types';
import type { Database } from '#lib/supabase.js';
import { userState } from '#lib/state.svelte.js';

export const prerender = true;

export const load: LayoutLoad = async ({ fetch }) => {
	console.log('Load called');

	const supabase = createClient<Database>(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_KEY, {
		auth: {
			autoRefreshToken: true
		}
	});
	const { data } = await supabase.auth.getUser();
	userState.user = data.user;

	return { supabase };
};

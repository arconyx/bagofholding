import { error } from '@sveltejs/kit';

export const ssr = false;

export const load = async ({ parent }) => {
	const { supabase } = await parent();
	const { data: user_data, error: db_error } = await supabase.auth.getUser();

	if (db_error || user_data.user == null) {
		error(403, 'Not signed in');
	}

	const { user } = user_data;

	return { supabase, user };
};

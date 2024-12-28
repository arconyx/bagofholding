<script lang="ts">
	import { PUBLIC_BASE_PATH } from '$env/static/public';
	import type { SupabaseClient } from '@supabase/supabase-js';

	let { data } = $props();
	const supabase = data.supabase;

	async function signInWithDiscord() {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'discord',
			options: {
				redirectTo: `${PUBLIC_BASE_PATH}/auth/callback`
			}
		});
		return;
	}
</script>

<button onclick={signInWithDiscord}>Login with Discord</button>

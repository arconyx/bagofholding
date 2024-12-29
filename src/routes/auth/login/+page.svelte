<script lang="ts">
	import type { SupabaseClient } from '@supabase/supabase-js';

	let { data } = $props();
	const supabase = data.supabase;

	async function signInWithDiscord() {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'discord'
		});
		return;
	}
</script>

<button onclick={signInWithDiscord}>Login with Discord</button>

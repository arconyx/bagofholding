<script lang="ts">
	import { page } from '$app/state';
	import { base } from '$app/paths';

	let { data } = $props();
	const supabase = data.supabase;

	async function signInWithDiscord() {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'discord',
			options: {
				redirectTo: `${origin}${base}/auth/callback`
			}
		});
		return;
	}
</script>

<button onclick={signInWithDiscord}>Login with Discord</button>

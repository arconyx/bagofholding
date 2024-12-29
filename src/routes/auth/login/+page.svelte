<script lang="ts">
	import { page } from '$app/state';

	const origin = page.url.origin;

	let { data } = $props();
	const supabase = data.supabase;

	async function signInWithDiscord() {
		const { data, error } = await supabase.auth.signInWithOAuth({
			provider: 'discord',
			options: {
				redirectTo: `${origin}/collections`
			}
		});
		return;
	}
</script>

<button onclick={signInWithDiscord}>Login with Discord</button>

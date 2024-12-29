<script lang="ts">
	import '../app.css';
	let { children, data } = $props();
	const { supabase, loggedIn } = data;

	let hasCurrentSession = $state(loggedIn);

	supabase.auth.onAuthStateChange((event, session) => {
		if (event == 'SIGNED_IN') {
			hasCurrentSession = true;
		} else if (event === 'SIGNED_OUT') {
			// clear local and session storage
			[window.localStorage, window.sessionStorage].forEach((storage) => {
				Object.entries(storage).forEach(([key]) => {
					storage.removeItem(key);
				});
			});
			hasCurrentSession = false;
		}
	});
</script>

<nav class="auto flex flex-row pb-2 pl-4 pr-4 pt-2">
	<a href="/collections" class="flex-grow">Collections</a>
	{#if hasCurrentSession}
		<a href="/auth/logout">Logout</a>
	{:else}
		<a href="/auth/login">Login</a>
	{/if}
</nav>
<hr class="mb-4 ml-2 mr-2" />

{@render children()}

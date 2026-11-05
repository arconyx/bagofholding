<script lang="ts">
	import '../app.css';
	import { resolve } from '$app/paths';
	import { userState } from '#lib/state.svelte.js';
	import { goto } from '$app/navigation';

	let { children, data } = $props();
	const { supabase } = data;

	// console.log('User', userState);

	supabase.auth.onAuthStateChange(async (event, session) => {
		console.log('Auth event detected', event);
		if (event == 'SIGNED_IN') {
			userState.user = session?.user ?? null;
			console.log('User update', $state.snapshot(userState));
		} else if (event === 'SIGNED_OUT') {
			userState.user = null;

			// clear local and session storage
			[window.localStorage, window.sessionStorage].forEach((storage) => {
				Object.entries(storage).forEach(([key]) => {
					storage.removeItem(key);
				});
			});

			goto(resolve(('/').slice(1)));
		}
	});
</script>

<nav class="auto flex flex-row pb-2 pl-4 pr-4 pt-2">
	<a href="{resolve('/collections')}" class="flex-grow">Collections</a>
	{#if userState.user}
		<a href="{resolve('/auth/logout')}">Logout</a>
	{:else}
		<a href="{resolve('/auth/login')}">Login</a>
	{/if}
</nav>

<hr class="mb-2 ml-2 mr-2" />
<div class="p-2">{@render children()}</div>

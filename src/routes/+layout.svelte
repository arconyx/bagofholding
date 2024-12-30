<script lang="ts">
	import '../app.css';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte';

	let { children, data } = $props();
</script>

<nav class="auto flex flex-row pb-2 pl-4 pr-4 pt-2">
	<a href="{base}/collections" class="flex-grow">Collections</a>
	{#if userState.user != null}
		<a href="{base}/auth/logout">Logout</a>
	{:else}
		<a href="{base}/auth/login">Login</a>
	{/if}
</nav>
<hr class="mb-4 ml-2 mr-2" />

{@render children()}

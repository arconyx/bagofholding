<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';
	const { data } = $props();
	const { collection, supabase } = data;
	import { error } from '@sveltejs/kit';

	async function leaveCollection() {
		const user = userState?.user;

		if (!user) {
			console.error('No user session');
			return;
		}

		const { error: del_error } = await supabase
			.from('members')
			.delete()
			.eq('collection_id', collection.id)
			.eq('user_id', user.id);

		if (del_error) {
			error(500, 'Error leaving collection');
		}

		console.log('Left collection');

		goto(base + '/collections');
	}
</script>

<h1 class="text-xl">{collection.name}</h1>
<p>Are you sure you want to leave this collection?</p>
<button class="p-4 pr-12" onclick={leaveCollection}>Yes</button>
<a class="p-4" href="../">No</a>

<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	const { data } = $props();
	const { collection, supabase } = data;
	import { error } from '@sveltejs/kit';

	async function deleteCollection() {
		const { error: del_error } = await supabase
			.from('collections')
			.delete()
			.eq('id', collection.id);

		if (del_error) {
			error(500, 'Error deleting collection');
		}

		console.log('Deleted collection');

		goto(base + '/collections');
	}
</script>

<h1 class="text-xl">{collection.name}</h1>
<p>Are you sure you want to delete this collection?</p>
<button class="p-4 pr-12" onclick={deleteCollection}>Yes</button>
<a class="p-4" href="./">No</a>

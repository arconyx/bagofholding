<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	const { data } = $props();
	const { bag, supabase } = data;
	import { error } from '@sveltejs/kit';

	async function deleteBag() {
		const { error: del_error } = await supabase.from('bags').delete().eq('id', bag.id);

		if (del_error) {
			error(500, 'Error deleting bag');
		}

		console.log('Deleted bag');

		goto(base + '/collection/' + bag.collection_id);
	}
</script>

<h1 class="text-xl">{bag.name}</h1>
<p>Are you sure you want to delete this bag?</p>
<button class="p-4 pr-12" onclick={deleteBag}>Yes</button>
<a class="p-4" href="./">No</a>

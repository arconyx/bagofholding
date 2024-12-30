<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	const { data } = $props();
	const { item, supabase } = data;
	import { error } from '@sveltejs/kit';

	async function deleteItem() {
		const { error: del_error } = await supabase.from('items').delete().eq('id', item.id);

		if (del_error) {
			error(500, 'Error deleting item');
		}

		console.log('Deleted item');

		goto(base + '/bag/' + item.bag_id);
	}
</script>

<h1 class="text-xl">{item.name}</h1>
<p>Are you sure you want to delete this item?</p>
<button class="p-4 pr-12" onclick={deleteItem}>Yes</button>
<a class="p-4" href="./">No</a>

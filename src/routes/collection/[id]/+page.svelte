<script lang="ts">
	import ItemList from './ItemList.svelte';
	import { page } from '$app/state';

	let { data } = $props();
	const { supabase, collection, filledBags } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md pb-4">{collection.description}</p>
<a href="{page.params.id}/bag/new">Add Bag</a>

<ul class="pt-4">
	{#each filledBags as bag}
		<li>
			<h2 class="text-lg">{bag.name}</h2>
			<ItemList items={bag.items} />
		</li>
	{/each}
</ul>

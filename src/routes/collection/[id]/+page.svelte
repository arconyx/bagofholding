<script lang="ts">
	import ItemList from './ItemList.svelte';

	let { data } = $props();
	const { supabase, collection, filledBags } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md mb-4">{collection.description}</p>
<a href="{collection.id}/bags/new">Add Bag</a>

<ul class="mt-4">
	{#each filledBags as bag}
		<li class="mb-2">
			<h2 class="text-lg">{bag.name}</h2>
			<p class="text-md">{bag.description}</p>
			<a
				class="text-sm"
				href="/bag/{bag.id}/items/new?redir={encodeURIComponent('/collection/' + collection.id)}"
			>
				Add Item
			</a>
			<ItemList items={bag.items} />
		</li>
	{/each}
</ul>

<script lang="ts">
	import { base } from '$app/paths';
	import type { FilledBag } from '$lib/schema/FilledBag';
	import ItemList from '$lib/ItemList.svelte';

	function usedCapacity(bag: FilledBag) {
		let items = bag.items;
		return Math.floor(items.reduce((sum, i) => sum + i.quantity * i.unit_bulk, 0));
	}

	let { data } = $props();
	const { collection, filledBags } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md mb-4">{collection.description}</p>
<a href="{collection.id}/bags/new">Add Bag</a>

<ul class="mt-4">
	{#each filledBags as bag}
		<li class="mb-2">
			<h2 class="text-lg">{bag.name} ({usedCapacity(bag)}/{bag.capacity})</h2>
			<p class="text-md">{bag.description}</p>
			<a
				class="text-sm"
				href="{base}/bag/{bag.id}/items/new?redir={encodeURIComponent(
					base + '/collection/' + collection.id
				)}"
			>
				Add Item
			</a>
			<ItemList items={bag.items} />
		</li>
	{/each}
</ul>

<a class="mt-8 block" href="{collection.id}/delete"> Delete Bag </a>

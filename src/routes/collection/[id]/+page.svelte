<script lang="ts">
	import { base } from '$app/paths';
	import ItemList from '$lib/ItemList.svelte';
	import { usedCapacity } from '$lib/utils.js';

	let { data } = $props();
	const { collection, filledBags } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md mb-4">{collection.description}</p>
<a href="{collection.id}/bags/new">Add Bag</a>

<ul class="mt-4">
	{#each filledBags as bag}
		<li class="mb-2">
			<h2 class="text-lg">
				<a href="{base}/bag/{bag.id}">{bag.name}</a> ({usedCapacity(bag)}/{bag.capacity})
			</h2>
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

<a class="mt-8 block" href="{collection.id}/delete"> Delete Collection </a>

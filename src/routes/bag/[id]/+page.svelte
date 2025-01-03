<script lang="ts">
	import { base } from '$app/paths';
	import ItemList from '$lib/ItemList.svelte';
	import { usedCapacity } from '$lib/utils.js';
	const { data } = $props();
	const { bag } = data;
</script>

<h2 class="text-lg">{bag.name} ({usedCapacity(bag)}/{bag.capacity})</h2>
<p class="text-md">{bag.description}</p>

<ItemList items={bag.items} />

<div class="mt-8 grid grid-flow-row auto-rows-min grid-cols-auto-fill-48 gap-4 text-center">
	<a href="{base}/bag/{bag.id}/items/new?redir={encodeURIComponent('../')}"> Add Item </a>
	<a href="{base}/collection/{bag.collection_id}">View collection</a>
	<a href="{bag.id}/edit">Edit Bag</a>
	<a href="{bag.id}/delete">Delete Bag</a>
</div>

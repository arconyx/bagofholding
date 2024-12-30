<script lang="ts">
	import { base } from '$app/paths';
	import ItemList from '$lib/ItemList.svelte';
	import { usedCapacity } from '$lib/utils.js';
	const { data } = $props();
	const { bag } = data;
</script>

<h2 class="text-lg">{bag.name} ({usedCapacity(bag)}/{bag.capacity})</h2>
<p class="text-md">{bag.description}</p>
<a class="pr-4 text-sm" href="{base}/bag/{bag.id}/items/new?redir={encodeURIComponent('../')}">
	Add Item
</a>
<a class="pr-4 text-sm" href="{base}/collection/{bag.collection_id}">View collection</a>
<a class="pr-4 text-sm" href="{bag.id}/delete">Delete Bag</a>

<ItemList items={bag.items} />

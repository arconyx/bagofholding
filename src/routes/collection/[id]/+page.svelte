<script lang="ts">
	import { base } from '$app/paths';
	import ItemList from '$lib/ItemList.svelte';
	import PurseDisplay from '$lib/PurseDisplay.svelte';
	import { userState } from '$lib/state.svelte.js';
	import { usedCapacity } from '$lib/utils.js';

	let { data } = $props();
	const { collection, filledBags } = data;

	var totalGP = $state(0);
	filledBags.forEach((i) => {
		totalGP += 10 * i.coin_platinum + i.coin_gold + 0.1 * i.coin_silver + i.coin_gold;
	});
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md">{collection.description}</p>
<div class="mb-4">Total Funds: {totalGP} gp</div>

<ul class="mt-4">
	<!-- TODO: Sort bags before displaying -->
	{#each filledBags as bag}
		<li class="mb-2">
			<h2 class="text-lg">
				<a href="{base}/bag/{bag.id}">{bag.name}</a> ({usedCapacity(bag)}/{bag.capacity})
			</h2>
			<p class="text-md">{bag.description}</p>
			<PurseDisplay {bag} prefix="Purse: " />
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

<div class="mt-8 grid grid-flow-row auto-rows-min grid-cols-auto-fill-48 gap-4 text-center">
	<a href="{collection.id}/bags/new">Add Bag</a>
	<a href="{collection.id}/edit"> Edit Collection </a>
	{#if userState?.user?.id === collection.owner_id}
		<a href="{collection.id}/members"> View Members </a>
		<a href="{collection.id}/delete"> Delete Collection </a>
	{:else}
		<a href="{collection.id}/members/leave"> Leave Collection </a>
	{/if}
</div>

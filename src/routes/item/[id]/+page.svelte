<script lang="ts">
	import { base } from '$app/paths';

	let { data } = $props();
	const { item } = data;
</script>

<div class="flex flex-col">
	<h1 class="text-xl">{item.name}</h1>
	<p class="pb-4">{item.description}</p>
	<span>Quantity: {item.quantity}</span>
	<span>
		Bulk:
		{#if item.quantity == 1}{item.unit_bulk}
		{:else}{item.unit_bulk * item.quantity} ({item.unit_bulk} each)
		{/if}
	</span>
	<!-- <span class="capitalize">Type: {item.type}</span> -->
	<a class="pt-4" href="{base}/bag/{item.bag_id}">View Bag</a>
	<a class="pt-4 text-sm" href="{item.id}/delete">Delete Item</a>
</div>

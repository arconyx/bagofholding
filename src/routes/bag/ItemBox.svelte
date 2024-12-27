<script lang="ts">
	import type { Item } from '$lib/schema/Item';

	interface Props {
		item: Item;
	}

	let { item }: Props = $props();
</script>

<li data-item-id={item.id} class="m-2 block min-w-48 border-2 bg-slate-50 p-2 hover:bg-slate-100">
	<h3 class="text-lg">{item.name}</h3>
	<p>{item.notes}</p>
	<div class="flex flex-row">
		<span class="flex-auto">{item.quantity}x</span>
		<span class="flex-auto">{item.unit_bulk * item.quantity} bulk</span>
	</div>
</li>

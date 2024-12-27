<script lang="ts">
	import type { Item } from '$lib/schema/Item';

	interface Props {
		item: Item;
	}

	let { item }: Props = $props();
</script>

<li data-item-id={item.id}>
	<h3 class="text-lg">{item.name}</h3>
	<p>{item.notes}</p>
	<div class="flex flex-row">
		<span class="flex-auto">{item.quantity}x</span>
		<span class="flex-auto">{item.unit_bulk * item.quantity} bulk</span>
	</div>
</li>

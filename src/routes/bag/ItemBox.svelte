<script lang="ts">
	import type { Item } from '$lib/schema/Item';

	interface Props {
		item: Item;
	}

	let { item }: Props = $props();
</script>

<li
	data-item-id={item.id}
	class="m-2 block flex min-w-48 flex-col border-2 bg-slate-50 p-2 hover:bg-slate-100"
>
	<h3 class="flex-inital text-lg">{item.name}</h3>
	<p class="text-md flex-grow">{item.notes}</p>
	<div class="flex flex-initial flex-row">
		<span class="flex-auto text-sm text-slate-600">{item.quantity}x</span>
		<span class="text-sm text-slate-600">{item.unit_bulk * item.quantity} bulk</span>
	</div>
</li>

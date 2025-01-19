<script lang="ts">
	import type { Tables } from '$lib/supabase';
	import ItemBox from './ItemBox.svelte';

	interface Props {
		items: Tables<'items'>[];
	}

	let { items: itemsInput }: Props = $props();
	var items: Tables<'items'>[] = $state(itemsInput);

	function sortItems(sort: string | null) {
		if (sort === 'name:a-z') {
			return items.sort((a, b) => {
				if (a.name > b.name) {
					return 1;
				} else if (a.name < b.name) {
					return -1;
				} else {
					return 0;
				}
			});
		} else if (sort === 'total_bulk:9-0') {
			return items.sort((a, b) => {
				return b.quantity * b.unit_bulk - a.quantity * a.unit_bulk;
			});
		} else {
			return items;
		}
	}

	const sortNameAZ = () => {
		items = sortItems('name:a-z');
	};
	const sortTotalBulk90 = () => {
		items = sortItems('total_bulk:9-0');
	};
</script>

<div class="flex gap-4 text-sm">
	<button onclick={sortNameAZ}>Sort A-Z</button>
	<button onclick={sortTotalBulk90}>Sort Bulk</button>
</div>
<ul class="grid grid-flow-row auto-rows-min grid-cols-auto-fill-48">
	{#each items as item}
		<ItemBox {item} />
	{/each}
</ul>

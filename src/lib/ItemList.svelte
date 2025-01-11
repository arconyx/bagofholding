<script lang="ts">
	import type { Tables } from '$lib/supabase';
	import ItemBox from './ItemBox.svelte';

	interface Props {
		items: Tables<'items'>[];
	}

	let { items: itemsInput }: Props = $props();
	 var items: Tables<'items'>[] = $state(itemsInput);

	function sortItems(sort: string | null)
	{
	     if (sort === 'name:a-z') {
		  return items.sort(
		      (a, b) =>  {
			   if (a.name > b.name) { return 1}
			   else if (a.name < b.name) { return -1}
			   else {return 0}
		      }
		  )
	     } else {
		  return items
	     }
	}


	 const sortNameAZ = () => {items = sortItems('name:a-z')} 
</script>

<div>
    <button onclick={sortNameAZ}>Sort A-Z</button>
</div>
<ul class="grid grid-flow-row auto-rows-min grid-cols-auto-fill-48">
	{#each items as item}
		<ItemBox {item} />
	{/each}
</ul>

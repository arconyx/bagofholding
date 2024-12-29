<script lang="ts">
	import ItemList from './ItemList.svelte';

	let { data } = $props();
	const { supabase, collection, filledBags } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>
<p class="text-md">{collection.description}</p>
<br />
<ul>
	{#each filledBags as bag}
		<li>
			<h2 class="text-lg">{bag.name}</h2>
			<ItemList items={bag.items} />
		</li>
	{/each}
</ul>

<script lang="ts">
	import ItemBox from './ItemBox.svelte';

	let { data } = $props();
</script>

<h1 class="text-xl">Bag of Holding</h1>

<ul>
	{#each data.items as item}
		<ItemBox {item} />
	{/each}
</ul>

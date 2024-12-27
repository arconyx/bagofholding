<script lang="ts">
	import ItemBox from './ItemBox.svelte';

	let { data } = $props();
</script>

<h1 class="text-xl">Bag of Holding</h1>

<ul class="grid-cols-auto-fill-48 grid grid-flow-row auto-rows-max" style="">
	{#each data.items as item}
		<ItemBox {item} />
	{/each}
</ul>

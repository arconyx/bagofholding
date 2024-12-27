<script lang="ts">
	import ItemBox from './ItemBox.svelte';

	let { data } = $props();
</script>

<h1 class="text-xl">Bag of Holding</h1>

<!-- TODO: Make grid-template-columns a tailwind thing? -->
<ul class="item-grid grid auto-cols-auto auto-rows-max" style="">
	{#each data.items as item}
		<ItemBox {item} />
	{/each}
</ul>

<style>
	.item-grid {
		grid-template-columns: repeat(auto-fill, minmax(12rem, 1fr));
	}
</style>

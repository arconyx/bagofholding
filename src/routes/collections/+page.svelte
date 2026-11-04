<script lang="ts">
	import { resolve } from '$app/paths';

	let { data } = $props();
</script>

<h1 class="text-xl">Collections</h1>

<ul class="pb-4 pt-4 text-lg">
	{#each data.collections as collection}
		<li><a href="{resolve('')}/collection/{collection.id}">{collection.name}</a></li>
	{/each}
</ul>

<a href="{resolve('')}/collections/new">New Collection</a>

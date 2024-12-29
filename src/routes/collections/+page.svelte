<script lang="ts">
	let { data } = $props();
</script>

<h1 class="text-xl">Collections</h1>

<ul class="pb-4 pt-4 text-lg">
	{#each data.collections as collection}
		<a href="../collection/{collection.id}">{collection.name}</a>
	{/each}
</ul>

<a href="collections/new"> New Collection </a>

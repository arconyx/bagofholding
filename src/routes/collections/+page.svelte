<script lang="ts">
	let { data } = $props();
</script>

<h1 class="text-xl">Collections</h1>

<ul>
	{#each data.collections as collection}
		<h3>{collection.name}</h3>
	{/each}
</ul>

<a href="/collections/new"> New Collection </a>

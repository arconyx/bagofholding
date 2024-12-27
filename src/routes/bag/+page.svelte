<script lang="ts">
	let { data } = $props();
</script>

<h1>Bag of Holding</h1>

<ul>
	{#each data.items as { name }}
		<li>{name}</li>
	{/each}
</ul>

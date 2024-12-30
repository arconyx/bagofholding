<script lang="ts">
	const { data } = $props();
	const { collection, players } = data;

	const owner = players.filter((i) => i.id == collection.owner_id)[0];
	const otherPlayers = players.filter((i) => i.id != collection.owner_id);
</script>

<h1 class="text-xl">Members of <span class="italic">{collection.name}</span></h1>
<ul>
	<li>{owner.name} (Owner)</li>
	{#each otherPlayers as player}
		<li>{player.name} <button>(remove)</button></li>
	{/each}
</ul>

<script lang="ts">
	const { data } = $props();
	const { supabase, collection, players } = data;

	const owner = players.filter((i) => i.id == collection.owner_id)[0];
	let otherPlayers = $state(players.filter((i) => i.id != collection.owner_id));

	async function removePlayer(e: Event) {
		const target = e.target;

		if (!target) {
			console.error('No button target');
			return;
		}

		// @ts-ignore
		const id = target.dataset.userId as string;

		const { data, error } = await supabase
			.from('members')
			.delete()
			.eq('collection_id', collection.id)
			.eq('user_id', id);

		if (error) {
			return;
		}

		otherPlayers = otherPlayers.filter((i) => i.id != id);
	}
</script>

<h1 class="text-xl">Members of <span class="italic">{collection.name}</span></h1>
<ul>
	<li>{owner.name} (Owner)</li>
	{#each otherPlayers as player}
		<li>{player.name} <button data-user-id={player.id} onclick={removePlayer}>(remove)</button></li>
	{/each}
</ul>

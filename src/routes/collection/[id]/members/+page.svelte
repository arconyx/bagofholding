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

		const { error } = await supabase
			.from('members')
			.delete()
			.eq('collection_id', collection.id)
			.eq('user_id', id);

		if (error) {
			return;
		}

		otherPlayers = otherPlayers.filter((i) => i.id != id);
	}

	async function addPlayer(e: SubmitEvent) {
		const target = e.target;

		if (!target) {
			console.error('No button target');
			return;
		}

		// @ts-ignore
		const form = new FormData(target);
		const name = form.get('name') as string;

		const { data } = await supabase.from('players').select('id').eq('name', name).single();

		if (!data) {
			console.error("Couldn't find user with that name");
			return;
		}

		const { error } = await supabase.from('members').insert({
			collection_id: collection.id,
			user_id: data.id
		});

		location.reload();
	}
</script>

<h1 class="text-xl">Members of <span class="italic">{collection.name}</span></h1>
<ul>
	<li>{owner.name} (Owner)</li>
	{#each otherPlayers as player}
		<li>{player.name} <button data-user-id={player.id} onclick={removePlayer}>(remove)</button></li>
	{/each}
</ul>
<form class="mt-4" onsubmit={addPlayer}>
	<label>Add User <input name="name" type="text" placeholder="Username" required /></label>
	<button>Confirm</button>
</form>

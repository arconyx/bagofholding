<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';

	const { data } = $props();
	const { supabase, user } = data;
	let submissionError = $state(false);

	console.log(user.user_metadata);

	async function setUsername(event: SubmitEvent) {
		if (event.target == null) {
			console.error('Invalid event target');
			throw new Error('Invalid input');
		}

		event.preventDefault();

		// @ts-ignore
		const form = new FormData(event.target);
		const name = form.get('username') as string;

		const { data, error } = await supabase.from('players').upsert({
			name: name,
			id: user.id
		});

		if (error) {
			console.error('Unable to submit username', error, data);
			submissionError = true;
			return false;
		}

		goto(base + '/collections');
		return false;
	}
</script>

<h1 class="text-xl">Welcome</h1>

<p>Please select a username. Minimum length is three.</p>
{#if submissionError}
	<p class="text-red-700">There was an error setting your username. Please try again.</p>
{/if}
<form onsubmit={setUsername}>
	<label
		>Username <input
			class="border-1 invalid:border-red-700"
			name="username"
			type="text"
			minlength="3"
			required
		/></label
	>
	<button>Submit</button>
</form>

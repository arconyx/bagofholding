<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';
	import Bag from '$lib/forms/Bag.svelte';

	const { data } = $props();
	const { bag, supabase } = data;

	async function onSuccess() {
		console.log('Bag on success', bag);
		const url = `${base}/bag/${bag.id}`;
		await goto(url);
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent): Promise<string | null> {
		event.preventDefault();

		const form = new FormData(formElement);
		console.log('Bag on submit', bag);

		if (!userState.user) {
			console.error('User not set');
			return 'Invalid user session';
		}

		let capacity = (form.get('capacity') ?? -1) as number;
		if (capacity < 1) {
			return 'Capacity must be at least one';
		}

		const { error } = await supabase
			.from('bags')
			.update({
				name: form.get('name') as string,
				description: form.get('description') as string,
				capacity: capacity
			})
			.eq('id', bag.id);

		if (error != null) {
			console.error('Bag update error', error);
			return 'Unable to submit data';
		}

		bag.name = form.get('name') as string;
		bag.description = form.get('description') as string;
		bag.capacity = capacity;

		return null;
	}
</script>

<h1 class="text-xl">Edit Bag</h1>

<Bag {bag} submitLabel="Save" {onSuccess} {submit} />

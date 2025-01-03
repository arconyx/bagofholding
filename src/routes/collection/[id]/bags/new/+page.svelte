<script lang="ts">
	import Bag from '$lib/forms/Bag.svelte';
	import { goto, invalidate } from '$app/navigation';
	import { page } from '$app/state';

	let { data } = $props();
	const { supabase } = data;

	async function onSuccess() {
		const url = '../';
		await invalidate(url);
		await goto(url);
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent): Promise<string | null> {
		if (event.target == null) {
			console.error('Invalid event target');
			throw new Error('Invalid input');
		}

		event.preventDefault();

		// @ts-ignore
		const form = new FormData(event.target);

		let capacity = (form.get('capacity') ?? -1) as number;
		if (capacity < 1) {
			return 'Capacity must be at least one';
		}

		const { data, error: sub_error } = await supabase.from('bags').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			capacity: capacity,
			collection_id: page.params.id
		});

		if (sub_error != null) {
			// TODO: Error handling
			console.error('Failed to create bag', sub_error, data);
			return 'Unable to create bag.';
		}
		return null;
	}
</script>

<h1 class="text-xl">Create Bag</h1>

<Bag bag={null} {submit} {onSuccess} submitLabel="Create" />

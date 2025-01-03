<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';
	import Collection from '$lib/forms/Collection.svelte';

	let { data } = $props();
	const { collection, supabase } = data;

	async function onSuccess() {
		const url = `${base}/collection/${collection.id}`;
		// await invalidate(url);
		await goto(url);
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent): Promise<string | null> {
		event.preventDefault();

		const form = new FormData(formElement);

		if (!userState.user) {
			console.error('User not set');
			return 'Invalid user session';
		}

		const { error } = await supabase
			.from('collections')
			.update({
				name: form.get('name') as string,
				description: form.get('description') as string
			})
			.eq('id', collection.id);

		if (error != null) {
			console.error('Collection update error', error);
			return 'Unable to submit data';
		}

		collection.name = form.get('name') as string;
		collection.description = form.get('description') as string;

		return null;
	}
</script>

<h1 class="text-xl">Edit Collection</h1>

<Collection {collection} submitLabel="Save" {onSuccess} {submit} />

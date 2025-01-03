<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';
	import Collection from '$lib/forms/Collection.svelte';

	let { data } = $props();
	const supabase = data.supabase;

	async function onSuccess() {
		await goto(base + '/collections');
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent): Promise<string | null> {
		event.preventDefault();

		const form = new FormData(formElement);

		if (!userState.user) {
			console.error('User not set');
			return 'Invalid user session';
		}

		const { error } = await supabase.from('collections').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			owner_id: userState.user.id
		});

		if (error != null) {
			console.error('Collection creation error', error);
			return 'Unable to submit data';
		}

		return null;
	}
</script>

<h1 class="text-xl">Create Collection</h1>

<Collection collection={null} submitLabel="Create" {onSuccess} {submit} />

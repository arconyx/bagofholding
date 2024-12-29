<script lang="ts">
	import { goto } from '$app/navigation';
	import { redirect } from '@sveltejs/kit';

	let { data } = $props();
	const supabase = data.supabase;

	async function submit(event: SubmitEvent) {
		if (event.target == null) {
			console.error('Invalid event target');
			throw new Error('Invalid input');
		}

		event.preventDefault();

		// @ts-ignore
		const form = new FormData(event.target);
		const { data: session_data, error } = await supabase.auth.getSession();

		if (error != null || session_data.session == null) {
			console.error('Error fetching session', error, session_data.session);
			throw new Error('Invalid session');
		}

		const { data, error: sub_error } = await supabase.from('collections').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			owner_id: session_data.session.user.id
		});

		if (sub_error != null) {
			// TODO: Report error to user instead of erroring in code
			throw new Error('Unable to submit data');
		}

		await goto('/collections');

		return false;
	}
</script>

<h1 class="text-xl">Create Collection</h1>

<form method="POST" onsubmit={submit}>
	<label>
		Name
		<input name="name" type="text" required />
	</label>
	<label>
		Description
		<input name="description" />
	</label>
	<button>Create</button>
</form>

<script lang="ts">
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

		if (error || session_data.session == null) {
			console.error('Error fetching session', error, session_data.session);
			throw new Error('Invalid session');
		}

		await supabase.from('collections').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			owner_id: session_data.session.user.id
		});

		return false;
	}
</script>

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

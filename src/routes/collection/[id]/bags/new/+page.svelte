<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';

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

		let capacity = (form.get('capacity') ?? -1) as number;
		if (capacity < 1) {
			// TODO: Error properly
			return false;
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
			return false;
		}

		goto('../');

		return false;
	}
</script>

<h1 class="text-xl">Create Bag</h1>

<form method="POST" onsubmit={submit}>
	<label>
		Name
		<input name="name" type="text" required />
	</label>
	<label>
		Description
		<input name="description" type="text" />
	</label>
	<label>
		Capacity
		<input name="capacity" type="number" step="1" pattern="\d+" defaultValue="25" required />
	</label>
	<button>Create</button>
</form>

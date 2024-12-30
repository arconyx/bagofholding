<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { userState } from '$lib/state.svelte.js';

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

		let quantity = (form.get('quantity') ?? -1) as number;
		if (quantity < 1) {
			// TODO: Error properly
			return false;
		}

		let bulk = (form.get('bulk') ?? -1) as number;
		if (bulk < 0) {
			// TODO: Error properly
			return false;
		}

		console.log(page.params.bag_id);

		const { data, error: sub_error } = await supabase.from('items').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			quantity: quantity,
			unit_bulk: bulk,
			bag_id: page.params.id
		});

		if (sub_error != null) {
			// TODO: Error handling
			console.error('Failed to create item', sub_error, data);
			return false;
		}

		const redirect_to = page.url.searchParams.get('redir') ?? '../';
		goto(redirect_to);

		return false;
	}
</script>

<h1 class="text-xl">Add Item</h1>

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
		Quantity
		<input name="quantity" type="number" step="1" pattern="\d+" defaultValue="1" required />
	</label>
	<label>
		Bulk per unit
		<input name="bulk" type="number" step="0.1" defaultValue="1" required />
	</label>
	<button>Create</button>
</form>

<script lang="ts">
	import { goto, invalidate } from '$app/navigation';
	import { page } from '$app/state';
	import Item from '$lib/forms/Item.svelte';

	let { data } = $props();
	const supabase = data.supabase;

	async function onSuccess() {
		const url = page.url.searchParams.get('redir') ?? '../';
		await invalidate(url);
		await goto(url);
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent) {
		event.preventDefault();
		const form = new FormData(formElement);

		let quantity = (form.get('quantity') ?? -1) as number;
		if (quantity < 1) {
			return 'Quantity must be at least one';
		}

		// 'on' if checked, else null
		const isLight = form.get('light_bulk') === 'on';
		let bulk = -2;
		if (isLight) {
			bulk = 0.1;
		} else {
			bulk = (form.get('bulk') ?? -1) as number;
		}
		if (bulk < 0) {
			return `Bulk is ${bulk} but bulk cannot be negative.`;
		}

		const { data, error: sub_error } = await supabase.from('items').insert({
			name: form.get('name') as string,
			description: form.get('description') as string,
			quantity: quantity,
			unit_bulk: bulk,
			bag_id: page.params.id
		});

		if (sub_error != null) {
			console.error('Failed to create item', sub_error, data);
			return 'Unable to create item';
		}

		return null;
	}
</script>

<h1 class="text-xl">Add Item</h1>
<Item {submit} {onSuccess} submitLabel="Create" item={null} />

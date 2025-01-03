<script lang="ts">
	import { goto, invalidate } from '$app/navigation';
	import { base } from '$app/paths';
	import Item from '$lib/forms/Item.svelte';

	const { data } = $props();
	const { supabase, item } = data;

	async function onSuccess() {
		const url = `${base}/item/${item.id}`;
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

		let bulk = (form.get('bulk') ?? -1) as number;
		if (bulk < 0) {
			return 'Bulk cannot be negative.';
		}

		const { data, error: sub_error } = await supabase
			.from('items')
			.update({
				name: form.get('name') as string,
				description: form.get('description') as string,
				quantity: quantity,
				unit_bulk: bulk
			})
			.eq('id', item.id);

		if (sub_error != null) {
			console.error('Failed to update item', sub_error, data);
			return 'Unable to edit item';
		}

		item.name = form.get('name') as string;
		item.description = form.get('description') as string;
		item.quantity = quantity;
		item.unit_bulk = bulk;

		return null;
	}
</script>

<h1 class="text-xl">Edit Item</h1>
<Item {submit} {onSuccess} submitLabel="Save" {item} />

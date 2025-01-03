<script lang="ts">
	import type { Tables } from '$lib/supabase';
	let errorMsg: string | null = $state(null);

	interface Props {
		item: Tables<'items'> | null;
		submit: (form: HTMLFormElement, event: SubmitEvent) => Promise<string | null>;
		onSuccess: () => Promise<void>;
		submitLabel: String;
	}

	let { item, submit, onSuccess, submitLabel }: Props = $props();

	async function wrappedSubmit(this: HTMLFormElement, event: SubmitEvent) {
		const error = await submit(this, event);

		errorMsg = error;

		if (!error) {
			await onSuccess();
		}
	}
</script>

<form method="POST" onsubmit={wrappedSubmit} class="grid max-w-md auto-cols-min grid-cols-1 gap-6">
	<label>
		Name
		<input class="block" name="name" type="text" defaultValue={item?.name ?? ''} required />
	</label>
	<label>
		Description
		<textarea class="block" name="description" defaultValue={item?.description ?? ''}></textarea>
	</label>
	<label>
		Quantity
		<input
			class="block"
			name="quantity"
			type="number"
			step="1"
			min="1"
			pattern="\d+"
			defaultValue={item?.quantity ?? 1}
			required
		/>
	</label>
	<label>
		Bulk per unit
		<input
			class="block"
			name="bulk"
			type="number"
			step="0.1"
			min="0"
			defaultValue={item?.unit_bulk ?? 1}
			required
		/>
	</label>
	{#if errorMsg}
		<span class="block text-red-600">Error: {errorMsg}</span>
	{/if}
	<div>
		<button
			class="rounded-lg bg-blue-700 px-5 py-2.5 text-white hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
			>{submitLabel}</button
		>
	</div>
</form>

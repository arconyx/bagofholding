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

	var oldBulk = item?.unit_bulk ?? 1;

	function setInitalStep(): number {
		if ((item?.unit_bulk ?? 1) < 1) {
			return 0.1;
		} else {
			return 1;
		}
	}

	function stepBulk(this: HTMLInputElement) {
		const newBulk = this.valueAsNumber;
		if (oldBulk === 1 && newBulk < 1) {
			this.valueAsNumber = 0.1;
			this.step = '0.1';
		} else if (oldBulk === 0.1) {
			if (newBulk < 0.1) {
				this.valueAsNumber = 0;
				this.step = '0.1';
			} else if (1 > newBulk && newBulk > 0.1) {
				this.valueAsNumber = 1;
				this.step = '1';
			}
		} else {
			this.step = '1';
		}
		oldBulk = this.valueAsNumber;
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
			step={setInitalStep()}
			min="0"
			defaultValue={item?.unit_bulk ?? 1}
			required
			oninput={stepBulk}
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

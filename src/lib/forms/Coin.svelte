<script lang="ts">
	import type { Tables } from '$lib/supabase';
	let errorMsg: string | null = $state(null);

	interface Props {
		bag: Tables<'bags'>;
		submit: (form: HTMLFormElement, event: SubmitEvent) => Promise<string | null>;
		onSuccess: () => Promise<void>;
		submitLabel: String;
	}

	let { bag, submit, onSuccess, submitLabel }: Props = $props();

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
		Platinum
		<input
			class="block"
			name="platinum"
			type="number"
			min="0"
			defaultValue={bag.coin_platinum}
			required
		/>
	</label>
	<label>
		Gold
		<input class="block" name="gold" type="number" min="0" defaultValue={bag.coin_gold} required />
	</label>
	<label>
		Silver
		<input
			class="block"
			name="silver"
			type="number"
			min="0"
			defaultValue={bag.coin_silver}
			required
		/>
	</label>
	<label>
		Copper
		<input
			class="block"
			name="copper"
			type="number"
			min="0"
			defaultValue={bag.coin_copper}
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

<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import type { Tables } from '$lib/supabase';
	let errorMsg: string | null = $state(null);

	const { data } = $props();
	const { bags, supabase, item } = data;

	async function wrappedSubmit(this: HTMLFormElement, event: SubmitEvent) {
		event.preventDefault();
		const form = new FormData(this);

		const id = form.get('collection') as string;

		const { error } = await supabase.from('items').update({ bag_id: id }).eq('id', item.id);

		if (error) {
			errorMsg = 'Error moving item';
			return;
		}

		await goto(base + '/bag/' + id);
	}
</script>

<form method="POST" onsubmit={wrappedSubmit} class="grid max-w-md auto-cols-min grid-cols-1 gap-6">
	<label>
		Select new bag
		<select name="collection">
			{#each bags as bag}
				<option value={bag.id}>{bag.name}</option>
			{/each}
		</select>
	</label>

	{#if errorMsg}
		<span class="block text-red-600">Error: {errorMsg}</span>
	{/if}
	<div>
		<button
			class="rounded-lg bg-blue-700 px-5 py-2.5 text-white hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800"
			>Submit</button
		>
	</div>
</form>

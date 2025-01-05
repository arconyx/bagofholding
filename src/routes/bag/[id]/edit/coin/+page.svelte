<script lang="ts">
	import { goto } from '$app/navigation';
	import { base } from '$app/paths';
	import { userState } from '$lib/state.svelte.js';
	import Coin from '$lib/forms/Coin.svelte';

	const { data } = $props();
	const { bag, supabase } = data;

	async function onSuccess() {
		const url = `${base}/bag/${bag.id}`;
		await goto(url);
	}

	async function submit(formElement: HTMLFormElement, event: SubmitEvent): Promise<string | null> {
		event.preventDefault();

		const form = new FormData(formElement);

		if (!userState.user) {
			console.error('User not set');
			return 'Invalid user session';
		}

		const platinum = (form.get('platinum') ?? -1) as number;
		if (platinum < 1) {
			return 'Platinum cannot be negative';
		}
		const gold = (form.get('gold') ?? -1) as number;
		if (platinum < 1) {
			return 'Gold cannot be negative';
		}
		const silver = (form.get('silver') ?? -1) as number;
		if (platinum < 1) {
			return 'Silver cannot be negative';
		}
		const copper = (form.get('copper') ?? -1) as number;
		if (platinum < 1) {
			return 'Copper cannot be negative';
		}

		const { error } = await supabase
			.from('bags')
			.update({
				coin_platinum: platinum,
				coin_gold: gold,
				coin_silver: silver,
				coin_copper: copper
			})
			.eq('id', bag.id);

		if (error != null) {
			console.error('Bag update error', error);
			return 'Unable to submit data';
		}

		bag.coin_platinum = platinum;
		bag.coin_gold = gold;
		bag.coin_silver = silver;
		bag.coin_copper = copper;

		return null;
	}
</script>

<h1 class="text-xl">Edit Coin</h1>
<p>For bag {bag.name}</p>

<Coin {bag} submitLabel="Save" {onSuccess} {submit} />

<script lang="ts">
	import type { Tables } from './supabase';
	import { purseGpEquivalent } from './utils';

	interface Props {
		bag: Tables<'bags'>;
		prefix: string;
	}

	const { bag, prefix }: Props = $props();

	function getPurseString(bag: Tables<'bags'>, prefix: string): string | null {
		if (purseGpEquivalent(bag) > 0) {
			const parts: string[] = new Array();
			if (bag.coin_platinum > 0) {
				parts.push(`${bag.coin_platinum} pp`);
			}
			if (bag.coin_gold > 0) {
				parts.push(`${bag.coin_gold} gp`);
			}
			if (bag.coin_silver > 0) {
				parts.push(`${bag.coin_silver} sp`);
			}
			if (bag.coin_copper > 0) {
				parts.push(`${bag.coin_copper} cp`);
			}
			return `${prefix}${parts.join(', ')}`;
		}
		return null;
	}

	const display = getPurseString(bag, prefix);
</script>

<div>
	<span>{display}</span>
</div>

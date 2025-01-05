<script lang="ts">
	import { getPurseTotalGp, type Purse } from './schema/Purse';

	interface Props {
		purse: Purse;
		prefix: string;
	}

	const { purse, prefix }: Props = $props();

	function getPurseString(purse: Purse, prefix: string): string | null {
		if (getPurseTotalGp(purse) > 0) {
			const parts: string[] = new Array();
			if (purse.platinum > 0) {
				parts.push(`${purse.platinum} pp`);
			}
			if (purse.gold > 0) {
				parts.push(`${purse.gold} gp`);
			}
			if (purse.silver > 0) {
				parts.push(`${purse.silver} sp`);
			}
			if (purse.copper > 0) {
				parts.push(`${purse.copper} cp`);
			}
			return `${prefix}${parts.join(', ')}`;
		}
		return null;
	}

	const display = getPurseString(purse, prefix);
</script>

<div>
	<span>{display}</span>
</div>

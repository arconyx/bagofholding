<script lang="ts">
	import type { Purse } from './schema/Purse';

	interface Props {
		purse: Purse;
	}

	let { purse }: Props = $props();
</script>

<div>
	Purse: {purse.platinum} pp, {purse.gold} gp, {purse.silver} sp, {purse.copper} cp
</div>

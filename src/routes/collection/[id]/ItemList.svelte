<script lang="ts">
	import type { Tables } from '$lib/supabase';
	import ItemBox from './ItemBox.svelte';

	interface Props {
		items: Tables<'items'>[];
	}

	let { items }: Props = $props();
</script>

<ul class="grid grid-flow-row auto-rows-min grid-cols-auto-fill-48" style="">
	{#each data.items as item}
		<ItemBox {item} />
	{/each}
</ul>

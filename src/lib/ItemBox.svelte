<script lang="ts">
	import { base } from '$app/paths';
	import type { Tables } from '$lib/supabase';

	interface Props {
		item: Tables<'items'>;
	}

	let { item }: Props = $props();
</script>

<div
	class="m-2 border-2 bg-slate-50 p-2 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:hover:bg-slate-800"
>
	<a href="{base}/item/{item.id}">
		<li data-item-id={item.id} class="flex min-w-48 flex-col">
			<h3 class="flex-inital text-lg">{item.name}</h3>
			<p class="text-md flex-grow">{item.description}</p>
			<div class="flex flex-initial flex-row">
				<span class="flex-auto text-sm text-slate-600">{item.quantity}x</span>
				<span class="text-sm text-slate-600">{item.unit_bulk * item.quantity} bulk</span>
			</div>
		</li>
	</a>
</div>

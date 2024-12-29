<script lang="ts">
	let { data } = $props();
	const { supabase, collection } = data;
</script>

<h1 class="text-xl">{collection.name}</h1>

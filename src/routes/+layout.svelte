<script lang="ts">
	import '../app.css';
	let { children } = $props();
</script>

<nav class="auto flex flex-row pb-2 pl-4 pr-4 pt-2">
	<a href="/collections" class="flex-grow">Collections</a>
	<a href="/auth/login">Login</a>
	<!-- TODO: Logout -->
</nav>
<hr class="mb-4 ml-2 mr-2" />

{@render children()}

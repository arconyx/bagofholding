<script lang="ts">
	import '../app.css';
	let { children } = $props();
</script>

<nav class="p-2">
	<a href="/collections">Collections</a>
	|
	<a href="/auth/login">Login</a>
	<!-- TODO: Logout -->
</nav>
<hr class="mb-4" />

{@render children()}

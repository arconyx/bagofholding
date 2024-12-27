import containerQueries from '@tailwindcss/container-queries';
import forms from '@tailwindcss/forms';
import type { Config } from 'tailwindcss';

export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],

	theme: {
		extend: {
			gridTemplateColumns: {
				'auto-fill-48': 'repeat(auto-fill, minmax(12rem, 1fr))',
				'auto-fit-48': 'repeat(auto-fit, minmax(12rem, 1fr))',
			},
		}
	},

	plugins: [forms, containerQueries]
} satisfies Config;

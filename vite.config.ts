import {defineConfig} from 'vite-plus';

export default defineConfig({
	fmt: {
		semi: true,
		singleQuote: true,
		useTabs: true,
		tabWidth: 4,
		printWidth: 120,
		bracketSpacing: false,
		trailingComma: 'all',
		arrowParens: 'always',
		// HTML fragments under templates/ are concatenated into dist/index.html and
		// are not valid standalone documents, so oxfmt cannot parse them.
		ignorePatterns: ['dist', 'templates/**/*.html'],
		overrides: [
			{
				files: ['.yamllint.yaml', '**/*.yaml', '**/*.yml'],
				options: {
					useTabs: false,
					tabWidth: 2,
				},
			},
		],
	},
	staged: {
		'*': 'vp check --fix',
	},
});

import {defineConfig} from 'vite-plus';

export default defineConfig(
	{
		// Formatting runs through oxfmt-next-line (configured in .oxfmtrc.json), not Vite+'s bundled oxfmt.
		// HTML fragments under templates/ are concatenated into dist/index.html and are not valid standalone
		// documents, so .oxfmtrc.json ignores them along with dist.
		check:
		{
			fmt: false,
		},
	},
);

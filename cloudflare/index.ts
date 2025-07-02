import { Container, getContainer } from '@cloudflare/containers';

export class TypstFront extends Container {
	defaultPort = 3000;
	sleepAfter = '3m';
}

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const container = getContainer(env.TYPSTFRONT);
		return container.fetch(request);
	},
} satisfies ExportedHandler<Env>;

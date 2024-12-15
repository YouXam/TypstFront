
import { readFile } from 'node:fs/promises';

import path from 'node:path';
import typst from './typst'

import { Hono } from 'hono';
import { getCookie, setCookie } from 'hono/cookie';

const templateHTML = path.join(__dirname, 'template.html');
const indexTypst = path.join(__dirname, 'index.typ');

const templateString = (await Bun.file(templateHTML).text()).split('{{svg}}')

function template(svg: string): string {
    return templateString[0] + svg + templateString[1];
}

const storage = new Map<string, Record<string, any>>();
const typstBase = './typst';

const app = new Hono()
    .all("*", async c => {
        const req = c.req;
        const url = new URL(req.url);
        const params = url.searchParams
        let sessionId = getCookie(c, 'sessionId')
        if (!sessionId) {
            sessionId = Math.random().toString(36).slice(2);
            setCookie(c, 'sessionId', sessionId, {
                maxAge: 60 * 60 * 24 * 365
            })
        }
        const storageValue = storage.get(sessionId) || {};
        const route = path.join(typstBase, "pages", url.pathname, "page.typ");
        if (!await Bun.file(route).exists()) {
            return new Response("404 Not Found", {
                status: 404,
                headers: {
                    "Content-Type": "text/plain"
                }
            })
        }
        let state = {}
        if (req.method === "POST") {
            const data = await req.json();
            state = data.state ?? {}
            if (data?.storage?.set || data?.storage?.del) {
                for (const key in data?.storage?.set ?? {}) {
                    storageValue[key] = data.storage.set[key];
                }
                for (const key of data?.storage?.del ?? []) {
                    delete storageValue[key];
                }
                storage.set(sessionId, storageValue);
            }
            if (data?.redirect) {
                return new Response(null, {
                    status: 200,
                    headers: {
                        "Location": data.redirect
                    }
                })
            }
        }
        const mainContent = (await readFile(indexTypst, { encoding: "utf-8" }))
            .replace(
                /^\/\/state_begin[\s\S]*?\/\/state_end/m,
                `#let _query = json.decode(${JSON.stringify(JSON.stringify(params))})\n` +
                `#let _state = json.decode(${JSON.stringify(JSON.stringify(state))})\n` +
                `#let _storage = json.decode(${JSON.stringify(JSON.stringify(storageValue))})\n`
            ) +
            `\n#import "/pages${url.pathname.replace(/^\/$/, '')}/page.typ": Page` +
            `\n#Page(ctx: ctx, query: _query, storage: _storage)`;
        const svg = await typst.svg({ mainContent });
        return new Response(params.has('_svg') ? svg : template(svg), {
            headers: {
                "Content-Type": "text/html"
            }
        })
    })

Bun.serve({
    idleTimeout: 255,
    fetch: app.fetch
})
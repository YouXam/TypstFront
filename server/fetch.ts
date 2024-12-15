let global_resolve: any = null;

async function recv(): Promise<any> {
    return new Promise((resolve) => {
        global_resolve = resolve;
    })
}

addEventListener('message', async (event) => {
    if (global_resolve) global_resolve(event.data);
})

;(async function () {
    const { lengthSab, url } = await recv();
    const int32Length = new Int32Array(lengthSab);
    const res = await fetch(url);
    const arrayBuffer = await res.arrayBuffer()
    const data = new Uint8Array(arrayBuffer);
    Atomics.store(int32Length, 0, data.length);
    Atomics.notify(int32Length, 0, 1);

    const { bodySab, bodySinal } = await recv();
    const int32Signal = new Int32Array(bodySinal);
    const body = new Uint8Array(bodySab);
    body.set(data);
    Atomics.store(int32Signal, 0, body.length);
    Atomics.notify(int32Signal, 0, 1);
})()

import { $typst, TypstSnippet } from '@myriaddreamin/typst.ts/dist/esm/contrib/snippet.mjs';
import type { WritableAccessModel } from '@myriaddreamin/typst.ts/dist/esm/fs/index.mjs';
import type { FsAccessModel, PackageSpec } from '@myriaddreamin/typst.ts/dist/esm/internal.types.mjs';
import { FetchPackageRegistry } from '@myriaddreamin/typst.ts/dist/esm/main.mjs';
import { readFileSync } from 'node:fs';
import path from 'node:path';

function syncFetchBlock(url: string) {
    const worker = new Worker("./server/fetch.ts");
    const lengthSab = new SharedArrayBuffer(4);
    const int32Length = new Int32Array(lengthSab);
    worker.postMessage({ lengthSab, url });
    Atomics.wait(int32Length, 0, 0);
    const bodySab = new SharedArrayBuffer(int32Length[0]);
    const bodySinal = new SharedArrayBuffer(4);
    worker.postMessage({ bodySab, bodySinal });
    const int32Signal = new Int32Array(bodySinal);
    Atomics.wait(int32Signal, 0, 0);
    const data = new Uint8Array(bodySab);
    worker.terminate();
    return data;
}

class AccessModel implements FsAccessModel, WritableAccessModel {
    files: Map<string, Uint8Array> = new Map();
    getMTime(path: string): Date | undefined {
        return new Date();
    }
    removeFile(path: string): void {
        this.files.delete(path);
    }
    isFile(): boolean | undefined {
        return true;
    }
    getRealPath(path: string): string | undefined {
        return undefined;
    }
    readAll(filepath: string): Uint8Array | undefined {
        if (this.files.has(filepath)) {
            return this.files.get(filepath);
        }
        const data = new Uint8Array(readFileSync(path.join("./typst", filepath.replace(/^\/tmp/g, ""))));
        if (process.env.ENV !== "dev") {
            this.files.set(filepath, data);
        }
        return data;
    }
    insertFile(path: string, data: Uint8Array, mtime: Date): void {
        this.files.set(path, data);
    }
}

class BunFetchPackageRegistry extends FetchPackageRegistry {
    constructor(
        am: WritableAccessModel
    ) {
        super(am);
    }
    pullPackageData(path: PackageSpec): Uint8Array | undefined {
        const url = this.resolvePath(path)
        return syncFetchBlock(url);
    }
}

const accessModel = new AccessModel();
$typst.use(TypstSnippet.withAccessModel(accessModel));
$typst.use(TypstSnippet.withPackageRegistry(new BunFetchPackageRegistry(accessModel)))

export default $typst
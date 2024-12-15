export class TempMap<K, V> extends Map<K, V> {
  private readonly TTL: number = 12 * 60 * 60 * 1000;
  private timestamps: Map<K, number> = new Map();

  constructor() {
    super();
    setInterval(() => this.cleanExpired(), 60 * 60 * 1000);
  }

  set(key: K, value: V): this {
    super.set(key, value);
    this.timestamps.set(key, Date.now());
    return this;
  }

  get(key: K): V | undefined {
    const entry = super.get(key);
    if (entry !== undefined && this.isExpired(key)) {
      this.delete(key);
      return undefined;
    }
    return entry;
  }

  delete(key: K): boolean {
    this.timestamps.delete(key);
    return super.delete(key);
  }

  clear(): void {
    super.clear();
    this.timestamps.clear();
  }

  private cleanExpired() {
    for (const key of this.timestamps.keys()) {
      if (this.isExpired(key)) {
        this.delete(key);
      }
    }
  }

  private isExpired(key: K): boolean {
    const timestamp = this.timestamps.get(key);
    if (timestamp && Date.now() - timestamp > this.TTL) {
      return true;
    }
    return false;
  }
}

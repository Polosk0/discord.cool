interface RateLimitEntry {
  count: number;
  resetAt: number;
}

class RateLimiter {
  private limits: Map<string, RateLimitEntry> = new Map();

  private getKey(userId: string, command: string): string {
    return `${userId}:${command}`;
  }

  isAllowed(userId: string, command: string, maxRequests: number = 10, windowMs: number = 60000): boolean {
    const key = this.getKey(userId, command);
    const now = Date.now();
    const entry = this.limits.get(key);

    if (!entry || now > entry.resetAt) {
      this.limits.set(key, {
        count: 1,
        resetAt: now + windowMs,
      });
      return true;
    }

    if (entry.count >= maxRequests) {
      return false;
    }

    entry.count++;
    return true;
  }

  reset(userId: string, command: string): void {
    const key = this.getKey(userId, command);
    this.limits.delete(key);
  }

  clear(): void {
    this.limits.clear();
  }
}

export const rateLimiter = new RateLimiter();


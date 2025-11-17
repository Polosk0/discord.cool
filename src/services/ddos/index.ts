import { AttackConfig } from '../../types';
import { httpFloodService } from './http-flood';
import { tcpFloodService } from './tcp-flood';

export class DDoSService {
  async start(config: AttackConfig): Promise<void> {
    switch (config.method) {
      case 'http-flood':
        await httpFloodService.start(config);
        break;
      case 'tcp-flood':
        await tcpFloodService.start(config);
        break;
      default:
        throw new Error(`Unsupported DDoS method: ${config.method}`);
    }
  }

  stopAll(): void {
    httpFloodService.stopAll();
    tcpFloodService.stopAll();
  }
}

export const ddosService = new DDoSService();


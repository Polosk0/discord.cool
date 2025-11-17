import { createConnection } from 'net';
import { NetworkScanResult } from '../../types';
import { isValidPort } from '../../utils/validators';

export class PortScanService {
  async scanPort(host: string, port: number, timeout: number = 3000): Promise<boolean> {
    return new Promise((resolve) => {
      if (!isValidPort(port)) {
        resolve(false);
        return;
      }

      const socket = createConnection(port, host);
      let resolved = false;

      const cleanup = () => {
        if (!resolved) {
          resolved = true;
          socket.destroy();
        }
      };

      socket.on('connect', () => {
        cleanup();
        resolve(true);
      });

      socket.on('error', () => {
        cleanup();
        resolve(false);
      });

      socket.setTimeout(timeout, () => {
        cleanup();
        resolve(false);
      });
    });
  }

  async scanPortRange(
    host: string,
    startPort: number,
    endPort: number,
    timeout: number = 3000
  ): Promise<NetworkScanResult> {
    const openPorts: number[] = [];
    const maxConcurrent = 50;
    let currentIndex = startPort;

    const scanNext = async (): Promise<void> => {
      while (currentIndex <= endPort) {
        const port = currentIndex++;
        const isOpen = await this.scanPort(host, port, timeout);
        if (isOpen) {
          openPorts.push(port);
        }
      }
    };

    const promises: Promise<void>[] = [];
    for (let i = 0; i < Math.min(maxConcurrent, endPort - startPort + 1); i++) {
      promises.push(scanNext());
    }

    await Promise.all(promises);

    return {
      host,
      ports: openPorts,
      status: openPorts.length > 0 ? 'open' : 'closed',
    };
  }

  async scanCommonPorts(host: string): Promise<NetworkScanResult> {
    const commonPorts = [21, 22, 23, 25, 53, 80, 110, 143, 443, 3306, 3389, 5432, 8080];
    const openPorts: number[] = [];

    await Promise.all(
      commonPorts.map(async (port) => {
        const isOpen = await this.scanPort(host, port);
        if (isOpen) {
          openPorts.push(port);
        }
      })
    );

    return {
      host,
      ports: openPorts,
      status: openPorts.length > 0 ? 'open' : 'closed',
    };
  }
}

export const portScanService = new PortScanService();


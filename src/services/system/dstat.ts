import { SystemStats } from '../../types';
import * as os from 'os';

export class DstatService {
  private statsHistory: SystemStats[] = [];

  getStats(): SystemStats {
    const cpus = os.cpus();
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;

    const networkInterfaces = os.networkInterfaces();
    let received = 0;
    let sent = 0;

    Object.values(networkInterfaces).forEach((interfaces) => {
      interfaces?.forEach((iface) => {
        if (iface.internal === false) {
          received += parseInt(iface.address.split('.').join(''), 10) || 0;
          sent += parseInt(iface.address.split('.').join(''), 10) || 0;
        }
      });
    });

    const stats: SystemStats = {
      cpu: {
        usage: this.calculateCpuUsage(),
        cores: cpus.length,
      },
      memory: {
        used: usedMem,
        total: totalMem,
        percentage: (usedMem / totalMem) * 100,
      },
      network: {
        received,
        sent,
      },
      disk: {
        used: 0,
        total: 0,
        percentage: 0,
      },
    };

    this.statsHistory.push(stats);
    if (this.statsHistory.length > 100) {
      this.statsHistory.shift();
    }

    return stats;
  }

  private calculateCpuUsage(): number {
    const cpus = os.cpus();
    let totalIdle = 0;
    let totalTick = 0;

    cpus.forEach((cpu) => {
      for (const type in cpu.times) {
        totalTick += cpu.times[type as keyof typeof cpu.times];
      }
      totalIdle += cpu.times.idle;
    });

    return 100 - (totalIdle / totalTick) * 100;
  }

  getHistory(): SystemStats[] {
    return [...this.statsHistory];
  }

  formatBytes(bytes: number): string {
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes === 0) return '0 B';
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
  }
}

export const dstatService = new DstatService();


import { SystemStats } from '../../types';
import * as os from 'os';
import { execSync } from 'child_process';

export class DstatService {
  private statsHistory: SystemStats[] = [];
  private lastCpuUsage = 0;
  private lastCpuTime = { idle: 0, total: 0 };

  getStats(): SystemStats {
    const cpus = os.cpus();
    const totalMem = os.totalmem();
    const freeMem = os.freemem();
    const usedMem = totalMem - freeMem;

    const cpuUsage = this.calculateCpuUsage();
    
    let diskUsed = 0;
    let diskTotal = 0;
    let diskPercentage = 0;

    try {
      if (process.platform === 'win32') {
        const result = execSync('wmic logicaldisk get size,freespace,caption', { encoding: 'utf-8' });
        const lines = result.split('\n').filter((line) => line.trim() && !line.includes('Caption'));
        if (lines.length > 0) {
          const parts = lines[0].trim().split(/\s+/);
          if (parts.length >= 2) {
            const free = parseInt(parts[0], 10);
            const total = parseInt(parts[1], 10);
            if (!isNaN(free) && !isNaN(total)) {
              diskTotal = total;
              diskUsed = total - free;
              diskPercentage = (diskUsed / total) * 100;
            }
          }
        }
      } else {
        const result = execSync("df -B1 / | tail -n 1 | awk '{print $2,$3}'", { encoding: 'utf-8' });
        const parts = result.trim().split(/\s+/);
        if (parts.length >= 2) {
          diskTotal = parseInt(parts[0], 10);
          diskUsed = parseInt(parts[1], 10);
          if (!isNaN(diskTotal) && !isNaN(diskUsed)) {
            diskPercentage = (diskUsed / diskTotal) * 100;
          }
        }
      }
    } catch {
    }

    const stats: SystemStats = {
      cpu: {
        usage: cpuUsage,
        cores: cpus.length,
      },
      memory: {
        used: usedMem,
        total: totalMem,
        percentage: (usedMem / totalMem) * 100,
      },
      network: {
        received: 0,
        sent: 0,
      },
      disk: {
        used: diskUsed,
        total: diskTotal,
        percentage: diskPercentage,
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

    if (this.lastCpuTime.total === 0) {
      this.lastCpuTime = { idle: totalIdle, total: totalTick };
      return 0;
    }

    const idle = totalIdle - this.lastCpuTime.idle;
    const total = totalTick - this.lastCpuTime.total;
    const usage = 100 - (idle / total) * 100;

    this.lastCpuTime = { idle: totalIdle, total: totalTick };

    return Math.max(0, Math.min(100, usage));
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


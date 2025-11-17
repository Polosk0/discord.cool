import { exec } from 'child_process';
import { promisify } from 'util';
import { logger } from '../../utils/logger';

const execAsync = promisify(exec);

export interface PingStats {
  packetsSent: number;
  packetsReceived: number;
  packetLoss: number;
  minLatency: number;
  maxLatency: number;
  avgLatency: number;
  currentLatency?: number;
  lastUpdate: Date;
}

export interface PingResult {
  success: boolean;
  latency?: number;
  error?: string;
}

export class LivePingService {
  private pingProcesses: Map<string, any> = new Map();
  private pingStats: Map<string, PingStats> = new Map();

  async startLivePing(host: string, userId: string): Promise<void> {
    const key = `${userId}_${host}`;
    
    if (this.pingProcesses.has(key)) {
      throw new Error('Ping already running for this host');
    }

    const stats: PingStats = {
      packetsSent: 0,
      packetsReceived: 0,
      packetLoss: 0,
      minLatency: Infinity,
      maxLatency: 0,
      avgLatency: 0,
      lastUpdate: new Date(),
    };

    this.pingStats.set(key, stats);

    const command = process.platform === 'win32' 
      ? `ping -t ${host}`
      : `ping -i 1 ${host}`;

    const pingProcess = exec(command, (error, stdout, stderr) => {
      if (error && error.code !== 1) {
        logger.error(`Ping process error for ${host}:`, error);
      }
    });

    let buffer = '';
    
    pingProcess.stdout?.on('data', (data: string) => {
      buffer += data;
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        this.parsePingLine(line, stats, host);
      }
    });

    pingProcess.stderr?.on('data', (data: string) => {
      logger.warn(`Ping stderr for ${host}:`, data);
    });

    pingProcess.on('exit', () => {
      this.pingProcesses.delete(key);
      this.pingStats.delete(key);
    });

    this.pingProcesses.set(key, pingProcess);
    logger.info(`Started live ping for ${host} (user: ${userId})`);
  }

  private parsePingLine(line: string, stats: PingStats, host: string): void {
    if (process.platform === 'win32') {
      const timeMatch = line.match(/time[<=](\d+(?:\.\d+)?)\s*ms/i);
      if (timeMatch) {
        const latency = parseFloat(timeMatch[1]);
        stats.packetsSent++;
        stats.packetsReceived++;
        stats.currentLatency = latency;
        
        if (latency < stats.minLatency) stats.minLatency = latency;
        if (latency > stats.maxLatency) stats.maxLatency = latency;
        
        const totalLatency = stats.avgLatency * (stats.packetsReceived - 1) + latency;
        stats.avgLatency = totalLatency / stats.packetsReceived;
        
        stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        stats.lastUpdate = new Date();
      } else if (line.includes('Request timed out') || line.includes('Destination host unreachable')) {
        stats.packetsSent++;
        stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        stats.lastUpdate = new Date();
      }
    } else {
      const timeMatch = line.match(/time=(\d+(?:\.\d+)?)\s*ms/i);
      if (timeMatch) {
        const latency = parseFloat(timeMatch[1]);
        stats.packetsSent++;
        stats.packetsReceived++;
        stats.currentLatency = latency;
        
        if (latency < stats.minLatency) stats.minLatency = latency;
        if (latency > stats.maxLatency) stats.maxLatency = latency;
        
        const totalLatency = stats.avgLatency * (stats.packetsReceived - 1) + latency;
        stats.avgLatency = totalLatency / stats.packetsReceived;
        
        stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        stats.lastUpdate = new Date();
      } else if (line.includes('100% packet loss') || line.includes('Network is unreachable')) {
        stats.packetsSent++;
        stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        stats.lastUpdate = new Date();
      }
    }
  }

  getStats(userId: string, host: string): PingStats | null {
    const key = `${userId}_${host}`;
    return this.pingStats.get(key) || null;
  }

  stopPing(userId: string, host: string): boolean {
    const key = `${userId}_${host}`;
    const process = this.pingProcesses.get(key);
    
    if (process) {
      if (process.platform === 'win32') {
        process.kill();
      } else {
        process.kill('SIGTERM');
      }
      this.pingProcesses.delete(key);
      this.pingStats.delete(key);
      logger.info(`Stopped live ping for ${host} (user: ${userId})`);
      return true;
    }
    
    return false;
  }

  async singlePing(host: string, count: number = 4): Promise<PingResult> {
    try {
      const command = process.platform === 'win32' 
        ? `ping -n ${count} ${host}`
        : `ping -c ${count} ${host}`;

      const { stdout, stderr } = await execAsync(command, { timeout: 10000 });

      if (stderr) {
        return {
          success: false,
          error: stderr,
        };
      }

      const latencyMatch = stdout.match(/time[<=](\d+(?:\.\d+)?)\s*ms/i) || stdout.match(/time=(\d+(?:\.\d+)?)\s*ms/i);
      const packetLossMatch = stdout.match(/(\d+(?:\.\d+)?)%\s*(?:packet\s*)?loss/i);

      return {
        success: true,
        latency: latencyMatch ? parseFloat(latencyMatch[1]) : undefined,
      };
    } catch (error: any) {
      return {
        success: false,
        error: error.message || 'Unknown error',
      };
    }
  }
}

export const livePingService = new LivePingService();


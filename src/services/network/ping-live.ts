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

    if (!pingProcess.stdout) {
      throw new Error('Failed to start ping process');
    }

    let buffer = '';
    
    pingProcess.stdout.on('data', (data: string) => {
      buffer += data;
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        if (line.trim()) {
          this.parsePingLine(line, stats, host);
        }
      }
    });

    pingProcess.stderr?.on('data', (data: string) => {
      const errorLine = data.toString().trim();
      if (errorLine && !errorLine.includes('PING')) {
        logger.warn(`Ping stderr for ${host}:`, errorLine);
      }
    });

    pingProcess.on('exit', (code) => {
      logger.info(`Ping process exited for ${host} with code ${code}`);
      this.pingProcesses.delete(key);
      setTimeout(() => {
        this.pingStats.delete(key);
      }, 5000);
    });

    pingProcess.on('error', (error) => {
      logger.error(`Ping process error for ${host}:`, error);
      this.pingProcesses.delete(key);
      this.pingStats.delete(key);
    });

    this.pingProcesses.set(key, pingProcess);
    logger.info(`Started live ping for ${host} (user: ${userId})`);
  }

  private parsePingLine(line: string, stats: PingStats, host: string): void {
    const trimmedLine = line.trim();
    if (!trimmedLine) return;

    if (process.platform === 'win32') {
      const timeMatch = trimmedLine.match(/time[<=](\d+(?:\.\d+)?)\s*ms/i);
      if (timeMatch) {
        const latency = parseFloat(timeMatch[1]);
        stats.packetsSent++;
        stats.packetsReceived++;
        stats.currentLatency = latency;
        
        if (latency < stats.minLatency || stats.minLatency === Infinity) {
          stats.minLatency = latency;
        }
        if (latency > stats.maxLatency) {
          stats.maxLatency = latency;
        }
        
        if (stats.packetsReceived === 1) {
          stats.avgLatency = latency;
        } else {
          const totalLatency = stats.avgLatency * (stats.packetsReceived - 1) + latency;
          stats.avgLatency = totalLatency / stats.packetsReceived;
        }
        
        if (stats.packetsSent > 0) {
          stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        }
        stats.lastUpdate = new Date();
      } else if (trimmedLine.includes('Request timed out') || 
                 trimmedLine.includes('Destination host unreachable') ||
                 trimmedLine.includes('General failure')) {
        stats.packetsSent++;
        if (stats.packetsSent > 0) {
          stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        }
        stats.lastUpdate = new Date();
      }
    } else {
      const timeMatch = trimmedLine.match(/time=(\d+(?:\.\d+)?)\s*ms/i);
      if (timeMatch) {
        const latency = parseFloat(timeMatch[1]);
        stats.packetsSent++;
        stats.packetsReceived++;
        stats.currentLatency = latency;
        
        if (latency < stats.minLatency || stats.minLatency === Infinity) {
          stats.minLatency = latency;
        }
        if (latency > stats.maxLatency) {
          stats.maxLatency = latency;
        }
        
        if (stats.packetsReceived === 1) {
          stats.avgLatency = latency;
        } else {
          const totalLatency = stats.avgLatency * (stats.packetsReceived - 1) + latency;
          stats.avgLatency = totalLatency / stats.packetsReceived;
        }
        
        if (stats.packetsSent > 0) {
          stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        }
        stats.lastUpdate = new Date();
      } else if (trimmedLine.includes('100% packet loss') || 
                 trimmedLine.includes('Network is unreachable') ||
                 trimmedLine.includes('Name or service not known')) {
        stats.packetsSent++;
        if (stats.packetsSent > 0) {
          stats.packetLoss = ((stats.packetsSent - stats.packetsReceived) / stats.packetsSent) * 100;
        }
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
    const pingProcess = this.pingProcesses.get(key);
    
    if (pingProcess) {
      try {
        if (process.platform === 'win32') {
          exec(`taskkill /F /T /PID ${pingProcess.pid}`, () => {});
        } else {
          pingProcess.kill('SIGTERM');
        }
      } catch (error) {
        logger.error(`Error stopping ping process:`, error);
      }
      
      this.pingProcesses.delete(key);
      setTimeout(() => {
        this.pingStats.delete(key);
      }, 1000);
      
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


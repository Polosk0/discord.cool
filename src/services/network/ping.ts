import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export interface PingResult {
  host: string;
  success: boolean;
  latency?: number;
  packetLoss?: number;
  error?: string;
}

export class PingService {
  async ping(host: string, count: number = 4): Promise<PingResult> {
    try {
      const command = process.platform === 'win32' 
        ? `ping -n ${count} ${host}`
        : `ping -c ${count} ${host}`;

      const { stdout, stderr } = await execAsync(command, { timeout: 10000 });

      if (stderr) {
        return {
          host,
          success: false,
          error: stderr,
        };
      }

      const latencyMatch = stdout.match(/time[<=](\d+(?:\.\d+)?)\s*ms/i);
      const packetLossMatch = stdout.match(/(\d+(?:\.\d+)?)%\s*(?:packet\s*)?loss/i);

      return {
        host,
        success: true,
        latency: latencyMatch ? parseFloat(latencyMatch[1]) : undefined,
        packetLoss: packetLossMatch ? parseFloat(packetLossMatch[1]) : undefined,
      };
    } catch (error: any) {
      return {
        host,
        success: false,
        error: error.message || 'Unknown error',
      };
    }
  }
}

export const pingService = new PingService();


import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

export interface TracerouteResult {
  host: string;
  hops: Array<{
    hop: number;
    ip?: string;
    hostname?: string;
    latency?: number;
  }>;
  success: boolean;
  error?: string;
}

export class TracerouteService {
  async trace(host: string, maxHops: number = 30): Promise<TracerouteResult> {
    try {
      const command = process.platform === 'win32'
        ? `tracert -h ${maxHops} ${host}`
        : `traceroute -m ${maxHops} ${host}`;

      const { stdout, stderr } = await execAsync(command, { timeout: 30000 });

      if (stderr) {
        return {
          host,
          hops: [],
          success: false,
          error: stderr,
        };
      }

      const hops: TracerouteResult['hops'] = [];
      const lines = stdout.split('\n');

      for (const line of lines) {
        const hopMatch = line.match(/(\d+)\s+([^\s]+)\s+\(?([^)]+)?\)?\s+(\d+(?:\.\d+)?)\s*ms/i);
        if (hopMatch) {
          hops.push({
            hop: parseInt(hopMatch[1], 10),
            hostname: hopMatch[2],
            ip: hopMatch[3] || hopMatch[2],
            latency: parseFloat(hopMatch[4]),
          });
        }
      }

      return {
        host,
        hops,
        success: true,
      };
    } catch (error: any) {
      return {
        host,
        hops: [],
        success: false,
        error: error.message || 'Unknown error',
      };
    }
  }
}

export const tracerouteService = new TracerouteService();


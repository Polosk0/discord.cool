import { lookup } from 'dns';
import { promisify } from 'util';

const lookupAsync = promisify(lookup);

export interface DnsLookupResult {
  hostname: string;
  addresses: string[];
  success: boolean;
  error?: string;
}

export class DnsLookupService {
  async lookup(hostname: string): Promise<DnsLookupResult> {
    try {
      const result = await lookupAsync(hostname, { all: true });
      const addresses = Array.isArray(result) 
        ? result.map((r) => r.address)
        : [result.address];

      return {
        hostname,
        addresses,
        success: true,
      };
    } catch (error: any) {
      return {
        hostname,
        addresses: [],
        success: false,
        error: error.message || 'DNS lookup failed',
      };
    }
  }

  async reverseLookup(ip: string): Promise<DnsLookupResult> {
    try {
      const result = await lookupAsync(ip);
      return {
        hostname: result.hostname || ip,
        addresses: [ip],
        success: true,
      };
    } catch (error: any) {
      return {
        hostname: ip,
        addresses: [],
        success: false,
        error: error.message || 'Reverse DNS lookup failed',
      };
    }
  }
}

export const dnsLookupService = new DnsLookupService();


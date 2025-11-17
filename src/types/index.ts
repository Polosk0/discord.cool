export type CommandCategory = 
  | 'ddos'
  | 'network'
  | 'system'
  | 'utility'
  | 'admin';

export type DDoSMethod = 
  | 'http-flood'
  | 'tcp-flood'
  | 'udp-flood'
  | 'slowloris'
  | 'syn-flood';

export type NetworkTool = 
  | 'ping'
  | 'traceroute'
  | 'nmap'
  | 'whois'
  | 'dns-lookup'
  | 'port-scan';

export interface CommandContext {
  userId: string;
  channelId: string;
  guildId: string | null;
  isAdmin: boolean;
}

export interface AttackConfig {
  target: string;
  method: DDoSMethod;
  duration: number;
  threads: number;
  port?: number;
}

export interface NetworkScanResult {
  host: string;
  ports: number[];
  status: 'open' | 'closed' | 'filtered';
  service?: string;
}

export interface SystemStats {
  cpu: {
    usage: number;
    cores: number;
  };
  memory: {
    used: number;
    total: number;
    percentage: number;
  };
  network: {
    received: number;
    sent: number;
  };
  disk: {
    used: number;
    total: number;
    percentage: number;
  };
}


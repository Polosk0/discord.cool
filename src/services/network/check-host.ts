import { logger } from '../../utils/logger';

interface CheckHostNode {
  node: string;
  location: string;
  status: 'OK' | 'ERROR' | 'PENDING';
  rtt?: number;
  error?: string;
}

interface CheckHostResult {
  requestId: string;
  nodes: CheckHostNode[];
  completed: boolean;
}

export class CheckHostService {
  private readonly apiBase = 'https://check-host.net';

  async startPingCheck(host: string, maxNodes: number = 5): Promise<string> {
    try {
      const url = `${this.apiBase}/check-ping?host=${encodeURIComponent(host)}&max_nodes=${maxNodes}`;
      
      logger.info(`Starting ping check for ${host} with ${maxNodes} nodes`);
      
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000);
      
      try {
        const response = await fetch(url, {
          method: 'GET',
          headers: {
            'Accept': 'application/json',
          },
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          const errorText = await response.text().catch(() => 'Unknown error');
          logger.error(`HTTP error! status: ${response.status}, body: ${errorText.substring(0, 200)}`);
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json() as { request_id?: string };
        
        logger.debug(`API response:`, JSON.stringify(data));
        
        if (!data.request_id) {
          logger.error('No request_id in response:', JSON.stringify(data));
          throw new Error('No request_id in response');
        }

        logger.info(`Started ping check for ${host}, request_id: ${data.request_id}`);
        return data.request_id;
      } catch (fetchError: any) {
        clearTimeout(timeoutId);
        if (fetchError.name === 'AbortError') {
          throw new Error('Request timeout - check-host.net API is not responding');
        }
        throw fetchError;
      }
    } catch (error: any) {
      logger.error('Failed to start ping check', error);
      throw error;
    }
  }

  async getPingResults(requestId: string): Promise<CheckHostResult> {
    try {
      const url = `${this.apiBase}/check-result/${requestId}`;
      
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        const errorText = await response.text().catch(() => 'Unknown error');
        logger.error(`HTTP error getting results! status: ${response.status}, body: ${errorText}`);
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json() as Record<string, any>;
      
      logger.debug(`Results for ${requestId}:`, JSON.stringify(data).substring(0, 500));
      
      if (!data[requestId]) {
        logger.debug(`No data for request_id ${requestId} yet`);
        return {
          requestId,
          nodes: [],
          completed: false,
        };
      }

      const nodes: CheckHostNode[] = [];
      const results = data[requestId] as Record<string, any>;

      if (!results || typeof results !== 'object') {
        logger.warn(`Invalid results format for ${requestId}:`, typeof results);
        return {
          requestId,
          nodes: [],
          completed: false,
        };
      }

      for (const [nodeId, nodeData] of Object.entries(results)) {
        try {
          if (Array.isArray(nodeData) && nodeData.length > 0) {
            const firstResult = nodeData[0];
            
            if (Array.isArray(firstResult)) {
              if (firstResult[0] === 'OK') {
                nodes.push({
                  node: this.getNodeName(nodeId),
                  location: this.getNodeLocation(nodeId),
                  status: 'OK',
                  rtt: firstResult[1] ? parseFloat(String(firstResult[1])) : undefined,
                });
              } else if (firstResult[0] === 'ERROR') {
                nodes.push({
                  node: this.getNodeName(nodeId),
                  location: this.getNodeLocation(nodeId),
                  status: 'ERROR',
                  error: firstResult[1] ? String(firstResult[1]) : 'Unknown error',
                });
              } else {
                nodes.push({
                  node: this.getNodeName(nodeId),
                  location: this.getNodeLocation(nodeId),
                  status: 'PENDING',
                });
              }
            } else {
              nodes.push({
                node: this.getNodeName(nodeId),
                location: this.getNodeLocation(nodeId),
                status: 'PENDING',
              });
            }
          } else {
            nodes.push({
              node: this.getNodeName(nodeId),
              location: this.getNodeLocation(nodeId),
              status: 'PENDING',
            });
          }
        } catch (nodeError) {
          logger.warn(`Error processing node ${nodeId}:`, nodeError);
          nodes.push({
            node: this.getNodeName(nodeId),
            location: this.getNodeLocation(nodeId),
            status: 'PENDING',
          });
        }
      }

      const completed = nodes.length > 0 && nodes.every((node) => node.status !== 'PENDING');

      logger.debug(`Processed ${nodes.length} nodes, completed: ${completed}`);

      return {
        requestId,
        nodes,
        completed,
      };
    } catch (error: any) {
      logger.error('Failed to get ping results', error);
      throw error;
    }
  }

  private getNodeName(nodeId: string): string {
    const nodeMap: Record<string, string> = {
      'ir1.node.check-host.net': 'Iran 1',
      'ir2.node.check-host.net': 'Iran 2',
      'us1.node.check-host.net': 'USA 1',
      'us2.node.check-host.net': 'USA 2',
      'us3.node.check-host.net': 'USA 3',
      'us4.node.check-host.net': 'USA 4',
      'uk1.node.check-host.net': 'UK 1',
      'uk2.node.check-host.net': 'UK 2',
      'de1.node.check-host.net': 'Germany 1',
      'de2.node.check-host.net': 'Germany 2',
      'de3.node.check-host.net': 'Germany 3',
      'fr1.node.check-host.net': 'France 1',
      'fr2.node.check-host.net': 'France 2',
      'nl1.node.check-host.net': 'Netherlands 1',
      'nl2.node.check-host.net': 'Netherlands 2',
      'ru1.node.check-host.net': 'Russia 1',
      'ru2.node.check-host.net': 'Russia 2',
      'ru3.node.check-host.net': 'Russia 3',
      'ru4.node.check-host.net': 'Russia 4',
      'ru5.node.check-host.net': 'Russia 5',
      'ru6.node.check-host.net': 'Russia 6',
      'ru7.node.check-host.net': 'Russia 7',
      'ru8.node.check-host.net': 'Russia 8',
      'sg1.node.check-host.net': 'Singapore 1',
      'sg2.node.check-host.net': 'Singapore 2',
      'in1.node.check-host.net': 'India 1',
      'in2.node.check-host.net': 'India 2',
      'jp1.node.check-host.net': 'Japan 1',
      'jp2.node.check-host.net': 'Japan 2',
      'kr1.node.check-host.net': 'South Korea 1',
      'au1.node.check-host.net': 'Australia 1',
      'au2.node.check-host.net': 'Australia 2',
      'br1.node.check-host.net': 'Brazil 1',
      'br2.node.check-host.net': 'Brazil 2',
      'ca1.node.check-host.net': 'Canada 1',
      'ca2.node.check-host.net': 'Canada 2',
    };

    return nodeMap[nodeId] || nodeId;
  }

  private getNodeLocation(nodeId: string): string {
    if (nodeId.includes('ir')) return '🇮🇷 Iran';
    if (nodeId.includes('us')) return '🇺🇸 USA';
    if (nodeId.includes('uk')) return '🇬🇧 UK';
    if (nodeId.includes('de')) return '🇩🇪 Germany';
    if (nodeId.includes('fr')) return '🇫🇷 France';
    if (nodeId.includes('nl')) return '🇳🇱 Netherlands';
    if (nodeId.includes('ru')) return '🇷🇺 Russia';
    if (nodeId.includes('sg')) return '🇸🇬 Singapore';
    if (nodeId.includes('in')) return '🇮🇳 India';
    if (nodeId.includes('jp')) return '🇯🇵 Japan';
    if (nodeId.includes('kr')) return '🇰🇷 South Korea';
    if (nodeId.includes('au')) return '🇦🇺 Australia';
    if (nodeId.includes('br')) return '🇧🇷 Brazil';
    if (nodeId.includes('ca')) return '🇨🇦 Canada';
    
    return '🌍 Unknown';
  }
}

export const checkHostService = new CheckHostService();


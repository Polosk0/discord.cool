import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join } from 'path';
import { logger } from '../../utils/logger';

interface License {
  userId: string;
  licenseKey: string;
  createdAt: number;
  expiresAt: number | null;
  permissions: string[];
}

class LicenseService {
  private licensesPath = join(process.cwd(), 'data', 'licenses.json');
  private licenses: Map<string, License> = new Map();

  constructor() {
    this.loadLicenses();
  }

  private loadLicenses(): void {
    try {
      if (!existsSync(this.licensesPath)) {
        const dataDir = join(process.cwd(), 'data');
        if (!existsSync(dataDir)) {
          mkdirSync(dataDir, { recursive: true });
        }
        this.saveLicenses();
        return;
      }

      const data = readFileSync(this.licensesPath, 'utf-8');
      const licensesArray: License[] = JSON.parse(data);
      
      this.licenses.clear();
      licensesArray.forEach((license) => {
        this.licenses.set(license.userId, license);
      });

      logger.info(`Loaded ${this.licenses.size} licenses`);
    } catch (error) {
      logger.error('Failed to load licenses', error as Error);
      this.licenses.clear();
    }
  }

  private saveLicenses(): void {
    try {
      const dataDir = join(process.cwd(), 'data');
      if (!existsSync(dataDir)) {
        mkdirSync(dataDir, { recursive: true });
      }

      const licensesArray = Array.from(this.licenses.values());
      writeFileSync(this.licensesPath, JSON.stringify(licensesArray, null, 2), 'utf-8');
    } catch (error) {
      logger.error('Failed to save licenses', error as Error);
    }
  }

  generateLicenseKey(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let key = '';
    for (let i = 0; i < 16; i++) {
      if (i > 0 && i % 4 === 0) key += '-';
      key += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return key;
  }

  createLicense(userId: string, expiresInDays: number | null = null, permissions: string[] = ['bot', 'attack'], licenseKey?: string): string {
    const key = licenseKey || this.generateLicenseKey();
    const now = Date.now();
    const expiresAt = expiresInDays ? now + expiresInDays * 24 * 60 * 60 * 1000 : null;

    const existingLicense = this.licenses.get(userId);
    if (existingLicense && existingLicense.licenseKey !== key) {
      this.licenses.delete(userId);
    }

    const license: License = {
      userId,
      licenseKey: key,
      createdAt: now,
      expiresAt,
      permissions,
    };

    this.licenses.set(userId, license);
    this.saveLicenses();

    logger.info(`License created for user ${userId}`);
    return key;
  }

  hasLicense(userId: string): boolean {
    const license = this.licenses.get(userId);
    if (!license) return false;

    if (license.expiresAt && Date.now() > license.expiresAt) {
      this.licenses.delete(userId);
      this.saveLicenses();
      return false;
    }

    return true;
  }

  hasPermission(userId: string, permission: string): boolean {
    if (!this.hasLicense(userId)) return false;
    
    const license = this.licenses.get(userId);
    return license?.permissions.includes(permission) || false;
  }

  validateLicenseKey(licenseKey: string): { valid: boolean; userId?: string; license?: License } {
    for (const [userId, license] of this.licenses.entries()) {
      if (license.licenseKey === licenseKey) {
        if (license.expiresAt && Date.now() > license.expiresAt) {
          return { valid: false };
        }
        return { valid: true, userId, license };
      }
    }
    return { valid: false };
  }

  revokeLicense(userId: string): boolean {
    if (this.licenses.delete(userId)) {
      this.saveLicenses();
      logger.info(`License revoked for user ${userId}`);
      return true;
    }
    return false;
  }

  getLicense(userId: string): License | null {
    return this.licenses.get(userId) || null;
  }

  getAllLicenses(): License[] {
    return Array.from(this.licenses.values());
  }
}

export const licenseService = new LicenseService();


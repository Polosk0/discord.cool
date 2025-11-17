import { appendFileSync, mkdirSync, existsSync } from 'fs';
import { join } from 'path';

type LogLevel = 'info' | 'warn' | 'error' | 'debug' | 'success';

class Logger {
  private logDir = 'logs';
  private logFile = join(this.logDir, 'bot.log');

  constructor() {
    if (!existsSync(this.logDir)) {
      mkdirSync(this.logDir, { recursive: true });
    }
  }

  private formatMessage(level: LogLevel, message: string): string {
    const timestamp = new Date().toISOString();
    return `[${timestamp}] [${level.toUpperCase()}] ${message}`;
  }

  private writeToFile(level: LogLevel, message: string, error?: Error): void {
    try {
      const logMessage = this.formatMessage(level, message);
      appendFileSync(this.logFile, logMessage + '\n', 'utf-8');
      
      if (error && error.stack) {
        appendFileSync(this.logFile, error.stack + '\n', 'utf-8');
      }
    } catch (err) {
      console.error('Failed to write to log file:', err);
    }
  }

  info(message: string): void {
    const formatted = this.formatMessage('info', message);
    console.log(formatted);
    this.writeToFile('info', message);
  }

  warn(message: string): void {
    const formatted = this.formatMessage('warn', message);
    console.warn(formatted);
    this.writeToFile('warn', message);
  }

  error(message: string, error?: Error): void {
    const formatted = this.formatMessage('error', message);
    console.error(formatted);
    if (error) {
      console.error(error.stack);
    }
    this.writeToFile('error', message, error);
  }

  debug(message: string): void {
    if (process.env.NODE_ENV === 'development') {
      const formatted = this.formatMessage('debug', message);
      console.debug(formatted);
      this.writeToFile('debug', message);
    }
  }

  success(message: string): void {
    const formatted = this.formatMessage('success', message);
    console.log(formatted);
    this.writeToFile('success', message);
  }
}

export const logger = new Logger();


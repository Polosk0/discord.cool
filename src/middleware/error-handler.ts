import { logger } from '../utils/logger';

export class ErrorHandler {
  static handle(error: Error, context?: string): void {
    const message = context 
      ? `Error in ${context}: ${error.message}`
      : error.message;

    logger.error(message, error);
  }

  static async handleAsync(
    fn: () => Promise<void>,
    context?: string
  ): Promise<void> {
    try {
      await fn();
    } catch (error) {
      this.handle(error as Error, context);
    }
  }
}


import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
const crypto = require('crypto');

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    console.log(this.generatePKCE());
    return this.appService.getHello();
  }

  private generatePKCE() {
    const codeVerifier = crypto.randomBytes(32).toString('hex');
    const codeChallenge = crypto
      .createHash('sha256')
      .update(codeVerifier)
      .digest('base64')
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=+$/, '');
    return { codeVerifier, codeChallenge };
  }
}

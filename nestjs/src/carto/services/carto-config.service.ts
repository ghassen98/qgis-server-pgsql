import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class CartoConfigService {
  constructor(private readonly configService: ConfigService) {}

  get externalServiceUrl(): string {
    return this.configService.get<string>('EXTERNAL_SERVICE_URL') || '';
  }
}
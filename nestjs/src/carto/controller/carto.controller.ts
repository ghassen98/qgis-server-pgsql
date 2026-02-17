import { CartoExternalService } from '@carto/external-services/carto-external.service';
import { mapDesc } from '@carto/mapper/colors-mapper';
import { Body, Controller, Get, Post, BadRequestException } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { Routes } from 'src/constants/routes.constant';

@Controller('carto')
export class cartoController {
  constructor(private readonly cartoExternalService: CartoExternalService) {}

  // Format attendu pour bbox : "minX,minY,maxX,maxY" — ex: "8.46,42.53,11.84,50.98"
  // Vérifie que minX < maxX et minY < maxY avant d'appeler QGIS.

  @Post(Routes.GET_DATA)
  async getData(@Body('bbox') bbox: string, @Body('layername') layername: string): Promise<any> {
    const normalizedBbox = this.validateBbox(bbox);

    if (!layername || typeof layername !== 'string' || !layername.trim()) {
      throw new BadRequestException('layername is required');
    }

    try {
      const response = await this.cartoExternalService.fetchData(normalizedBbox, layername.trim());
      return response['data'];
    } catch (error) {
      return {
        error: 'Failed to fetch data from service',
        details: error?.message ?? String(error),
      };
    }
  }

  private validateBbox(bbox: string): string {
    if (!bbox || typeof bbox !== 'string') {
      throw new BadRequestException('bbox is required and must be a string in format "minX,minY,maxX,maxY"');
    }

    const parts = bbox.split(',').map(p => p.trim());
    if (parts.length !== 4) {
      throw new BadRequestException('bbox must contain 4 comma-separated values: "minX,minY,maxX,maxY"');
    }

    const nums = parts.map(Number);
    if (nums.some(n => Number.isNaN(n))) {
      throw new BadRequestException('bbox contains non-numeric values');
    }

    const [minX, minY, maxX, maxY] = nums;
    if (!(minX < maxX && minY < maxY)) {
      throw new BadRequestException('bbox must follow "minX,minY,maxX,maxY" with minX < maxX and minY < maxY');
    }

    return `${minX},${minY},${maxX},${maxY}`;
  }
}

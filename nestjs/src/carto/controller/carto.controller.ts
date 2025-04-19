import { CartoExternalService } from '@carto/external-services/carto-external.service';
import { mapDesc } from '@carto/mapper/colors-mapper';
import { Body, Controller, Get, Post } from '@nestjs/common';
import { lastValueFrom } from 'rxjs';
import { Routes } from 'src/constants/routes.constant';

@Controller('carto')
export class cartoController {
  constructor(private readonly cartoExternalService: CartoExternalService) {}

  // exemple de bbox :11.84,42.53,8.46,50.98
  // minX=-11.84 : Longitude minimale (à l'ouest, près de l'Espagne ou de l'Atlantique).
  // minY=42.53 : Latitude minimale (sud, proche du sud de la France ou de l'Espagne).
  // maxX=8.46 : Longitude maximale (à l'est, proche de l'Italie ou de la Méditerranée).
  // maxY=50.98 : Latitude maximale (nord, englobant une partie de l'Europe de l'Ouest).

  @Post(Routes.GET_DATA)
  async getData(@Body('bbox') bbox: string, @Body('layername') layername: string): Promise<any> {
    try {
      const response = await this.cartoExternalService.fetchData(bbox, layername)
      return response['data'];
    } catch (error) {
      return {
        error: 'Failed to fetch data from service',
        details: error.message,
      };
    }
  }
}

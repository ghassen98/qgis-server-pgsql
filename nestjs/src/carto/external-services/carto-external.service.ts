import { Injectable, HttpException, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { catchError, retry } from 'rxjs/operators';
import { Observable, throwError } from 'rxjs';
import { CartoConfigService } from '@carto/services/carto-config.service';
import { RetryHttp } from 'src/decorators/httpRetry';

@Injectable()
export class CartoExternalService {
  private readonly logger = new Logger(CartoExternalService.name);

  constructor(
    private readonly httpService: HttpService,
    private readonly cartoConfigService: CartoConfigService,
  ) {}


  @RetryHttp(3)
  fetchData(bbox: string, layername: string): Observable<any> {
    const url = this.cartoConfigService.externalServiceUrl;
    this.logger.log(`Bounding box (bbox): ${bbox}`);
    this.logger.log(`Layer name: ${layername}`);

    if (!url) {
      this.logger.error('External service URL is not configured.');
      throw new Error('External service URL is missing in configuration.');
    }
    if (!bbox) {
      this.logger.error('Bounding box (bbox) parameter is required.');
      throw new Error('Bounding box (bbox) parameter is missing.');
    }
    if (!layername) {
      this.logger.error('Layer name parameter is required.');
      throw new Error('Layer name parameter is missing.');
    }
   
    const fullUrl = `http://nginx/qgis-server?SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=${layername}&outputFormat=application/json&BBOX=${bbox}`;
    this.logger.log(`Fetching data from external service: ${fullUrl}`);

    return this.httpService.get(fullUrl).pipe(
      catchError((error) => {
        this.logger.error(`Error fetching data from external service: ${error.message}`);
        return throwError(() => new HttpException('Failed to fetch data', 500));
      })
    );
    
  }
}

import { Logger, Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { CartoConfigService } from '@carto/services/carto-config.service';
import { CartoExternalService } from '@carto/external-services/carto-external.service';
import { cartoController } from '@carto/controller/carto.controller';


@Module({
  imports: [
    HttpModule.register({
      timeout: 5000,
      maxRedirects: 5,
    }),
  ],
  controllers: [cartoController],
  providers: [CartoExternalService, CartoConfigService, Logger],
  exports: [CartoExternalService],
})
export class CartoModule {}
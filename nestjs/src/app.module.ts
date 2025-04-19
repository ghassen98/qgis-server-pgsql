import { Logger, Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import { CartoModule } from '@carto/carto.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    CartoModule
  ],
  controllers: [AppController],
  providers: [AppService, Logger],
})
export class AppModule {}

import { Injectable, HttpException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { catchError, retry } from 'rxjs/operators';
import { Observable, throwError } from 'rxjs';

/**
 * Retry HTTP Request Decorator
 * @param retryCount - Number of retries
 */
export function RetryHttp(retryCount: number = 3): MethodDecorator {
  return function (target: any, propertyKey: string | symbol, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const httpService: HttpService = this.httpService;

      if (!httpService) {
        throw new Error('HttpService is required to use RetryHttp decorator');
      }

      const request$: Observable<any> = originalMethod.apply(this, args);

      if (!(request$ instanceof Observable)) {
        throw new Error('RetryHttp decorator can only be applied to methods returning Observables');
      }

      return request$
        .pipe(
          retry(retryCount),
          catchError((error) => {
            console.error(`RetryHttp: Request failed after ${retryCount} retries.`);
            return throwError(() => new HttpException(error.response?.data || 'Request failed', error.status || 500));
          }),
        )
        .toPromise();
    };

    return descriptor;
  };
}

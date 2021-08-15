import 'package:dio/dio.dart';

class RetryOnError extends Interceptor{
  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async{
    print(err);
    if(_shouldRetry(err)){
      try{
        print("Retry...");
        schduleRequestRetry(err.requestOptions);
      }catch (e){
        print(e);
      }
    }
    return err;
  }

  bool _shouldRetry(DioError err){
    return err.type == DioErrorType.connectTimeout || err.type == DioErrorType.receiveTimeout;
  }

  Future<Response> schduleRequestRetry(RequestOptions requestOptions) async{
    return Dio().request(requestOptions.path,
      cancelToken: requestOptions.cancelToken,
      data: requestOptions.data,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onReceiveProgress,
      );
  }
}
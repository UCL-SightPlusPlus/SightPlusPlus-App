import 'package:dio/dio.dart';
import 'package:sight_plus_plus/network_server_state.dart';

class RetryOnError extends Interceptor{
  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async{
    print("Error: ");
    print(err);
    if(_shouldRetry(err)){
      try{
        print("Retry...");
        schduleRequestRetry(err.requestOptions);
      }catch (e){
        print(e);
      }
    }else{
      NetworkState.ip = '';
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
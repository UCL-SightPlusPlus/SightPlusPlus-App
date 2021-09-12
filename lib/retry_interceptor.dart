import 'package:dio/dio.dart';
import 'package:sight_plus_plus/bluetooth_beacon_state.dart';
import 'package:sight_plus_plus/network_server_state.dart';

class RetryOnError extends Interceptor{
  //this class is used for the situation that the server is timeout
  //the dio will resend the request to the server

  RetryOnError(this.beaconState);
  BluetoothBeaconState beaconState;

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
    }else if(err.response == null){
      NetworkState.ip = '';
    }
    beaconState.setIsHandling = false;
    beaconState.notifyFromError();
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
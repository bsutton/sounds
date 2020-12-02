import '../platform/sounds_platform_api.dart';

///
extension Responses on Response {
  ///
  static Response success() {
    var response = Response();
    response.success = true;

    return response;
  }

  ///
  static Response onError(int errorCode, String error) {
    var response = Response();
    response.success = false;
    response.errorCode = errorCode;
    response.error = response.error;

    return response;
  }
}

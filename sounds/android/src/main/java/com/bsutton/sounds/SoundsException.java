package com.bsutton.sounds;

public class SoundsException extends Exception{

    long errorCode;
    String error;
    SoundsException(long errorCode, String error)
    {
        this.errorCode = errorCode;
        this.error = error;
    }

    SoundsPlatformApi.Response getResponse()
    {
        SoundsPlatformApi.Response response = new SoundsPlatformApi.Response();
        response.setSuccess(false);
        response.setErrorCode(errorCode);
        response.setError(error);

        return response;
    }
}

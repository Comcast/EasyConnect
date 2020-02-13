package com.easyconnect.easyconnectap.network.retrofit;

import com.easyconnect.easyconnectap.network.model.DPPResponse;
import com.easyconnect.easyconnectap.network.model.DPPUri;
import com.google.gson.JsonObject;


import io.reactivex.Single;
import retrofit2.Call;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;


public interface DPPService {

    @POST("/api/v1/configurator-initiate-dpp")
    Single <DPPResponse> sendDPPUri(@Body JsonObject dppJson);

    @POST("/api/v1/configurator-initiate-dpp")
    Single <DPPResponse> sendDPPUri(@Header("X-Authorization-Token") String token,@Body JsonObject dppJson);

    @POST("/api/v1/configurator-initiate-dpp")
    Single <DPPResponse> sendChallenge(@Header("X-Challenge-Response") String challengeResponse, @Body JsonObject dppJson);

    @POST("/api/v1/configurator-dpp-uri")
    Single <DPPUri> getDPPUrii();

    @POST("/api/v1/configurator-dpp-uri")
    Single <DPPUri> getDPPUrii(@Header("X-Challenge-Response") String challengeResponse);
}

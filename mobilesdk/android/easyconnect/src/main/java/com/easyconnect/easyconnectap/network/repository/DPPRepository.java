package com.easyconnect.easyconnectap.network.repository;

import com.easyconnect.easyconnectap.network.model.DPPResponse;
import com.easyconnect.easyconnectap.network.model.DPPUri;
import com.google.gson.JsonObject;

import io.reactivex.Single;


public interface DPPRepository {

    Single<DPPResponse> getDPPResponse(JsonObject dppJson);

    Single<DPPResponse> getDPPResponse(String token,JsonObject dppJson);

    Single<DPPResponse> sendChallengeResponse(String challengeResponse,JsonObject dppJson);

    Single<DPPUri> getDPPUri();
    Single<DPPUri> getDPPUri(String challengeResponse);
 }

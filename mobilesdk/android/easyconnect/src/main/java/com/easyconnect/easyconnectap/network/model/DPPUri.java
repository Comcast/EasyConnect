package com.easyconnect.easyconnectap.network.model;

import androidx.annotation.Nullable;

import com.google.gson.annotations.SerializedName;
/**
 * POJO Class for getting DPP URI
 */
public class DPPUri {

    @SerializedName("status")
    private String status;
    @SerializedName("message")
    private String message;

    @Nullable
    @SerializedName("dpp_uri")
    private String dpp_uri;


    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDpp_uri() {
        return dpp_uri;
    }

    public void setDpp_uri(String dpp_uri) {
        this.dpp_uri = dpp_uri;
    }
}

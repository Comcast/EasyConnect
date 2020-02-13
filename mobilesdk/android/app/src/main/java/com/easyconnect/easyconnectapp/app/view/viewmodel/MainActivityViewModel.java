package com.easyconnect.easyconnectapp.app.view.viewmodel;

import android.app.Activity;
import android.app.Application;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;

import com.easyconnect.easyconnectap.instance.ProviderInstance;
import com.easyconnect.easyconnectap.network.model.DPPResponse;
import com.easyconnect.easyconnectap.network.model.DPPUri;
import com.easyconnect.easyconnectap.network.repository.DPPRepository;
import com.easyconnect.easyconnectap.util.RuntimePermissionHelper;
import com.easyconnect.easyconnectap.util.SharedPrefsUtils;
import com.easyconnect.easyconnectapp.app.R;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import retrofit2.HttpException;

import static androidx.constraintlayout.widget.Constraints.TAG;

public class MainActivityViewModel extends AndroidViewModel {

    private DPPRepository dppRepository = null;

    public MainActivityViewModel(@NonNull Application application) {
        super(application);
    }

    public DPPRepository getDppRepository() {

        try {
            String dnsIp = SharedPrefsUtils.getInstance().getStringPreference(getApplication(), getApplication().getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_ip));
            Integer dnsPort = SharedPrefsUtils.getInstance().getIntegerPreference(getApplication(), getApplication().getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_port), 00);

            String URL = getApplication().getResources().getString(R.string.http) + dnsIp + ":" + dnsPort + "/";

            Log.d("URL", URL);

            if (dnsIp != null) {

                dppRepository = ProviderInstance.getProvider().getDPPRepository(URL);

                return dppRepository;

            } else {

                Toast.makeText(getApplication(), "Unable to find MDNS Configurator, Select MDNS Configurator.", Toast.LENGTH_SHORT).show();
            }

        } catch (Exception e) {
            e.printStackTrace();

            Log.d(TAG, "DPPResponse body " + e.getMessage());

            Toast.makeText(getApplication(), "Unable to send to server, Please try again", Toast.LENGTH_SHORT).show();
        }

        return dppRepository;
    }

    public DPPResponse parseErrorResponse(HttpException httpException) {

        try {
            //To get status code
            httpException.code();

            Gson gson = new Gson();
            Type type = new TypeToken<HttpException>() {
            }.getType();
            HttpException errorResponse = gson.fromJson(httpException.response().errorBody().charStream(), type);
            String message = errorResponse.message();

            return getDppResponse(httpException.code(),message);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public DPPUri parseDPPErrorResponse(HttpException httpException) {

        try {
            //To get the status code
            httpException.code();
            Gson gson = new Gson();
            Type type = new TypeToken<HttpException>() {
            }.getType();
            HttpException errorResponse = gson.fromJson(httpException.response().errorBody().charStream(), type);
            String message = errorResponse.message();

           return getDppUri(httpException.code(),message);

        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

    public DPPResponse getDppResponse(int status,String message){

        //Creating DPPResponse object to set response details
        DPPResponse dppResponse = new DPPResponse();
        dppResponse.setStatus(String.valueOf(status));
        dppResponse.setMessage(message);
        dppResponse.setToken(null);

        SharedPrefsUtils.getInstance().setTokenPreference(getApplication(), getApplication().getResources().getString(R.string.token), null);

        return dppResponse;
    }

    public DPPUri getDppUri(int status,String message){

        DPPUri dppUri = new DPPUri();
        dppUri.setStatus(String.valueOf(status));
        dppUri.setMessage(message);
        dppUri.setDpp_uri(null);

        SharedPrefsUtils.getInstance().setStringPreference(getApplication(), getApplication().getResources().getString(R.string.dpp_for_qrcode), null);

        return dppUri;
    }
}

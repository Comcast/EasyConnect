package com.easyconnect.easyconnectap.network;

import android.util.Log;

import com.easyconnect.easyconnectap.instance.ProviderInstance;
import com.easyconnect.easyconnectap.network.repository.DPPRepository;
import com.easyconnect.easyconnectap.network.repositoryImpl.DPPRepositoryImpl;
import com.easyconnect.easyconnectap.network.retrofit.DPPService;
import com.easyconnect.easyconnectap.util.HttpTimeOut;
import com.easyconnect.easyconnectapp.BuildConfig;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory;
import retrofit2.converter.gson.GsonConverterFactory;

/*
 * This Provider Class will provide the all repository objects.
 * To call the rest apis
 *
 * @param context
 */


public class Provider {
    private volatile Retrofit retrofitInstance;

    private volatile OkHttpClient okHttpClient;
    private volatile DPPRepository dppRepository;


    public Retrofit getRetrofitInstance(String URL) {
        Retrofit result = retrofitInstance;
        Log.e("getRetrofitInstance","getRetrofitInstance creation");

        try {
            if (result == null) {
                synchronized (this) {
                    result = retrofitInstance;
                    if (result == null) {
                        Retrofit.Builder retrofit = new Retrofit.Builder().client(getOkHttpClient())
                                .baseUrl(URL)
                                .addConverterFactory(GsonConverterFactory.create())
                                .addCallAdapterFactory(RxJava2CallAdapterFactory.create());
                        retrofitInstance = result = retrofit.build();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    public synchronized OkHttpClient getOkHttpClient() {
        Log.e("getOkHttpClient","getRetrofitInstance getOkHttpClient creation");
        try {
            if (okHttpClient == null) {
                HttpLoggingInterceptor logging = new HttpLoggingInterceptor();

                if (BuildConfig.DEBUG) {
                    logging.setLevel(HttpLoggingInterceptor.Level.BODY);
                } else {
                    logging.setLevel(HttpLoggingInterceptor.Level.NONE);
                }

                OkHttpClient.Builder builder = new OkHttpClient.Builder()
                        .connectTimeout(HttpTimeOut.CONNECTION_TIME_OUT, TimeUnit.SECONDS)
                        .readTimeout(HttpTimeOut.READ_TIME_OUT, TimeUnit.SECONDS)
                        .writeTimeout(HttpTimeOut.WRITE_TIME_OUT, TimeUnit.SECONDS)
                        .addInterceptor(logging)
                        .addInterceptor
                        (new Interceptor() {
                            @Override
                            public Response intercept(Chain chain) throws IOException {

                                Request originalRequest = chain.request();

                                Request newRequest = originalRequest.newBuilder()
                                        .header("Accept","application/json")
                                        .header("Content-Type","application/json")
                                        .header("Cache-Control","no-cache")
                                        .build();
                                return chain.proceed(newRequest);
                            }
                        });

                okHttpClient = builder.build();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return okHttpClient;
    }


     // Get the DppRepository object
    public DPPRepository getDPPRepository(String url){
        DPPRepository result = dppRepository;
        if (result == null) {
            synchronized (this) {
                result = dppRepository;
                if (result == null) {
                    try {
                        dppRepository = result = new DPPRepositoryImpl(ProviderInstance.getProvider().getRetrofitInstance(url).create(DPPService.class));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return result;
    }
}

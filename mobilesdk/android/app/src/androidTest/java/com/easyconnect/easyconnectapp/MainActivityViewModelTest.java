package com.easyconnect.easyconnectapp;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;
import android.util.Log;

import androidx.test.InstrumentationRegistry;
import androidx.test.rule.ActivityTestRule;

import com.easyconnect.easyconnectap.network.model.DPPResponse;
import com.easyconnect.easyconnectap.network.model.DPPUri;
import com.easyconnect.easyconnectapp.app.view.MainActivity;
import com.easyconnect.easyconnectapp.app.view.viewmodel.MainActivityViewModel;

import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import kotlin.jvm.Throws;
import retrofit2.HttpException;
import retrofit2.Response;
import retrofit2.http.HTTP;

import static org.junit.Assert.*;


public class MainActivityViewModelTest {

    @Rule
    public ActivityTestRule<MainActivity> mainActivityViewModelActivityTestRule = new ActivityTestRule<>(MainActivity.class);
    private Context appContext;
    private MainActivityViewModel mainActivityViewModel;

    @Before
    public void setup() throws Exception {

        appContext= InstrumentationRegistry.getTargetContext();
        mainActivityViewModel =new MainActivityViewModel((Application) appContext.getApplicationContext());
    }

    @Test
    public void parseErrorResponse(){

        DPPResponse dppResponse = mainActivityViewModel.getDppResponse(401,"what is the wifi passphrase");
        assertNotNull(dppResponse);
    }

    @Test
    public void parseDPPErrorResponse(){

        DPPUri dppUri = mainActivityViewModel.getDppUri(400,"Bad Request");
        assertNotNull(dppUri);
    }

    @After
    public void terDown() throws Exception {

        mainActivityViewModel = null;
    }
}

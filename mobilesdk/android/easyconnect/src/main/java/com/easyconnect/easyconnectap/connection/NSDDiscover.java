package com.easyconnect.easyconnectap.connection;

import android.content.Context;
import android.net.nsd.NsdManager;
import android.net.nsd.NsdServiceInfo;
import android.util.Log;

import com.easyconnect.easyconnectap.util.Constants;
import com.easyconnect.easyconnectap.util.SharedPrefsUtils;
import com.easyconnect.easyconnectapp.R;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * NSD Device Discovery implementation
 */
public class NSDDiscover {

    public final String TAG = "TrackingFlow";
    public String mDiscoveryServiceName = "EasyConnectNSDDiscover";
    private NsdManager mNsdManager;

    DISCOVERY_STATUS mCurrentDiscoveryStatus = DISCOVERY_STATUS.OFF;
    private List<NsdServiceInfo> mDNSServiceInfoList = new ArrayList<>();
    private IMDNSDiscovery iMDNSDiscovery;
    private static NSDDiscover nsdDiscover;
    private static NsdManager nsdManager;
    private IConfigurator mIConfigurator;

    Context mContext;
    String mHostFound;
    int mPortFound;

    private enum DISCOVERY_STATUS {
        ON,
        OFF
    }

    /**
     * static method to create instance of NSDDiscover class
     */
    public static NSDDiscover getInstance() {
        if (nsdDiscover == null)
            nsdDiscover = new NSDDiscover();

        return nsdDiscover;
    }

    /**
     * static method to create instance of NsdManager class
     */
    public static NsdManager getNsdManager(Context context) {

        if (nsdManager == null)
            nsdManager = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
        return nsdManager;
    }

    /**
     * To discover MDNS Devices based on the service type
     */
    public void DiscoverMDNSConfigurator(Context context, IMDNSDiscovery imdnsDiscovery) {
        this.mContext = context;
        this.mNsdManager = (NsdManager) context.getSystemService(Context.NSD_SERVICE);
        this.iMDNSDiscovery = imdnsDiscovery;

        mCurrentDiscoveryStatus = DISCOVERY_STATUS.ON;
        mDNSServiceInfoList = new ArrayList<>();

        mNsdManager.discoverServices(Constants.SERVICE_TYPE, NsdManager.PROTOCOL_DNS_SD, mDiscoveryListener);


        try {
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
            Thread.currentThread().interrupt();
        }
        mNsdManager.stopServiceDiscovery(mDiscoveryListener);

    }

    /**
     * Listener for MDNS Discovery
     */
    private NsdManager.DiscoveryListener mDiscoveryListener = new NsdManager.DiscoveryListener() {


        @Override
        public void onDiscoveryStarted(String regType) {
            Log.d(TAG, "Service discovery started");
        }

        @Override
        public void onServiceFound(NsdServiceInfo service) {

            mDNSServiceInfoList.add(service);

            Log.d(TAG, "mDNSServiceInfoList size: " + mDNSServiceInfoList.size());

            Log.d(TAG, "Service discovery success" + service);
            if (!service.getServiceType().equals(Constants.SERVICE_TYPE)) {
                Log.d(TAG, "Unknown Service Type: " + service.getServiceType());
            } else if (service.getServiceName().equals(mDiscoveryServiceName)) {
                Log.d(TAG, "Same machine: " + mDiscoveryServiceName);
            }
        }

        @Override
        public void onServiceLost(NsdServiceInfo service) {
            Log.d(TAG, "service lost" + service);
        }

        @Override
        public void onDiscoveryStopped(String serviceType) {
            Log.d(TAG, "Discovery stopped: " + serviceType);

            iMDNSDiscovery.mDNSConfigList(mDNSServiceInfoList);
        }

        @Override
        public void onStartDiscoveryFailed(String serviceType, int errorCode) {
            Log.d(TAG, "Discovery failed: Error code:" + errorCode);
            mNsdManager.stopServiceDiscovery(this);
        }

        @Override
        public void onStopDiscoveryFailed(String serviceType, int errorCode) {
            Log.d(TAG, "Discovery failed: Error code:" + errorCode);
            mCurrentDiscoveryStatus = DISCOVERY_STATUS.OFF;
            mNsdManager.stopServiceDiscovery(this);
        }
    };

    public void stopServicediscovery(Context context) {

        getNsdManager(context).stopServiceDiscovery(mDiscoveryListener);
    }

    /**
     * Resolve listener for a particular nsdServiceInfo to findout host and port
     */
    public void getResolveListener(Context context, NsdServiceInfo nsdServiceInfo, IConfigurator iConfigurator) {

        mIConfigurator = iConfigurator;

        getNsdManager(context).resolveService(nsdServiceInfo, new NsdManager.ResolveListener() {
            @Override
            public void onResolveFailed(NsdServiceInfo serviceInfo, int errorCode) {
                Log.d(TAG, "Resolve failed" + errorCode);
            }

            @Override
            public void onServiceResolved(NsdServiceInfo serviceInfo) {

                Log.d(TAG, "Resolve Succeeded. " + serviceInfo);

                Log.d(TAG, "Resolve serviceInfo host" + serviceInfo.getHost());
                Log.d(TAG, "Resolve serviceInfo port " + serviceInfo.getPort());

                mIConfigurator.getselectedConfigurator(new Configurator(serviceInfo.getServiceName()
                        , serviceInfo.getHost().toString(), serviceInfo.getPort()));
            }
        });
    }
}

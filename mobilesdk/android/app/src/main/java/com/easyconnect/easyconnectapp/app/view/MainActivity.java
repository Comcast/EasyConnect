package com.easyconnect.easyconnectapp.app.view;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.databinding.DataBindingUtil;
import androidx.fragment.app.FragmentManager;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.net.Uri;
import android.net.nsd.NsdServiceInfo;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.easyconnect.easyconnectap.connection.Configurator;
import com.easyconnect.easyconnectap.connection.IConfigurator;
import com.easyconnect.easyconnectap.network.model.DPPResponse;
import com.easyconnect.easyconnectap.network.model.DPPUri;
import com.easyconnect.easyconnectap.network.repository.DPPRepository;
import com.easyconnect.easyconnectap.scan.IScanResult;
import com.easyconnect.easyconnectap.scan.ScanQRCode;
import com.easyconnect.easyconnectap.util.FileUtils;
import com.easyconnect.easyconnectap.util.RuntimePermissionHelper;
import com.easyconnect.easyconnectap.util.SharedPrefsUtils;
import com.easyconnect.easyconnectapp.BuildConfig;
import com.easyconnect.easyconnectapp.app.R;
import com.easyconnect.easyconnectapp.app.databinding.ActivityMainBinding;
import com.easyconnect.easyconnectap.connection.IMDNSDiscovery;
import com.easyconnect.easyconnectap.connection.NSDDiscover;

import com.easyconnect.easyconnectap.mdns.MDNSDialogFragment;
import com.easyconnect.easyconnectapp.app.view.viewmodel.MainActivityViewModel;
import com.google.gson.JsonObject;

import java.util.ArrayList;
import java.util.List;

import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.observers.DisposableSingleObserver;
import io.reactivex.schedulers.Schedulers;
import me.dm7.barcodescanner.zxing.ZXingScannerView;
import retrofit2.HttpException;

/**
 * * Home View for Easy Connect
 */
public class MainActivity extends AppCompatActivity implements View.OnClickListener, IMDNSDiscovery, IConfigurator, IScanResult {

    private String TAG = "MainActivity";
    private ActivityMainBinding mBinding;
    private Context mContext;
    private LogcatListAdapter logcatListAdapter;
    private boolean scanFlag = true;
    private boolean qrScanFlag = false;
    private List<String> mConsoleList = new ArrayList<>();
    private ZXingScannerView mScannerView;
    private RuntimePermissionHelper runtimePermissionHelper;
    private int count = 0;
    private MainActivityViewModel homeViewModel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG, "onCreate");
        mContext = this;

        mBinding = DataBindingUtil.setContentView(this, R.layout.activity_main);
        mBinding.setHomeactivity(this);

        homeViewModel = ViewModelProviders.of(this).get(MainActivityViewModel.class);

        logcatListAdapter = new LogcatListAdapter(mContext, mConsoleList);
        mBinding.recyclerviewConsole.setLayoutManager(new LinearLayoutManager(mContext));
        mBinding.recyclerviewConsole.setAdapter(logcatListAdapter);

        mScannerView = mBinding.zXingScannerView;

        //updating console with initial message
        updateConsole(this);

        //To start mdns discovery thread
        startMDNSDiscovery();
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.d(TAG, "onStart");
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        Log.d(TAG, "onRestart");
    }

    @Override
    public void onResume() {
        super.onResume();
        Log.d(TAG, "onResume");
    }

    @Override
    public void onPause() {
        super.onPause();
        Log.d(TAG, "onPause");
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG, "onStop");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "onDestroy");
        try {
            NSDDiscover.getInstance().stopServicediscovery(this);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onBackPressed() {
        if(qrScanFlag) {
            mScannerView.stopCamera();
            mScannerView.setVisibility(View.GONE);
            qrScanFlag = false;
            mBinding.recyclerviewConsole.setVisibility(View.VISIBLE);
        }
        else{
            super.onBackPressed();
        }

    }

    @Override
    public void onClick(View v) {
        if (v == mBinding.btnScanMdns) {
            Log.d(TAG, "btnScanQR clik");

            SharedPrefsUtils.getInstance().clearSharedPreference(mContext);
            mConsoleList.clear();
            startMdnsDiscover();

        } else if (v == mBinding.btnShowQrcode) {

            String dppURI = SharedPrefsUtils.getInstance().getStringPreference(this, getResources().getString(R.string.dpp_for_qrcode));
            if(dppURI!=null) {
                startActivity(new Intent(this, QRCodeActivity.class));
            }
            else{
                Toast.makeText(this, "Unable to get QRCode from DPP URI", Toast.LENGTH_SHORT).show();
            }

        } else if (v == mBinding.btnScanQR) {

            //To start QR code Scan
            startScanQRCode();

        } else if (v == mBinding.imvSettings) {

            showPopup(this, v.getRootView());
        }
    }

    /**
     * * To start separate thread for MDNS Discovery
     */
    private void startMDNSDiscovery() {

        Thread thread = new Thread(() -> {

            SharedPrefsUtils.getInstance().clearSharedPreference(mContext);
            mConsoleList.clear();
            SharedPrefsUtils.getInstance().setBooleanPreference(MainActivity.this, getResources().getString(R.string.config_scan), false);
            startMdnsDiscover();
        });

        thread.start();
    }

    /**
     * * To start QR Code Scan
     */
    private void startScanQRCode() {

        if (scanFlag) {
            Toast.makeText(mContext, "Scanning in progress, Please try later", Toast.LENGTH_SHORT).show();
        } else {
            String mdnsIP = SharedPrefsUtils.getInstance().getStringPreference(mContext, getResources().getString(R.string.mdns_ip));
            if (mdnsIP != null) {
                //askPermission();
                scanQRCodetogetUri();
            } else {
                showDialog(mContext, getResources().getString(R.string.message_error), false, getResources().getString(R.string.error_no_configurators_detected), 0);
            }
        }
    }

   /* *//**
     * * To get runtime permission
     *//*
    private void askPermission() {
        //Asking runtime permission before starting camera
        if (Build.VERSION.SDK_INT >= 23) {
            runtimePermissionHelper = RuntimePermissionHelper.getInstance(this);
            if (runtimePermissionHelper.isPermissionAvailable(RuntimePermissionHelper.PERMISSION_CAMERA)) {
                //Scan QR Code
                scanQRCodetogetUri();
            } else {
                runtimePermissionHelper.setActivity(this);
                runtimePermissionHelper.requestPermissionIfDenied(RuntimePermissionHelper.PERMISSION_CAMERA);
            }
        } else {
            //Starting Camera without runtime permission
            scanQRCodetogetUri();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        boolean permissionGranted = true;
        for (int i : grantResults) {
            if (i != PackageManager.PERMISSION_GRANTED) {
                permissionGranted = false;
                break;
            }
        }
        if (permissionGranted) {

            // Start camera once permission is granted
            scanQRCodetogetUri();

        } else {
            if (count > 2) {
                Toast.makeText(this, R.string.camera_permission_toast, Toast.LENGTH_SHORT).show();
                startActivity(new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + BuildConfig.APPLICATION_ID)));
            }
            runtimePermissionHelper.requestPermissionIfDenied(RuntimePermissionHelper.PERMISSION_CAMERA);
        }
        count++;
    }*/

    /**
     * * To start scanning the QR code
     */
    private void scanQRCodetogetUri() {
        mBinding.recyclerviewConsole.setVisibility(View.GONE);
        mScannerView.setVisibility(View.VISIBLE);
        qrScanFlag = true;
        ScanQRCode.getInstance().scanQRCodeToGetUri(mScannerView, MainActivity.this, this);
    }

    /**
     * * Callback method after QR code scanning
     */
    @Override
    public void getScanResult(String dppUri) {

        mScannerView.setVisibility(View.GONE);
        mBinding.recyclerviewConsole.setVisibility(View.VISIBLE);

        scanFlag = false;
        writeTexttoFile(getResources().getString(com.easyconnect.easyconnectapp.R.string.message_sending_uri));
        sendUriToServer(this);
    }

    /**
     * To start MDNS Discovery
     */
    private void startMdnsDiscover() {

        writeTexttoFile(getResources().getString(com.easyconnect.easyconnectapp.R.string.message_scan_configurators));

        Thread thread = new Thread(() -> {
            try {
                NSDDiscover.getInstance().DiscoverMDNSConfigurator(mContext, MainActivity.this);
            } catch (Exception e) {
                e.printStackTrace();
            }

        });

        thread.start();
    }

    /**
     * To  get messages from file and update console
     */
    private void updateConsole(Context context) {

        List<String> consoleList;
        consoleList = FileUtils.getInstance().readFromFile(context);
        mConsoleList.clear();

        for (String message : consoleList) {

            mConsoleList.add(message);
        }
        runOnUiThread(() -> {
            synchronized (logcatListAdapter) {
                logcatListAdapter.notifyDataSetChanged();
            }
        });
    }

    //Method to send dpp and other detials top server
    //Getting response as DPPResponse model
    private void sendUriToServer(Context context) {

        String dppUri = SharedPrefsUtils.getInstance().getStringPreference(context, getApplication().getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_dpp_uri));

        if (dppUri != null) {

            String token = SharedPrefsUtils.getInstance().getTokenPreference(MainActivity.this, getResources().getString(R.string.token));

            JsonObject dppObject = new JsonObject();
            dppObject.addProperty("dpp_uri", dppUri);

            homeViewModel.getDppRepository().getDPPResponse(token, dppObject)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeWith(new DisposableSingleObserver<DPPResponse>() {
                        @Override
                        public void onSuccess(DPPResponse dppResponse) {

                            handleDppResponse(dppResponse);
                        }

                        @Override
                        public void onError(Throwable e) {

                            handleHttpException(e);
                        }
                    });
        }
    }

    /**
     * * To send challenge response to configurator
     */

    private void sendChallenge(String challengeResponse) {

        try {
            String dppUri = SharedPrefsUtils.getInstance().getStringPreference(this, getResources().getString(R.string.mdns_dpp_uri));

            JsonObject dppObject = new JsonObject();
            dppObject.addProperty("dpp_uri", dppUri);

            homeViewModel.getDppRepository().sendChallengeResponse(challengeResponse, dppObject)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeWith(new DisposableSingleObserver<DPPResponse>() {
                        @Override
                        public void onSuccess(DPPResponse dppResponse) {

                            if (dppResponse.getToken() != null) {

                                try {
                                    SharedPrefsUtils.getInstance().setTokenPreference(MainActivity.this, getResources().getString(R.string.token), dppResponse.getToken());
                                } catch (Resources.NotFoundException e) {
                                    e.printStackTrace();
                                }
                            }
                            displayMessageFromConfigurator(dppResponse);
                        }

                        @Override
                        public void onError(Throwable e) {
                            handleHttpException(e);
                        }
                    });

        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }
    }

    private void handleDppResponse(DPPResponse dppResponse) {

        if (dppResponse.getToken() != null) {

            try {
                SharedPrefsUtils.getInstance().setTokenPreference(MainActivity.this, getResources().getString(R.string.token), dppResponse.getToken());
            } catch (Resources.NotFoundException e) {
                e.printStackTrace();
            }
        }

        displayMessageFromConfigurator(dppResponse);
    }

    private void handleHttpException(Throwable e) {
        try {
            HttpException httpException = (HttpException) e;
            DPPResponse dppResponse = homeViewModel.parseErrorResponse(httpException);
            displayMessageFromConfigurator(dppResponse);
        } catch (Exception ex) {
            ex.printStackTrace();
            writeTexttoFile(getResources().getString(R.string.server_error));
            showDialog(MainActivity.this, getResources().getString(R.string.message_error), false, getResources().getString(R.string.server_error), 00);
        }
    }

    /**
     * To get dpp uri from AP
     */
    private void getDPPUriFromServer() {

        try {
            homeViewModel.getDppRepository().getDPPUri()
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeWith(new DisposableSingleObserver<DPPUri>() {
                        @Override
                        public void onSuccess(DPPUri dppUri) {

                            SharedPrefsUtils.getInstance().setStringPreference(MainActivity.this, getResources().getString(R.string.dpp_for_qrcode), dppUri.getDpp_uri());
                            displayMessageDPPURI(dppUri);
                        }

                        @Override
                        public void onError(Throwable e) {

                            handleDPPHttpException(e);
                        }
                    });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * To get dpp uri from AP
     */
    private void sendChallengeResponsetogetURI(String challengeResponse) {

        try {
            homeViewModel.getDppRepository().getDPPUri(challengeResponse)
                    .subscribeOn(Schedulers.io())
                    .observeOn(AndroidSchedulers.mainThread())
                    .subscribeWith(new DisposableSingleObserver<DPPUri>() {
                        @Override
                        public void onSuccess(DPPUri dppUri) {

                            SharedPrefsUtils.getInstance().setStringPreference(MainActivity.this, getResources().getString(R.string.dpp_for_qrcode), dppUri.getDpp_uri());
                            displayMessageDPPURI(dppUri);
                        }

                        @Override
                        public void onError(Throwable e) {
                            handleDPPHttpException(e);
                        }
                    });

        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }
    }

    private void handleDPPHttpException(Throwable e) {
        try {
            HttpException httpException = (HttpException) e;
            DPPUri dppUri = homeViewModel.parseDPPErrorResponse(httpException);
            displayMessageDPPURI(dppUri);

        } catch (Exception ex) {
            ex.printStackTrace();
            writeTexttoFile(getResources().getString(R.string.server_error));
            showDialog(MainActivity.this, getResources().getString(R.string.message_error), false, getResources().getString(R.string.server_error), 00);
            Log.d(TAG, "DPPResponse code " + ex.getMessage());
        }
    }

    /**
     * To display dialog based on the server response
     */
    private void displayMessageFromConfigurator(DPPResponse dppResponse) {

        int statuscode = Integer.parseInt((dppResponse.getStatus()));
        String message = dppResponse.getMessage();

        switch (statuscode) {
            case 200:
                writeTexttoFile(getResources().getString(R.string.message_success));
                showDialog(this, message, false, getResources().getString(R.string.message_dpp_initiates), statuscode);
                return;
            case 307:
                writeTexttoFile(getResources().getString(R.string.message_temporary_redirect));
                showDialog(this, getResources().getString(R.string.message_error), false, message, statuscode);
                return;
            case 400:
                writeTexttoFile(getResources().getString(R.string.message_bad_request));
                showDialog(this, getResources().getString(R.string.message_error), false, message, statuscode);
                return;
            case 401:
                writeTexttoFile(getResources().getString(R.string.message_passphrase_requested));
                showDialog(this, getResources().getString(R.string.message_error), false, message, statuscode);
                return;
            case 404:
                writeTexttoFile(getResources().getString(R.string.message_not_found));
                showDialog(this, getResources().getString(R.string.message_error), false, message, statuscode);
                return;
            case 500:
                writeTexttoFile(getResources().getString(R.string.message_internal_server_error));
                showDialog(this, getResources().getString(R.string.message_error), false, message, statuscode);
                return;
            default:
                showDialog(this, getResources().getString(R.string.message_error), false, "DPP URI sending failed. Please retry ", statuscode);
                return;
        }
    }

    /**
     * To display dialog based on the server response
     */
    private void displayMessageDPPURI(DPPUri dppUri) {

        int statuscode = Integer.parseInt((dppUri.getStatus()));
        String message = dppUri.getMessage();

        switch (statuscode) {
            case 200:
                writeTexttoFile(getResources().getString(R.string.message_success_dpp));
                showDialog(this, message, true, getResources().getString(R.string.message_success_dpp), statuscode);
                return;
            case 307:
                writeTexttoFile(getResources().getString(R.string.message_temporary_redirect_dpp));
                showDialog(this, getResources().getString(R.string.message_error), true, message, statuscode);
                return;
            case 400:
                writeTexttoFile(getResources().getString(R.string.message_bad_request_dpp));
                showDialog(this, getResources().getString(R.string.message_error), true, message, statuscode);
                return;
            case 401:
                writeTexttoFile(getResources().getString(R.string.message_passphrase_requested));
                showDialog(this, getResources().getString(R.string.message_error), true, message, statuscode);
                return;
            case 404:
                writeTexttoFile(getResources().getString(R.string.message_not_found_dpp));
                showDialog(this, getResources().getString(R.string.message_error), true, message, statuscode);
                return;
            case 500:
                writeTexttoFile(getResources().getString(R.string.message_internal_server_errordpp_dpp));
                showDialog(this, getResources().getString(R.string.message_error), true, message, statuscode);
                return;
            default:
                showDialog(this, getResources().getString(R.string.message_error), true, "DPP URI sending failed. Please retry ", statuscode);
                return;
        }
    }

    /**
     * Callback function after MDNS Discovery
     * showing dialog fragment, if having multiple configurators
     */
    @Override
    public void mDNSConfigList(List<NsdServiceInfo> mDnsConfigList) {

        Log.d(TAG, "Config List: " + mDnsConfigList.size());

        runOnUiThread(() -> {

            if (mDnsConfigList.size() == 1) {

                writeTexttoFile(getResources().getString(R.string.detected_configurator));

            } else if (mDnsConfigList.size() > 1) {

                writeTexttoFile(getResources().getString(R.string.detected_configurators));
            }

            for (NsdServiceInfo nsdServiceInfo : mDnsConfigList) {

                writeTexttoFile(nsdServiceInfo.getServiceName());
            }

            if ((mDnsConfigList != null) && (mDnsConfigList.size() > 0)) {

                if (mDnsConfigList.size() == 1) {

                    NSDDiscover.getInstance().getResolveListener(mContext, mDnsConfigList.get(0), this);

                } else {

                    FragmentManager fm = getSupportFragmentManager();
                    MDNSDialogFragment editNameDialogFragment = MDNSDialogFragment.newInstance(MainActivity.this, MainActivity.this, mDnsConfigList);
                    editNameDialogFragment.show(fm, "MDNS List");
                }

                scanFlag = false;

            } else {
                scanFlag = false;
                writeTexttoFile(getResources().getString(R.string.message_no_config_detected));
                showDialog(MainActivity.this, getResources().getString(R.string.message_error), false, getResources().getString(R.string.message_enter_config_details), 100);
            }
        });
    }

    /**
     * To write message to file
     */
    private void writeTexttoFile(String text) {

        try {
            FileUtils.getInstance().writeToFile(text, getApplicationContext());

        } catch (Exception e) {
            e.printStackTrace();
        }

        updateConsole(getApplicationContext());
    }

    /**
     * * Callback method after getting Configurator IP and PORT details
     */
    @Override
    public void getselectedConfigurator(Configurator configurator) {

        String selectedString = getResources().getString(com.easyconnect.easyconnectapp.R.string.message_selected) + " " + configurator.getConfigName() + " " + getResources().getString(com.easyconnect.easyconnectapp.R.string.message_configurator);
        writeTexttoFile(selectedString);

        //Clearing preference to add new NsdServiceInfo details
        SharedPrefsUtils.getInstance().clearSharedPreference(this);

        SharedPrefsUtils.getInstance().setIntegerPreference(this, getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_port), configurator.getConfigPort());
        SharedPrefsUtils.getInstance().setStringPreference(this, getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_ip), configurator.getConfigIP());

        boolean manualScan = SharedPrefsUtils.getInstance().getBooleanPreference(this, getResources().getString(R.string.config_scan), false);
        if (!manualScan) {
            getDPPUriFromServer();
        }
    }

    /**
     * To show dialog with customised title and message
     */
    private void showDialog(Context context, String titile, boolean dpp, String message, int statuscode) {

        // custom dialog
        final Dialog dialog = new Dialog(context);
        dialog.setContentView(R.layout.dialog_passphrase);
        dialog.getWindow().setBackgroundDrawable(ContextCompat.getDrawable(this, R.drawable.dialog_bg));
        dialog.setCancelable(false);

        TextView textTitle = (TextView) dialog.findViewById(R.id.txt_title);
        textTitle.setText(titile);

        TextView textMessage = (TextView) dialog.findViewById(R.id.txt_message);
        textMessage.setText(message);

        EditText editText = (EditText) dialog.findViewById(R.id.edt_response);

        Button button_ok = (Button) dialog.findViewById(R.id.btn_ok);
        Button button_cancel = (Button) dialog.findViewById(R.id.btn_cancel);

        if (statuscode == 401) {

            editText.setHint("Enter response here..");
            editText.setVisibility(View.VISIBLE);

        } else if (statuscode == 100) {
            editText.setText("10.0.0.1:80");
            editText.setVisibility(View.VISIBLE);
        } else {
            editText.setVisibility(View.GONE);
            button_cancel.setVisibility(View.GONE);
        }


        // if button is clicked, close the custom dialog
        button_ok.setOnClickListener(v -> {

            dialog.dismiss();

            handleChallengeResponse(dpp, statuscode, editText.getText().toString());
        });

        button_cancel.setOnClickListener(v -> {
            dialog.dismiss();
        });

        if(!((Activity) context).isFinishing())
        {
            //show dialog
            dialog.show();
        }
        //dialog.show();
    }

    private void handleChallengeResponse(boolean dppFlag, int statuscode, String response) {

        if (dppFlag) {
            if (statuscode == 401) {
                writeTexttoFile(getResources().getString(R.string.message_passphrase_sent));
                sendChallengeResponsetogetURI(response);
            }
        } else {

            if (statuscode == 401) {
                writeTexttoFile(getResources().getString(R.string.message_passphrase_sent));
                sendChallenge(response);

            } else if (statuscode == 100) {
                try {
                    String[] configarray = response.split(":");

                    Log.d(TAG, "Config ip: " + configarray[0] + "config port: " + configarray[1]);
                    writeTexttoFile(getResources().getString(R.string.message_manual_configurator));
                    String ip = configarray[0];
                    SharedPrefsUtils.getInstance().setStringPreference(this, getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_ip), "/" + ip);
                    SharedPrefsUtils.getInstance().setIntegerPreference(this, getResources().getString(com.easyconnect.easyconnectapp.R.string.mdns_port), Integer.parseInt(configarray[1]));

                } catch (Exception e) {
                    e.printStackTrace();
                    showDialog(MainActivity.this, getResources().getString(R.string.message_error), false, getResources().getString(R.string.error_update_config_details), 100);
                }
            }
        }
    }

    /**
     * To show popup for settings icon
     */
    private void showPopup(Context mContext, View view) {

        LayoutInflater layoutInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View customView = layoutInflater.inflate(R.layout.popup, null);

        //instantiate popup window
        final PopupWindow popupWindow = new PopupWindow(customView, ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        popupWindow.setOutsideTouchable(false);
        popupWindow.setFocusable(true);

        TextView textAddConfig = (TextView) customView.findViewById(R.id.txt_add_configurator);

        TextView textMdnsScan = (TextView) customView.findViewById(R.id.txt_mdns_scan);

        TextView textGetUri = (TextView) customView.findViewById(R.id.txt_get_uri);



        //display the popup window
        popupWindow.setOnDismissListener(new PopupWindow.OnDismissListener() {
            @Override
            public void onDismiss() {

                Log.i("popup window", "Dismissing");
            }
        });

        textAddConfig.setOnClickListener(v -> {

            popupWindow.dismiss();
            showDialog(MainActivity.this, getResources().getString(R.string.message_setting), false, getResources().getString(R.string.message_user_enter_config_details), 100);
        });

        textMdnsScan.setOnClickListener(v -> {

            popupWindow.dismiss();
            scanFlag = true;
            SharedPrefsUtils.getInstance().setBooleanPreference(MainActivity.this, getResources().getString(R.string.config_scan), true);
            startMdnsDiscover();
        });

        textGetUri.setOnClickListener(v -> {

            popupWindow.dismiss();
            getDPPUriFromServer();

        });

        //getting the location of the cardview
        int[] location = new int[2];
        view.getLocationInWindow(location);
        popupWindow.showAtLocation(view, Gravity.BOTTOM | Gravity.RIGHT, location[0], location[1] + view.getHeight() / 7);
        popupWindow.setFocusable(true);
    }
}

package com.easyconnect.easyconnectapp.app.view;

import android.os.Bundle;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.easyconnect.easyconnectap.scan.GenerateQRCode;
import com.easyconnect.easyconnectap.util.SharedPrefsUtils;
import com.easyconnect.easyconnectapp.app.R;


/**
 * * Generate and Display QR Code from DPP URI
 */
public class QRCodeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_qrcode);

        ImageView qrImageview = (ImageView) findViewById(R.id.img_qrcode);

        String dppURI = SharedPrefsUtils.getInstance().getStringPreference(this, getResources().getString(R.string.dpp_for_qrcode));

        if(dppURI!=null) {
            qrImageview.setImageBitmap(GenerateQRCode.getInstance().getQRCodeFromDPP(dppURI));
        } else{
            Toast.makeText(this, "Unable to get QRCode from DPP URI", Toast.LENGTH_SHORT).show();
        }
    }
}

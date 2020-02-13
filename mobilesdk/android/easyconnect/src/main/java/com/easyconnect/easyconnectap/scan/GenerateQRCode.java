package com.easyconnect.easyconnectap.scan;

import android.graphics.Bitmap;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.journeyapps.barcodescanner.BarcodeEncoder;

public class GenerateQRCode {

    private static GenerateQRCode generateQRCode;

    /**
     * To get the instance of GenerateQRCode
     */
    public static GenerateQRCode getInstance(){

        if(generateQRCode == null){

            generateQRCode = new GenerateQRCode();
        }

        return generateQRCode;
    }

    /**
     * To get QR code bitmap from dppURI
     * @Param String dppuri
     * @Retuen generated qrcode bitmap
     */
    public Bitmap getQRCodeFromDPP(String dppUrl){
        Bitmap bitmap = null;
        MultiFormatWriter multiFormatWriter = new MultiFormatWriter();
        try {
            BitMatrix bitMatrix = multiFormatWriter.encode(dppUrl, BarcodeFormat.QR_CODE, 400, 400);
            BarcodeEncoder barcodeEncoder = new BarcodeEncoder();
            bitmap = barcodeEncoder.createBitmap(bitMatrix);
            return bitmap;

        } catch (WriterException e) {
            e.printStackTrace();
        }

        return bitmap;
    }

}

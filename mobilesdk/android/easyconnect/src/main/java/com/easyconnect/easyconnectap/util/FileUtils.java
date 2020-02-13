package com.easyconnect.easyconnectap.util;

import android.content.Context;
import android.util.Log;

import androidx.lifecycle.MutableLiveData;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;

public class FileUtils {

    private static FileUtils fileUtils;
    OutputStreamWriter outputStreamWriter;

    public static synchronized FileUtils getInstance() {

        if (fileUtils == null) {

            fileUtils = new FileUtils();
        }

        return fileUtils;
    }

    public void writeToFile(String data, Context context) {

        try {

            if (outputStreamWriter == null) {

                outputStreamWriter = new OutputStreamWriter(context.openFileOutput("console.txt", Context.MODE_PRIVATE));
                outputStreamWriter.write(data);
            } else {

                outputStreamWriter.write("\n");
                outputStreamWriter.append(data);
            }

            outputStreamWriter.flush();

        } catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
    }

    public List<String> readFromFile(Context context) {

        List<String> consoleList = new ArrayList<>();
        try {
            InputStream inputStream = context.openFileInput("console.txt");

            if (inputStream != null) {
                InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                String receiveString = "";
                StringBuilder stringBuilder = new StringBuilder();

                while ((receiveString = bufferedReader.readLine()) != null) {
                    stringBuilder.append(receiveString);
                    consoleList.add(receiveString);
                }

                inputStream.close();
            }
        } catch (FileNotFoundException e) {
            Log.e("login activity", "File not found: " + e.toString());
        } catch (IOException e) {
            Log.e("login activity", "Can not read file: " + e.toString());
        }

        return consoleList;
    }
}

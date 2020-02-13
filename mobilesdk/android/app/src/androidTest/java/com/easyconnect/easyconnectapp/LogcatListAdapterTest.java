package com.easyconnect.easyconnectapp;

import android.content.Context;

import androidx.test.InstrumentationRegistry;
import androidx.test.rule.ActivityTestRule;

import com.easyconnect.easyconnectapp.app.view.LogcatListAdapter;
import com.easyconnect.easyconnectapp.app.view.MainActivity;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import java.util.ArrayList;
import java.util.List;
import static org.junit.Assert.*;

public class LogcatListAdapterTest {

    @Rule
    public ActivityTestRule<MainActivity> mainActivityViewModelActivityTestRule = new ActivityTestRule<>(MainActivity.class);
    private Context mContext;
    private List<String> logList;
    private LogcatListAdapter mLogListAdapter;

    @Before
    public void setUp() throws Exception{
        mContext = InstrumentationRegistry.getTargetContext();
        logList = new ArrayList<>();

        logList.add("Configurator1");
        logList.add("configurator2");
        mLogListAdapter = new LogcatListAdapter(mContext, logList);
    }

    @Test
    public void getItemCount() {

        assertEquals(2,mLogListAdapter.getItemCount());
    }
}

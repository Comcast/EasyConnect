package com.easyconnect.easyconnectap.connection;

import android.net.nsd.NsdServiceInfo;

import java.io.FileOutputStream;
import java.util.List;

/**
 * * @Interface to pass discovered NSDService List
 */
public interface IMDNSDiscovery {

    public void mDNSConfigList(List<NsdServiceInfo> mDnsConfigList);
}

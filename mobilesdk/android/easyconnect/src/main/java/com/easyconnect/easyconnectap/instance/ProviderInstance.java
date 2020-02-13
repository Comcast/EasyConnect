package com.easyconnect.easyconnectap.instance;

import com.easyconnect.easyconnectap.network.Provider;

/**
 * To get Provider instance
 */
public class ProviderInstance {

    private static Provider provider;

    private ProviderInstance() {
    }

    public static Provider getProvider(){
        if(provider==null){

                provider=new Provider();
        }
        return provider;
    }
}

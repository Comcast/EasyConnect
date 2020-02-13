package com.easyconnect.easyconnectap.connection;

public class Configurator {

    private String configName;
    private String configIP;
    private int configPort;

    public Configurator(String configName, String configIP, int configPort) {
        this.configName = configName;
        this.configIP = configIP;
        this.configPort = configPort;
    }

    public String getConfigName() {
        return configName;
    }

    public String getConfigIP() {
        return configIP;
    }

    public int getConfigPort() {
        return configPort;
    }
}

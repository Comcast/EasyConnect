# Configurator Discovery and REST API

This section will focus on how to discover a DPP capable configurator in the local network using mDNS and the REST APIs for configurator delegation.

## Configurator Discovery

Mobile application uses multicast DNS Service Discovery (mDNS-SD) to discover the configurator

###	Sample mDNS-SD definition
```
<?xml version="1.0" standalone='no'?>

<service-group>

  <name replace-wildcards="yes">REST API for Device Provisioning Protocol</name>

  <service>
    <type>_dpp._tcp</type>
    <port>80</port>
    <txt-record>role=configurator</txt-record>
    <txt-record>path=/api/v1/configurator-initiate-dpp</txt-record>
    <txt-record>path=/api/v1/configurator-dpp-uri</txt-record>
  </service>

</service-group>
```

###	Sample mDNS-SD response
```
= eth0 IPv6 REST API for Device Provisioning Protocol _dpp._tcp local
     hostname = [flash.local]
     address = [2001:558:1438:32:511f:8958:f738:e850]
     port = [80]
     txt = ["path=/api/v1/configurator-dpp-uri" "path=/api/v1/configurator-initiate-dpp" "role=configurator"]
= eth0 IPv4 REST API for Device Provisioning Protocol _dpp._tcp local
     hostname = [flash.local]
     address = [10.26.52.182]
     port = [80]
     txt = ["path=/api/v1/configurator-dpp-uri" "path=/api/v1/configurator-initiate-dpp" "role=configurator"]
```

##	Configurator APIs

During initial setup, the enrollee’s bootstrapping key is reported to the configurator and then the configurator is instructed to initiate DPP authentication with the enrollee.  This procedure is not defined in the DPP specification; therefore, we must define an application layer interface to allow for this.  We have defined an HTTP REST API that can be used by the mobile phone in order to trigger client enrollment.

###	API Definition
```
openapi: 3.0.1
info:
  title: Configurator APIs
  description: APIs to initiate DPP authentication with the enrollee and
               to get DPP Bootstrap URI
  version: 1.0.0
host: Discovered using mDNS-SD and provides “_dpp._tcp” service
schemes:
  - https
basePath: /api/v1
produces:
  - application/json
components:
  securitySchemes:
    bearerAuth:
      type: https
      scheme: bearer
security:
  - bearerAuth: []

paths:
  /configurator-initiate-dpp:
    post:
      title: Configurator Delegation API
      summary: Configurator Delegation and DPP initiation
      description: |
        Instructs configurator to initiate DPP authentication with 
        the enrollee, by passing enrollee’s bootstrapping key
      consumes:
        - application/json
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                dpp_uri:
                  type: string
            examples:
              '0':
                value: >-
                  {"dpp_uri":"DPP:C:81/1;M:00:c0:ca:97:64:ca;K:MDkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDIgADJdurpFdNuybzhXApRNxsj9LlBro2QdWJR7q6V/SaThQ=;;"}
      
responses:
        200:
          description: Success
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: 200
                  message:
                    type: string
                    example: Success
                  token: [optional]
                    type: string
                    example: eyJtYWMiOiIwMTIzNDU2Nzg5QUIiLCJleHBpcnkiOjE1NzU1NzE0NDd9

        307:
          description: Temporary Redirect
        400:
          description: Bad Request or Invalid parameters
        401:
          description: Unauthorized
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: 401
                  message:
                    type: string
                    example: What is the WiFi Passphrase?
        404:
          description: Not Found
        500:
          description: Internal Server Error

paths:
  /configurator-dpp-uri:
    get:
      title: API to get DPP URI
      summary: Get DPP Bootstrap URI from the configurator
      description: |
        Allows associated clients to query the configurator for its DPP 
        Bootstrap URI (and makes the configurator listen on respective
        Wi-Fi channel for a new enrollee)
      responses:
        200:
          description: Success
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: 200
                  message:
                    type: string
                    example: Success
                  dpp_uri:
                    type: string
        307:
          description: Temporary Redirect
        400:
          description: Bad Request or Invalid parameters
        401:
          description: Unauthorized
          content:
            application/json:
              schema:
                type: object
                properties:
                  status:
                    type: string
                    example: 401
                  message:
                    type: string
                    example: What is the WiFi Passphrase?
        404:
          description: Not Found
        500:
          description: Internal Server Error
```

# Wi-Fi Easy Connect
[Wi-Fi Easy Connect](https://www.wi-fi.org/discover-wi-fi/wi-fi-easy-connect) was introduced by [the Wi-Fi Alliance (WFA)](https://www.wi-fi.org/) to reduce complexity and enhance the user experience of connecting devices to Wi-Fi networks, while simultaneously incorporating the highest security standards.
 
With Wi-Fi Easy Connect in place, consumers will be able to connect Wi-Fi devices, including those without a screen or an intuitive user interface, to their network by simply scanning a QR code with a smartphone or tablet. Wi-Fi Easy Connect incorporates strong encryption through public key cryptography to ensure networks remain secure as new devices are added.
 
# EasyConnect Reference Kit
Comcast has created a Reference Kit that can be used to demonstrate, understand and help implement Wi-Fi Easy Connect. This reference kit covers Easy Connect configurator discovery and bootstrap delegation to enable Wi-Fi onboarding of a new device using Wi-Fi Easy Connect, by simply scanning a QR code.
 
Setup requires 2 Raspberry Pis and a mobile app. One of the Pis will be configured as a Wi-Fi client (the enrollee) and the other will be configured as an AP (the configurator). A mobile app will be used to scan the QR code from the enrollee and send the bootstrap information to the configurator.
 
Reference kit includes an [iOS app](/mobilesdk/ios), an [android app](/mobilesdk/android) and [patches for Raspberry Pi](/raspberrypi) to make Easy Connect work natively in Raspberry Pi.

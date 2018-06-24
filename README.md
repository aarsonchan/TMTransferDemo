# TMTransferDemo
A Simple Transfer Demo App Using Swift

## Introduction
This is a simple mobile application demostrating Transfer Money
including two views, one is for input amount with basic validation and the another is result showing page.(See Screen Captures as below)

In fact, as payment transaction app, security is of uymost important. It should have basic encrpytion in every API call among mobile side and server side. This application include logic of generate a random AES Symmetric Key and pass to Server using RSA public key encrpytion (Assume Server owns the RSA private key)in the beginning i.e.`requestBuildSession` and after that every API call like `requestTransferMoney` will be sent to server with data encrpyted with previous AES Key. Also, white list checking and Certificate Pinning are also implemented.

However, in order to complete demo of whole transfer progresss, a dummy API call `sendToGetDummyJsonFromHost` with static JSON reponse from online hosting is used to replace as server URL is invalid/ not available at this moment.

### Assumption:
  - User had already provide authentication like PIN input for the payment transaction
  - User had already input the payer account number and payee account number before (Hence, hardcode account number in the demo)

## Screen Captures
<p align="center">
  <img src="https://github.com/aarsonchan/TMTransferDemo/blob/master/InputPage.png" width="280"/>
  <img src="https://github.com/aarsonchan/TMTransferDemo/blob/master/InputInvalidPage.png" width="280"/>
  <img src="https://github.com/aarsonchan/TMTransferDemo/blob/master/ResultPage.png" width="280"/>
</p>

## Requirements
- Xcode 9.0+
- iOS 11.0+
- Swift 4.0+

## Installation and Build
Please download whole project and open `TMTransferDemo.xcworkspace`

## 3rd Party Libraries Used
This project using 'CocoaPods' for 3rd party library installation:
1. Alamofire
   - Alamofire is a useful HTTP networking library written in Swift, which helps to handle Request / Response Methods, HTTP Response Validation, TLS Certificate and Public Key Pinning
2. CryptoSwift
   - CryptoSwift includes standard and secure cryptographic algorithms such as SHA256 and AES
3. SwiftyRSA
   - SwiftyRSA is used for RSA public/private key encryption
4. CocoaLumberjack
   - CocoaLumberjack is a fast and simple logging framework for customized logger used in this app
5. PKHUD
   - PKHUD is a simple HUD activity indicator for handling progress of ongoing task (especially API Call)

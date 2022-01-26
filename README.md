# payze-ios-sdk
Payze Library for easy integration of payments into the iOS app.

### Installation:


Add our dependencie by choosing 'File' in your Xcode project, then choose Add packages and search our library with github url
```groovy
https://github.com/payzeio/payze-ios-sdk.git
```

### Usage:
Using our library is pretty simple. you need to create instance of PaymentDetails and initialize it, then just call PaymentService method 'startPayment()' by using shared instance of it.
### Example Code:

```swift
guard let paymentDetails = PaymentDetails.init(number: "1234567890", 
                                               cardHolder: "card holder", 
                                               expirationDate: "11/12", 
                                               securityNumber: "123", 
                                               transactionId: "transaction id", 
                                               billingAddress: "billing address") else { return }
        
PaymentService.shared.startPayment(paymentDetails: paymentDetails) { result in
            print(result)
   }
```

The result of the startPayment call is handled in it's closure

Follow the instructions for transaction processing on our website https://payze.io/docs.

### Error codes:
Some error codes from library.
* 1001: No internet connection
* 1002: Unsuccessful Request, General
* 1003: Canceled card verification
* 1004: Transaction status is not Successful
* 1005: Unknown error


#### Example
A simple iOS app using this sdk can be found here https://github.com/payzeio/payze-ios-sdk-example

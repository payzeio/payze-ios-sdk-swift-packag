//
//  PaymentInfo.swift
//  PaySms
//
//  Created by Irakli Shelia on 12.12.21.
//

import Foundation

public struct PaymentDetails {
    var number: String = ""
    var cardHolder: String = ""
    var expirationDate: String = ""
    var securityNumber: String = ""
    var transactionId: String = ""
    var billingAddress: String? = ""
    public static let defaultBillingAddress: String = ""
    
    public init?(number: String?,cardHolder: String?,expirationDate: String?,securityNumber: String?,transactionId: String?, billingAddress: String?) {
        
        guard let number = number else { return nil }
        guard let cardHolder = cardHolder else { return nil }
        guard let expirationDate = expirationDate else { return nil }
        guard let securityNumber = securityNumber else { return nil }
        guard let transactionId = transactionId else { return nil }
        
        self.number = number
        self.cardHolder = cardHolder
        self.expirationDate = expirationDate
        self.securityNumber = securityNumber
        self.transactionId = transactionId
        self.billingAddress = billingAddress
        
    }
    
}



//
//  PostCardResponse.swift
//  PaySms
//
//  Created by Irakli Shelia on 04.12.21.
//

import Foundation

public struct StartPaymentResponse: Codable {
    let success: Bool
    let url: String?
    let threeDSIsPresent: Bool
    
    private enum CodingKeys: String, CodingKey {
        case success = "success"
        case url = "url"
        case threeDSIsPresent = "threeDSIsPresent"
        
    }
}

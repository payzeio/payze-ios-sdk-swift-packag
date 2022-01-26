//
//  CheckTransactionStatusDTO.swift
//  PaySms
//
//  Created by Irakli Shelia on 12.12.21.
//

import Foundation

struct CheckTransactionStatusResponse: Codable {
    let status: String
    
    private enum CodingKeys: String, CodingKey {
        case status = "status"
    }
}

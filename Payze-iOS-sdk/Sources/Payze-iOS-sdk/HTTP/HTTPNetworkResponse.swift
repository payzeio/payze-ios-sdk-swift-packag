//
//  HTTPNetworkResponse.swift
//  PaySms
//
//  Created by Irakli Shelia on 04.12.21.
//

import Foundation

struct HTTPNetworkResponse {
    
    // Properly checks and handles the status code of the response
    static func handleNetworkResponse(for response: HTTPURLResponse?) -> Result<String, Error> {
        
        guard let res = response else { return .failure(HTTPNetworkError.UnwrappingError)}
        switch res.statusCode {
        case 200...299: return  .success(HTTPNetworkError.success.rawValue) //Result.success(HTTPNetworkError.success.rawValue)
        case 401: return .failure(HTTPNetworkError.authenticationError)
        case 400...499: return .failure(HTTPNetworkError.badRequest)
        case 500...599: return .failure(HTTPNetworkError.serverSideError)
        default: return .failure(HTTPNetworkError.failed)
        }
    }
}

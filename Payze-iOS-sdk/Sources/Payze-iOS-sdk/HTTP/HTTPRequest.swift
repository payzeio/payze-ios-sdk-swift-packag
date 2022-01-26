//
//  HTTPRequest.swift
//  PaySms
//
//  Created by Irakli Shelia on 04.12.21.
//

import Foundation

public typealias HTTPParameters = [String: Any]?
public typealias HTTPHeaders = [String: Any]?

struct HTTPNetworkRequest {
    private static let baseUrl = "https://paygate.payze.io"
    /// Set the body, method, headers, and paramaters of the request
    static func configureHTTPRequest(from route: HTTPNetworkRoute, with parameters: HTTPParameters, includes headers: HTTPHeaders, contains body: Data?, and method: HTTPMethod) throws -> URLRequest {
        
        guard let url = URL(string: "\(baseUrl)/\(route.rawValue)") else { throw HTTPNetworkError.missingURL}
        
        /*
                    *** NOTES ABOUT REQUEST ***
        
            * You can use the simple initializer if you'd like:
                  var request = URLRequest(url: url)
            * The timeoutInterval argument tells URLSession the amount of time(in seconds) to wait for a response from the server
            * When Making a GET request, we don't pass anything in the body
            * You can cmd+click on each method and parameter to learn more about them.
        */
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");
        request.httpMethod = method.rawValue
        request.httpBody = body
        try configureParametersAndHeaders(parameters: parameters, headers: headers, request: &request)
        
        return request
    }
    
    /// Configure the request parameters and headers before the API Call
    private static func configureParametersAndHeaders(parameters: HTTPParameters?,
                                         headers: HTTPHeaders?,
                                         request: inout URLRequest) throws {

        do {

            if let headers = headers, let parameters = parameters {
                try URLEncoder.encodeParameters(for: &request, with: parameters)
                try URLEncoder.setHeaders(for: &request, with: headers)
            }
        } catch {
            throw HTTPNetworkError.encodingFailed
        }
    }
}

//
//  PostCardService.swift
//  PaySms
//
//  Created by Irakli Shelia on 04.12.21.
//

import Foundation
import UIKit
import WebKit


public protocol PaymentServiceProtocol {
    func startPayment(paymentDetails: PaymentDetails, _ completion: @escaping (Result<StartPaymentResponse, Error>) -> ())
}

public final class PaymentService: NSObject, PaymentServiceProtocol {
    
    public static let shared = PaymentService()
    private let postSession = URLSession(configuration: .default)
    private var twoFactorAuthResponse: TwoFAResponse?
    private var popUpView: MyWebView?
    private let cardPaymentKeys: [String] = ["number",
                                             "cardHolder",
                                             "expirationDate",
                                             "securityNumber",
                                             "transactionId",
                                             "billingAddress"]
    
    public func startPayment(paymentDetails: PaymentDetails, _ completion: @escaping (Result<StartPaymentResponse, Error>) -> ()) {
        cleanup()
        guard let request = createStartPaymentRequest(with: paymentDetails) else { return }
        postSession.dataTask(with: request) { [weak self] (data, res, err) in
            guard let self = self else { return }
            if let response = res as? HTTPURLResponse, let unwrappedData = data {
                let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                switch result {
                case .success:
                    let result = try? JSONDecoder().decode(StartPaymentResponse.self, from: unwrappedData)
                    guard let result = result else { return }
                    if result.threeDSIsPresent {
                        self.handle2FA(result: result) { result in
                            self.checkStatusForTransaction(paymentDetails.transactionId) { transcationStatus in
                                switch transcationStatus {
                                case .success(_):
                                    completion(result)
                                default:
                                    completion(.failure(HTTPNetworkError.badRequest))
                                }
                                self.dismissWebView()
                            }
                        }
                    } else if result.success {
                        self.checkStatusForTransaction(paymentDetails .transactionId) { transactionStatus in
                            switch transactionStatus {
                            case.success(_):
                                completion(.success(result))
                            default:
                                completion(.failure(HTTPNetworkError.badRequest))
                            }
                        }
                    }
                case .failure:
                    completion(.failure(HTTPNetworkError.decodingFailed))
                }
            }
        }.resume()
    }
    
    private func createStartPaymentRequest(with paymentDetails: PaymentDetails) -> URLRequest? {
        var paymentParams = Dictionary(uniqueKeysWithValues: cardPaymentKeys.map {($0, "")})
        paymentParams["number"] = paymentDetails.number
        paymentParams["cardHolder"] = paymentDetails.cardHolder
        paymentParams["expirationDate"] = paymentDetails.expirationDate
        paymentParams["securityNumber"] = paymentDetails.securityNumber
        paymentParams["transactionId"] = paymentDetails.transactionId
        paymentParams["billingAddress"] = paymentDetails.billingAddress
        do {
            let jsonString = paymentParams.reduce("") { "\($0)\($1.0)=\($1.1)&" }.dropLast()
            let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
            let request = try HTTPNetworkRequest.configureHTTPRequest(from: .postCardDetails, with: nil, includes: nil, contains: jsonData, and: .post)
            return request
        } catch {
            print(HTTPNetworkError.badRequest)
        }
        return nil
    }
    
    private func handle2FA(result: StartPaymentResponse, _ completion: @escaping (Result<StartPaymentResponse, Error>) -> ()) {
        guard let iframeUrl = result.url else { return }
        show2FAView(iframeUrl: iframeUrl) { smsResult in
            switch smsResult {
            case .success(_):
                completion(.success(result))
            case .failure(_):
                completion(.failure(HTTPNetworkError.badRequest))
            default:break
            }
        }
    }
    
    private func show2FAView(iframeUrl: String, _ completion: @escaping (TwoFAResponse) -> ()) {
        // Show WKWebView on top of everything
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.popUpView = MyWebView(url: iframeUrl)
            self.popUpView!.webDelegate = self
            let rootVC = UIApplication.shared.windows.first?.rootViewController
            rootVC?.view.addSubview(self.popUpView!)
        }
        
        // Wait for WKWebView redirect
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            while self.twoFactorAuthResponse == nil {
                print("sleeping")
                usleep(100000) // 0.1 s
            }
            switch self.twoFactorAuthResponse {
            case .success(_):
                completion(.success(true))
            default:
                completion(.failure(HTTPNetworkError.badRequest))
            }
        }
    }
    
    private func checkStatusForTransaction(_ transactionId: String, _ completion: @escaping (TwoFAResponse) -> ()) {
        let params = ["transactionId": transactionId]
        do {
            let request =  try HTTPNetworkRequest.configureHTTPRequest(from: .getTransactionStatus, with: params, includes: nil, contains: nil, and: .get)
            postSession.dataTask(with: request) { (data, res, err) in
                if let response = res as? HTTPURLResponse, let unwrappedData = data {
                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {
                    case .success:
                        let result = try? JSONDecoder().decode(CheckTransactionStatusResponse.self, from: unwrappedData)
                        guard let result = result else { return }
                        guard result.status == "Success" else {
                            completion(.failure(HTTPNetworkError.badRequest))
                            return
                        }
                        completion(.success(true))
                    case .failure:
                        completion(.failure(HTTPNetworkError.badRequest))
                    }
                }
            }.resume()
        } catch {
            print(HTTPNetworkError.badRequest)
        }
    }
    
    private func dismissWebView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.popUpView?.removeFromSuperview()
        }
    }
    
    // TODO handle cleanup
    private func cleanup() {
        twoFactorAuthResponse = nil
        popUpView = nil
    }
}

extension PaymentService: WebControllerDelegate {
    func redirected(with response: TwoFAResponse) {
        // WebView Redirected we save response to handle success/fail
        twoFactorAuthResponse = response
        print("Redirect delegate called")
    }
}

//
//  InternalRequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum InternalRequestUtils {
    static var baseURLWithoutParams: URL { return URL(string: DevelopmentConstant.url + "/\(UIApplication.appVersion)") ?? URL(fileURLWithPath: "foo") }
    
    private static var sessionConfig: URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15.0
        sessionConfig.timeoutIntervalForResource = 30.0
        sessionConfig.waitsForConnectivity = false
        return sessionConfig
    }
    private static let session = URLSession(configuration: sessionConfig)
    
    /// Takes an already constructed URLRequest and executes it, returning it in a compeltion handler. This is the basis to all URL requests
    private static func genericRequest(forRequest request: URLRequest, invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        // TO DO FUTURE interpret rate limited responses by CloudFlare
        guard NetworkManager.shared.isConnected else {
            DispatchQueue.main.async {
                if invokeErrorManager == true {
                    ErrorConstant.GeneralRequestError.noInternetConnection.alert()
                }
                
                completionHandler(nil, .noResponse)
            }
            return nil
        }
        
        var modifiedRequest = request
        
        // append userIdentifier if we have it, need it to perform requests
        if let userIdentifier = UserInformation.userIdentifier, let url = request.url {
            // deconstruct request slightly
            var deconstructedURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            // if we try to append to nil, then it fails. so if the array is nil, we just make it an empty array
            if deconstructedURLComponents?.queryItems == nil {
                deconstructedURLComponents?.queryItems = []
            }
            deconstructedURLComponents?.queryItems?.append(URLQueryItem(name: KeyConstant.userIdentifier.rawValue, value: userIdentifier))
            modifiedRequest.url = deconstructedURLComponents?.url ?? request.url
        }
        
        AppDelegate.APIRequestLogger.notice("\(modifiedRequest.httpMethod ?? VisualConstant.TextConstant.unknownText) Request for \(modifiedRequest.url?.description ?? VisualConstant.TextConstant.unknownText)")
        
        // send request
        let task = session.dataTask(with: modifiedRequest) { data, response, error in
            // extract status code from URLResponse
            let responseStatusCode: Int? = (response as? HTTPURLResponse)?.statusCode
            
            // parse response from json
            var responseBody: [String: Any]?
            // if no data or if no status code, then request failed
            if let data = data {
                // try to serialize data as "result" form with array of info first, if that fails, revert to regular "message" and "error" format
                responseBody = try?
                JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: [[String: Any]]]
                ?? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
            }
            
            guard error == nil, let responseBody = responseBody, let responseStatusCode = responseStatusCode else {
                // assume an error is no response as that implies request/response failure, meaning the end result of no response is the same
                AppDelegate.APIResponseLogger.warning(
                    "No \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)\nData Task Error: \(error?.localizedDescription ?? VisualConstant.TextConstant.unknownText)")
                
                var responseError = ErrorConstant.GeneralResponseError.getNoResponse
                
                switch request.httpMethod {
                case "GET":
                    responseError = ErrorConstant.GeneralResponseError.getNoResponse
                case "POST":
                    responseError = ErrorConstant.GeneralResponseError.postNoResponse
                case "PUT":
                    responseError = ErrorConstant.GeneralResponseError.putNoResponse
                case "DELETE":
                    responseError = ErrorConstant.GeneralResponseError.deleteNoResponse
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    if invokeErrorManager == true {
                        responseError.alert()
                    }
                    
                    completionHandler(responseBody, .noResponse)
                }
                
                return
            }
            
            guard 200...299 ~= responseStatusCode else {
                // Our request went through but was invalid
                AppDelegate.APIResponseLogger.warning(
                    "Failure \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)\n Message: \(responseBody[KeyConstant.message.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)\n Code: \(responseBody[KeyConstant.code.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)\n Type:\(responseBody[KeyConstant.name.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)")
                
                let responseErrorCode: String? = responseBody[KeyConstant.code.rawValue] as? String
                
                let responseError: HoundError = {
                    if let responseErrorCode = responseErrorCode {
                        if let error = ErrorConstant.serverError(forErrorCode: responseErrorCode) {
                            return error
                        }
                        else if let error = ErrorConstant.serverError(forErrorCode: responseErrorCode) {
                            return error
                        }
                    }
                    
                    switch request.httpMethod {
                    case "GET":
                        return ErrorConstant.GeneralResponseError.getFailureResponse
                    case "POST":
                        return ErrorConstant.GeneralResponseError.postFailureResponse
                    case "PUT":
                        return ErrorConstant.GeneralResponseError.putFailureResponse
                    case "DELETE":
                        return ErrorConstant.GeneralResponseError.deleteFailureResponse
                    default:
                        return ErrorConstant.GeneralResponseError.getFailureResponse
                    }
                }()
                
                guard responseError.name != ErrorConstant.GeneralResponseError.appVersionOutdatedName else {
                    // If we experience an app version response error, that means the user's local app is outdated. If this is the case, then nothing will work until the user updates their app. Therefore we stop everything and do not return a completion handler. This might break something but we don't care.
                    DispatchQueue.main.async {
                        responseError.alert()
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    if invokeErrorManager == true {
                        responseError.alert()
                    }
                    
                    completionHandler(responseBody, .failureResponse)
                }
                return
            }
            
            // Our request was valid and successful
            AppDelegate.APIResponseLogger.notice("Success \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)")
            DispatchQueue.main.async {
                completionHandler(responseBody, .successResponse)
            }
        }
        
        // free up task when request is pushed
        task.resume()
        
        return task.progress
    }
}

extension InternalRequestUtils {
    
    // MARK: - Generic GET, POST, PUT, and DELETE requests
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericGetRequest(invokeErrorManager: Bool, forURL URL: URL, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "GET"
        
        return genericRequest(forRequest: request, invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /// Perform a generic get request at the specified url with provided body. completionHandler is on the .main thread.
    static func genericPostRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        return genericRequest(forRequest: request, invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /// Perform a generic get request at the specified url with provided body, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericPutRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any], completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        return genericRequest(forRequest: request, invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
        
    }
    
    /// Perform a generic get request at the specified url, assuming URL params are already provided. completionHandler is on the .main thread.
    static func genericDeleteRequest(invokeErrorManager: Bool, forURL URL: URL, forBody body: [String: Any]? = nil, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "DELETE"
        
        if let body = body {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
        }
        
        return genericRequest(forRequest: request, invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
}

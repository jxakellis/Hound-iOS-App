//
//  RequestUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ResponseStatus {
    /// 200...299
    case successResponse
    /// != 200...299, e.g. 400, 404, 500
    case failureResponse
    /// Request couldn't be constructed, request wasn't sent, request didn't go through, server was down, response was lost, or some other error
    case noResponse
}

/// abstractions used by other endpoint classes to make their request to the server, not used anywhere else in hound so therefore internal to endpoints and api requests.
enum RequestUtils {
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
    private static func genericRequest(forRequest originalRequest: URLRequest, invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        guard NetworkManager.shared.isConnected else {
            DispatchQueue.main.async {
                if invokeErrorManager == true {
                    ErrorConstant.GeneralRequestError.noInternetConnection().alert()
                }
                
                completionHandler(nil, .noResponse)
            }
            return nil
        }
        
        var request = originalRequest
        
        // append userIdentifier if we have it, need it to perform requests
        if let userIdentifier = UserInformation.userIdentifier, let url = request.url {
            // deconstruct request slightly
            var deconstructedURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            // if we try to append to nil, then it fails. so if the array is nil, we just make it an empty array
            if deconstructedURLComponents?.queryItems == nil {
                deconstructedURLComponents?.queryItems = []
            }
            deconstructedURLComponents?.queryItems?.append(URLQueryItem(name: KeyConstant.userIdentifier.rawValue, value: userIdentifier))
            request.url = deconstructedURLComponents?.url ?? request.url
        }
        
        AppDelegate.APIRequestLogger.notice("\(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Request for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)")
        
        // send request
        let task = session.dataTask(with: request) { data, response, error in
            // extract status code from URLResponse
            let responseStatusCode: Int? = (response as? HTTPURLResponse)?.statusCode
            
            // parse response from json
            let responseBody: [String: Any]? = {
                // if no data or if no status code, then request failed
                guard let data = data else {
                    return nil
                }
                
                // try to serialize data as "result" form with array of info first, if that fails, revert to regular "message" and "error" format
                return try?
                JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: [[String: Any]]]
                ?? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
            }()
            
            guard error == nil, let responseBody = responseBody, let responseStatusCode = responseStatusCode else {
                genericRequestNoResponse(forRequest: request, invokeErrorManager: invokeErrorManager, completionHandler: completionHandler, forResponseBody: responseBody, forError: error)
                return
            }
            
            guard 200...299 ~= responseStatusCode else {
                genericRequestFailureResponse(forRequest: request, invokeErrorManager: invokeErrorManager, completionHandler: completionHandler, forResponseBody: responseBody)
                return
            }
            
            genericRequestSuccessResponse(forRequest: request, completionHandler: completionHandler, forResponseBody: responseBody)
        }
        
        // free up task when request is pushed
        task.resume()
        
        return task.progress
    }
    
    /// Handles a case of a no response from a data task query
    private static func genericRequestNoResponse(forRequest request: URLRequest, invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void, forResponseBody responseBody: [String: Any]?, forError error: Error?) {
        // assume an error is no response as that implies request/response failure, meaning the end result of no response is the same
        AppDelegate.APIResponseLogger.warning(
            "No \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)\nData Task Error: \(error?.localizedDescription ?? VisualConstant.TextConstant.unknownText)")
        
        let responseError: HoundError = {
            switch request.httpMethod {
            case "GET":
                return ErrorConstant.GeneralResponseError.getNoResponse()
            case "POST":
                return ErrorConstant.GeneralResponseError.postNoResponse()
            case "PUT":
                return ErrorConstant.GeneralResponseError.putNoResponse()
            case "DELETE":
                return ErrorConstant.GeneralResponseError.deleteNoResponse()
            default:
                return ErrorConstant.GeneralResponseError.getNoResponse()
            }
        }()
        
        DispatchQueue.main.async {
            if invokeErrorManager == true {
                responseError.alert()
            }
            
            completionHandler(responseBody, .noResponse)
        }
    }
    
    /// Handles a case of a failure response from a data task query
    private static func genericRequestFailureResponse(forRequest request: URLRequest, invokeErrorManager: Bool, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void, forResponseBody responseBody: [String: Any]) {
        // Our request went through but was invalid
        AppDelegate.APIResponseLogger.warning(
            "Failure \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)\n Message: \(responseBody[KeyConstant.message.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)\n Code: \(responseBody[KeyConstant.code.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)\n Type:\(responseBody[KeyConstant.name.rawValue] as? String ?? VisualConstant.TextConstant.unknownText)")
        
        let responseErrorCode: String? = responseBody[KeyConstant.code.rawValue] as? String
        let requestId: Int = responseBody[KeyConstant.requestId.rawValue] as? Int ?? -1
        let responseId: Int = responseBody[KeyConstant.responseId.rawValue] as? Int ?? -1
        
        let responseError: HoundError = {
            // attempt to construct an error from responseErrorCode
            if let responseErrorCode = responseErrorCode, let error = ErrorConstant.serverError(forErrorCode: responseErrorCode, forRequestId: requestId, forResponseId: responseId) {
                return error
            }
            
            // could not construct an error, use a default error message based upon the http method
            switch request.httpMethod {
            case "GET":
                return ErrorConstant.GeneralResponseError.getFailureResponse(forRequestId: requestId, forResponseId: responseId)
            case "POST":
                return ErrorConstant.GeneralResponseError.postFailureResponse(forRequestId: requestId, forResponseId: responseId)
            case "PUT":
                return ErrorConstant.GeneralResponseError.putFailureResponse(forRequestId: requestId, forResponseId: responseId)
            case "DELETE":
                return ErrorConstant.GeneralResponseError.deleteFailureResponse(forRequestId: requestId, forResponseId: responseId)
            default:
                return ErrorConstant.GeneralResponseError.getFailureResponse(forRequestId: requestId, forResponseId: responseId)
            }
        }()
        
        guard responseError.name != ErrorConstant.GeneralResponseError.appVersionOutdated(forRequestId: -1, forResponseId: -1).name else {
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
            
            // if the error happened to be about the user's account or family disappearing or them losing access, then revert them to the login page
            if responseError.name == ErrorConstant.PermissionResponseError.noUser(forRequestId: -1, forResponseId: -1).name || responseError.name == ErrorConstant.PermissionResponseError.noFamily(forRequestId: -1, forResponseId: -1).name {
                PresentationManager.globalPresenter?.dismissIntoServerSyncViewController()
            }
            // if the error happens to be because a dog, log, or reminder was deleted, then invoke a low level refresh to update the user's data.
            else if responseError.name == ErrorConstant.FamilyResponseError.deletedDog(forRequestId: -1, forResponseId: -1).name ||
                responseError.name == ErrorConstant.FamilyResponseError.deletedLog(forRequestId: -1, forResponseId: -1).name ||
                responseError.name == ErrorConstant.FamilyResponseError.deletedReminder(forRequestId: -1, forResponseId: -1).name {
                MainTabBarController.mainTabBarController?.shouldRefreshDogManager = true
            }
            
            completionHandler(responseBody, .failureResponse)
        }
    }
    
    /// Handles a case of a success response from a data task query
    private static func genericRequestSuccessResponse(forRequest request: URLRequest, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void, forResponseBody responseBody: [String: Any]) {
        // Our request was valid and successful
        AppDelegate.APIResponseLogger.notice("Success \(request.httpMethod ?? VisualConstant.TextConstant.unknownText) Response for \(request.url?.description ?? VisualConstant.TextConstant.unknownText)")
        DispatchQueue.main.async {
            completionHandler(responseBody, .successResponse)
        }
    }
}

extension RequestUtils {
    
    // MARK: - Generic GET, POST, PUT, and DELETE requests
    
    /// Perform a generic get request at the specified url with NO body; assumes URL params are already provided. completionHandler is on the .main thread.
    static func genericGetRequest(invokeErrorManager: Bool, forURL URL: URL, completionHandler: @escaping ([String: Any]?, ResponseStatus) -> Void) -> Progress? {
        
        // create request to send
        var request = URLRequest(url: URL)
        
        // specify http method
        request.httpMethod = "GET"
        
        return genericRequest(forRequest: request, invokeErrorManager: invokeErrorManager) { responseBody, responseStatus in
            completionHandler(responseBody, responseStatus)
        }
    }
    
    /// Perform a generic get request at the specified url with provided body; assumes URL params are already provided. completionHandler is on the .main thread.
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
    
    /// Perform a generic get request at the specified url with provided body; assumes URL params are already provided. completionHandler is on the .main thread.
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
    
    /// Perform a generic get request at the specified url with NO body; assumes URL params are already provided. completionHandler is on the .main thread.
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

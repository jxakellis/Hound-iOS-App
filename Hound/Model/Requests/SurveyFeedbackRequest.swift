//
//  SurveyFeedbackRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation
import UIKit

enum SurveyFeedbackRequest {
    static var baseURL: URL { FamilyRequest.baseURL.appendingPathComponent("/surveyFeedback")}
    
    /**
     Invoke function when user fills out the feedback survey for why they are cancelling their Hound+ subscription.
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        userCancellationReason: SubscriptionCancellationReason?,
        userCancellationFeedback: String,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        var body: JSONRequestBody = [:]
        body[Constant.Key.surveyFeedbackType.rawValue] = .string(SurveyFeedbackType.cancelSubscription.rawValue)
        body[Constant.Key.surveyFeedbackUserCancellationReason.rawValue] = .string(userCancellationReason?.internalValue)
        body[Constant.Key.surveyFeedbackUserCancellationFeedback.rawValue] = .string(userCancellationFeedback)
        
        return create(errorAlert: errorAlert, sourceFunction: sourceFunction, body: body, completionHandler: completionHandler)
    }
    
    /**
     Invoke function when user fills out the feedback survey for their experience with Hound
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        numberOfStars: Int,
        appExperienceFeedback: String,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: JSONRequestBody = [
            Constant.Key.surveyFeedbackType.rawValue: .string(SurveyFeedbackType.appExperience.rawValue),
            Constant.Key.surveyFeedbackAppExperienceNumberOfStars.rawValue: .int(numberOfStars),
            Constant.Key.surveyFeedbackAppExperienceFeedback.rawValue: .string(appExperienceFeedback)
        ]
        
        return create(errorAlert: errorAlert, sourceFunction: sourceFunction, body: body) { responseStatus, houndError in
            guard responseStatus != .failureResponse else {
                completionHandler(responseStatus, houndError)
                return
            }
            
            // We successfully submitted the survey for app experience, so track that
            if responseStatus == .successResponse {
                LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.append(Date())
            }
            
            completionHandler(responseStatus, houndError)
        }
    }

    /**
     Sends a generic surveyFeedback request to the Hound server, appending a variety of device metrics to the passed body
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult private static func create(
        errorAlert: ResponseAutomaticErrorAlertTypes,
        sourceFunction: RequestSourceFunctionTypes = .normal,
        body: JSONRequestBody,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
       
        var bodyWithDeviceMetrics = body
        bodyWithDeviceMetrics[Constant.Key.surveyFeedbackDeviceMetricModel.rawValue] = .string(UIDevice.current.model)
        bodyWithDeviceMetrics[Constant.Key.surveyFeedbackDeviceMetricSystemVersion.rawValue] = .string(UIDevice.current.systemVersion)
        bodyWithDeviceMetrics[Constant.Key.surveyFeedbackDeviceMetricAppVersion.rawValue] = .string(AppVersion.current.rawValue)
        bodyWithDeviceMetrics[Constant.Key.surveyFeedbackDeviceMetricLocale.rawValue] = .string(Locale.current.identifier)
        
        // All of the previous body should be encapsulated inside a surveyFeedback body
        var body: JSONRequestBody = [:]
        body[Constant.Key.surveyFeedback.rawValue] = .object(bodyWithDeviceMetrics)
        
        return RequestUtils.genericPostRequest(
            errorAlert: errorAlert,
            sourceFunction: sourceFunction,
            url: baseURL,
            body: body) { _, responseStatus, error in
                completionHandler(responseStatus, error)
        }
    }
}

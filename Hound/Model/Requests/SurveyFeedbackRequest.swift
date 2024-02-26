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
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        userCancellationReason: SubscriptionCancellationReason?,
        userCancellationFeedback: String,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON?] = [
            KeyConstant.surveyFeedbackType.rawValue: SurveyFeedbackType.cancelSubscription.rawValue,
            KeyConstant.surveyFeedbackUserCancellationReason.rawValue: userCancellationReason?.internalValue,
            KeyConstant.surveyFeedbackUserCancellationFeedback.rawValue: userCancellationFeedback
        ]
        
        return create(forErrorAlert: forErrorAlert, forSourceFunction: forSourceFunction, forBody: body, completionHandler: completionHandler)
    }
    
    /**
     Invoke function when user fills out the feedback survey for their experience with Hound
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        numberOfStars: Int,
        appExperienceFeedback: String,
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
        let body: [String: CompatibleDataTypeForJSON?] = [
            KeyConstant.surveyFeedbackType.rawValue: SurveyFeedbackType.appExperience.rawValue,
            KeyConstant.surveyFeedbackAppExperienceNumberOfStars.rawValue: numberOfStars,
            KeyConstant.surveyFeedbackAppExperienceFeedback.rawValue: appExperienceFeedback
        ]
        
        return create(forErrorAlert: forErrorAlert, forSourceFunction: forSourceFunction, forBody: body) { responseStatus, houndError in
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
        forErrorAlert: ResponseAutomaticErrorAlertTypes,
        forSourceFunction: RequestSourceFunctionTypes = .normal,
        forBody: [String: CompatibleDataTypeForJSON?],
        completionHandler: @escaping (ResponseStatus, HoundError?) -> Void
    ) -> Progress? {
       
        var forBodyWithDeviceMetrics = forBody
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricModel.rawValue] = UIDevice.current.model
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricSystemVersion.rawValue] = UIDevice.current.systemVersion
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricAppVersion.rawValue] = UIApplication.appVersion
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricLocale.rawValue] = Locale.current.identifier
        
        // All of the previous body should be encapsulated inside a surveyFeedback body
        let body: [String: [String: CompatibleDataTypeForJSON?]] = [ KeyConstant.surveyFeedback.rawValue: forBodyWithDeviceMetrics]
        
        return RequestUtils.genericPostRequest(
            forErrorAlert: forErrorAlert,
            forSourceFunction: forSourceFunction,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
                completionHandler(responseStatus, error)
        }
    }
}

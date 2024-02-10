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
    @discardableResult static func create(invokeErrorManager: Bool, userCancellationReason: SubscriptionCancellationReason?, userCancellationFeedback: String, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body: [String: PrimativeTypeProtocol?] = [
            KeyConstant.surveyFeedbackType.rawValue: SurveyFeedbackType.cancelSubscription.rawValue,
            KeyConstant.surveyFeedbackUserCancellationReason.rawValue: userCancellationReason?.internalValue,
            KeyConstant.surveyFeedbackUserCancellationFeedback.rawValue: userCancellationFeedback
        ]
        
        return create(invokeErrorManager: invokeErrorManager, forBody: body, completionHandler: completionHandler)
    }
    
    /**
     Invoke function when user fills out the feedback survey for their experience with Hound
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(invokeErrorManager: Bool, numberOfStars: Int, appExperienceFeedback: String, completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        let body: [String: PrimativeTypeProtocol?] = [
            KeyConstant.surveyFeedbackType.rawValue: SurveyFeedbackType.appExperience.rawValue,
            KeyConstant.surveyFeedbackAppExperienceNumberOfStars.rawValue: numberOfStars,
            KeyConstant.surveyFeedbackAppExperienceFeedback.rawValue: appExperienceFeedback
        ]
        
        return create(invokeErrorManager: invokeErrorManager, forBody: body, completionHandler: completionHandler)
    }

    /**
     Sends a generic surveyFeedback request to the Hound server, appending a variety of device metrics to the passed body
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult private static func create(invokeErrorManager: Bool, forBody: [String: PrimativeTypeProtocol?], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
       
        var forBodyWithDeviceMetrics = forBody
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricModel.rawValue] = UIDevice.current.model
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricSystemVersion.rawValue] = UIDevice.current.systemVersion
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricAppVersion.rawValue] = UIApplication.appVersion
        forBodyWithDeviceMetrics[KeyConstant.surveyFeedbackDeviceMetricLocale.rawValue] = Locale.current.identifier
        
        // All of the previous body should be encapsulated inside a surveyFeedback body
        let body: [String: PrimativeTypeProtocol?] = [ KeyConstant.surveyFeedback.rawValue: forBodyWithDeviceMetrics]
        
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: body) { _, responseStatus, error in
            switch responseStatus {
            case .successResponse:
                completionHandler(true, responseStatus, error)
            case .failureResponse:
                completionHandler(false, responseStatus, error)
            case .noResponse:
                completionHandler(false, responseStatus, error)
            }
        }
    }
}

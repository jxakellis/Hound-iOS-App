//
//  SurveyFeedbackRequest.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum SurveyFeedbackRequest {
    static var baseURL: URL { FamilyRequest.baseURL.appendingPathComponent("/surveyFeedback")}

    /**
     Invoke function when user fills out the feedback survey for why they are cancelling their Hound+ subscription. Does not invoke error manager as this request should be silent.
     If query is successful, automatically DEFAULT-DOES-NOTHING and returns (true, .successResponse)
     If query isn't successful, returns (false, .failureResponse) or (false, .noResponse)
   */
    @discardableResult static func create(invokeErrorManager: Bool, forBody: [String: Any?], completionHandler: @escaping (Bool, ResponseStatus, HoundError?) -> Void) -> Progress? {
        return RequestUtils.genericPostRequest(
            invokeErrorManager: invokeErrorManager,
            forURL: baseURL,
            forBody: forBody) { _, responseStatus, error in
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

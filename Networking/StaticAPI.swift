//
//  API.swift
//  HTTPClient
//
//  Created by Nunzio Giulio Caggegi on 14/11/20.
//

import Foundation
import PromiseKit
import SwiftyJSON
import Alamofire

public enum APIResult {
    case success(FalconResponse)
    case error(FalconResponse?, Error?)
}

public class Falcon: NSObject {
    
    internal static var requestManager: RestClient?
    
    public static func setup(baseUrl: String) {
        self.requestManager = RestClient()
        requestManager?.setupBaseUrl(baseUrl: baseUrl)
    }
    
    public static func request(url: String?, method: HTTPMethod, parameters: [String:AnyObject]? = nil, withQuery: Bool = false, completion: @escaping (APIResult) -> ()) {
        if let _url = url {
            self.requestManager?.request(method, URIString: _url, parameters: parameters, withQuery: withQuery).done({ (response) in
                if let statCode = response.statusCode {
                    if statCode >= 200, statCode < 300 {
                        completion(.success(response))
                    } else {
                        completion(.error(response, response.error))
                    }
                } else {
                    completion(APIResult.error(nil, response.error))
                }
            }).catch({ (error) in
                completion(APIResult.error(nil, error))
            })
        }        
    }
}

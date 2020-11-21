//
//  API.swift
//  HTTPClient
//
//  Created by Nunzio Giulio Caggegi on 14/11/20.
//

import Foundation

public struct FalconResponse {
    public var success: Bool
    public var response: HTTPURLResponse?
    public var error: APIError?
    public var data: Data?
    public var json: [String : Any]
}



public class Falcon: NSObject {
    
    internal static var requestManager: NetworkManager?
    
    public static func setup(baseUrl: URL) {
        self.requestManager = NetworkManager()
        requestManager?.setupBaseUrl(baseUrl: baseUrl)
    }
    
    public static func request(url: String?, method: HTTPMethod, parameters: [String:AnyObject]? = nil, withQuery: Bool = false, completion: @escaping (FalconResponse) -> ()) {
        
        if let _url = url {
            requestManager?.request(method: method, path: _url, { (success, response, error, data, json) in
                let falconResponse = FalconResponse(success: success, response: response, error: error, data: data, json: json)
                completion(falconResponse)
            })
        }        
    }
}

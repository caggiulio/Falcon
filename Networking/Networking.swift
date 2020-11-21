//
//  Networking.swift
//  HTTPClient
//
//  Created by Nunzio Giulio Caggegi on 14/11/20.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
}

class APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var body: Data?

    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }

    init<Body: Encodable>(method: HTTPMethod, path: String, body: Body) throws {
        self.method = method
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }
}

public struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
    let json: [String:Any]?
}

extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.decodingFailure
        }
        
        var finalJson: [String:Any]?
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                finalJson = json
            }
        } catch let error as NSError {
            //ConsoleLogger.shared.log("Failed to load: \(error.localizedDescription)")
        }
        
        let decodedJSON = try JSONDecoder().decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode,
                                     body: decodedJSON, json: finalJson)
    }
}

public enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailure
    case genericError(statusCode: Int)
    case unrecoverableForbidden //The request has returned 401 and the attempt to refresh the token hsa failed
}

public enum APIResult<Body> {
    case success(APIResponse<Body>)
    case failure(APIError)
}

class NetworkManager: NSObject, URLSessionDelegate {
    

    typealias APIClientCompletion = (APIResult<Data?>) -> Void
    
    var session: URLSession?
    var baseURL: URL?
    
    private var initialized: Bool = false
    
    func setupBaseUrl(baseUrl: URL) {
        initialized = true
        self.baseURL = baseUrl
    }
    
    private func reconfigure() {
        if session == nil {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            
            session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        }
    }

    func request(method: HTTPMethod, path: String, extraHeaderField: [String:String]? = nil, parametersAsDictionary: [String:Any]? = nil, parametersAsData: Data? = nil, _ completion: @escaping (_ success: Bool, _ response: HTTPURLResponse?, _ error: APIError?, _ data: Data?, _ json: [String:Any]) -> ()) {
        
        if initialized == false {
            fatalError("YOU MUST CALL SETUP")
        }
        
        reconfigure()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL?.scheme
        urlComponents.host = baseURL?.host
        urlComponents.path = baseURL!.path
        urlComponents.port = baseURL!.port
        
        guard let url = urlComponents.url?.appendingPathComponent(path) else {
            completion(false, nil, .invalidURL, nil, [:])
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        //SET PARAMETERS
        if let params = parametersAsDictionary {
            request.httpBody = params.percentEncoded()
        }
        if let paramsAsData = parametersAsData {
            request.httpBody = paramsAsData
        }

        //SET HEADER
        var header: [String:String] = [
            "content-type":"application/json",
            "Accept":"application/json"
        ]
        
        if let extra = extraHeaderField {
            header = header.mergeOnto(target: extra)
        }
        
        request.allHTTPHeaderFields = header
        
        let task = session?.dataTask(with: request) { [weak self] (data, response, error) in
            
            var requestBodyStr: String?
            var responseBodyStr: String?
            
            if let body = request.httpBody {
                requestBodyStr = String(data: body, encoding: .utf8)
            }
            
            if let responseData = data {
                responseBodyStr = String(data: responseData, encoding: .utf8)
                print(responseBodyStr)
            }
        
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, nil, .requestFailed, nil, [:])
                return
            }
            
            guard let data = data else { return }
            var finalJson: [String:Any]?
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .fragmentsAllowed]) as? [String: Any] {
                    finalJson = json
                }
            } catch let error as NSError {
                
            }
            
            if httpResponse.statusCode < 300 && httpResponse.statusCode >= 200 {
                completion(true, httpResponse, nil, data, finalJson ?? [:])
                // SUCCESS
            }
            else {
                completion(false, httpResponse, .genericError(statusCode: httpResponse.statusCode), nil, [:])
            }
        }
        task?.resume()
    }
}

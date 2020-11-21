//
//  Utility.swift
//  Falcon
//
//  Created by Nunzio Giulio Caggegi on 17/11/20.
//

import Foundation

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension Dictionary where Value: Any {
    func mergeOnto(target: [Key: Value]?) -> [Key: Value] {
        guard let target = target else { return self }
        return self.merging(target) { current, _ in current }
    }
}



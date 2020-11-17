//
//  ToDO.swift
//  Falcon_Example
//
//  Created by Nunzio Giulio Caggegi on 17/11/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

struct Todo: Codable {

    let title: String
    let userId: Int
    let completed: Bool

    private enum CodingKeys: String, CodingKey {
        case title = "title"
        case userId = "userId"
        case completed = "completed"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        userId = try values.decode(Int.self, forKey: .userId)
        completed = try values.decode(Bool.self, forKey: .completed)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(userId, forKey: .userId)
        try container.encode(completed, forKey: .completed)
    }

}

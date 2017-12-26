//
//  GoogleVisionStruct.swift
//  Whatsthat
//
//  Created by Jinfeng on 12/12/17.
//  Copyright © 2017 jinfeng. All rights reserved.
//

import Foundation

struct Root: Codable {
    let responses: [Responses]
}

struct Responses: Codable {
    let labelAnnotations: [LabelAnnotations]
}

struct LabelAnnotations: Codable {
    let mid: String
    let description: String
    let score: Double
}


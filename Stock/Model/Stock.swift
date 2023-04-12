//
//  Stock.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import Foundation

struct Stock: Codable {
    let meta: Meta
    let values: [Value]
}

struct Meta: Codable {
    let symbol: String
    let currency: String
    let exchange: String
}

struct Value: Codable {
    let datetime: String
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
}



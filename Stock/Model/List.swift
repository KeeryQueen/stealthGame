
//
//  List.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import Foundation

struct List: Codable {
    let data: [Data]
}

struct Data: Codable {
    let symbol: String
    let name: String
    let currency: String
    let exchange: String
    let type: String
}
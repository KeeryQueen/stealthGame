//
//  ErrorMessage.swift
//  Stock
//
//  Created by 張永霖 on 2021/5/6.
//

import Foundation

enum ErrorMessage: String, Error {
    case connectionFaild = "Ineternet connection failed. Please try again."
    case invalidURL = "URL seems to have some problem."
    case unableToComplete = "Unable to complete."
    case invalidData = "Something about data went wrong."
    case invalidDecodeData = "Something about data went wrong at decoding."
}

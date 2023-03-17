//
//  CurrencyRateResponse.swift
//  TestTask
//
//  Created by Taleh Mammadov on 18.03.23.
//

import Foundation

struct CurrencyRateResponse: Decodable {
    let from: String
    let to: String
    let result: Double
    let date: String
    let menbe: String
}

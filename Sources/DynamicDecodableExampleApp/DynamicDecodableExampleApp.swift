//
//  DynamicDecodableExampleApp.swift
//  DynamicDecodable
//
//  Created by Yuri on 10.06.2024.
//

import Foundation
import DynamicDecodable

let orderData1 =
"""
{
    "order_id": 119528356,
    "pair": "btc_usdt",
    "type": "sell",
    "price_requested": 1,
    "price_filled": 66490.9150842,
    "asset_sold_id": 2,
    "asset_sold_change": 0.006978,
    "asset_get_id": 10,
    "asset_get_change": 463.97360545,
    "fee": "0.00185589",
    "created_at": 1711036761,
    "user_id": 5,
    "asset_get_code": "usdt",
    "asset_sold_code": "btc",
    "total": null
}
""".data(using: .utf8)!

@DynamicDecodableMapping
enum OrderType: String {
    
    case buy
    case sell
}

@DynamicDecodableMapping
struct Order {
    
    let orderId: Int
    let pair: String
    let type: OrderType
    let priceRequested: Bool
    let priceFilled: Decimal
    let assetSoldId: Int
    let assetGetId: Int
    let createdAt: Date
    let total: Decimal?
    
}

@main
struct App {
    
    static func main() {
        print("DemoApp")
        
        do {
            let data = try DynamicDecodable(orderData1)
            guard let order = Order(data) else {
                throw NSError()
            }
            
            print(order)
        } catch {
            print("Failed with error", error)
        }
    }
    
}

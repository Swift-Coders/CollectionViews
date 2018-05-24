//
//  TradesyAPI.swift
//  CollectionViews
//
//  Created by Yariv Nissim on 5/23/18.
//  Copyright © 2018 Yariv Nissim. All rights reserved.
//

import Foundation

class Tradesy {
    /// Fetch items from Tradesy API
    /// - parameter completion: returns a dictionary of categories and a list of their items. called on Main queue.
    static func getItemsByCategory(completion: @escaping ([Category]) -> Void) {
        guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else { fatalError("You cannot call this method without the Tradesy API. Create a mock data provider instead.") }

        let url = URL(string: "https://api.tradesy.com/2.0.0/search?num_per_page=100")!
        var request = URLRequest(url: url)

        request.allHTTPHeaderFields = ["apiKey": apiKey]

        URLSession.shared.dataTask(with: request) { data, _, _ in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            guard let data = data,
                let response = try? decoder.decode(Response.self, from: data)
                else { return }

            let categories = Dictionary(grouping: response.items, by: { $0.category })
                .compactMap({ (category, items) in
                    return Category(name: category, items: items)
                })
                .sorted(by: { (left, right) in
                    left.items.count < right.items.count // desc
                })

            DispatchQueue.main.async {
                completion(categories)
            }
        }.resume()
    }
}

struct Category {
    let name: String
    let items: [Item]
    var count: Int { return items.count }

    init?(name: String, items: [Item]) {
        guard items.first != nil else { return nil } // fail if no items
        self.name = name
        self.items = items
    }

    subscript(index: Int) -> Item {
        return items[index]
    }
}

extension Collection where Element == Category, Index == Int {
    subscript(indexPath: IndexPath) -> Item {
        return self[indexPath.section][indexPath.item]
    }
}

struct Response: Codable {
    let items: [Item]
}

struct Item: Codable {
    let title: String
    let displayBrand: String
    let category: String
    let type: String
    let displaySize: String
    let price: String
    let displayPrice: String
    let shippingPrice: String
    let url: URL
    let imageCat: URL
}

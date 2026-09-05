//
//  WatchProvider.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation

struct WatchProvidersResponse: Decodable {
    let results: [String: CountryProviders]
}

struct CountryProviders: Decodable {
    let flatrate: [WatchProvider]?
}

struct WatchProvider: Decodable, Identifiable {
    let provider_id: Int
    let provider_name: String
    let logo_path: String?
    let display_priority: Int?
    
    var id: Int { provider_id }
}

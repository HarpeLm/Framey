//
//  ActivityItem.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation

struct ActivityItem: Identifiable {
    let id: String
    let actionText: String
    let title: String
    let posterPath: String?
    var rating: Int? = nil
    let date: Date
    let mediaItem: MediaItemEntity
}

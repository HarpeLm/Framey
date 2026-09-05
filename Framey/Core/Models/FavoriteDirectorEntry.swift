//
//  FavoriteDirectorEntry.swift
//  Framey
//
//  Created by Fabian Dargaud on 05/09/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteDirectorEntry {
    var personId: Int
    var name: String = ""
    var profilePath: String?
    var position: Int = 0
    
    init(personId: Int, name: String = "", profilePath: String? = nil, position: Int = 0) {
        self.personId = personId
        self.name = name
        self.profilePath = profilePath
        self.position = position
    }
}

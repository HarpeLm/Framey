//
//  ProfileTab.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation

enum ProfileTab: String, CaseIterable, Identifiable {
    case activite, listes, watchlist, aPropos
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .activite: "Activité"
        case .listes: "Listes"
        case .watchlist: "Watchlist"
        case .aPropos: "À propos"
        }
    }
}

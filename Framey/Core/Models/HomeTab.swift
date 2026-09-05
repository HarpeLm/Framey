//
//  HomeTab.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation

enum HomeTab: String, CaseIterable, Identifiable {
    case accueil, pourVous, films, series, listes
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .accueil: "Accueil"
        case .pourVous: "Pour vous"
        case .films: "Films"
        case .series: "Séries"
        case .listes: "Listes"
        }
    }
}

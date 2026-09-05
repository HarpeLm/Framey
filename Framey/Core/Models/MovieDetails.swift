//
//  MovieDetails.swift
//  Framey
//
//  Created by Fabian Dargaud on 03/09/2026.
//

import Foundation

struct MovieDetails: Decodable {
    let id: Int
    let title: String
    let runtime: Int?
    let vote_average: Double?
    let vote_count: Int?
    let genres: [Genre]
    let credits: Credits
}

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct Credits: Decodable {
    let crew: [CrewMember]
}

struct CrewMember: Decodable {
    let job: String?
    let name: String
}

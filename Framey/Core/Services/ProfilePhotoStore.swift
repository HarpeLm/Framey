//
//  ProfilePhotoStore.swift
//  Framey
//
//  Created by Fabian Dargaud on 04/09/2026.
//

import Foundation

enum ProfilePhotoStore {
    private static var fileURL: URL {
        URL.documentsDirectory.appending(path: "profile_photo.jpg")
    }
    
    static func load() -> Data? {
        try? Data(contentsOf: fileURL)
    }
    
    static func save(_ data: Data) {
        try? data.write(to: fileURL, options: .atomic)
    }
}

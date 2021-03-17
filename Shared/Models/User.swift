//
//  User.swift
//  Cloth
//
//  Created by Dante Gil-Marin on 3/9/21.
//

import Foundation
import SwiftUI

class User: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            } catch {
                fatalError("Can't find documents directory.")
            }
        }
    private static var fileURL: URL { return documentsFolder.appendingPathComponent("cloth.data") }
    
    @Published var userData: UserData = UserData.data[0]
    @Published var clothItems: [ClothItem] = []
    @Published var clothFits: [ClothFit] = []
    
    func load() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let data = try? Data(contentsOf: Self.fileURL) else {
                    #if DEBUG
                    DispatchQueue.main.async {
                        self?.clothItems = ClothItem.data
                        self?.clothFits = ClothFit.data
                        self?.userData = UserData.data[0]
                    }
                    #endif
                    return
                }
                guard let clothItems = try? JSONDecoder().decode([ClothItem].self, from: data) else {
                    fatalError("Can't decode saved cloth item data.")
                }
//                guard let clothFits = try? JSONDecoder().decode([ClothFit].self, from: data) else {
//                    fatalError("Can't decode saved cloth fit data.")
//                }
//                guard let userData = try? JSONDecoder().decode(UserData.self, from: data) else {
//                    fatalError("Can't decode saved cloth user data.")
//                }
                DispatchQueue.main.async {
                    self?.clothItems = clothItems
//                    self?.clothFits = clothFits
//                    self?.userData = userData
                }
            }
    }
    
    func save() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let clothItems = self?.clothItems else { fatalError("Self out of scope") }
                guard let data = try? JSONEncoder().encode(clothItems) else { fatalError("Error encoding data") }
                do {
                    let outfile = Self.fileURL
                    try data.write(to: outfile)
                } catch {
                    fatalError("Can't write to file")
                }
            }
    }
}

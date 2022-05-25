//
//  DataManager.swift
//  ChatAppHussyR
//
//  Created by Данил on 22.03.2022.
//

import Foundation

protocol DataManagerGCDServiceProtocol {
    func writeThemeData(theme: Int)
    func readThemeData() -> Int
    func writeProfileData(model: ProfileModel) -> Bool
    func readProfileData() -> Result<ProfileModel, Error>
}

class DataManagerGCDService: DataManagerGCDServiceProtocol {
    
    static let shared = DataManagerGCDService()
    
    private init() {
        
    }
    
    var oldSavedModel: ProfileModel?
    
    func getDocumentDirectory() -> URL {
        let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
        return url
    }
    
    func getProfile() -> URL {
        return getDocumentDirectory().appendingPathComponent("profile.plist")
    }
    
    func getTheme() -> URL {
        return getDocumentDirectory().appendingPathComponent("theme.json")
    }
    
    func writeThemeData(theme: Int) {
        do {
            let data = try JSONEncoder().encode(theme)
            try data.write(to: getTheme())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readThemeData() -> Int {
        do {
            let data = try Data(contentsOf: getTheme())
            let theme = try JSONDecoder().decode(Int.self, from: data)
            return theme
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func writeProfileData(model: ProfileModel) -> Bool {
        do {
            let data = try PropertyListEncoder().encode(model)
            try data.write(to: getProfile())
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func readProfileData() -> Result<ProfileModel, Error> {
        do {
            let data = try Data(contentsOf: getProfile())
            let model = try PropertyListDecoder().decode(ProfileModel.self, from: data)
            return .success(model)
        } catch {
            print(error.localizedDescription)
            return .failure(error)
        }
    }
    
}

// MARK: - Profile Data

struct ProfileModel: Codable {
    var name: String
    var description: String
    var image: Data?
}

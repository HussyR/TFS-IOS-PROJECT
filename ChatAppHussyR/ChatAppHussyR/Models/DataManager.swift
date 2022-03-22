//
//  DataManager.swift
//  ChatAppHussyR
//
//  Created by Данил on 22.03.2022.
//



import Foundation

class DataManager {
    
    static let shared = DataManager()
    
    private init() {
        
    }
    
    func getDocumentDirectory() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0]
        return url
    }
    
    func getProfile() -> URL {
        return getDocumentDirectory().appendingPathComponent("profile.plist")
    }
    
    func getTheme() -> URL {
        return getDocumentDirectory().appendingPathComponent("theme.plist")
    }
    
    func writeProfileData(model: ProfileData) {
        do {
            let data = try PropertyListEncoder().encode(model)
            try data.write(to: getProfile())
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func readProfileData() -> ProfileData? {
        do {
            let data = try Data(contentsOf: getProfile())
            let model = try PropertyListDecoder().decode(ProfileData.self, from: data)
            return model
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
}

//MARK: Profile Data

struct ProfileData: Codable {
    var name: String
    var description: String
    var image: Data?
}

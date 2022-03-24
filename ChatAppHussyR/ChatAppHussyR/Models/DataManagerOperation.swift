//
//  DataManagerOperation.swift
//  ChatAppHussyR
//
//  Created by Данил on 22.03.2022.
//

import Foundation

class DataManagerOperation: Operation {
    
    enum ReadOrWrite {
        case read
        case write
    }
    
    var completion: ((Bool) -> Void)?
    var readOrWrite = ReadOrWrite.write
    var profileData: ProfileModel?
    
    var getProfile: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("profile.plist")
    }
    
    override func main() {
        switch readOrWrite {
        case .read:
            read()
        case .write:
            write()
        }
    }
    
    func write() {
        guard let profileData = profileData else {
            return
        }
        do {
            let data = try PropertyListEncoder().encode(profileData)
            try data.write(to: getProfile)
            completion?(true)
        } catch {
            print(error.localizedDescription)
            completion?(false)
        }
    }
    
    func read() {
        do {
            let data = try Data(contentsOf: getProfile)
            let model = try PropertyListDecoder().decode(ProfileModel.self, from: data)
            profileData = model
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}

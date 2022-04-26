//
//  FirebaseCore.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.04.2022.
//

import Foundation
import Firebase

protocol FirebaseCoreProtocol {
    var db: Firestore { get }
    var channelsReference: CollectionReference { get }
    func addSnapshotListener(
        reference: CollectionReference,
        block: @escaping (QuerySnapshot) -> Void
    )
}

class FirebaseCore: FirebaseCoreProtocol {
    var db: Firestore {
        return Firestore.firestore()
    }
    var channelsReference: CollectionReference {
        return  db.collection("channels")
    }
    
    func addSnapshotListener(
        reference: CollectionReference,
        block: @escaping (QuerySnapshot) -> Void
    ) {
        reference.addSnapshotListener { snap, error in
            guard let snap = snap,
                  error == nil
            else { return }
            block(snap)
        }
    }
}

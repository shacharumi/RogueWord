//
//  HomeModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/6.
//


import Foundation
import UIKit
import SpriteKit

class HomeModel { 
    var personData: UserData?


    func fetchLevelNumber(completion: @escaping (UserData?) -> Void) {
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {
            print("User ID not found.")
            completion(nil)
            return
        }

        let docRef = FirestoreEndpoint.fetchPersonData.ref.document(userID)

        FirestoreService.shared.getDocument(docRef) { (personData: UserData?) in
            if let personData = personData {
                print("DEBUG here \(personData)")
                completion(personData)
            } else {
                print("DEBUG: Failed to fetch or decode UserData.")
                completion(nil)
            }
        }
    }
}

//
//  FirebaseToJSONFileUploader.swift
//  RogueWord
//
//  Created by shachar on 2024/9/13.
//

import FirebaseFirestore
import Foundation

class FirebaseToJSONFileUploader {
    let db = Firestore.firestore().collection("WordsVersion").document("0").collection("wordsCollection")
    
    // MAKR: --抓資料
    func fetchAndSaveWordsToJSON() {
        db.order(by: "levelNumber", descending: false).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in wordsCollection")
                return
            }
            
            var wordsData: [String: [String: Any]] = [:]
            
            for document in documents {
                wordsData[document.documentID] = document.data()
            }
            
            self.writeToJSONFile(wordsData: wordsData)
        }
    }
    
    // MARK: --寫進JSON
    func writeToJSONFile(wordsData: [String: [String: Any]]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: wordsData, options: .prettyPrinted)
            
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent("words.json")
                
                try jsonData.write(to: fileURL, options: .atomic)
                print("Successfully wrote words to \(fileURL.path)")
            }
        } catch {
            print("Error writing JSON file: \(error.localizedDescription)")
        }
    }
    
    // 讀檔案轉格式
    func readWordsFromJSONFile() -> [String: [String: Any]]? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("words.json")
            print("JSON file path: \(fileURL.path)")

            do {
                let data = try Data(contentsOf: fileURL)
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                return jsonData as? [String: [String: Any]]
                
            } catch {
                print("Error reading JSON file: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}

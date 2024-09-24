//
//  LevelUpGamePageModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/12.
//

import Foundation
import Firebase

class LevelUpGamePageModel {
    
    private var words: [JsonWord] = []
    private var questions: [JsonWord] = []
    var currentQuestionIndex: Int = 0
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        loadWords()
    }
    
    private func loadWords() {
        words = loadWordsFromFile()
        questions = words
    }
    
    func getCurrentQuestion() -> JsonWord? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    func generateWrongAnswers(for correctAnswer: String) -> [String] {
        var wrongAnswers = words.map { $0.chinese }.filter { $0 != correctAnswer }
        wrongAnswers.shuffle()
        return Array(wrongAnswers.prefix(3))
    }
    
    func checkAnswer(_ answer: String) -> Bool {
        guard let question = getCurrentQuestion() else { return false }
        return answer == question.chinese
    }
    
    func moveToNextQuestion() -> Bool {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            updateLevelNumber()
            return true
        } else {
            return false
        }
    }
    
    func updateLevelNumber() {
            let docRef = FirestoreEndpoint.fetchPersonData.ref.document(account)
            let fieldsToUpdate: [String: Any] = [
                "LevelNumber": currentQuestionIndex
            ]
            
            FirestoreService.shared.updateData(at: docRef, with: fieldsToUpdate) { error in
                if let error = error {
                    print("DEBUG: Failed to update LevelNumber -", error.localizedDescription)
                } else {
                    print("DEBUG: Successfully updated LevelNumber to \(self.currentQuestionIndex)")
                }
            }
        }
    func addToFavorites() {
        guard let word = getCurrentQuestion() else { return }
        
        let favoriteData: [String: Any] = [
            "LevelNumber": currentQuestionIndex,
            "Tag": "All"
        ]
        
        let db = Firestore.firestore()
        let userCollectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords").document("\(currentQuestionIndex)")
        
        userCollectionRef.setData(favoriteData, merge: true) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(self.currentQuestionIndex)")
            }
        }
    }
    
    func removeToFavorites() {
        guard let word = getCurrentQuestion() else {return}
        
        let db = Firestore.firestore()
        let userCollectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords").document("\(currentQuestionIndex)")
        
        userCollectionRef.delete() { error in
            if let error = error {
                print("Error remove document: \(error)")
            } else {
                print("Document removed with ID: \(self.currentQuestionIndex)")
            }
        }
    }
}

func loadWordsFromFile() -> [JsonWord] {
    guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Error: Could not find the documents directory.")
        return []
    }

    let fileURL = documentDirectory.appendingPathComponent("words.json")

    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        print("Error: words.json file not found in the documents directory.")
        return []
    }

    do {
        let data = try Data(contentsOf: fileURL)
        print("Successfully loaded data from words.json in documents directory.")

        let wordFile = try JSONDecoder().decode([String: JsonWord].self, from: data)
        print("Successfully decoded JSON data.")

        let sortedWords = wordFile.sorted { (firstPair, secondPair) -> Bool in
            if let firstKey = Int(firstPair.key), let secondKey = Int(secondPair.key) {
                return firstKey < secondKey
            }
            return false
        }

        print(sortedWords.map { $0.value })

        return sortedWords.map { $0.value }
    } catch {
        print("Error during JSON loading or decoding: \(error.localizedDescription)")
        return []
    }
    
    
}

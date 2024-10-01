//
//  FirestoreService.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

import FirebaseFirestore
import Foundation


enum FirestoreEndpoint {
    case fetchPersonData
    case fetchWrongQuestion
    case fetchAccurencyRecords
    var ref: CollectionReference {
        let firestore = Firestore.firestore()
        let userID = UserDefaults.standard.string(forKey: "userID")

        switch self {
        case .fetchPersonData:
            return firestore.collection("PersonAccount")
        case .fetchWrongQuestion:
            return firestore.collection("PersonAccount")
                .document(userID ?? "")
                .collection("CollectionFolderWrongQuestions")
        case .fetchAccurencyRecords:
            return firestore.collection("PersonAccount")
                .document(userID ?? "")
                .collection("AccurencyRecords")
        }
    }
}
final class FirestoreService {
    static let shared = FirestoreService()

    func getDocuments<T: Decodable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func getDocument<T: Decodable>(_ docRef: DocumentReference, completion: @escaping (T?) -> Void) {
        docRef.getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching document -", error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("DEBUG: Document does not exist.")
                completion(nil)
                return
            }
            
            print("DEBUG: Document data: \(snapshot.data() ?? [:])")
            
            do {
                let data = try snapshot.data(as: T.self)
                completion(data)
            } catch {
                print("DEBUG: Error decoding document -", error.localizedDescription)
                completion(nil)
            }
        }
    }
    func updateData(at docRef: DocumentReference, with fields: [String: Any], completion: @escaping (Error?) -> Void) {
            docRef.updateData(fields) { error in
                if let error = error {
                    print("DEBUG: Error updating document -", error.localizedDescription)
                    completion(error)
                } else {
                    print("DEBUG: Document successfully updated.")
                    completion(nil)
                }
            }
        }
    
    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(T.self) data -", error.localizedDescription)
        }
    }

    func newDocument(of collection: CollectionReference) -> DocumentReference {
        collection.document()
    }

    private func parseDocuments<T: Decodable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let errorMessage = error?.localizedDescription ?? ""
            print("DEBUG: Error fetching snapshot -", errorMessage)
            return []
        }

        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("DEBUG: Error decoding \(T.self) data -", error)
            }
        }
        return models
    }
}




struct GetParagraphType: Decodable {
    var questions: String
    var options: [String: [String]]
    var answerOptions: [String]
    var answer: String
    var title: String?
    var timestamp: Timestamp

   
}

struct GetReadingType: Decodable {
    var readingMessage: String
    var questions: [String]
    var options: [String: [String]]
    var answerOptions: [String]
    var answer: [String]
    var title: String?
    var timestamp: Timestamp
}

struct GetWordFillType: Decodable {
    var question: String  // 單一問題
    var options: [String]  // 選項數組
    var answerOptions: String  // 正確答案
    var answer: String  // 答案解釋
}

struct WordFillDocument: Decodable {
    var title: String?  // 文檔的標題
    var tag: String  // 文檔的標籤
    var questions: [GetWordFillType]  // 包含的問題列表
    var timestamp: Timestamp
}

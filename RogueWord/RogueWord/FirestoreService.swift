//
//  FirestoreService.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

import FirebaseFirestore
import Foundation

enum FirestoreEndpoint {
    case articles
    case fetchWrongQuestion
    var ref: CollectionReference {
        let firestore = Firestore.firestore()

        switch self {
        case .articles:
            return firestore.collection("articles")
        case .fetchWrongQuestion:
            return firestore.collection("PersonAccount")
                .document(account)
                .collection("CollectionFolderWrongQuestions")

        }
        
    }
}

final class FirestoreService {
    static let shared = FirestoreService()

    func getDocuments<T: Decodable>(_ query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments {[weak self] snapshot, error in
            guard let `self` = self else { return }
            completion(self.parseDocuments(snapshot: snapshot, error: error))
        }
    }

    func setData<T: Encodable>(_ data: T, at docRef: DocumentReference) {
        do {
            try docRef.setData(from: data)
        } catch {
            print("DEBUG: Error encoding \(data.self) data -", error.localizedDescription)
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
    
   
}

struct GetReadingType: Decodable {
    var readingMessage: String
    var questions: [String]
    var options: [String: [String]]
    var answerOptions: [String]
    var answer: [String]
    var title: String?
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
}

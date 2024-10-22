//
//  FirestoreService.swift
//  RogueWord
//
//  Created by shachar on 2024/9/23.
//

import FirebaseFirestore
import Foundation
import FirebaseStorage

enum FirestoreEndpoint {
    case fetchPersonData
    case fetchWrongQuestion
    case fetchFolderWords
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
        case .fetchFolderWords:
            return firestore.collection("PersonAccount")
                .document(userID ?? "")
                .collection("CollectionFolderWords")
        case .fetchAccurencyRecords:
            return firestore.collection("PersonAccount")
                .document(userID ?? "")
                .collection("AccurencyRecords")
        }
    }
}
final class FirestoreService {
    static let shared = FirestoreService()
    static let storage = Storage.storage()

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

    func setData<T: Encodable>(_ data: T, at documentRef: DocumentReference, completion: ((Error?) -> Void)? = nil) {
        do {
            let encodedData = try Firestore.Encoder().encode(data)
            documentRef.setData(encodedData) { error in
                completion?(error)
            }
        } catch let error {
            completion?(error)
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

    func deleteDocuments(matching query: Query, completion: @escaping (Error?) -> Void) {
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: 查詢文檔失敗 - \(error.localizedDescription)")
                    completion(error)
                    return
                }

                guard let snapshot = snapshot else {
                    print("DEBUG: 沒有匹配的文檔。")
                    completion(nil)
                    return
                }

                let batch = Firestore.firestore().batch()
                for document in snapshot.documents {
                    batch.deleteDocument(document.reference)
                }

                batch.commit { error in
                    if let error = error {
                        print("DEBUG: 批量刪除文檔失敗 - \(error.localizedDescription)")
                        completion(error)
                    } else {
                        print("DEBUG: 文檔已成功刪除。")
                        completion(nil)
                    }
                }
            }
        }

    func deleteDocument(at docRef: DocumentReference, completion: @escaping (Error?) -> Void) {
           docRef.delete { error in
               if let error = error {
                   print("DEBUG: 刪除文檔失敗 -", error.localizedDescription)
                   completion(error)
               } else {
                   print("DEBUG: 文檔刪除成功")
                   completion(nil)
               }
           }
       }

    func uploadImage(image: UIImage, path: String, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("DEBUG: 無法轉成JEPG")
            completion(nil)
            return
        }

        let storageRef = FirestoreService.storage.reference().child(path)

        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            guard self != nil else { return }

            if let error = error {
                print("DEBUG: 上傳圖片失敗 -", error.localizedDescription)
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: 無法獲取圖片下載 URL -", error.localizedDescription)
                    completion(nil)
                } else if let downloadURL = url {
                    print("DEBUG: 圖片下載 URL: \(downloadURL)")
                    completion(downloadURL)
                }
            }
        }
    }

    func saveImageURLToFirestore(url: URL, documentPath: String, completion: @escaping (Error?) -> Void) {
        let imageURLString = url.absoluteString
        let documentRef = Firestore.firestore().document(documentPath)

        documentRef.setData(["imageURL": imageURLString]) { error in
            if let error = error {
                print("DEBUG: 儲存圖片 URL 到 Firestore 失敗 -", error.localizedDescription)
                completion(error)
            } else {
                print("DEBUG: 圖片 URL 已成功儲存到 Firestore")
                completion(nil)
            }
        }
    }

    func downloadImageData(path: String, completion: @escaping (Data?) -> Void) {
        let storageRef = FirestoreService.storage.reference().child(path)
        storageRef.getData(maxSize: 50 * 1024 * 1024) { data, error in
            if let error = error {
                print("DEBUG: Error downloading image data - \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(data)
            }
        }
    }
}

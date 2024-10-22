import Firebase
import UIKit

class CollectionPageViewModel {

    var onDataChange: (() -> Void)?
    var onTagChange: (() -> Void)?
    var onFilterChange: (() -> Void)?
    var viewModelTag: String?
    private(set) var words: [FireBaseWord] = [] {
        didSet {
            onDataChange?()
        }
    }

    private(set) var tags: [String] = [] {
        didSet {
            onTagChange?()
        }
    }

    private(set) var filterData: [FireBaseWord] = [] {
        didSet {
            onFilterChange?()
        }
    }

    private var jsonWords: [Int: JsonWord] = [:]

    init() {}

    private func loadWordFromFile(for levelNumber: Int) -> JsonWord? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find the documents directory.")
            return nil
        }

        let fileURL = documentDirectory.appendingPathComponent("words.json")

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Error: words.json file not found in the documents directory.")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            print("Successfully loaded data from words.json in documents directory.")

            let wordFile = try JSONDecoder().decode([String: JsonWord].self, from: data)
            print("Successfully decoded JSON data.")

            if let jsonWord = wordFile["\(levelNumber)"] {
                return jsonWord
            } else {
                print("No word found for level \(levelNumber) in JSON")
                return nil
            }
        } catch {
            print("Error during JSON loading or decoding: \(error.localizedDescription)")
            return nil
        }
    }

    func fetchDataFromFirebase() {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
        let collectionRef = db.collection("PersonAccount").document(userID).collection("CollectionFolderWords").whereField("Tag", isEqualTo: viewModelTag as Any)

        collectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            guard let snapshot = snapshot else { return }

            var firebaseWords: [FireBaseWord] = []

            snapshot.documents.forEach { document in
                let data = document.data()
                guard let levelNumber = data["LevelNumber"] as? Int,
                      let tag = data["Tag"] as? String else {
                    return
                }
                print("\(levelNumber), \(tag)")
                if let jsonWord = self?.loadWordFromFile(for: levelNumber) {
                    let fireBaseWord = FireBaseWord(levelNumber: levelNumber, tag: tag, word: jsonWord)
                    firebaseWords.append(fireBaseWord)

                } else {
                    print("No data found in JSON for level \(levelNumber)")
                }
            }
            self?.words = firebaseWords
        }
    }

    func fetchTagFromFirebase() {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
        let accountRef = db.collection("PersonAccount").document(userID)

        accountRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching tags: \(error)")
                return
            }

            guard let document = document, document.exists else {
                print("Document does not exist.")
                return
            }

            if let tags = document.data()?["Tag"] as? [String] {
                self?.tags = tags

            } else {
                print("No tags found in the document.")
            }
        }
    }

    func removeWord(at index: Int) {
        let wordToRemove = words[index]

        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}

        let collectionRef = db.collection("PersonAccount").document(userID).collection("CollectionFolderWords")

        collectionRef.document("\(wordToRemove.levelNumber)").delete { [weak self] error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
                self?.words.remove(at: index)
            }
        }
    }

    func removeTag(_ index: Int) {
        let tagToRemove = tags[index]
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
        let accountRef = db.collection("PersonAccount").document(userID)
        let collectionRef = accountRef.collection("CollectionFolderWords")
        accountRef.updateData([
            "Tag": FieldValue.arrayRemove([tagToRemove])
        ]) { [weak self] error in
            if let error = error {
                print("Error removing tag: \(error)")
            } else {
                print("Tag successfully removed!")
                self?.tags.remove(at: index)
                self?.onTagChange?()

                self?.removeWordsWithTag(tagToRemove, collectionRef: collectionRef)
            }
        }
    }

    private func removeWordsWithTag(_ tag: String, collectionRef: CollectionReference) {
        collectionRef.whereField("Tag", isEqualTo: tag).getDocuments { [weak self] (snapshot, error) in
            if let error = error {

                print("Error fetching words with tag: \(error)")
            } else {
                guard let documents = snapshot?.documents else { return }

                for document in documents {
                    collectionRef.document(document.documentID).delete { error in
                        if let error = error {
                            print("Error removing word with tag: \(error)")
                        } else {
                            print("Word with tag \(tag) successfully removed!")
                            print("Before removeAll: \(String(describing: self?.words))")
                            self?.words.removeAll { $0.tag == tag }
                            print("After removeAll: \(String(describing: self?.words))")
                            self?.onDataChange?()
                        }
                    }
                }
            }
        }
    }

    func updateWordTag(_ tag: String, _ levelNumber: Int) {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
        let collectionRef = db.collection("PersonAccount").document(userID).collection("CollectionFolderWords")
        print(self.words)

        collectionRef.document("\(levelNumber)").updateData([
            "Tag": tag
        ]) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")

                if let index = self?.words.firstIndex(where: { $0.levelNumber == levelNumber }) {
                    self?.words[index].tag = tag
                    self?.onDataChange?()
                }
            }
        }
    }

    func addTag(_ tagText: String) {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}

        let accountRef = db.collection("PersonAccount").document(userID)

        accountRef.updateData([
            "Tag": FieldValue.arrayUnion([tagText])
        ]) { [weak self] error in
            if let error = error {
                print("Error adding tag: \(error)")
            } else {
                print("Tag successfully added!")
                self?.tags.append(tagText)
                self?.onTagChange?()
            }
        }
    }

    func fetchFilterData(_ tag: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        guard let userID = UserDefaults.standard.string(forKey: "userID") else {return}
        let collectionRef = db.collection("PersonAccount").document(userID).collection("CollectionFolderWords")

        collectionRef.whereField("Tag", isEqualTo: tag).getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completion()
                return
            }

            guard let snapshot = snapshot else {
                print("No data found for tag: \(tag)")
                completion()
                return
            }

            var filteredWords: [FireBaseWord] = []

            snapshot.documents.forEach { document in
                let data = document.data()
                guard let levelNumber = data["LevelNumber"] as? Int,
                      let tag = data["Tag"] as? String else {
                    return
                }

                if let jsonWord = self?.loadWordFromFile(for: levelNumber) {
                    let fireBaseWord = FireBaseWord(levelNumber: levelNumber, tag: tag, word: jsonWord)
                    filteredWords.append(fireBaseWord)
                } else {
                    print("No data found in JSON for level \(levelNumber)")
                }
            }

            self?.words = filteredWords
            completion()
        }
    }

}

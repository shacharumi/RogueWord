import Firebase
import UIKit

class CollectionPageViewModel {
    
    var onDataChange: (() -> Void)?
    var onTagChange: (() -> Void)?
    var onFilterChange: (() -> Void)?
    
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

    // 初始化時不直接載入本地 JSON，改為先從 Firebase 獲取數據
    init() {}

    // 讀取本地的 words.json 檔案，並將其解析為字典形式
    // 查詢本地的 JSON 檔案，根據 levelNumber 返回對應的 JsonWord
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

            // 查找與 levelNumber 對應的 word
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

    // 從 Firebase 獲取資料，並逐個查詢對應的 JSON 檔案
    func fetchDataFromFirebase() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords")
        
        collectionRef.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            // 創建一個空的陣列來儲存結果
            var firebaseWords: [FireBaseWord] = []
            
            // 遍歷從 Firebase 獲取的文件
            snapshot.documents.forEach { document in
                let data = document.data()
                guard let levelNumber = data["LevelNumber"] as? Int,
                      let tag = data["Tag"] as? String else {
                    return
                }
                print("\(levelNumber), \(tag)")
                // 查詢本地 JSON 檔案對應的 word
                if let jsonWord = self?.loadWordFromFile(for: levelNumber) {
                    let fireBaseWord = FireBaseWord(levelNumber: levelNumber, tag: tag, word: jsonWord)
                    firebaseWords.append(fireBaseWord)
                    
                } else {
                    print("No data found in JSON for level \(levelNumber)")
                }
            }
            
            // 更新 words，通知資料已變更
            self?.words = firebaseWords
            print(firebaseWords)

        }
    }
    
    func fetchTagFromFirebase() {
        let db = Firestore.firestore()
        let accountRef = db.collection("PersonAccount").document(account)
        
        accountRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching tags: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist.")
                return
            }
            
            // 確保我們能夠成功讀取 `Tag` 資料
            if let tags = document.data()?["Tag"] as? [String] {
                self?.tags = tags.sorted()  // 選擇性地對標籤進行排序
                
                // 通知 UI 標籤已更新
                self?.onTagChange?()
            } else {
                print("No tags found in the document.")
            }
        }
    }




    // 從 Firebase 中移除詞彙
    func removeWord(at index: Int) {
        let wordToRemove = words[index]
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document("CollectionFolder")
        
        collectionRef.updateData([
            "\(wordToRemove.levelNumber)": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

    // 更新詞彙的 tag
    func updateWordTag(_ tag: String, _ levelNumber: Int) {
        print("aa")
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords")
        
        collectionRef.document("\(levelNumber)").updateData([
            "Tag": tag
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }

    // 過濾數據
    // 過濾數據
    func fetchFilterData(_ tag: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("PersonAccount").document(account).collection("CollectionFolderWords")
        
        // 過濾 Firebase 中對應 tag 的文檔
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
            
            // 創建一個空的陣列來存放過濾結果
            var filteredWords: [FireBaseWord] = []
            
            // 遍歷獲取的文檔，根據 levelNumber 讀取本地 JSON 資料
            snapshot.documents.forEach { document in
                let data = document.data()
                guard let levelNumber = data["LevelNumber"] as? Int,
                      let tag = data["Tag"] as? String else {
                    return
                }
                
                // 使用 levelNumber 從本地 JSON 中獲取對應的資料
                if let jsonWord = self?.loadWordFromFile(for: levelNumber) {
                    let fireBaseWord = FireBaseWord(levelNumber: levelNumber, tag: tag, word: jsonWord)
                    filteredWords.append(fireBaseWord)
                } else {
                    print("No data found in JSON for level \(levelNumber)")
                }
            }
            
            // 更新 filterData，通知資料已變更
            self?.words = filteredWords
            completion()
        }
    }

}

// FireBaseWord 結構，包含 levelNumber、tag 和對應的詞彙資料
struct FireBaseWord {
    let levelNumber: Int
    let tag: String
    let word: JsonWord
}

// 本地詞彙的結構
struct JsonWord: Decodable {
    let levelNumber: Int
    let english: String
    let chinese: String
    let property: String
    let sentence: String
}

//
//  WrongQuestionWordViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

// WrongQuestionWordViewModel.swift
// WrongQuestionWordViewModel.swift
// WrongQuestionWordViewModel.swift
import Foundation
import Firebase

class WrongQuestionWordViewModel {
    var questions: [GetWordFillType]
    var selectedAnswers: [String]
    var isTapCheck: Bool = false
    var questionsTitle: String?
    
    // 移除 dataDismiss，因为这是视图控制器的职责
    // var dataDismiss: (() -> Void)?
    
    init(questions: [GetWordFillType], questionsTitle: String?) {
        self.questions = questions
        self.selectedAnswers = Array(repeating: "", count: questions.count)
        self.questionsTitle = questionsTitle
    }
    
    func getQuestion(at index: Int) -> GetWordFillType {
        return questions[index]
    }
    
    func getSelectedAnswer(for index: Int) -> String {
        return selectedAnswers[index]
    }
    
    func setSelectedAnswer(_ answer: String, for index: Int) {
        selectedAnswers[index] = answer
    }
    
    func isAnswerCorrect(at index: Int) -> Bool {
        return selectedAnswers[index] == questions[index].answerOptions
    }
    
    func showAnswers() {
        isTapCheck = true
    }
    
    func cancelCollection(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let title = questionsTitle else {
            completion(.failure(NSError(domain: "No title", code: -1, userInfo: nil)))
            return
        }
        let query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("title", isEqualTo: title)
        query.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                if snapshot.documents.isEmpty {
                    completion(.failure(NSError(domain: "No documents", code: -1, userInfo: nil)))
                    return
                }
                for document in snapshot.documents {
                    document.reference.delete { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            print("Document successfully removed!")
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
}

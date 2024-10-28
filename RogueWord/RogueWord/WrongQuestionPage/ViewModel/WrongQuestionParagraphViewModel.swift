//
//  WrongQuestionParagraphViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation
import Firebase

class WrongQuestionParagraphViewModel {
    var questionData: GetParagraphType
    var selectedAnswers: [String]
    var isTapCheck: Bool = false
    var questionsTitle: String?
    var answerArray: [String]

    init(questionData: GetParagraphType, questionsTitle: String?) {
        self.questionData = questionData
        self.questionsTitle = questionsTitle

        let optionsCount = questionData.options.count
        self.selectedAnswers = Array(repeating: "", count: optionsCount)

        self.answerArray = questionData.answer.components(separatedBy: "。")
    }

    func getQuestionText() -> String {
        return questionData.questions
    }

    func getOptions(for index: Int) -> [String] {
        return questionData.options["option_set_\(index)"] ?? []
    }

    func getSelectedAnswer(for index: Int) -> String {
        return selectedAnswers[index]
    }

    func setSelectedAnswer(_ answer: String, for index: Int) {
        selectedAnswers[index] = answer
    }

    func getCorrectAnswer(for index: Int) -> String {
        return questionData.answerOptions[index]
    }

    func showAnswers() {
        isTapCheck = true
    }

    func getAnswerText(for index: Int) -> String {
        if index < answerArray.count {
            return answerArray[index]
        } else {
            return "No answer available"
        }
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

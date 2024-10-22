//
//  WrongQuestionReadingViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation
import Firebase

class WrongQuestionReadingViewModel {
    var readingData: GetReadingType
    var selectedAnswers: [String]
    var isTapCheck: Bool = false
    var questionsTitle: String?

    init(readingData: GetReadingType, questionsTitle: String?) {
        self.readingData = readingData
        self.questionsTitle = questionsTitle

        let questionsCount = readingData.questions.count
        self.selectedAnswers = Array(repeating: "", count: questionsCount)
    }

    func getReadingMessage() -> String {
        return readingData.readingMessage
    }

    func getQuestion(at index: Int) -> String {
        return readingData.questions[index]
    }

    func getOptions(for index: Int) -> [String] {
        return readingData.options["option_set_\(index)"] ?? []
    }

    func getSelectedAnswer(for index: Int) -> String {
        return selectedAnswers[index]
    }

    func setSelectedAnswer(_ answer: String, for index: Int) {
        selectedAnswers[index] = answer
    }

    func getCorrectAnswer(for index: Int) -> String {
        return readingData.answerOptions[index]
    }

    func getAnswerText(for index: Int) -> String {
        return readingData.answer[index]
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

////
////  FirebaseService.swift
////  RogueWord
////
////  Created by shachar on 2024/9/11.
////
//
//import FirebaseFirestore
//
//class FirebaseService {
//    private let db = Firestore.firestore()
//
//    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
//        db.collection("questions").getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                var questions: [Question] = []
//                for document in querySnapshot!.documents {
//                    let data = document.data()
//                    let questionText = data["question"] as? String ?? ""
//                    let options = data["options"] as? [String] ?? []
//                    let correctAnswer = data["correctAnswer"] as? String ?? ""
//                    let question = Question(question: questionText, options: options, correctAnswer: correctAnswer)
//                    questions.append(question)
//                }
//                completion(questions)
//            }
//        }
//    }
//}
//
//
//import Foundation
//
//struct Question {
//    let question: String
//    let options: [String]
//    let correctAnswer: String
//}

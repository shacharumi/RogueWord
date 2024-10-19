//
//  WrongQuestionsViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation
import FirebaseFirestore

class WrongQuestionsViewModel {
    
    enum QuestionType {
        case wordQuiz
        case paragraph
        case reading
    }
    
    // MARK: - Properties
    private(set) var wordQuestions: [WordFillDocument] = []
    private(set) var paragraphQuestions: [GetParagraphType] = []
    private(set) var readingQuestions: [GetReadingType] = []
    
    var currentQuestionType: QuestionType = .paragraph {
        didSet {
            fetchQuestions()
        }
    }
    
    var onDataUpdated: (() -> Void)?
    
    // MARK: - Methods
    
    func fetchQuestions() {
        var query: Query?
        
        switch currentQuestionType {
        case .wordQuiz:
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "單字測驗")
        case .paragraph:
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "段落填空")
        case .reading:
            query = FirestoreEndpoint.fetchWrongQuestion.ref.whereField("tag", isEqualTo: "閱讀理解")
        }
        
        guard let query = query else { return }
        
        // Fetch data based on currentQuestionType
        switch currentQuestionType {
        case .wordQuiz:
            FirestoreService.shared.getDocuments(query) { [weak self] (questions: [WordFillDocument]) in
                self?.wordQuestions = questions
                self?.onDataUpdated?()
            }
        case .paragraph:
            FirestoreService.shared.getDocuments(query) { [weak self] (paragraphs: [GetParagraphType]) in
                self?.paragraphQuestions = paragraphs
                self?.onDataUpdated?()
            }
        case .reading:
            FirestoreService.shared.getDocuments(query) { [weak self] (readings: [GetReadingType]) in
                self?.readingQuestions = readings
                self?.onDataUpdated?()
            }
        }
    }
}


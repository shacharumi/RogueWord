//
//  ExamViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/9/22.
//

import Foundation

class ExamViewModel {

    private(set) var exams: [Exam]
    var currentVisibleIndex: Int?

    init() {
        self.exams = [
            Exam(title: "單字填空"),
            Exam(title: "段落填空"),
            Exam(title: "閱讀理解"),
            Exam(title: "聽力測驗")
        ]
    }

    func numberOfExams() -> Int {
        return exams.count
    }

    func examTitle(at index: Int) -> String {
        return exams[index].title
    }

    func updateCurrentVisibleIndex(to index: Int) {
        currentVisibleIndex = index
    }

    func currentExamTitle() -> String? {
        guard let currentVisibleIndex = currentVisibleIndex else { return nil }
        return exams[currentVisibleIndex].title
    }
}

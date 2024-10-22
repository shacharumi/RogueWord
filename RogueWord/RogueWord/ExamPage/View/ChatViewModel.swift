//
//  ChatViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/16.
//

import Foundation

class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    var reloadTableViewClosure: (() -> Void)?
    var scrollToBottomClosure: (() -> Void)?
    var showErrorClosure: ((String) -> Void)?
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(role: "user", content: text)
        messages.append(userMessage)
        reloadTableViewClosure?()
        scrollToBottomClosure?()
        
        sendToChatGPT()
    }
    
    private func sendToChatGPT() {
        guard let apiKey = getAPIKey() else {
            showErrorClosure?("無法取得 API 金鑰。")
            return
        }
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemMessage = ChatMessage(role: "system", content: "如果問題是中文，請優先使用繁體中文回答")
        
        let maxMessages = 20
        let recentMessages = messages.suffix(maxMessages)
        let messagesForAPI = [["role": systemMessage.role, "content": systemMessage.content]] + recentMessages.map { ["role": $0.role, "content": $0.content] }
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messagesForAPI
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            showErrorClosure?("無法序列化 JSON。")
            return
        }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.showErrorClosure?("請求錯誤：\(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self?.showErrorClosure?("未收到任何資料。")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let messageDict = choices.first?["message"] as? [String: Any],
                   let content = messageDict["content"] as? String {
                    
                    let botMessage = ChatMessage(role: "assistant", content: content.trimmingCharacters(in: .whitespacesAndNewlines))
                    self?.messages.append(botMessage)
                    DispatchQueue.main.async {
                        self?.reloadTableViewClosure?()
                        self?.scrollToBottomClosure?()
                    }
                } else {
                    self?.showErrorClosure?("無法解析回應資料。")
                }
            } catch {
                self?.showErrorClosure?("解析錯誤：\(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    
    private func getAPIKey() -> String? {
        return ChatGPTAPIKey.key
    }
}

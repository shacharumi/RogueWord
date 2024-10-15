import Foundation
import FirebaseStorage
import UIKit
import UserNotifications

class PersonFileViewModel {
    
    var user = PersonPageModel()
    
    let settingsOptions = [
        ("修改名稱 & 大頭貼", UIImage(systemName: "person.crop.circle.fill")),
        ("分享APP给朋友", UIImage(systemName: "square.and.arrow.up")),
        ("設定提醒時間", UIImage(systemName: "clock.fill")),
        ("選擇版本", UIImage(systemName: "book.fill")),
        ("登出", UIImage(systemName: "arrowshape.turn.up.left.fill")),
        ("刪除帳號", UIImage(systemName: "trash.fill"))
    ]
    
    func shareApp(from viewController: UIViewController) {
        let appLink = "沒有連結QQ"
        let activityVC = UIActivityViewController(activityItems: ["快點下載這個好用APP", appLink], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true, completion: nil)
    }
    
    func scheduleNotification(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "時間到了！"
        content.body = "快點來複習拉！！"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DEBUG 設置通知失敗：\(error.localizedDescription)")
            } else {
                print("設置通知成功")
            }
        }
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("授權成功")
            } else if let error = error {
                print("DEBUG 授權失敗：\(error.localizedDescription)")
            }
        }
    }
    
    func clearUserData() {
        user.clearUserData()
    }
}

class PersonPageModel {
    var name: String {
        get {
            return UserDefaults.standard.string(forKey: "userName") ?? "預設用戶"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userName")
            guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
            let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
            let fieldsToUpdate: [String: Any] = [
                "userName": newValue,
            ]
            
            FirestoreService.shared.updateData(at: query, with: fieldsToUpdate) { error in
                if let error = error {
                    print("DEBUG: Failed to update userName -", error.localizedDescription)
                } else {
                    print("DEBUG: Successfully updated userName to \(newValue)")
                }
            }
        }
    }
    
    var profileImage: UIImage {
        get {
            if let imageData = UserDefaults.standard.data(forKey: "imageData"),
               let image = UIImage(data: imageData) {
                return image
            } else {
                return UIImage(named: "default_avatar") ?? UIImage()
            }
        }
        
        set {
            if let imageData = newValue.pngData() {
                UserDefaults.standard.set(imageData, forKey: "imageData")
            }
            uploadImageToFirebase(image: newValue)
        }
    }
    
    func uploadImageToFirebase(image: UIImage) {
        guard let imageData = image.pngData() else {
            print("DEBUG 無法將圖片轉換為 PNG")
            return
        }
        
        let fileName = UserDefaults.standard.string(forKey: "userID") ?? "預設用戶"
        let storageRef = Storage.storage().reference().child("\(fileName)/userImage.png")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("圖片上傳失敗: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("DEBUG 獲取圖片 URL 失敗: \(error.localizedDescription)")
                } else if let downloadURL = url {
                    UserDefaults.standard.set(downloadURL, forKey: "userImageURL")
                    print("圖片上傳成功，下載 URL: \(downloadURL)")
                    
                    guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
                    let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
                    let fieldsToUpdate: [String: Any] = [
                        "image": "\(fileName)/userImage.png",
                    ]
                    FirestoreService.shared.updateData(at: query, with: fieldsToUpdate) { error in
                        if let error = error {
                            print("DEBUG: Failed to update image -", error.localizedDescription)
                        } else {
                            print("DEBUG: Successfully updated image to \(downloadURL)")
                        }
                    }
                }
            }
        }
    }
    
    var selectedVersion: String {
        get {
            return UserDefaults.standard.string(forKey: "userVersion") ?? "多益"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userVersion")
            guard let userID = UserDefaults.standard.string(forKey: "userID") else { return }
            let query = FirestoreEndpoint.fetchPersonData.ref.document(userID)
            let fieldsToUpdate: [String: Any] = [
                "version": newValue,
            ]
            
            FirestoreService.shared.updateData(at: query, with: fieldsToUpdate) { error in
                if let error = error {
                    print("DEBUG: Failed to update version -", error.localizedDescription)
                } else {
                    print("DEBUG: Successfully updated version to \(newValue)")
                }
            }
        }
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "imageData")
        UserDefaults.standard.removeObject(forKey: "userVersion")
    }
}

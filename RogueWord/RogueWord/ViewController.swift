//import UIKit
//import FirebaseDatabase
//
//let player1 = "leo"
//let player2 = "jack"
//
//class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    @IBOutlet weak var roomIdTextField: UITextField!
//    @IBOutlet weak var createRoomButton: UIButton!
//    @IBOutlet weak var tableView: UITableView!
//    
//    var rooms: [String] = []  // 用來儲存房間ID的列表
//    let gameService = GameService()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        // 監聽房間列表的變化
//        gameService.observeGames { [weak self] newRooms in
//            self?.rooms = newRooms
//            self?.tableView.reloadData()  // 更新UITableView
//        }
//    }
//
//    // MARK: - UITableView DataSource
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return rooms.count  // 房間數量
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath)
//        cell.textLabel?.text = rooms[indexPath.row]  // 顯示房間ID
//        let joinButton = UIButton(type: .system)
//        joinButton.setTitle("+", for: .normal)
//        joinButton.addTarget(self, action: #selector(joinRoomTapped(_:)), for: .touchUpInside)
//        cell.accessoryView = joinButton
//        joinButton.tag = indexPath.row  // 使用tag來標記行數
//        return cell
//    }
//    
//    // 當按下加入按鈕時
//    @objc func joinRoomTapped(_ sender: UIButton) {
//        let roomId = rooms[sender.tag]  // 獲取房間ID
//        gameService.joinGame(gameId: roomId, player2Id: "2") { success in
//            if success {
//                print("Successfully joined game: \(roomId)")
//                // 可以跳轉到遊戲界面或進行其他操作
//            } else {
//                print("Failed to join game")
//            }
//        }
//    }
//
//    // 當按下創建房間按鈕時
//    @IBAction func createRoomTapped(_ sender: UIButton) {
//        guard let roomId = roomIdTextField.text, !roomId.isEmpty else {
//            print("Please enter a room ID")
//            return
//        }
//        
//        // 創建房間
//        gameService.createGame(player1Id: player1, roomId: player1) { [weak self] gameId in
//            if let gameId = gameId {
//                // 創建成功，呈現滿版的 GamingViewController
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let gamingVC = storyboard.instantiateViewController(identifier: "GamingViewController") as? GamingViewController {
//                    gamingVC.gameId = gameId  // 傳遞房間ID
//                    gamingVC.player1Id = "1"  // Player1 ID
//                    gamingVC.modalPresentationStyle = .fullScreen  // 設置為滿版呈現
//                    self?.present(gamingVC, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//}


import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

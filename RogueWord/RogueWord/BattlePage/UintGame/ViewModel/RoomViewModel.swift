//
//  RoomViewModel.swift
//  RogueWord
//
//  Created by shachar on 2024/10/15.
//

import Foundation
import Firebase
import FirebaseDatabaseInternal

class RoomViewModel {

    private var roomID: String?
    private var databaseRef: DatabaseReference?

    var participants: [Participant] = [] {
        didSet {
            self.onParticipantsUpdated?()
        }
    }

    var isRoomCreator: Bool = false {
        didSet {
            self.onRoomCreatorStatusChanged?()
        }
    }

    var isStart: Bool = false {
        didSet {
            self.onIsStartChanged?()
        }
    }

    var onParticipantsUpdated: (() -> Void)?
    var onRoomCreatorStatusChanged: (() -> Void)?
    var onIsStartChanged: (() -> Void)?
    var onError: ((Error) -> Void)?

    init(roomID: String?) {
        self.roomID = roomID
        if let roomID = roomID {
            self.databaseRef = Database.database().reference().child("rooms").child(roomID)
        }
    }

    func fetchParticipants() {
        guard let ref = databaseRef?.child("participants") else { return }

        ref.observe(.value) { [weak self] snapshot in
            var fetchedParticipants: [Participant] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let participantData = childSnapshot.value as? [String: Any],
                   let participant = Participant(dictionary: participantData) {
                    fetchedParticipants.append(participant)
                }
            }

            fetchedParticipants.sort { p1, p2 in
                if p1.accuracy != p2.accuracy {
                    return p1.accuracy > p2.accuracy
                } else {
                    return p1.time < p2.time
                }
            }

            self?.participants = fetchedParticipants
        }
    }

    func checkIfRoomCreator() {
        guard let ref = databaseRef else { return }

        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self,
                  let roomData = snapshot.value as? [String: Any],
                  let createdByEmail = roomData["createdByEmail"] as? String,
                  let currentUserEmail = UserDefaults.standard.string(forKey: "email") else { return }

            self.isRoomCreator = (createdByEmail == currentUserEmail)
        }
    }

    func observeIsStart() {
        guard let ref = databaseRef?.child("isStart") else { return }

        ref.observe(.value) { [weak self] snapshot in
            if let isStart = snapshot.value as? Bool {
                self?.isStart = isStart
                if isStart {
                    ref.removeAllObservers()
                }
            }
        }
    }

    func startGame(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let ref = databaseRef else { return }

        ref.updateChildValues(["isStart": true]) { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func removeObservers() {
        databaseRef?.removeAllObservers()
    }
}

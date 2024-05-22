//
//  ChatViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/20/24.
//
// MARK: - ChatViewModel(채팅 관리)
// MainView

import Foundation
import Firebase

final class ChatViewModel: ObservableObject  {
    
    // MARK: - Property
    @Published var messages: [Message] = []
    
    @Published var chatText: String = ""
    
    let db = Firestore.firestore() // FireStore 데이터베이스 참조 생성
    
    private let firebaseService: FirebaseServiceProtocol
    
    // MARK: - init
    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
        loadMessage()
    }
    
    
    // MARK: - Function
    
    // FireBase 데이터베이스 데이터 로드
    func loadMessage() {
        // addSnapshotListener로 실시간 업데이트 수신
        db.collection(K.Firebase.collectionName)
            .order(by: K.Firebase.dateField) // date기준 정렬
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.messages = []
                if let error = error {
                    print("SnapshotError: \(error.localizedDescription)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments { // 스냅샷을 반복하여 스캔
                            print(doc.data())
                            let data = doc.data() // data는 key-value 쌍 ["body": ~, "sender": a@abc.com]
                            if let messageSender = data[K.Firebase.senderField] as? String,
                               let meessageBody = data[K.Firebase.bodyField] as? String { // 타입캐스팅(Any? -> String)
                                let newMessage = Message(sender: messageSender, body: meessageBody, isSentByCurrentUser: messageSender == Auth.auth().currentUser?.email ? true : false)
                                self.messages.append(newMessage)
                            }
                        }
                    }
                }
            }
    }
}

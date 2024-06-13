//
//  ChatViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/20/24.
//
// MARK: - ChatViewModel(채팅 관리)
// MainView

import Foundation
import Combine

final class ChatViewModel: ObservableObject  {
    
    // MARK: - Property
    @Published var messages: [Message] = []
    
    @Published var chatText: String = ""
    
    private let firebaseService: FirebaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - init
    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
//        firebaseService.deleteDocuments() // 파이어베이스 데이터 삭제
        bindFirebaseService()
    }
    
    
    // MARK: - Function
    
    func sendMessage() {
        guard !chatText.isEmpty else { return }
        print(chatText)
        firebaseService.sendMessage(inText: chatText)
    }

    // FireBase 데이터베이스 데이터 로드
    func loadMessage() {
        firebaseService.loadMessage()
    }
    
    
    // MARK: - Private Function
    
    // MARK: (Combine)FirebaseService 바인딩
    private func bindFirebaseService() {
        firebaseService.messageStatePublisher
            .receive(on: DispatchQueue.main)
        // MARK: (Old) .sink는 클로저를 통해 값을 처리하므로 추가적인 로직이 필요할때 사용
//            .sink { [weak self] message in
//                guard let self = self else { return }
//                self.messages = message
//                print("messageStatePublisher-1\(message)")
//                print("messageStatePublisher-2\(self.messages)")
//            }
        // MARK: (New) .assign은 간단하게 값을 할당할 때 사용
        // 현재 객체의 messages(키패스)에 값을 받는다.
            .assign(to: \.messages, on: self)
            .store(in: &cancellables)
    }
}

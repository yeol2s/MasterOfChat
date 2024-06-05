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
//        firebaseService.deleteDocuments()
        bindFirebaseService()
        loadMessage()
    }
    
    
    // MARK: - Function
    
    func sendMessage() {
        guard !chatText.isEmpty else { return }
        print(chatText)
        firebaseService.sendMessage(inText: chatText)
    }
    
    
    
    // MARK: - Private Function
    
    // FireBase 데이터베이스 데이터 로드
    private func loadMessage() {
        firebaseService.loadMessage()
    }
    
    // MARK: (Combine)FirebaseService 바인딩
    private func bindFirebaseService() {
        firebaseService.messageStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else { return }
                self.messages = message
                print("messageStatePublisher-1\(message)")
                print("messageStatePublisher-2\(self.messages)")
            }
            .store(in: &cancellables)
    }

}

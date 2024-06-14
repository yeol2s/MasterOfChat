//
//  MainViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/13/24.
//
// MARK: - AuthViewModel(FireBase 인증관리)
// MainView

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    // MARK: - Property

    //@Published var isloginViewSheet: Bool = false
    @Published var isUserLoggedIn: Bool = false // 로그인 상태 변경 감지
    
    
    @Published var showAlert: Bool = false
    
    private let firebaseService: FirebaseServiceProtocol
    private var cancellables = Set<AnyCancellable>() // Combine 구독취소(메모리 누수 관리)
    
    // MARK: - init
    // 싱글톤으로 FirebaseSerivce 주입
    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
        setupFirebaseAuth() // 삭제된 계정 확인 및 addStateDidChangeListener 등록
        bindFirebaseService()
    }
    
    // MARK: - Funtion
    
    // 로그아웃
    func signOut() {
        firebaseService.signOut()
    }
    
    
    // MARK: - Private Function
    
    // Firebase Setup(등록사용자 및 로그인 상태 확인)
    private func setupFirebaseAuth() {
        
        // 로그인 상태에서 콘솔에서 계정 삭제가 되는 경우 앱 다시 실행시 Firebase에서 ID Token을 확인하여 로그아웃 처리하고 리스너에서 변화된 값을 감지해서 currentUser를 nil 처리 -> 로그인 화면 sheet
        firebaseService.userAuthStatusCheck()
    }
    
    // MARK: (Combine)FirebaseService 바인딩
    private func bindFirebaseService() {
        firebaseService.authStatePublisher
            .receive(on: DispatchQueue.main) // 메인스레드에서 값을 수신 처리
            .sink { [weak self] isLoggedIn in // 구독
                guard let self = self else { return }
                self.isUserLoggedIn = isLoggedIn // Publisher로 부터 send를 받아서 할당하여 로그인 상태 변경
            }
        // .store: Subscription을 저장하고 관리
        // AnyCancellable에 넣어주므로 메모리에서 사라질 때 구독도 같이 취소되도록 하여 메모리 누수를 방지.
            .store(in: &cancellables)
    }
}



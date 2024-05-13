//
//  MainViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/13/24.
//
// MARK: - Main ViewModel(
// 채팅 화면

import Foundation
import Firebase

final class MainViewModel: ObservableObject {
    // MARK: - Property
    // 현재 유저 로그인 상태 체크
    @Published var currentUser: Firebase.User?
    @Published var isLoginStatus: Bool = false
    
    // MARK: - init
    init() {
        currentUser = Auth.auth().currentUser // 현재 유저의 상태를 가져와서 할당
        setupLoginStatus() // 로그인 상태(로그인 상태일시 false, 아닐시 true)
    }
    
    // MARK: - Funtion
    
    // MARK: - 🖐️ sheet 때문에 Bool 값을 반대로 설정했는데 추후 다시 보자.
    // 로그인 상태 Bool 값으로 할당(.sheet에 바인딩되어 true일시 로그인뷰로 sheet되므로 Bool 값을 반대로 할당)
    private func setupLoginStatus() {
        if let _ = currentUser {
            isLoginStatus = false
        } else {
            isLoginStatus = true
        }
    }
}



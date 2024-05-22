//
//  FirebaseSerivce.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/22/24.
//
// MARK: - FireBaseService
// 의존성 주입으로 구현

import Foundation
import Firebase

// MARK: - Protocol
protocol FirebaseServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<LoginSuccess, LoginError>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void)
    func signOut()
    func loadMessage()
    func userAuthStatusCheck()
    func checkIDToken(user: User)
    
    
}

// MARK: - FireBaseService(싱글톤)
final class FirebaseService: FirebaseServiceProtocol {
    
    static let shared = FirebaseService()
    private init() {} // 새로운 객체 생성 차단
    
    // TODO: 뷰모델에 의존성 주입
    func signIn(email: String, password: String, completion: @escaping (Result<LoginSuccess, LoginError>) -> Void) {
        // TODO: LoginViewModel
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // TODO: AuthViewModel
    }
    
    func signOut() {
        // TODO: AuthViewModel
    }
    
    func loadMessage() {
        // TODO: ChatViewModel
    }
    
    func userAuthStatusCheck() {
        // TODO: AuthViewModel
    }
    
    func checkIDToken(user: User) {
        // TODO: AuthViewModel
    }

}

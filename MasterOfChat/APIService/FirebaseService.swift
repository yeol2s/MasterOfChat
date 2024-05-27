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
    //    func signIn(email: String, password: String, completion: @escaping (Result<LoginSuccess, LoginError>) -> Void)
    func signIn(email: String, password: String) async -> Result<LoginSuccess, LoginError>
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
    
    // MARK: - Function
    
    // async/await
    func signIn(email: String, password: String) async -> Result<LoginSuccess, LoginError> {
        await withCheckedContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let _ = error {
                    continuation.resume(returning: .failure(.authError))
                } else {
                    continuation.resume(returning: .success(.loginSuccess))
                }
            }
        }
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
    
    // MARK: - Private Function
    
    // 이메일 유효성 확인
    private func isValidEmail(_ email: String) -> Bool {
        // 이메일 주소 정규표현식
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegex)
            let matches = regex.matches(in: email, range: NSRange(location: 0, length: email.utf16.count))
            return !matches.isEmpty
        } catch {
            return false
        }
    }
    
}

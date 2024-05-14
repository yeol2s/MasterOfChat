//
//  RegisterViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/13/24.
//
// MARK: - Register ViewModel
// 회원가입

import Foundation
import Firebase

// MARK: - TypeAlias
typealias AlertStatus = (title: String, message: String)

// MARK: - Protocol
protocol AlertType { }

// MARK: - Enum
enum RegisterSuccess: AlertType {
    case joinSuccess
}

// MARK: - Error
enum RegisterError: Error, AlertType {
    case notEmailFormat
    case notPasswordSame
    case passwordLength
    case authFailed
}

final class RegisterViewModel: ObservableObject {
    // MARK: - Property
    // (기본값)빈문자열로
    @Published var registerID: String = ""
    @Published var registerPW: String = ""
    @Published var confirmPW: String = ""
    
    // Alert
    @Published var showAlert: Bool = false
    
    // MARK: - Function
    
    // MARK:  🖐️🖐️일단 이건 좀 다시 검토하자.
    func isChecked(completion: @escaping (Result<RegisterSuccess, RegisterError>) -> Void) {
        guard isValidEmail(registerID) else {
            completion(.failure(.notEmailFormat))
            return }
        
        if registerPW.count >= 4 {
            if registerPW == confirmPW {
                registerAuth { result in
                    if result {
                        completion(.success(.joinSuccess))
                    } else {
                        completion(.failure(.authFailed))
                    }
                }
            } else {
                completion(.failure(.notPasswordSame))
            }
        } else {
            completion(.failure(.passwordLength))
        }
    }
    
    // MARK: 🖐️ 다형성을 기반으로한 메서드 만들어봄
    // Alert
    func getAlertValue(alert: AlertType) -> AlertStatus {
        
        if alert is RegisterSuccess {
            print("성공")
        } else if alert is RegisterError {
            print("실패")
        }
        
        
        return
    }
    
    
    // (Firebase)계정 등록
    private func registerAuth(completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: registerID, password: registerPW) { authResult, error in
            if let error = error {
                print("에러 발생:\(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
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



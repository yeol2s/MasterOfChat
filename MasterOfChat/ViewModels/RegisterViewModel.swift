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

// MARK: - Enum
enum RegisterSuccess: AlertType { // 회원 가입 성공(Success)
    case joinSuccess
}

// MARK: - Error
enum RegisterError: Error, AlertType { // 회원 가입 실패(Error)
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
        
        if registerPW.count >= 6 { // 패스워드는 6자리 이상(Firebase에서 6자리 이상 요구)
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
    
    func getAlertValue(alert: AlertType) -> AlertValue {
        
        if alert is RegisterSuccess {
            print("성공")
            if let value = alert as? RegisterSuccess {
                switch value {
                case .joinSuccess:
                    return ("성공", "가입이 완료되었습니다")
                }
            }
        } else if alert is RegisterError {
            print("실패")
            if let value = alert as? RegisterError {
                switch value {
                case .notEmailFormat:
                    return ("오류", "이메일 계정이 아닙니다")
                case .notPasswordSame:
                    return ("오류", "패스워드를 확인하세요")
                case .passwordLength:
                    return ("오류", "패스워드가 짧습니다(4자리 이상)")
                case .authFailed:
                    return ("오류", "인증 오류")
                }
            }
        }
        return ("오류", "알 수 없는 오류 발생")
    }
    
    // MARK: - Private Function
    
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



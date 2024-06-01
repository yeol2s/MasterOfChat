//
//  RegisterViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/13/24.
//
// MARK: - Register ViewModel
// 회원가입

import Foundation

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
    
    private let firebaseService: FirebaseServiceProtocol
    
    // MARK: - Property
    // (기본값)빈문자열로
    @Published var registerID: String = ""
    @Published var registerPW: String = ""
    @Published var confirmPW: String = ""
    
    // Alert
    @Published var showAlert: Bool = false
    var alertType: AlertType? = nil
    
    // MARK: - init
    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
    }

    
    // MARK: - Function
    
    func signUp() {
            firebaseService.signUp(email: registerID, password: registerPW, confirmPW: confirmPW) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    self.alertType = success
                    // MARK: UI를 변경하므로 메인 스레드에서 처리
                    DispatchQueue.main.async {
                        self.showAlert.toggle()
                    }
                case .failure(let error):
                    self.alertType = error
                    DispatchQueue.main.async {
                        self.showAlert.toggle()
                    }
                }
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



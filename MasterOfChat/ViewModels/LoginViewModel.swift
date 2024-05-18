//
//  UserViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/7/24.
//
// MARK: - Login ViewModel(로그인, 회원가입)
// (LoginView)로그인 뷰에서 뷰모델 생성하고 회원가입을 진행할 시 (RegisterView)회원가입 뷰로 뷰모델 넘겨주도록
// MARK: - 🖐️ SOLID의 단일책임을 고려했을 때 로그인, 회원가입 뷰모델을 나누는 것이 좋을까?(아니면 '로그인->회원가입'을 하나의 책임으로 볼 수 있을까?)

import Foundation
import Firebase

// MARK: - TypeAlias
typealias AlertValue = (title: String, message: String)

// MARK: - Protocol
protocol AlertType { } // 다형성 메서드를 위한 프로토콜 선언

// MARK: - Enum
enum LoginSuccess: AlertType { // 로그인 성공(Success)
    case loginSuccess
}

// MARK: - Error
enum LoginError: Error, AlertType { // 로그인 실패(Error)
    case notEmailFormat
    case authError
}


final class LoginViewModel: ObservableObject {
    
    // MARK: - Property
    // 로그인
    @Published var loginID: String?
    @Published var loginPW: String?
    @Published var isInputValid: Bool = false
    // Alert
    @Published var showAlert: Bool = false
    
    
    // MARK: - init
    
    
    // MARK: - Function
    
    // (FireBase)로그인
    // 컴플리션핸들러처리 -> Auth.signIn 클로저의 결과처리를 Result로 뷰에서 참조하기 위해(힙 영역 보냄)
    func login(completion: @escaping (Result<LoginSuccess, LoginError>) -> Void) {
        if let id = loginID, let pw = loginPW {
            // 이메일 형식 확인
            guard isValidEmail(id) else {
                completion(.failure(.notEmailFormat))
                return }
            // FireBase 로그인 결과를 받아와서 클로저 처리
            Auth.auth().signIn(withEmail: id, password: pw) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(.authError))
                } else {
                    completion(.success(.loginSuccess))
                }
            }
        }
    }
    
    
    // loginID 텍스트 검증 후 로그인 버튼 활성화(오버로딩)
    // MARK: 🖐️ (이게 최선인가?) 뷰모델에서 id, pw 현재 상태를 체크해서 뷰의 '로그인'버튼을 활성화 비활성화 하게끔 구현했는데 뭔가 로직이 지저분한 느낌임 조금 더 생각해보자.
    func inputStatus(loginID id: String) {
        guard !id.isEmpty else {
            isInputValid = false
            return }
        
        guard let _ = loginPW else { return }
        isInputValid = true // id가 비어있지 않고 옵셔널이 아니라면 true
    }
    
    // loginPW 텍스트 검증 후 로그인 버튼 활성화(오버로딩)
    func inputStatus(loginPW passWord: String) {
        guard let id = loginID else {
            isInputValid = false
            return }
        
        if !id.isEmpty && !passWord.isEmpty {
            isInputValid = true
            print("true")
        } else {
            isInputValid = false
            print("false")
        }
    }
    
    // MARK: 🖐️ 다형성을 기반으로한 메서드 만들어봄
    // Alert(alert: AlertType 프로토콜 타입) -> AlertValue 타입애일리어스
    func getAlertValue(alert: AlertType) -> AlertValue {
        
        if alert is LoginSuccess {
            // MARK: 🖐️ 바인딩된 Alert에서 메서드가 중복호출되는데 이게 뷰의 재렌더링 방식? 때문이라고 하는데 근본적으로 문제가 없는지 방지를 위한 처리가 필요한지.
            print("로그인 성공")
            if let value = alert as? LoginSuccess {
                switch value {
                case .loginSuccess:
                    print("success")
                    return ("완료", "로그인 되었습니다")
                }
            }
        } else if alert is LoginError {
            if let value = alert as? LoginError {
                switch value {
                case .notEmailFormat:
                    return ("실패", "이메일 형식으로 로그인하세요")
                case .authError:
                    return ("실패", "인증되지 않은 사용자")
                }
            }
        }
        return ("실패", "알 수 없는 오류 발생")
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

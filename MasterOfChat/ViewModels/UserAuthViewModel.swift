//
//  UserViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/7/24.
//
// MARK: - UserViewModel(로그인, 회원가입)
// (LoginView)로그인 뷰에서 뷰모델 생성하고 회원가입을 진행할 시 (RegisterView)회원가입 뷰로 뷰모델 넘겨주도록
// MARK: - 🖐️ SOLID의 단일책임을 고려했을 때 로그인, 회원가입 뷰모델을 나누는 것이 좋을까?(아니면 '로그인->회원가입'을 하나의 책임으로 볼 수 있을까?)

import Foundation
import Firebase

// MARK: - Error
enum LoginError: Error {
    case notEmailFormat
    case authError
}


final class UserAuthViewModel: ObservableObject {
    
    // MARK: - Property
    // 로그인
    @Published var loginID: String?
    @Published var loginPW: String?
    @Published var isInputValid: Bool = false
    // Alert
    @Published var showAlert: Bool = false
    
    // 회원가입
//    @Published var registerID: String?
//    @Published var registerPW: String?
//    @Published var confirmPW: String?
    
    // MARK: - init
    
    
    // MARK: - Function
    
    // (FireBase)로그인
    // 컴플리션핸들러처리 -> Auth.signIn 클로저의 결과처리를 Result로 뷰에서 참조하기 위해(힙 영역 보냄)
    func login(completion: @escaping (Result<Void, LoginError>) -> Void) {
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
                    completion(.success(()))
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

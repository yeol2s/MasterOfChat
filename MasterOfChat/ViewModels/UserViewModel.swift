//
//  UserViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/7/24.
//
// MARK: - UserViewModel(로그인, 회원가입)
// (LoginView)로그인 뷰에서 뷰모델 생성하고 회원가입을 진행할 시 (RegisterView)회원가입 뷰로 뷰모델 넘겨주도록

import Foundation
import Firebase

final class UserViewModel: ObservableObject {
    
    // MARK: - Property
    // 로그인
    @Published var loginID: String?
    @Published var loginPW: String?
    @Published var isInputValid: Bool = false
    
    // 회원가입
    @Published var registerID: String?
    @Published var registerPW: String?
    @Published var confirmPW: String?
    
    // MARK: - init
    
    
    // MARK: - Function
    
    // (FireBase)로그인
    func login() {
        
    }
    
    
    // MARK: - 🖐️ (이게 최선인가?) 뷰모델에서 id, pw 현재 상태를 체크해서 뷰의 '로그인'버튼을 활성화 비활성화 하게끔 구현했는데 뭔가 로직이 지저분한 느낌임 조금 더 생각해보자.
    // 오버로딩
    func inputStatus(loginID id: String) {
        guard !id.isEmpty else {
            isInputValid = false
            return }
        
        guard let pw = loginPW else { return }
        isInputValid = true
    }
    
    // 오버로딩
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
}

//
//  MainViewModel.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/13/24.
//
// MARK: - AuthViewModel(FireBase 인증관리)
// MainView

import Foundation
import Firebase

final class AuthViewModel: ObservableObject {
    // MARK: - Property
    // 현재 유저 로그인 상태 체크
    @Published private var currentUser: Firebase.User?
    @Published var isloginViewSheet: Bool = false
    
    @Published var showAlert: Bool = false
    
    private let firebaseService: FirebaseServiceProtocol
    
    // MARK: - init
    // 싱글톤으로 FirebaseSerivce 주입
    init(firebaseService: FirebaseServiceProtocol = FirebaseService.shared) {
        self.firebaseService = firebaseService
        setupFirebaseAuth() // Firebase 셋업(등록사용자 및 로그인 상태 확인)
    }
    
    // MARK: - Funtion
    
    // 로그아웃
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("signOut call")
        } catch let signOutError as NSError {
            print("로그아웃 에러 : \(signOutError.localizedDescription) ")
        }
    }
    
    
    // MARK: - Private Function
    
    // Firebase 로그인 셋업
    private func setupFirebaseAuth() {
        currentUser = Auth.auth().currentUser // 현재 유저의 상태를 가져와서 할당(현재 앱 세션에서 인증된 사용자 정보 얻어옴)(로컬에서 얻어옴)
        userAuthStatusCheck() // Firebase 콘솔에 등록된 사용자인지 조회
    }
    
    // 삭제된 계정인지 확인 -> 로그인 되어있다면 로그아웃
    private func userAuthStatusCheck() {
        // Firebase Auth 상태 변화 감지하는 리스너(변할때마다 호출)
        // 리스너는 등록할때는 동기적으로, 인증 상태 변화가 있을때는 비동기적으로 호출
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            print("Auth 상태 리스너 실행")
            
            if let user = user {
                // 로그인 상태인 경우
                print("authListener: check")
                self.checkIDToken(user: user)
            } else {
                // 로그아웃 상태인 경우
                print("authListener: nil")
                self.currentUser = nil
            }
            // 로그인 후 콘솔에서 계정 삭제를 시킨 후 앱을 다시 실행하면 (로그인 상태)false의 값으로 순간 실행되었다가 getIDTokenResult 메서드가 비동기적으로 실행되면서 토큰이없는 것 확인하고 signOut 처리를 하게 되면 등록된 리스너가 변화된 값을 감지하고 유저를 nil값으로 만들고 다시 isLoginStatus값이 (로그아웃)true 상태로 만들며 로그인 화면을 띄우도록 함
            setupLoginStatus() // 로그인 상태(로그인 상태일시 false, 아닐시 true)
        }
    }
    
    // Firebase ID Token 확인하여 삭제된 사용자 처리
    private func checkIDToken(user: User) {
        // Firebase에서 사용자 정보 가져오기(ID 토큰)(네트워킹 -> 비동기적으로 동작)
        user.getIDTokenResult(forcingRefresh: true) { [weak self] (idToken, error) in
            // 토큰을 받아오면 idToken에 토큰들어오고, 받아오지 못하면 error?
            guard let self = self else { return }
            
            if let error = error {
                print("ID Token을 받아오지 못함 : \(error.localizedDescription)")
                self.signOut()
            } else {
                print("토큰 확인")
            }
        }
    }
    
    
    // 로그인 상태(상태에 따라 .sheet)
    private func setupLoginStatus() {
        if let _ = currentUser {
            print("setupLoginStatus: false")
            isloginViewSheet = false // false일시 로그인이 되어있음
        } else {
            print("setupLoginStatus: true")
            isloginViewSheet = true // true일시 로그인이 되어있지 않음(로그인 화면 띄움 -> sheet)
        }
    }
}



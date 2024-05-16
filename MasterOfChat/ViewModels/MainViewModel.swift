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
    @Published private var currentUser: Firebase.User?
    @Published var isLoginStatus: Bool = false
    
    // MARK: - init
    init() {
        setupFirebaseAuth() // Firebase 셋업(등록사용자 및 로그인 상태 확인)
    }
    
    // MARK: - Funtion
    
    // 로그아웃
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("로그아웃 에러 : \(signOutError.localizedDescription) ")
        }
    }
    
    
    // MARK: - Private Function
    
    
    // TODO: 현재 문제가 1)가입후 로그인 후 앱 다시 켜면 자동로그인 -> 2)콘솔에서 계정 삭제 -> 3)앱 재실행시 토큰은 받아오지 못하나 앱은 로그인 상태로 인식하고 채팅방 화면으로 넘어감(아마 비동기적으로 호출되는 파베 메서드와 loginStatus 호출되는 시간 차이가 의심됨) -> 앱 두번째 재실행시에는 로그아웃된 로그인 화면 정상적으로 뜸
    
    // Firebase 로그인 셋업
    private func setupFirebaseAuth() {
        currentUser = Auth.auth().currentUser // 현재 유저의 상태를 가져와서 할당(현재 앱 세션에서 인증된 사용자 정보 얻어옴)
        userAuthStatusCheck() // Firebase 콘솔에 등록된 사용자인지 조회
        setupLoginStatus() // 로그인 상태(로그인 상태일시 false, 아닐시 true)
    }
    
    // 삭제된 계정인지 확인 -> 로그인 되어있다면 로그아웃
    private func userAuthStatusCheck() {
        // Firebase Auth 상태 변화 감지하는 리스너(변할때마다 호출)
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            print("Auth 상태 리스너 실행")
            
            if let user = user {
                // 로그인 상태인 경우
                self.checkIDToken(user: user)
            } else {
                // 로그아웃 상태인 경우
                self.currentUser = nil
            }
        }
    }
    
    // Firebase ID Token 확인하여 삭제된 사용자 처리
    private func checkIDToken(user: User) {
        // Firebase에서 사용자 정보 가져오기(ID 토큰)
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
    
    
    // MARK: 🖐️ sheet 때문에 Bool 값을 반대로 설정했는데 추후 다시 보자.
    // 로그인 상태 Bool 값으로 할당(.sheet에 바인딩되어 true일시 로그인뷰로 sheet되므로 Bool 값을 반대로 할당)
    private func setupLoginStatus() {
        if let _ = currentUser {
            isLoginStatus = false
        } else {
            isLoginStatus = true
        }
    }
}



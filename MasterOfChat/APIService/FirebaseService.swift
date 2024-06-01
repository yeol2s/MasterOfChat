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
import Combine

// MARK: - Protocol
protocol FirebaseServiceProtocol {
    //    func signIn(email: String, password: String, completion: @escaping (Result<LoginSuccess, LoginError>) -> Void)
    func signIn(email: String, password: String) async -> Result<LoginSuccess, LoginError>
    func signUp(email: String, password: String, confirmPW: String, completion: @escaping (Result<RegisterSuccess, RegisterError>) -> Void)
    func signOut()
    func loadMessage()
    func userAuthStatusCheck() -> Bool
    // Publisher
    var authStatePublisher: AnyPublisher<Bool, Never> { get }

}

// MARK: - FireBaseService(싱글톤)
final class FirebaseService: FirebaseServiceProtocol {
    
    static let shared = FirebaseService() // 싱글톤
    private init() {} // 새로운 객체 생성 차단
    
    lazy var currentUser: Firebase.User? = nil
    // Combine Publish 객체 생성(인증상태 변화를 외부로 Publish) -> AuthViewModel에서 구독
    private let authStateSubject = PassthroughSubject<Bool, Never>() // Never는 에러를 발생시키지 않음(CPU 제어권을 넘기지 않음 -> 필요시에는 에러타입으로 변경)
    var authStatePublisher: AnyPublisher<Bool, Never> { // 계산속성으로
        authStateSubject.eraseToAnyPublisher() // AnyPublisher로 퉁침(구체적인 퍼블리셔 타입을 지우고 표준화된 AnyPublisher 타입으로 변환 - 구현 세부사항을 감추는 것)
        // send: 값 발행(publish), sink: 구독(subscribe), PassthroughSubject: 형식 지정(발행할 값의 형식과 에러 형식 지정)(퍼블리셔의 형태 -> 다른 형태가 올 수 있음 ex: CurrentValueSubject)
    }
    
    // loadMessage
    let db = Firestore.firestore() // FireStore 데이터베이스 참조 생성
    
    // MARK: - Function
    
    // 로그인(async/await)
    func signIn(email: String, password: String) async -> Result<LoginSuccess, LoginError> {
        // withCheckedContinuation : 콜백 기반의 비동기 코드를 async/await 스타일로 변환할 때 사용(콜백기반의 비동기 작업을 async/awiate 스타일로 변환할 때 사용하는 유틸리티(비동기 작업의 완료를 기다리는 동안 현재 작업을 일시 중지하고, 작업이 완료되면 다시 실행)
        await withCheckedContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let _ = error {
                    continuation.resume(returning: .failure(.authError))
                } else {
                    continuation.resume(returning: .success(.loginSuccess))
                }
                // TODO: Combine
                //self.authStateSubject.send(authResult != nil)
            }
        }
    }
    
    // 회원가입
    func signUp(email: String, password: String, confirmPW: String, completion: @escaping (Result<RegisterSuccess, RegisterError>) -> Void) {
        // 이메일 형식 체크
        guard isValidEmail(email) else {
            completion(.failure(.notEmailFormat))
            return }
        // 패스워드 6자리 이상 체크
        if password.count >= 6 {
            if password == confirmPW {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let _ = error {
                        completion(.failure(.authFailed))
                    } else {
                        completion(.success(.joinSuccess))
                    }
                    // TODO: Combine
                    //self.authStateSubject.send(authResult != nil)
                }
            } else {
                completion(.failure(.notPasswordSame))
            }
        } else {
            completion(.failure(.passwordLength))
        }
    }
    
    // 로그아웃
    func signOut() {
        do {
            try Auth.auth().signOut()
            // TODO: Combine
            //authStateSubject.send(false)
        } catch let signOutError as NSError {
            print("로그아웃 에러 : \(signOutError.localizedDescription)")
        }
    }
    
    // 메세지 로드
    func loadMessage() {
        // TODO: ChatViewModel
        
    }
    
    // 삭제된 계정인지 확인(삭제된 계정이 로그인 되어있다면 로그아웃)
    func userAuthStatusCheck() -> Bool {
        // TODO: AuthViewModel
        
        currentUser = Auth.auth().currentUser // (lazy)현재 로그인된 유저 상태(현재 로그인된 유저가 담김)
        
        // Firebase Auth 상태 변화 감지하는 리스너(변할때마다 호출)
        // 리스너는 등록할때는 동기적으로, 인증 상태 변화가 있을때는 비동기적으로 호출
        // MARK: Combine이 추가되어 리스너에서 로그인 상태에 따라 퍼블리셔에게 로그인 상태에 따른 결과를 send 하면서 구독자인 authViewModel의 로그인 상태값이 변경된다.
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            print("Auth 상태 리스너 실행")
            
            if let user = user {
                // 로그인 상태인 경우
                print("authListener: check")
                self.checkIDToken(user: user)
                self.authStateSubject.send(true) // (combine) Publisher에 send
            } else {
                // 로그아웃 상태인 경우
                print("authListener: nil")
                self.authStateSubject.send(false) // combine
            }
        }
        
        return currentUser != nil
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
    
}

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
    func sendMessage(inText: String)
    func userAuthStatusCheck() -> Bool
    // (Combine) 계정 인증상태 Publisher (Subject에 직접 접근하지 않음)
    var authStatePublisher: AnyPublisher<Bool, Never> { get }
    // (Combine) Message Publisher (Subject에 직접 접근하지 않음)
    var messageStatePublisher: AnyPublisher<[Message], Never> { get }
    
    // TODO: 임시 Documents remove
    func deleteDocuments()
    
}

// MARK: - FireBaseService(싱글톤)
final class FirebaseService: FirebaseServiceProtocol {
    
    // MARK: - Property
    
    static let shared = FirebaseService() // 싱글톤
    private init() {} // 새로운 객체 생성 차단
        
    lazy var currentUser: Firebase.User? = nil // lazy
    let db = Firestore.firestore() // FireStore 데이터베이스 참조 생성
    
    private var messages: [Message] = []
    
    private var stateChangeListenerHandle: AuthStateDidChangeListenerHandle? // (addStateDidChangeListener)상태 감지 리스너 핸들
    
    private var messageListenerHandle: ListenerRegistration? // (addListener) 메세지 등록 리스너 핸들
    
    // MARK: Auth Combine(PassthroughSubject)
    // Combine Publish 객체 생성(인증상태 변화를 외부로 Publish) -> AuthViewModel에서 구독
    // PassthroughSubject : 초기값을 가지지 않는 새로운 값 퍼블리셔하는 Subject
    private let authStateSubject = PassthroughSubject<Bool, Never>() // Never는 에러를 발생시키지 않음(CPU 제어권을 넘기지 않음 -> 필요시에는 에러타입으로 변경)
    var authStatePublisher: AnyPublisher<Bool, Never> { // 계산속성으로
        authStateSubject.eraseToAnyPublisher() // AnyPublisher로 퉁침(구체적인 퍼블리셔 타입을 지우고 표준화된 AnyPublisher 타입으로 변환 - 구현 세부사항을 감추는 것)
        // send: 값 발행(publish), sink: 구독(subscribe), PassthroughSubject: 형식 지정(발행할 값의 형식과 에러 형식 지정)(퍼블리셔의 형태 -> 다른 형태가 올 수 있음 ex: CurrentValueSubject)
    }
    
    // MARK: Message Combine(CurrentValueSubject)
    // TODO: 초기값을 가지는 퍼블리셔니까 메세지를 미리 넣어서 초기화 시킬 수 있는지 고려
    private let messageStateSubject = CurrentValueSubject<[Message], Never>([])
    var messageStatePublisher: AnyPublisher<[Message], Never> {
        messageStateSubject.eraseToAnyPublisher()
    }
    

    
    // MARK: - Function
    
    // 로그인(async/await)
    func signIn(email: String, password: String) async -> Result<LoginSuccess, LoginError> {
        // withCheckedContinuation : 콜백 기반의 비동기 코드를 async/await 스타일로 변환할 때 사용(콜백기반의 비동기 작업을 async/awiate 스타일로 변환할 때 사용하는 유틸리티(비동기 작업의 완료를 기다리는 동안 현재 작업을 일시 중지하고, 작업이 완료되면 다시 실행)
        await withCheckedContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let _ = error {
                    continuation.resume(returning: .failure(.authError))
                } else {
                    continuation.resume(returning: .success(.loginSuccess))
                }
                
                // MARK: (Combine) 로그인되면 Alert 발생 후 로그인 화면으로 넘어감
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.authStateSubject.send(authResult != nil)
                }
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
                    // 회원가입 완료되면 Alert 발생 후 리스너 호출되어 자동 로그인
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
            authStateSubject.send(false)
//            // 테스트
            messages = [] // 메시지 초기화
            currentUser = nil // 사용자 정보 초기화
            messageStateSubject.send([]) // 메시지 퍼블리셔 초기화
            print("로그아웃 되었습니다.")
            
            // message 리스너 제거
            messageListenerHandle?.remove()
            messageListenerHandle = nil
        
            // 상태 리스너 제거
            if let handle = stateChangeListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
                stateChangeListenerHandle = nil
            }
        } catch let signOutError as NSError {
            print("로그아웃 에러 : \(signOutError.localizedDescription)")
        }
    }
    
    // 메세지 로드
    func loadMessage() {
        
        currentUser = Auth.auth().currentUser
        print("loadMessage currentUser: \(currentUser?.email ?? "nil")")
        
        // TODO: ChatViewModel
        // addSnapshotListener로 실시간 데이터 변경 사항 업데이트 수신
        messageListenerHandle = db.collection(K.Firebase.collectionName)
            .order(by: K.Firebase.dateField) // date기준 정렬
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                print("addSnapshotListener RUN")
                self.messages = []
                if let error = error {
                    print("SnapshotError: \(error.localizedDescription)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        // MARK: (Old)Codable 채택하지 않은 Decoding
//                        for doc in snapshotDocuments { // 스냅샷을 반복하여 스캔
//                            print(doc.data())
//                            let data = doc.data() // data는 key-value 쌍 ["body": ~, "sender": a@abc.com]
//                            if let messageSender = data[K.Firebase.senderField] as? String,
//                               let meessageBody = data[K.Firebase.bodyField] as? String { // 타입캐스팅(Any? -> String)(data가 Any? 타입으로 들어옴)\
//                                // TODO: currentUSer Lazy하지 않게 파이어베이스 싱글톤 생성시 같이 초기화 시키는게 나을지 고려
//                                let newMessage = Message(sender: messageSender, body: meessageBody, isSentByCurrentUser: messageSender == Auth.auth().currentUser?.email ? true : false)
//                                self.messages.append(newMessage)
//                            }
                        // MARK: (New)Codable 채택하여 Decoding
                        for doc in snapshotDocuments {
                            do {
                                var message = try doc.data(as: Message.self) // 디코딩
                                if let currentUserEmail = self.currentUser?.email {
                                    message.isSentByCurrentUser = (message.sender == currentUserEmail)
                                }
                                self.messages.append(message)
                            } catch let error {
                                print("Message Load 디코딩 에러 : \(error.localizedDescription)")
                            }
                        } // : SnapshotLoop
                    }
                }
                print("loaded Messages: \(self.messages)")
                self.messageStateSubject.send(messages) // Combine Send
            } // : SnapShotListener
    }
    
    // 메세지 전송
    func sendMessage(inText: String) {
        if let messageSender = currentUser?.email {
            db.collection(K.Firebase.collectionName).addDocument(data: [
                K.Firebase.senderField: messageSender,
                K.Firebase.bodyField: inText,
                K.Firebase.dateField: Date().timeIntervalSince1970 // 기준시간 1970.1.1 0시 ~ 현재까지 초 계산(생성시점)
            ]) { (error) in
                if let error {
                    print("Firebase data save error : \(error)")
                } else {
                    print("Success data save")
                    // 메세지가 정상적으로 들어갔으면 (데이터베이스가 변경되면서)db.collection에서 .addSnapshotListener가 비동기적으로 호출될 것(실시간 업데이트 반영)
                }
            }
        }
    }
    
    // 삭제된 계정인지 확인(삭제된 계정이 로그인 되어있다면 로그아웃)
    func userAuthStatusCheck() -> Bool {
        
        // (핸들)리스너가 비어있을때만 리스너 등록되도록
        guard stateChangeListenerHandle == nil else {
            return currentUser != nil
        }
        
        currentUser = Auth.auth().currentUser
        
        // Firebase Auth 상태 변화 감지하는 리스너(변할때마다 호출)
        // 리스너는 등록할때는 동기적으로, 인증 상태 변화가 있을때는 비동기적으로 호출
        // MARK: (Combine)Combine이 추가되어 리스너에서 로그인 상태에 따라 퍼블리셔에게 로그인 상태에 따른 결과를 send 하면서 구독자인 authViewModel의 로그인 상태값이 변경된다.
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
        } // : Listener
        
        return currentUser != nil
    }
    
    // MARK: 임시 Documents Delete
    func deleteDocuments() {
        deleteAllDocuments()
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
    
    // MARK: 임시 Documents Delete
    private func deleteAllDocuments() {
        let db = Firestore.firestore()
        let collectionRef = db.collection(K.Firebase.collectionName)
        
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("Document \(document.documentID) successfully deleted")
                    }
                }
            }
        }
    }
}

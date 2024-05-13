//
//  MasterOfChatApp.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/2/24.
//
// MARK: - APP

import SwiftUI
import Firebase

@main
struct MasterOfChatApp: App {
    
    // MARK: Firebase 초기화 코드
    init() {
        FirebaseApp.configure() // 파이어베이스 서버연결
        let db = Firestore.firestore() // 파이어베이스 DB 초기화
        print("FireStore가 초기화 되었습니다. \(db)")
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
            //LoginView()
        }
    }
}

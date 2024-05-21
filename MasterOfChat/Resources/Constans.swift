//
//  Constans.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/21/24.
//
// MARK: - 리소스 관리

struct K {
    static let appName = "채팅의 고수"
    static let appIcon = "bird"
    
    struct AppColors {
        static let chatRoomColor = "ChatRoomColor"
        static let loginBackGround = "LoginColor"
        static let loginBtnColor = "LoginButtonColor"
        
    }
    
    struct Firebase {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}

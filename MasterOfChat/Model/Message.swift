//
//  Message.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/20/24.
//
// MARK: - Model(Message Model)

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable { // TODO: Codable 채택?
    @DocumentID var id: String? // FireBase Document ID
    let sender: String // 메세지 보낸 사람(이메일 형식)
    let body: String // 메세지 body
    let isSentByCurrentUser: Bool // Sender = 로그인된 현재 사용자
}

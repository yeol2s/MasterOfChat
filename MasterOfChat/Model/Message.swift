//
//  Message.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/20/24.
//
// MARK: - Model(Message Model)

import Foundation
import FirebaseFirestoreSwift

// DocumentID 값 설정과, Document에서 디코딩 하기 위한 Codable 프로토콜 채택
// Equatable 프로토콜 채택(ScrollViewReader .onChange 사용)
struct Message: Identifiable, Codable, Equatable {
    @DocumentID var id: String? // FireBase Document ID
    let sender: String // 메세지 보낸 사람(이메일 형식)
    let body: String // 메세지 body
    var isSentByCurrentUser: Bool? = nil // 디코딩 되지 않도록 옵셔널
    
    // CodingKey 사용(isSentByCurrentUser 제외하기 위함) (디코딩할때 id, sender, body 필드만 사용)
    private enum CodingKeys: String, CodingKey {
        case id
        case sender
        case body
    }
}

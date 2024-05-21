//
//  Message.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/20/24.
//
// MARK: - Model(Message Model)

import Foundation

struct Message {
    // TODO: 필요시 UUID 생성(Firebase에 addDocument가 고유 ID를 자동 생성하기 때문에 일단 보류)
    let sender: String // 메세지 보낸 사람(이메일 형식)
    let body: String // 메세지 body
    let isSentByCurrentUser: Bool // Sender = 로그인된 현재 사용자
}

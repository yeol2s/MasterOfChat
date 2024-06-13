//
//  MessageCell.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/21/24.
//
// MARK: - Message Cell

import SwiftUI

struct MessageView: View {
    
    var message: Message // @State 선언했다가 고생했음.(속성래퍼를 다시 한번 필요한지 확인하고 사용할 것!)
    
    var body: some View {
        
        if let isCurrentUser = message.isSentByCurrentUser {
            HStack() {
                if !isCurrentUser {
                    Image(systemName: "person.fill")
                }
                VStack(spacing: 0) {
                    if !isCurrentUser {
                        Text(message.sender)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                    }
                    Text(message.body)
                        .padding()
                        .background(isCurrentUser ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.3))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, alignment: !isCurrentUser ? .leading : .trailing)
                } //:VSTACK
                if isCurrentUser {
                    Image(systemName: "person.wave.2.fill")
                }
            } //:HSTACK
            .padding()
        } else {
            Text("채팅창 불러오기에 실패하였습니다.")
        }
    }
}

#Preview {
    MessageView(message: Message(sender: "a@abc.com", body: "임시", isSentByCurrentUser: nil))
}

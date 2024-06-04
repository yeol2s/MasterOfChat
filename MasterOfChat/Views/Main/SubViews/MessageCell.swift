//
//  MessageCell.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/21/24.
//
// MARK: - Message Cell

import SwiftUI

struct MessageCell: View {
    
    @State var message: Message
    
    var body: some View {
        HStack() {
            if !message.isSentByCurrentUser {
                Image(systemName: "person.fill")
            }
            VStack(spacing: 0) {
                Text(message.sender)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                Text("message.body 들어갈 부분~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
                    .padding()
                    .background(message.isSentByCurrentUser ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .padding(message.isSentByCurrentUser ? .leading : .trailing, 50)
                
            } //:VSTACK
            if message.isSentByCurrentUser {
                Image(systemName: "person.wave.2.fill")
            }
        } //:HSTACK
        .padding()
        
    }
}

#Preview {
    MessageCell(message: Message(sender: "a@abc.com", body: "임시", isSentByCurrentUser: false))
}

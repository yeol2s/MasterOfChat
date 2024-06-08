//
//  MessageCell.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/21/24.
//
// MARK: - Message Cell

import SwiftUI

struct MessageView: View {
    
    @State var message: Message
    
    var body: some View {
        HStack() {
            if !(message.isSentByCurrentUser ?? false) {
                Image(systemName: "person.fill")
            }
            VStack(spacing: 0) {
                if !(message.isSentByCurrentUser ?? false) {
                    Text(message.sender)
                        .frame(maxWidth: .infinity, alignment: !message.isSentByCurrentUser! ? .leading : .trailing)
                        .padding(.leading, 10)
                }
                Text(message.body)
                    .padding()
                    .background(message.isSentByCurrentUser! ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.3))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, alignment: !message.isSentByCurrentUser! ? .leading : .trailing)
            } //:VSTACK
            if (message.isSentByCurrentUser ?? true) {
                Image(systemName: "person.wave.2.fill")
            }
        } //:HSTACK
        .padding()
    }
}

#Preview {
    MessageView(message: Message(sender: "a@abc.com", body: "임시", isSentByCurrentUser: true))
}

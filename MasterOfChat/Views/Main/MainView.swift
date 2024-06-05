//
//  MainView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/2/24.
//
// MARK: - Main View(채팅 화면)

import SwiftUI

struct MainView: View {
    // MARK: - Property
    @StateObject var authVm = AuthViewModel() // 인증 뷰모델
    @StateObject var chatVm = ChatViewModel() // 채팅 뷰모델
    
    // MARK: - View
    var body: some View {
            VStack(spacing: 2) {
                // 채팅 뷰
//                List(chatVm.messages) { message in
//                    //Text("테스트 채팅")
////                    ForEach(chatVm.messages) { message in
////                        MessageCell(message: message)
////                    }
////                    MessageCell(message: message)
////                        .listRowInsets(EdgeInsets()) // 여백 제거
//
//                } //:LIST
//                .scrollContentBackground(.hidden) // List 백그라운드 컬러 설정
//                .background(Color(K.AppColors.chatRoomColor))
                ScrollView {
                    ForEach(chatVm.messages) { message in
                        MessageView(message: message)
                    }
                } // : ScrollView
                
                HStack {
                    TextEditor(text: $chatVm.chatText)
                        .frame(minHeight: 50, maxHeight: 150)
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) // 텍스트에디터 높이 동적 크기 조절
                        .background(Color.clear)
                        .border(Color.gray, width: 1)
                        .padding(5)
                    
                    Button {
                        // TODO: Send
                        chatVm.sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .padding(.trailing, 20)
                } //:HSTACK
                .background(Color(K.AppColors.chatRoomColor).opacity(0.5))
            } //:VSTACK
            .fullScreenCover(isPresented: $authVm.isloginViewSheet) { //sheet(로그인 안되어있을시 로그인뷰)
                LoginView(authVm: authVm)
            }
        .navigationBarTitle("채팅방", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    authVm.showAlert.toggle()
                } label: {
                    Image(systemName: "power")
                        .font(.title3)
                        .tint(.green)
                }
                .alert(isPresented: $authVm.showAlert) {
                    getAlert()
                }
            }
        }
    }
    
    // MARK: - Function
    private func getAlert() -> Alert {
        return Alert(
            title: Text("알림"),
        message: Text("로그아웃 하시겠습니까?"),
            primaryButton: .destructive(Text("확인"), action: {
                authVm.signOut()
            }),
            secondaryButton: .cancel(Text("취소"))
        )}
}


#Preview {
    NavigationView {
        MainView()
    }
}

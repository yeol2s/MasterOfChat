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
            // MARK: (Old)List - 셀 재사용으로 메모리 관리는 좋으나 커스터마이징이 힘듦
            //            List(chatVm.messages) { message in
            //                MessageView(message: message)
            //            } //:LIST
            //            .scrollContentBackground(.hidden) // List 백그라운드 컬러 설정
            //            .background(Color(K.AppColors.chatRoomColor))
            
            // MARK: (New)ScrollView - 셀 재사용은 없지만 LazyVStack으로 필요한 부분만 로드하여 어느정도 커버 가능하고(매우 큰 데이터 처리는 불리) 커스터마이징이 유연하여 스크롤뷰 채택
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(chatVm.messages) { message in
                            MessageView(message: message)
                        }
                    } //:LazyVSTACK
                    .onChange(of: chatVm.messages) { _ in
                        withAnimation {
                            if let lastMessage = chatVm.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                } // : ScrollView
            } // : ScrollViewReader
            
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


//#Preview {
//    NavigationView {
//        MainView()
//    }
//}

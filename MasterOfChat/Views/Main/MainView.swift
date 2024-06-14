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
    @StateObject var chatVm = ChatViewModel() // 채팅 뷰모델
    @StateObject var authVm = AuthViewModel() // 인증 뷰모델
    
    // MARK: - View
    var body: some View {
        
        VStack(spacing: 2) {
            
            // MARK: ScrollView - 셀 재사용은 없지만 LazyVStack으로 필요한 부분만 로드하여 어느정도 커버 가능하고(매우 큰 데이터 처리는 불리) 커스터마이징이 유연하여 스크롤뷰 채택
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
                TextEditor(text: $chatVm.chatText) // 긴 문장 동적으로 조절되기 수월하게 TextEditor 사용
                    .frame(minHeight: 50, maxHeight: 150)
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) // 텍스트에디터 높이 동적 크기 조절
                    .background(Color.clear)
                    .border(Color.gray, width: 1)
                    .padding(5)
                
                Button {
                    chatVm.sendMessage()
                    chatVm.chatText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                }
                .padding(.trailing, 20)
            } //:HSTACK
            .background(Color(K.AppColors.chatRoomColor).opacity(0.5))
        } //:VSTACK
        .fullScreenCover(isPresented: $authVm.isUserLoggedIn.not) { //sheet(로그인 안되어있을시 로그인뷰)
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
        // MARK: 로그인 상태에 따른 (firebaseService)로드메세지 호출
        // 로그인이 되어있지 않은 상태에서 앱 실행시 로드메시지 호출되지 않고 로그인이 되어있을때 로드메세지 호출하여 메세지 로드하도록
        .onAppear {
            if authVm.isUserLoggedIn {
                print("MainView onAppear RUN")
                chatVm.loadMessage()
            }
        }
        .onChange(of: authVm.isUserLoggedIn) { isLoggedIn in
            if isLoggedIn {
                print("MainView onChange RUN")
                chatVm.loadMessage()
            } else {
                print("ChatVm messages remove")
                chatVm.messages.removeAll()
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

// MARK: - Extension
// Binding 확장 - LoginView .sheet 바인딩 값으로 isUserLoggedIn 변수의 Bool값 not 사용 위함
extension Binding where Value == Bool { // Binding<Bool> 타입만 확장 적용되도록 where절 선언
    var not: Binding<Bool> {
        Binding<Bool>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}


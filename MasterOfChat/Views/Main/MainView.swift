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
    @StateObject var vm = MainViewModel()
    
    // TODO: 뷰모델에서 관리할 채팅 입력 텍스트필드(임시)
    @State private var textChat: String = ""
    
    // MARK: - View
    var body: some View {
            VStack(spacing: 2) {
                // 채팅 뷰
                List {
                    Text("테스트 채팅")
                } //:LIST
                .scrollContentBackground(.hidden) // List 백그라운드 컬러 설정
                .background(Color("ChatRoomColor"))
                
                HStack {
                    TextEditor(text: $textChat)
                        .frame(minHeight: 50, maxHeight: 150)
                        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/) // 텍스트에디터 높이 동적 크기 조절
                        .background(Color.clear)
                        .border(Color.gray, width: 1)
                        .padding(5)
                    
                    Button {
                        // TODO: Send
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .padding(.trailing, 20)
                } //:HSTACK
                .background(Color("ChatRoomColor").opacity(0.5))
            } //:VSTACK
            .fullScreenCover(isPresented: $vm.isLoginStatus) { //sheet
                LoginView(mainVm: vm)
            }
        .navigationBarTitle("채팅방", displayMode: .inline)
    }
    
    // MARK: - Function

}


#Preview {
    NavigationView {
        MainView()
    }
}

//
//  LoginView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/3/24.
//
// MARK: - Login View(로그인 화면)

import SwiftUI

struct LoginView: View {
    
    // MARK: - Property
    // 로그인에서 뷰모델 만들고 회원가입시에는 회원가입뷰로 뷰모델을 넘겨주는 방식으로 하는게 좋을 것 같다.
    @StateObject var vm = UserViewModel()
    
//    @State var textID: String = ""
    
    // MARK: - View
    var body: some View {
        
        ZStack { // 전체 백그라운드 적용을 위한 ZStack
            
            Color("LoginColor").ignoresSafeArea()
            
            VStack(alignment: .center) {
                
                Spacer()
                
                HStack() {
                    Text("ID")
                        .font(.title)
                        .frame(width:60, height: 40)
                    
                    // (Binding) 사용자 정의 바인딩
                    TextField("이메일 형식의 아이디를 입력하세요", text: Binding(
                        get: { vm.loginID ?? ""},
                        set: { vm.loginID = $0.isEmpty ? nil : $0}))
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .onReceive(vm.$loginID) { id in
                        vm.inputStatus(loginID: id ?? "")
                    }
                } //:HSTACK
                .padding(.bottom)
                
                HStack {
                    Text("암호")
                        .font(.title)
                        .frame(width:60, height: 40)
                    
                    SecureField("패스워드를 입력하세요", text: Binding(
                        get: { vm.loginPW ?? ""},
                        set: { vm.loginPW = $0.isEmpty ? nil : $0}))
                        .textFieldStyle(.roundedBorder)
                    // 텍스트필드 입력마다 호출
                        .onReceive(vm.$loginPW) { passWord in
                            // id, pw 입력 되었는지 확인 메서드 호출
                            vm.inputStatus(loginPW: passWord ?? "")
                        }
                } //:HSTACK
                .padding(.bottom)
                
                Spacer()
                    .frame(height: 50) // Spacer 높이 설정
                
                HStack(spacing: 60) {
                    Button {
                        // TODO: Login Logic
                    } label: {
                        Text("로그인")
                    }
                    .frame(width: 100, height: 50)
                    .background(Color("LoginButtonColor").cornerRadius(10).shadow(radius: 2))
                    .foregroundColor(.white)
                    .font(.title.bold())
                    .disabled(!vm.isInputValid)
                    
                    
                    Button {
                        // TODO: Login cancel logic
                        
                    } label: {
                        Text("취소")
                    }
                    .frame(width: 100, height: 50)
                    .background(Color("LoginButtonColor").opacity(0.2).cornerRadius(10).shadow(radius: 2))
                    .foregroundColor(.white)
                    .font(.title.bold())
                    
                    
                } //:HSTACK
                Spacer()
                
                Divider()
                
                VStack(spacing: 10) {
                    Text("회원이 아니신가요?")
                        .font(.footnote)
                        .foregroundStyle(.gray.opacity(0.8))
                    
                    Text("회원가입")
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            // TODO: onTabGesture(ResiterView)
                            
                        }
                } //:VSTACK
                
            } //:VSTACK
            .padding()
            
        } //:ZSTACK
    }
}

#Preview {
    LoginView()
}

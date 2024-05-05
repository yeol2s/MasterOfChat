//
//  LoginView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/3/24.
//
// MARK: - Login View(로그인 화면)

import SwiftUI

struct LoginView: View {
    
    @State var textID: String = ""
    
    var body: some View {
        ZStack { // 전체 백그라운드 적용을 위한 ZStack
            
            Color("LoginColor").ignoresSafeArea()
            
            VStack(alignment: .center) {
                
                Spacer()
                
                HStack() {
                    Text("ID")
                        .font(.title)
                        .frame(width:60, height: 40)
                    
                    TextField("이메일 형식의 아이디를 입력하세요", text: $textID)
                        .textFieldStyle(.roundedBorder)
                        .font(.headline)
                } //:HSTACK
                .padding(.bottom)
                
                HStack {
                    Text("암호")
                        .font(.title)
                        .frame(width:60, height: 40)
                    
                    SecureField("패스워드를 입력하세요", text: $textID)
                        .textFieldStyle(.roundedBorder)
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

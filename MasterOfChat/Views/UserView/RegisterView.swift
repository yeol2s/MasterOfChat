//
//  RegisterView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/3/24.
//
// MARK: - Register View(회원 가입)

import SwiftUI

struct RegisterView: View {
    
    // MARK: - 뷰모델에 넣어서 컨펌확인까지 구현하자.
    @State private var registerID: String = ""
    @State private var registerPW: String = ""
    @State private var confirmPW: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
                .frame(height: 50)
            
            Text("회원 가입을 위한 정보를 입력하세요.")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            Spacer()
                .frame(height: 30)
            
            HStack() {
                Text("ID")
                    .font(.subheadline)
                    .frame(width:60, height: 40)
                
                TextField("이메일 형식의 아이디를 입력하세요", text: $registerID)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
            } //:HSTACK
            .padding(.bottom)
            
            HStack {
                Text("암호")
                    .font(.subheadline)
                    .frame(width:60, height: 40)
                
                SecureField("패스워드를 입력하세요", text: $registerPW)
                    .textFieldStyle(.roundedBorder)
            } //:HSTACK
            .padding(.bottom)
            
            HStack {
                Text("암호 확인")
                    .font(.subheadline)
                    .frame(width:60, height: 40)
                
                SecureField("패스워드를 입력하세요", text: $confirmPW)
                    .textFieldStyle(.roundedBorder)
            } //:HSTACK
            
            Button {
                // TODO: (패스워드가 통과되면)파이어베이스 등록
            } label: {
                Text("회원 가입")
            }
            .padding(.top, 30)

            
        } //:VSTACK
        .padding(5)
        Spacer()
    }
}

#Preview {
    RegisterView()
}

//
//  RegisterView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/3/24.
//
// MARK: - Register View(회원 가입)

import SwiftUI


struct RegisterView: View {
    
    // MARK: - Property
    @StateObject var vm: RegisterViewModel = RegisterViewModel()
    
    // MARK: - View
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
                
                TextField("이메일 형식의 아이디를 입력하세요", text: $vm.registerID)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
            } //:HSTACK
            .padding(.bottom)
            
            HStack {
                Text("암호")
                    .font(.subheadline)
                    .frame(width:60, height: 40)
                
                SecureField("패스워드를 입력하세요", text: $vm.registerPW)
                    .textFieldStyle(.roundedBorder)
            } //:HSTACK
            .padding(.bottom)
            
            HStack {
                Text("암호 확인")
                    .font(.subheadline)
                    .frame(width:60, height: 40)
                
                SecureField("패스워드를 입력하세요", text: $vm.confirmPW)
                    .textFieldStyle(.roundedBorder)
            } //:HSTACK
            
            Button {
                vm.signUp()
            } label: {
                Text("회원 가입")
            }
            .alert(isPresented: $vm.showAlert) {
                if let alert = vm.alertType {
                    getAlert(alert: alert)
                } else {
                    getAlert("알림")
                }
                
                // TODO: (성공)가입 완료된 후 dismiss
            }
            .padding(.top, 30)
        } //:VSTACK
        .padding(5)
        Spacer()
    }
    
    // MARK: - Function
    
    private func getAlert(alert: AlertType) -> Alert {
        
        let alertValue = vm.getAlertValue(alert: alert)
        
        return Alert(
            title: Text(alertValue.title),
            message: Text(alertValue.message),
            dismissButton: .default(Text("확인"))
        )
    }
    
    private func getAlert(_ alert: String) -> Alert {
        return Alert(
            title: Text(alert),
            message: Text("다시 시도해 주세요"),
            dismissButton: .default(Text("확인"))
        )
    }
}

#Preview {
    RegisterView(vm: RegisterViewModel())
}

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
    @StateObject var vm: LoginViewModel = LoginViewModel()

    @ObservedObject var authVm: AuthViewModel // 인증 뷰모델
    
    
    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack { // 전체 백그라운드 적용을 위한 ZStack
                Color(K.AppColors.loginBackGround).ignoresSafeArea()
                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    HStack() {
                        Text("ID")
                            .font(.title)
                            .frame(width:60, height: 40)
                        
                        // (Binding) 사용자 정의 바인딩(옵셔널이라)
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
                            // Task : SwiftUI에서 비동기 코드를 실행하기 위한 방법
                            // SwiftUI의 Button은 동기적으로 동작하므로 비동기 작업을 실행하려면 Task를 명시적으로 사용해야 함.
                            // 버튼을 탭했을 때 비동기 작업이 시작되고, 완료될 때까지 다른 작업이 차단되지 않는다.(안전하게 비동기 함수 호출)
                            Task {
                                await vm.signIn()
                                sheetStatusChange()
                            }
                        } label: {
                            Text("로그인")
                        }
                        .alert(isPresented: $vm.showAlert) {
                            if let alert = vm.alertType {
                                getAlert(alert: alert)
                            } else {
                                getAlert("로그인 실패")
                            }
                        }
                        .frame(width: 100, height: 50)
                        .background(Color(K.AppColors.loginBtnColor).cornerRadius(10).shadow(radius: 2))
                        .foregroundColor(.white)
                        .font(.title.bold())
                        .disabled(!vm.isInputValid)
                        
                        Button {
                            // TODO: Login cancel logic
                        } label: {
                            Text("취소")
                        }
                        .frame(width: 100, height: 50)
                        .background(Color(K.AppColors.loginBtnColor).opacity(0.2).cornerRadius(10).shadow(radius: 2))
                        .foregroundColor(.white)
                        .font(.title.bold())
                    } //:HSTACK
                    Spacer()
                    
                    Divider()
                    
                    VStack(spacing: 10) {
                        Text("회원이 아니신가요?")
                            .font(.footnote)
                            .foregroundStyle(.primary.opacity(0.5))
                        
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("회원가입")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                    } //:VSTACK
                } //:VSTACK
                .padding()
            } //:ZSTACK
        } //:NAVIGATION
    }
    
    // MARK: - Function
    
    private func sheetStatusChange() {
        if let alertType = vm.alertType {
            if alertType is LoginSuccess {
                authVm.isUserLoggedIn = true // 로그인 성공시 .sheet닫음
            }
        }
    }
    
    private func getAlert(alert: AlertType) -> Alert {
        print("getAlert")
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
    LoginView(authVm: AuthViewModel())
}

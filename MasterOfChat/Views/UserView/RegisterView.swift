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
    
    //@State var alertType: registerError? = nil
    @State var alertType: AlertType? = nil
    
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
                vm.isChecked { result in
                    switch result {
                    case .success(let success):
                        self.alertType = success
                        vm.showAlert.toggle()
                        print("가입 성공")
                    case .failure(let error):
                        self.alertType = error
                        vm.showAlert.toggle()
                        //                        switch error {
                        //                        case .notEmailFormat:
                        //                            print("이메일 형식 아님")
                        //                        case .notPasswordSame:
                        //                            print("동일하지 않은 패스워드")
                        //                        case .passwordLength:
                        //                            print("패스워드는 4자리 이상만 가능")
                        //                        case .authFailed:
                        //                            print("인증 오류 발생")
                        //                        }
                    }
                }
            } label: {
                Text("회원 가입")
            }
            .alert(isPresented: $vm.showAlert) {
                // MARK: 🖐️ 강제 언래핑 괜찮은가? (성공이든 실패든 값은 무조건 있을텐데..?)
                getAlert(alert: alertType!)
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
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("확인"))
        )
    }
    
    //    private func getAlert() -> Alert {
    //        let title = "오류"
    //        var message = ""
    //
    //        switch alertType {
    //        case .notEmailFormat:
    //            message = "이메일 형식으로 입력하세요"
    //        case .notPasswordSame:
    //            message = "패스워드를 확인하세요"
    //        case .passwordLength:
    //            message = "패스워드 최소 길이는 4자리 입니다"
    //        case .authFailed:
    //            message = "인증 오류입니다"
    //        case .none:
    //            message = "알 수 없는 오류"
    //        }
    //
    //        return Alert(
    //            title: Text(title),
    //            message: Text(message),
    //            dismissButton: .default(Text("확인"))
    //        )
    //    }
}

#Preview {
    RegisterView(vm: RegisterViewModel())
}

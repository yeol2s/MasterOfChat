//
//  SplashView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/2/24.
//
// MARK: - Splash View (첫 로딩화면)

import SwiftUI

struct SplashView: View {
    // MARK: - Property
    @State private var isActive: Bool = false
    @State private var size: Double = 0.5
    @State private var opacity: Double = 0.5
    
    var body: some View {
        if isActive {
            NavigationStack {
                MainView()
            }
        } else {
            VStack(spacing: 20) {
                Image("bird")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(100)
                
                Text("채팅의 고수")
                    .font(.title.bold())
            } //:VSTACK
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear() { // View가 시작될 떄 호출
                withAnimation(.easeInOut(duration: 1.5)) { // .easeInOut : 애니메이션 속도
                    size = 1.0
                    opacity = 1.0
                    
                    // (비동기적으로) 3초후 메인 스레드에서 앱 실행 상태로 변경
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        isActive = true
                    }
                }
            }
        } //:CONDITIONAL
    }
}

#Preview {
    NavigationView {
        SplashView()
    }
}

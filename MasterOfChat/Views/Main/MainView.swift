//
//  MainView.swift
//  MasterOfChat
//
//  Created by 유성열 on 5/2/24.
//
// MARK: - Main View(채팅 화면)

import SwiftUI

struct MainView: View {
    var body: some View {
        // TODO: (파이어베이스)로그인 유무에 따라 뷰 컨디셔널 처리 (+네비게이션뷰 처리)
        LoginView()
        
        // TODO: 로그인이 되어있다면 메인뷰에서 바로 채팅진행
    }
}

#Preview {
    NavigationView {
        MainView()
    }
}

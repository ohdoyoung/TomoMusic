//
//  SoundScapeApp.swift
//  SoundScape
//
//  Created by 오도영 on 1/25/25.
//

import SwiftUI

@main
struct SoundScapeApp: App {
    @StateObject private var userInfo = UserInfo()  // UserInfo 객체 초기화
    
    var body: some Scene {
        WindowGroup {
            LoginView()
            .environmentObject(userInfo)
        }
    }
}

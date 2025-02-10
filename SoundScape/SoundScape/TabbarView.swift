//
//  TabbarView.swift
//  SoundScape
//
//  Created by 오도영 on 2/9/25.
//

import SwiftUI

struct TabbarView: View {
    enum Tab {  // Tag에서 사용할 Tab 열겨형
        case a, b, c
    }
    @State private var selected: Tab = .a  // 선택된 Tab을 컨트롤할 수 있는 상태 변수
    
    var body: some View {
        TabView(selection: $selected) {
            Group {
                NavigationStack {
                    AlbumSearchView()
                }
                .tag(Tab.a)
                
                NavigationStack {
                    CalendarView()
                }
                .tag(Tab.b)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        tabBar
    }
    
    var tabBar: some View {
        HStack {
            Spacer()
            
            Button {
                selected = .a
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                    if selected == .a { Text("검색").font(.system(size: 11)) }
                }
            }
            .foregroundStyle(selected == .a ? Color.accentColor : Color.primary)
            
            Spacer()
            Button {
                selected = .b
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                    if selected == .b { Text("달력").font(.system(size: 11)) }
                }
            }
            .foregroundStyle(selected == .b ? Color.accentColor : Color.primary)
            
            Spacer()
        }
        .padding()
        .frame(height: 72)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
        .padding(.horizontal)
    }
}

#Preview {
    TabbarView()
}

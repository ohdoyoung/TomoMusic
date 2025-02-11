// TabbarView.swift
import SwiftUI

struct TabbarView: View {
    enum Tab {  // Tag에서 사용할 Tab 열겨형
        case a, b, c
    }
    
    @State private var selected: Tab = .a  // 선택된 Tab을 컨트롤할 수 있는 상태 변수
    @State private var selectedDate: Date = Date()  // 캘린더에 전달할 날짜 상태 변수
    @State private var diaryEntries: [MusicDiaryEntry] = []  // diaryEntries를 관리
    
    var body: some View {
        VStack {
            // TabView 부분
            TabView(selection: $selected) {
                Group {
                    NavigationStack {
                        AlbumSearchView() // 앨범 검색 뷰
                    }
                    .tag(Tab.a)
                
                    NavigationStack {
                        CalendarView(selectedDate: $selectedDate)  // @Binding을 사용하여 자식 뷰에 전달
                    }
                    .tag(Tab.b)
                    
                    NavigationStack {
                        MyPageView()  // 다른 탭 뷰
                    }
                    .tag(Tab.c)
                }
                .toolbar(.hidden, for: .tabBar)
            }

            // 커스텀 탭바
            tabBar
        }
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
                }
            }
            .foregroundStyle(selected == .b ? Color.accentColor : Color.primary)
            
            Spacer()
            
            Button {
                selected = .c
            } label: {
                VStack(alignment: .center) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                }
            }
            .foregroundStyle(selected == .c ? Color.accentColor : Color.primary)
            
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

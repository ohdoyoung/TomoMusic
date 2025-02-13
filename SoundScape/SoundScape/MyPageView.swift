import SwiftUI

struct MyPageView: View {
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var myInfo: MyInfo?
    @State private var albumsByMonth: [String: [AlbumInfo]] = [:] // 월별 앨범 목록
    @State private var customMonthTitles: [String: String] = [:] // 커스텀 월별 제목 저장
    @State private var isEditingTitle: [String: Bool] = [:] // 제목 수정 상태
    
    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            // 간단한 인사말 표시
            if let nickname = myInfo?.nickname {
                HStack {
                    Text("반가워요, \(nickname)님! 🌟")
                        .font(.title3) // 폰트 크기 줄이기
                        .fontWeight(.semibold) // 폰트 두께를 약간 두껍게
                        .foregroundColor(.primary)
                        .padding(.top, 10) // 위쪽 여백 조금 추가
                        .transition(.opacity) // 부드럽게 나타나는 효과 추가
                    Spacer() // 오른쪽 여백을 위해 Spacer 추가
                }
                .animation(.easeIn(duration: 0.5), value: myInfo != nil) // myInfo가 nil이 아닐 때만 애니메이션 적용
            }
            
            // 월별 앨범들
            ScrollView {
                ForEach(albumsByMonth.keys.sorted(), id: \.self) { month in
                    VStack(alignment: .leading) {
                        // 제목과 수정 버튼
                        HStack(alignment: .center) {
                            if isEditingTitle[month] == true {
                                // 수정 중일 때 TextField 보여주기
                                TextField("월별 제목", text: Binding(
                                    get: { customMonthTitles[month] ?? "\(month) Sound" },
                                    set: { newTitle in
                                        customMonthTitles[month] = newTitle // 제목 변경 시 업데이트
                                    }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // TextField 스타일
                                .padding(5)
                            } else {
                                // 기본 제목을 표시
                                Text(customMonthTitles[month] ?? "\(month) Sound")
                                    .font(.headline)
                                    .padding(.top)
                            }
                            
                            Spacer()
                            
                            // 수정 버튼 (아이콘으로 변경)
                            Button(action: {
                                if isEditingTitle[month] == true {
                                    // 수정 완료 후 isEditingTitle를 false로 설정하여 수정 종료
                                    isEditingTitle[month] = false
                                } else {
                                    // 수정 시작
                                    isEditingTitle[month] = true
                                }
                            }) {
                                // 수정 상태에 따라 아이콘 변경
                                Image(systemName: isEditingTitle[month] == true ? "checkmark.circle.fill" : "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding(.top, 5) // 위쪽 패딩을 추가하여 수직 정렬 맞추기
                            }
                        }
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                            ForEach(albumsByMonth[month] ?? [], id: \.id) { album in
                                VStack {
                                    AsyncImage(url: URL(string: album.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                        case .success(let image):
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill) // 비율을 맞추면서 채움
                                                .frame(width: 100, height: 100) // 고정 크기 설정
                                                .clipped() // 이미지가 프레임을 벗어나지 않도록 잘라냄
                                                .cornerRadius(8)
                                        case .failure:
                                            Text("이미지 로드 실패")
                                                .foregroundColor(.red)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    
                                    Spacer() // 제목이 길어져도 이미지가 밀리지 않도록 공간 추가
                                    
                                    Text(album.name) // 앨범 이름 표시
                                        .font(.caption) // 제목 크기 조정
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(1) // 제목이 너무 길면 한 줄로 자르기 (필요시 조정)
                                }
                                .frame(width: 120) // 앨범 이미지 크기
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            fetchUserInfo()
            fetchDiaryEntries() // 일기 데이터를 가져오는 함수 호출
        }
    }
    
    private func fetchDiaryEntries() {
        guard let url = URL(string: "http://192.168.219.94:8085/api/entries?loginId=\(userId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                logResponseData(data)
                parseDiaryEntries(data)
            }
        }.resume()
    }
    
    private func logResponseData(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            // 로그 확인용
            print("📌 서버 응답 JSON: \(jsonString)")
        }
    }
    
    private func parseDiaryEntries(_ data: Data) {
        do {
            let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
            DispatchQueue.main.async {
                diaryEntries = decodedEntries
                // 각 일기에서 앨범 ID를 추출하고 앨범 정보 가져오기
                for entry in decodedEntries {
                    if let albumId = entry.albumId {
                        fetchAlbumInfo(for: entry.id, albumId: albumId, createdAt: entry.createdAt)
                    }
                }
            }
        } catch {
            print("디코딩 오류: \(error)")
        }
    }
    
    private func fetchAlbumInfo(for entryId: Int, albumId: String, createdAt: String) {
        guard let url = URL(string: "http://192.168.219.94:8085/spotify/album/\(albumId)/detail") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(AlbumInfo.self, from: data)
                    DispatchQueue.main.async {
                        albumData[entryId] = decodedData
                        // 앨범의 createdAt을 기준으로 월별로 그룹화
                        groupAlbumsByMonth(album: decodedData, createdAt: createdAt)
                    }
                } catch {
                    print("Spring 서버 응답 디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
    
    private func groupAlbumsByMonth(album: AlbumInfo, createdAt: String) {
        // createdAt 값을 로그로 출력하여 확인
        print("createdAt: \(createdAt)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 서버에서 오는 포맷에 맞게 설정
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
            let year = calendar.component(.year, from: date)
            let monthYear = "\(year)년 \(month)"
            
            // 월별 앨범 목록에 추가
            if albumsByMonth[monthYear] == nil {
                albumsByMonth[monthYear] = []
            }
            albumsByMonth[monthYear]?.append(album)
        } else {
            print("createdAt 값 변환 실패: \(createdAt)")
        }
    }

    private func fetchUserInfo() {
        guard let url = URL(string: "http://192.168.219.94:8085/api/users/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(MyInfo.self, from: data)
                    DispatchQueue.main.async {
                        myInfo = decodedData
                    }
                } catch {
                    print("Error decoding data : \(error)")
                }
            }
        }.resume()
    }
}

#Preview {
    MyPageView()
}

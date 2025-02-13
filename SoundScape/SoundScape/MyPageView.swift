import SwiftUI

struct MyPageView: View {
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var trackData: [Int: TrackInfo] = [:]
    @State private var myInfo: MyInfo?
    @State private var albumsByMonth: [String: [AlbumInfo]] = [:]
    @State private var tracksByMonth: [String: [TrackInfo]] = [:]
    @State private var customMonthTitles: [String: String] = [:]
    @State private var isEditingTitle: [String: Bool] = [:]
    @State private var isHidden: Bool = false // 이미지 숨기기 상태
    @State private var hiddenMonths: [String: Bool] = [:] // 월별 숨김 여부 관리

    
    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            greetingMessage
            
            monthAlbumsSection
        }
        .padding()
        .onAppear {
            fetchUserInfo()
            fetchDiaryEntries()
        }
    }
    
    private var greetingMessage: some View {
        Group {
            if let nickname = myInfo?.nickname {
                HStack {
                    Text("반가워요, \(nickname)님! 🌟")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, 10)
                        .transition(.opacity)
                    Spacer()
                }
                .animation(.easeIn(duration: 0.5), value: myInfo != nil)
            }
        }
    }
    
    // 👁‍🗨 토글 버튼 (아이콘만 표시)
     private var toggleImagesButton: some View {
         Button(action: {
             isHidden.toggle() // 숨기기 상태 토글
         }) {
             Image(systemName: isHidden ? "eye.slash" : "eye")
                 .font(.title2)
                 .foregroundColor(.blue)
                 .padding()
         }
     }
    
    private var monthAlbumsSection: some View {
        ScrollView {
            ForEach(albumsByMonth.keys.sorted(), id: \.self) { month in
                VStack(alignment: .leading) {
                    titleWithEditButton(for: month)

                    // 👁 hiddenMonths[month]가 true이면 해당 월 숨김
                    if hiddenMonths[month] != true {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                            albumViews(for: month)
                            trackViews(for: month)
                        }
                    }
                }
            }
        }
    }
    private func titleWithEditButton(for month: String) -> some View {
        HStack(alignment: .center) {
            if isEditingTitle[month] == true {
                TextField("월별 제목", text: Binding(
                    get: { customMonthTitles[month] ?? "\(month) Sound" },
                    set: { newTitle in customMonthTitles[month] = newTitle }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(5)
            } else {
                Text(customMonthTitles[month] ?? "\(month) Sound")
                    .font(.headline)
                    .padding(.top)
            }
            
            Spacer()
            
            // ✏️ 수정 버튼
            Button(action: {
                if isEditingTitle[month] == nil {
                    isEditingTitle[month] = false
                }
                isEditingTitle[month]?.toggle()
            }) {
                Image(systemName: isEditingTitle[month] == true ? "checkmark.circle.fill" : "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
            }
            
            // 👁 숨기기 버튼 (앨범 & 트랙 숨기기)
            Button(action: {
                if hiddenMonths[month] == nil {
                    hiddenMonths[month] = false
                }
                hiddenMonths[month]?.toggle()
            }) {
                Image(systemName: hiddenMonths[month] == true ? "eye.slash" : "eye")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
            }
        }
    }
    
    private func albumViews(for month: String) -> some View {
        ForEach(albumsByMonth[month] ?? [], id: \.id) { album in
            albumView(for: album)
        }
    }

    
    private func albumView(for album: AlbumInfo) -> some View {
        VStack {
            loadImage(from: album.imageUrl ?? "")
            Text(album.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(width: 120)
    }

    
    private func trackViews(for month: String) -> some View {
        ForEach(tracksByMonth[month] ?? [], id: \.id) { track in
            trackView(for: track)
        }
    }

    private func trackView(for track: TrackInfo) -> some View {
        VStack {
            if let imageUrl = track.imageUrl, !imageUrl.isEmpty {
                loadImage(from: imageUrl)
            } else {
                Text("이미지 없음")
            }
            Text(track.name)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
    
    private func loadImage(from url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            case .failure:
                Text("이미지 로드 실패")
                    .foregroundColor(.red)
            @unknown default:
                EmptyView()
            }
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
            print("📌 서버 응답 JSON: \(jsonString)")
        }
    }
    
    private func parseDiaryEntries(_ data: Data) {
        do {
            let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
            DispatchQueue.main.async {
                diaryEntries = decodedEntries
                for entry in decodedEntries {
                    if let albumId = entry.albumId {
                        fetchAlbumInfo(for: entry.id, albumId: albumId, createdAt: entry.createdAt)
                    } else if let trackId = entry.trackId {
                        fetchTrackInfo(for: entry.id, trackId: trackId, createdAt: entry.createdAt)
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
                        groupAlbumsByMonth(album: decodedData, createdAt: createdAt)
                    }
                } catch {
                    print("Spring 서버 응답 디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
    
    private func groupAlbumsByMonth(album: AlbumInfo, createdAt: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
            let year = calendar.component(.year, from: date)
            let monthYear = "\(year)년 \(month)"
            
            if albumsByMonth[monthYear] == nil {
                albumsByMonth[monthYear] = []
            }
            
            albumsByMonth[monthYear]?.append(album)
        } else {
            print("createdAt 값 변환 실패: \(createdAt)")
        }
    }
    
    private func groupTracksByMonth(track: TrackInfo, createdAt: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: createdAt) {
            let calendar = Calendar.current
            let month = calendar.monthSymbols[calendar.component(.month, from: date) - 1]
            let year = calendar.component(.year, from: date)
            let monthYear = "\(year)년 \(month)"
            
            if tracksByMonth[monthYear] == nil {
                tracksByMonth[monthYear] = []
            }
            
            tracksByMonth[monthYear]?.append(track)
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
    
    private func fetchTrackInfo(for entryId: Int, trackId: String, createdAt: String) {
        guard let url = URL(string: "http://192.168.219.94:8085/spotify/track/\(trackId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Server Response: \(jsonString)")
                }

                do {
                    let decodedData = try JSONDecoder().decode(TrackInfo.self, from: data)
                    DispatchQueue.main.async {
                        trackData[entryId] = decodedData
                        groupTracksByMonth(track: decodedData, createdAt: createdAt)
                    }
                } catch {
                    print("Error decoding data : \(error)")
                }
            }
        }.resume()
    }
}

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var trackData: [Int: TrackInfo] = [:]
    @State private var recommendedTracks: [RecommendedTrack] = [] // 추천 트랙
    @State private var visibleTrackId: Int? = nil // 각 일기마다 추천 트랙을 보여줄지 여부를 다르게 설정
    
    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(10)
            
            List {
                let filteredEntries = filterDiaryEntries()
                
                ForEach(filteredEntries, id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 12) {
                        diaryEntryView(entry)
                        
                        // 추천 트랙 보기 버튼
                        Button(action: {
                            if visibleTrackId == entry.id {
                                visibleTrackId = nil // 같은 일기의 트랙을 클릭하면 숨김
                            } else {
                                visibleTrackId = entry.id
                                fetchRecommendedTracks(for: entry.emotions ?? [])
                            }
                        }) {
                            Text(visibleTrackId == entry.id ? "추천 트랙 숨기기" : "추천 트랙 보기")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                        
                        // 추천 트랙 리스트 표시
                        if let visibleTrackId = visibleTrackId, visibleTrackId == entry.id {
                            recommendedTracksList
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .overlay(
                diaryEntries.isEmpty ? Text("작성된 음악 일기가 없습니다")
                    .foregroundColor(.gray)
                    .italic() : nil
            )
            .listStyle(PlainListStyle())
        }
        .onAppear {
            fetchDiaryEntries()
        }
    }
    
    private func diaryEntryView(_ entry: MusicDiaryEntry) -> some View {
        HStack(spacing: 16) {
            if let album = albumData[entry.id] {
                loadImage(from: album.imageUrl, size: 60)
            }
            if let track = trackData[entry.id] {
                loadImage(from: track.imageUrl, size: 60)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let album = albumData[entry.id] {
                    Text(album.name ?? "앨범 이름 없음")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                if let track = trackData[entry.id] {
                    Text(track.name ?? "트랙 이름 없음")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)
                
                if let emotions = entry.emotions, !emotions.isEmpty {
                    emotionTagsView(emotions)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func emotionTagsView(_ emotions: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(emotions, id: \.self) { emotion in
                Text(emotion)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
            }
        }
    }
    
    private func filterDiaryEntries() -> [MusicDiaryEntry] {
        return diaryEntries.filter {
            if let createdDate = stringToDate($0.createdAt) {
                return formattedDate(selectedDate) == formattedDate(createdDate)
            }
            return false
        }
    }
    
    private func loadImage(from url: String?, size: CGFloat) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .success(let image):
                image.resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .cornerRadius(8)
            case .failure:
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func stringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: string)
    }
    
    private func fetchDiaryEntries() {
        guard let url = URL(string: "http://localhost:8085/api/entries?loginId=\(userId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                parseDiaryEntries(data)
            }
        }.resume()
    }
    
    private func parseDiaryEntries(_ data: Data) {
        do {
            let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
            DispatchQueue.main.async {
                diaryEntries = decodedEntries
                for entry in decodedEntries {
                    if let albumId = entry.albumId {
                        fetchAlbumInfo(for: entry.id, albumId: albumId)
                    }
                    if let trackId = entry.trackId {
                        fetchTrackInfo(for: entry.id, trackId: trackId)
                    }
                }
            }
        } catch {
            print("디코딩 오류: \(error)")
        }
    }
    
    private func fetchAlbumInfo(for entryId: Int, albumId: String) {
        guard let url = URL(string: "http://localhost:8085/spotify/album/\(albumId)/detail") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(AlbumInfo.self, from: data)
                    DispatchQueue.main.async {
                        albumData[entryId] = decodedData
                    }
                } catch {
                    print("Spring 서버 응답 디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
    
    private func fetchTrackInfo(for entryId: Int, trackId: String) {
        guard let url = URL(string: "http://localhost:8085/spotify/track/\(trackId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(TrackInfo.self, from: data)
                    DispatchQueue.main.async {
                        trackData[entryId] = decodedData
                    }
                } catch {
                    print("디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
    
    private func fetchRecommendedTracks(for emotions: [String]) {
        let emotionQuery = emotions.joined(separator: ",") // 이모지를 쉼표로 구분하여 하나의 문자열로 만듬
        
        guard let url = URL(string: "http://localhost:8085/spotify/searchByEmotion?emotions=\(emotionQuery)") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
            guard let data = data, error == nil else {
                print("Network request failed: \(String(describing: error))")
                return
            }
            
            do {
                // JSONDecoder로 응답 데이터 디코딩
                let decoder = JSONDecoder()
                let recommendationResponse = try decoder.decode(RecommendationResponse.self, from: data)
                
                // 디코딩된 트랙 데이터를 recommendedTracks 배열에 저장
                DispatchQueue.main.async {
                    self.recommendedTracks = recommendationResponse.tracks.items
                }
                
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        
        task.resume()
    }
    
    private var recommendedTracksList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recommendedTracks, id: \.id) { track in
                    VStack {
                        // 앨범 커버
                        AsyncImage(url: URL(string: track.album.images.first?.url ?? "")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 150, height: 150)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(12)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        // 트랙 이름
                        Text(track.name)
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                        // 아티스트
                        Text(track.artists.first?.name ?? "Unknown Artist")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 150)
                }
            }
            .padding(.horizontal)
        }
    }
}

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var diaryEntries: [MusicDiaryEntry] = []
    @State private var albumData: [Int: AlbumInfo] = [:]
    @State private var trackData: [Int: TrackInfo] = [:]
    
    let userId = UserInfo.shared.loginId
    
    var body: some View {
        VStack {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            List {
                let filteredEntries = diaryEntries.filter {
                    if let createdDate = stringToDate($0.createdAt) {
                        return formattedDate(selectedDate) == formattedDate(createdDate)
                    }
                    return false
                }
                
                ForEach(filteredEntries, id: \.id) { entry in
                    HStack {
                        if let album = albumData[entry.id] {
                            loadImage(from: album.imageUrl, size: 50)
                        }
                        if let track = trackData[entry.id] {
                            loadImage(from: track.imageUrl, size: 50)
                        }
                        
                        VStack(alignment: .leading) {
                            if let album = albumData[entry.id] {
                                Text(album.name ?? "앨범 이름 없음")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            if let track = trackData[entry.id]{
                                Text(track.name ?? "앨범 이름 없음")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Text(entry.content)
                                .font(.body)
                                .foregroundColor(.gray)
                            
                            HStack {
                                ForEach(entry.emotions ?? [], id: \.self) { emotion in
                                    Text(emotion)
                                }
                            }
                        }
                    }
                    .padding(5)
                }
            }
            .overlay(
                diaryEntries.isEmpty ? Text("작성된 음악 일기가 없습니다").foregroundColor(.gray) : nil
            )
        }
        .onAppear {
            fetchDiaryEntries()
        }
    }
    /// ✅ 공통 이미지 로딩 함수
    private func loadImage(from url: String?, size: CGFloat) -> some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
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
        //        guard let url = URL(string: "http://192.168.219.94:8085/api/entries?loginId=\(userId)") else { return }
        guard let url = URL(string: "http://localhost:8085/api/entries?loginId=\(userId)") else { return }
        
        print("유저아이디는 이거임 ㅋ: \(userId)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                logResponseData(data)
                parseDiaryEntries(data)
            }
        }.resume()
    }
    
    private func logResponseData(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            //            print("📌 서버 응답 JSON: \(jsonString)")
        }
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
                    if let trackId = entry.trackId{
                        fetchTrackInfo(for: entry.id, trackId: trackId)
                    }
                }
            }
        } catch {
            print("디코딩 오류: \(error)")
        }
    }
    
    private func fetchAlbumInfo(for entryId: Int, albumId: String) {
        //        guard let url = URL(string: "http://192.168.219.94:8085/spotify/album/\(albumId)/detail") else { return }
        guard let url = URL(string: "http://localhost:8085/spotify/album/\(albumId)/detail") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(AlbumInfo.self, from: data)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        //                        print("📌 Spring 서버 응답 JSON: \(jsonString)")
                    }
                    DispatchQueue.main.async {
                        albumData[entryId] = decodedData
                    }
                } catch {
                    print("Spring 서버 응답 디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
    private func fetchTrackInfo(for entryId: Int,trackId: String) {
        guard let url = URL(string: "http://localhost:8085/spotify/track/\(trackId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(TrackInfo.self, from: data)
                    
                    DispatchQueue.main.async {
                        // 트랙 정보를 처리
                        // 예: 트랙 이
                        trackData[entryId] = decodedData
                    }
                } catch {
                    print("Track info decoding error: \(error)")
                }
            }
        }.resume()
    }
}

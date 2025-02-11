import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @State private var albumDetails: AlbumDetails?
    @State private var showTracks = false // 트랙 목록을 표시할지 여부
    @State private var albumId: String? // 앨범 ID를 옵셔널로 관리
    
    var body: some View {
        VStack {
            // 앨범 썸네일 이미지
            AsyncImage(url: URL(string: album.firstImageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
            }
            .padding()
            
            // 앨범 이름 표시
            if let details = albumDetails {
                Text(details.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 5)
            }
            
            // 트랙 보기 버튼
            Button(action: {
                withAnimation {
                    showTracks.toggle() // 버튼 클릭 시 트랙 목록 토글
                }
            }) {
                Text(showTracks ? "트랙 숨기기" : "트랙 보기")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .padding(10)
                    .frame(maxWidth: 120,minHeight: 20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
            .padding(.top, 20)
            
            if let details = albumDetails, showTracks {
                List(details.tracks.items, id: \.id) { track in
                    HStack {
                        // 트랙 번호 표시
                        if let index = details.tracks.items.firstIndex(where: { $0.id == track.id }) {
                            Text("\(index + 1).")
                                .bold()
                        }
                        
                        VStack(alignment: .leading) {
                            Text(track.name)
                                .font(.headline)
                            Text(track.artistNames)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                }
                .frame(height: 200)
                .padding(.top, 10)
            }
            
            Spacer()
            
            // `albumId`를 `@Binding`으로 전달
            DiaryView(albumId: $albumId, trackId: .constant(nil)) // 앨범 ID를 바인딩으로 전달
                .padding()
        }
        .onAppear {
            fetchAlbumDetails(for: album.id) // 앨범 ID로 디테일 정보 가져오기
            albumId = album.id // `album.id`를 `albumId`에 저장
        }
        .navigationBarTitle("앨범 상세", displayMode: .inline)
    }
    
    // 앨범 상세 정보를 가져오는 함수
    func fetchAlbumDetails(for albumId: String) {
        APIService.fetchAlbumDetails(for: albumId) { details in
            DispatchQueue.main.async {
                self.albumDetails = details
            }
        }
    }
}

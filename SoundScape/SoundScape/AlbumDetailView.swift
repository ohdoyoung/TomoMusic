import SwiftUI

struct AlbumDetailView: View {
    let album: Album // 앨범 객체를 받음
    @State private var albumDetails: AlbumDetails?

    var body: some View {
        VStack {
            // ✅ 앨범 썸네일 이미지
            AsyncImage(url: URL(string: album.firstImageURL)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
            }
            .padding()

            // ✅ 앨범 정보 표시
            if let details = albumDetails {
                Text(details.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                // ✅ 트랙 목록 표시
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
            } else {
                // ✅ 로딩 표시
                ProgressView("로딩 중...")
                    .padding()
            }
        }
        .onAppear {
            fetchAlbumDetails(for: album.id) // 앨범 ID로 디테일 정보 가져오기
        }
    }

    // ✅ 앨범 상세 정보를 가져오는 함수
    func fetchAlbumDetails(for albumId: String) {
        APIService.fetchAlbumDetails(for: albumId) { details in
            DispatchQueue.main.async {
                self.albumDetails = details
                print(details)
            }
        }
    }
}

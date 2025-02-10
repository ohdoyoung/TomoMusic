//import SwiftUI
//
//struct AlbumSearchView: View {
//    @StateObject private var viewModel = AlbumSearchViewModel()
//    @State private var searchText = ""
//    @State private var selectedAlbumID: String?
//    @State private var selectedTrackID: String? // ✅ 노래 선택 ID 추가
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                // 검색 입력 필드
//                TextField("앨범/노래 검색", text: $searchText, onCommit: {
//                    viewModel.search(query: searchText) // ✅ 앨범 + 노래 검색
//                })
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//                // 검색 결과 목록
//                List {
//                    // ✅ 앨범 섹션
//                    if !viewModel.albums.isEmpty {
//                        Section(header: Text("앨범")) {
//                            ForEach(viewModel.albums, id: \.id) { album in
//                                NavigationLink(
//                                    destination: AlbumDetailView(album: album),
//                                    tag: album.id,
//                                    selection: $selectedAlbumID
//                                ) {
//                                    HStack {
//                                        AsyncImage(url: URL(string: album.firstImageURL)) { image in
//                                            image.resizable()
//                                        } placeholder: {
//                                            Color.gray
//                                        }
//                                        .frame(width: 50, height: 50)
//                                        .cornerRadius(8)
//
//                                        VStack(alignment: .leading) {
//                                            Text(album.name)
//                                                .font(.headline)
//                                            Text(album.artistNames)
//                                                .font(.subheadline)
//                                                .foregroundColor(.gray)
//                                        }
//
//                                        Spacer()
//
//                                        Button(action: {
//                                            selectedAlbumID = album.id
//                                        }) {
//                                            Image(systemName: "plus.circle.fill")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 15, height: 15)
//                                                .foregroundColor(.blue)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//
//                    // ✅ 노래(트랙) 섹션
//                    if !viewModel.tracks.isEmpty {
//                        Section(header: Text("노래")) {
//                            ForEach(viewModel.tracks, id: \.id) { track in
//                                NavigationLink(
//                                    destination: TrackDetailView(track: track), // ✅ 트랙 상세 화면
//                                    tag: track.id,
//                                    selection: $selectedTrackID
//                                ) {
//                                    HStack {
//                                        AsyncImage(url: URL(string: track.imageUrl)) { image in
//                                            image.resizable()
//                                        } placeholder: {
//                                            Color.gray
//                                        }
//                                        .frame(width: 50, height: 50)
//                                        .cornerRadius(8)
//
//                                        VStack(alignment: .leading) {
//                                            Text(track.name)
//                                                .font(.headline)
//                                            Text(track.artistName)
//                                                .font(.subheadline)
//                                                .foregroundColor(.gray)
//                                        }
//
//                                        Spacer()
//
//                                        Button(action: {
//                                            selectedTrackID = track.id
//                                        }) {
//                                            Image(systemName: "play.circle.fill")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 15, height: 15)
//                                                .foregroundColor(.green)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .navigationTitle("앨범/노래 검색")
//            }
//        }
//    }
//}
//
//#Preview {
//    AlbumSearchView()
//}


import SwiftUI

struct AlbumSearchView: View {
    @StateObject private var viewModel = AlbumSearchViewModel()
    @State private var searchText = ""
    @State private var selectedAlbumID: String?
    @State private var selectedTrackID: String?

    var body: some View {
        NavigationStack {
            VStack {
                // 검색 입력 필드
                TextField("앨범/노래 검색", text: $searchText, onCommit: {
                    viewModel.search(query: searchText)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                // 검색 결과 목록
                List {
                    if !viewModel.albums.isEmpty {
                        albumSection(viewModel.albums)
                    }

                    if !viewModel.tracks.isEmpty {
                        trackSection(viewModel.tracks)
                    }
                }
                .navigationTitle("앨범/노래 검색")
            }
        }
    }

    // ✅ 앨범 리스트 UI 분리
    private func albumSection(_ albums: [Album]) -> some View {
        Section(header: Text("앨범")) {
            ForEach(albums, id: \.id) { album in
                NavigationLink(
                    destination: AlbumDetailView(album: album),
                    tag: album.id,
                    selection: $selectedAlbumID
                ) {
                    albumRow(album)
                }
            }
        }
    }

    // ✅ 노래 리스트 UI 분리
    private func trackSection(_ tracks: [MusicTrack]) -> some View {
        Section(header: Text("노래")) {
            ForEach(tracks, id: \.id) { track in
                NavigationLink(
                    destination: TrackDetailView(track: track),
                    tag: track.id,
                    selection: $selectedTrackID
                ) {
                    trackRow(track)
                }
            }
        }
    }

    // ✅ 앨범 UI 요소 분리
    private func albumRow(_ album: Album) -> some View {
        HStack {
            albumImage(url: album.firstImageURL)
            VStack(alignment: .leading) {
                Text(album.name)
                    .font(.headline)
                Text(album.artistNames)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { selectedAlbumID = album.id }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.blue)
            }
        }
    }

    // ✅ 노래 UI 요소 분리
    private func trackRow(_ track: MusicTrack) -> some View {
        HStack {
            albumImage(url: track.imageUrl)
            VStack(alignment: .leading) {
                Text(track.name)
                    .font(.headline)
                Text(track.artistName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: { selectedTrackID = track.id }) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(.green)
            }
        }
    }

    // ✅ 이미지 뷰 분리
    private func albumImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable()
        } placeholder: {
            Color.gray
        }
        .frame(width: 50, height: 50)
        .cornerRadius(8)
    }
}

#Preview {
    AlbumSearchView()
}

import SwiftUI

struct AlbumSearchView: View {
    @StateObject private var viewModel = AlbumSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack {
            TextField("앨범 검색", text: $searchText, onCommit: {
                viewModel.searchAlbums(query: searchText)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            List(viewModel.albums, id: \.id) { album in
                HStack {
                    AsyncImage(url: URL(string: album.images.first?.url ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)

                    VStack(alignment: .leading) {
                        Text(album.name)
                            .font(.headline)
                        Text(album.artists.map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
        }
        .navigationTitle("앨범 검색")
    }
}

#Preview {
    AlbumSearchView()
}

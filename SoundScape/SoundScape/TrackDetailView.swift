import SwiftUI

struct TrackDetailView: View {
    let track: MusicTrack

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: track.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 200, height: 200)
            .cornerRadius(12)

            Text(track.name)
                .font(.title)
                .bold()

            Text(track.artistName)
                .font(.headline)
                .foregroundColor(.gray)

            Text("앨범: \(track.albumName)")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("노래 정보")
    }
}

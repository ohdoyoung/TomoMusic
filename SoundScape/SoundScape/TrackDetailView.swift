import SwiftUI

struct TrackDetailView: View {
    let track: MusicTrack
    @State private var TrackName=""
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: track.imageUrl)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(12)
                    .shadow(radius:5)
            } placeholder: {
                Color.gray
            }
            .padding()
            
            
            Text(track.name)
                .font(.title2)
                .bold()
                .padding(.top,5)
            
            Text(track.artistName)
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("앨범: \(track.albumName)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            DiaryView(name: $TrackName)
                .onAppear {
                    TrackName = track.name // `album.name`을 `albumName`에 저장
                }
        }
        .padding()
        .navigationTitle("노래 정보")
    }
}

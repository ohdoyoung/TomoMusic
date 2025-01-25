//import CoreData
//import SwiftUI
//
//class AlbumDataManager: ObservableObject {
//  static let shared = AlbumDataManager()
//
//  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//  @Published var savedAlbums: [AlbumEntity] = []
//
//  // 앨범 저장 함수
//  func saveAlbum(id: String, name: String, artist: String, coverUrl: String) {
//    let newAlbum = AlbumEntity(context: context)
//    newAlbum.id = id
//    newAlbum.name = name
//    newAlbum.artist = artist
//    newAlbum.coverUrl = coverUrl
//
//    do {
//      try context.save()
//      print("Album saved!")
//    } catch {
//      print("Error saving album: \(error)")
//    }
//  }
//
//  // 저장된 앨범 가져오기 함수
//  func fetchSavedAlbums() {
//    let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
//    do {
//      let albums = try context.fetch(request)
//      self.savedAlbums = albums
//    } catch {
//      print("Error fetching albums: \(error)")
//    }
//  }
//}

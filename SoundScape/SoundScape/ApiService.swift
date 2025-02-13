import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    private static let backendURL = "http://192.168.219.94:8085/music-diary" // 백엔드 API URL
//      private static let backendURL = "https://slim-dari-ohdoyoung-2098d088.koyeb.app/music-diary" // 백엔드 API URL

    // 앨범 목록을 가져오는 함수
    func fetchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://192.168.219.94:8085/spotify/search?query=\(encodedQuery)") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
        
//        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/spotify/search?query=\(encodedQuery)") else {
//            DispatchQueue.main.async {
//                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
//            }
//            return
//        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse.albums.items))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // 앨범 상세 정보를 가져오는 함수
    static func fetchAlbumDetails(for albumId: String, completion: @escaping (AlbumDetails?) -> Void) {
        let url = URL(string: "http://192.168.219.94:8085/spotify/album/\(albumId)")!
//        let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/spotify/album/\(albumId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch album details: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for album details.")
                completion(nil)
                return
            }
            
            do {
                let albumDetails = try JSONDecoder().decode(AlbumDetails.self, from: data)
                completion(albumDetails)
            } catch {
                print("Error decoding album details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    // **새로운 함수**: 음악 아이디(trackId)로 앨범 정보 가져오기
    static func fetchAlbumDetailsById(for trackId: String, completion: @escaping (AlbumDetails?) -> Void) {
        let url = URL(string: "http://192.168.219.94:8085/spotify/track/\(trackId)")! // 음악 아이디로 요청 URL 변경
//          let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/spotify/track/\(trackId)")! // 음악 아이디로 요청 URL 변경

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch track details: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for track details.")
                completion(nil)
                return
            }
            
            do {
                let trackDetails = try JSONDecoder().decode(AlbumDetails.self, from: data) // 여기서 AlbumDetails 대신 TrackDetails 사용 가능
                completion(trackDetails)
            } catch {
                print("Error decoding track details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    // 음악 일기와 관련된 앨범 정보를 함께 가져오는 함수
    func fetchDiaryEntries(for userId: String, completion: @escaping (Result<[MusicDiaryEntry], Error>) -> Void) {
        guard let url = URL(string: "http://192.168.219.94:8085/api/entries?loginId=\(userId)") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
//        
//        guard let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/api/entries?loginId=\(userId)") else {
//            DispatchQueue.main.async {
//                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
//            }
//            return
//        }
//        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedEntries))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    // 여러 앨범 ID를 받아 앨범 정보를 한 번에 가져오는 함수
    func fetchAlbumsDetailsByIds(albumIds: [String], completion: @escaping (Result<[AlbumDetails], Error>) -> Void) {
        var albums: [AlbumDetails] = []
        let group = DispatchGroup() // 여러 비동기 요청을 동기처럼 처리할 수 있게 해줌
        
        for albumId in albumIds {
            group.enter() // 새로운 요청 시작
            
            // 앨범 상세 정보를 가져오는 API 호출
            APIService.fetchAlbumDetails(for: albumId) { albumDetails in
                if let albumDetails = albumDetails {
                    albums.append(albumDetails)
                }
                group.leave() // 요청이 끝났으니 그룹에서 빠져나옴
            }
        }
        
        // 모든 요청이 끝날 때까지 기다림
        group.notify(queue: .main) {
            completion(.success(albums))
        }
    }
    
    static func getTrackDetails(trackId: String, completion: @escaping (TrackInfo?, Error?) -> Void) {
            let urlString = backendURL + trackId
            guard let url = URL(string: urlString) else {
                completion(nil, NSError(domain: "Invalid URL", code: 400, userInfo: nil))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // 헤더 설정 (필요한 경우, Authorization 헤더 추가 가능)
            // request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let data = data else {
                    completion(nil, NSError(domain: "No data received", code: 500, userInfo: nil))
                    return
                }
                
                do {
                    // JSON 디코딩
                    let trackInfo = try JSONDecoder().decode(TrackInfo.self, from: data)
                    completion(trackInfo, nil)
                } catch let decodeError {
                    completion(nil, decodeError)
                }
            }
            
            task.resume()
        }
}

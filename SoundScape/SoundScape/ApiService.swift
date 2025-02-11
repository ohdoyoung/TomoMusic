import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    
    private static let backendURL = "http://localhost:8085/music-diary" // 백엔드 API URL (음악 일기 관련 엔드포인트)
    
    // 앨범 목록을 가져오는 함수
    func fetchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:8085/spotify/search?query=\(encodedQuery)") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
        
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
        let url = URL(string: "http://localhost:8085/spotify/album/\(albumId)")!
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
    
    //    // 음악 일기 저장 함수
    //    static func saveDiary(entry: MusicDiaryEntry, completion: @escaping (Bool) -> Void) {
    //        // UserInfo.shared.loginId가 옵셔널이 아니라면 그냥 사용
    //        let userId = UserInfo.shared.loginId
    //        print(userId)
    //        var entryWithUserId = entry
    //         entryWithUserId.userId = userId // userId 값을 직접 할당
    //         
    //         guard let url = URL(string: "\(backendURL)/create") else {
    //             completion(false)
    //             return
    //         }
    //         
    //         var request = URLRequest(url: url)
    //         request.httpMethod = "POST"
    //         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //         
    //         // MusicDiaryEntry 객체를 JSON으로 인코딩
    //         do {
    //             let jsonData = try JSONEncoder().encode(entryWithUserId)
    //             request.httpBody = jsonData
    //         } catch {
    //             print("JSON 인코딩 오류: \(error)")
    //             completion(false)
    //             return
    //         }
    //
    //         // 데이터 전송
    //         URLSession.shared.dataTask(with: request) { data, response, error in
    //             if let error = error {
    //                 print("데이터 전송 실패: \(error.localizedDescription)")
    //                 completion(false)
    //                 return
    //             }
    //             
    //             if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
    //                 print("일기 저장 성공")
    //                 completion(true)
    //             } else {
    //                 print("서버 응답 오류")
    //                 completion(false)
    //             }
    //         }.resume()
    //    }
    //    
    //    
    //    // 날짜별 음악 일기 조회
    //    static func fetchDiaryByDate(date: String, completion: @escaping ([MusicDiaryEntry]) -> Void) {
    //        guard let url = URL(string: "\(backendURL)/entries?date=\(date)") else { return }
    //        
    //        URLSession.shared.dataTask(with: url) { data, response, error in
    //            if let error = error {
    //                print("데이터 불러오기 실패: \(error.localizedDescription)")
    //                completion([])  // 에러 발생 시 빈 배열을 반환
    //                return
    //            }
    //            
    //            if let data = data {
    //                do {
    //                    let entries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
    //                    completion(entries)  // 디코딩 성공 시 일기 항목 배열을 반환
    //                } catch {
    //                    print("JSON 디코딩 오류: \(error)")
    //                    completion([])  // 디코딩 오류 발생 시 빈 배열을 반환
    //                }
    //            }
    //        }.resume()
//}
}

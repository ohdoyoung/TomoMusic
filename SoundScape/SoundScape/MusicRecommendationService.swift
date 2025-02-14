//
//  MusicRecommendationService.swift
//  SoundScape
//
//  Created by 오도영 on 2/14/25.
//

import Foundation

// 추천 음악 정보 모델
struct RecommendedTrack: Codable {
    let name: String
    let artist: String
    let album: String
    let imageUrl: String
}

class MusicRecommendationService {
    
    // 이모지에 맞는 음악 추천을 받아오는 함수
    func fetchRecommendations(emotions: [String], completion: @escaping ([RecommendedTrack]?) -> Void) {
        // 이모지를 백엔드에 전달하여 추천받은 음악 목록을 가져오는 URL
        guard let url = URL(string: "http://192.168.219.151:8085/spotify/recommend?emotions=\(emotions.joined(separator: ","))") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching recommendations: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recommendations = try decoder.decode([RecommendedTrack].self, from: data)
                DispatchQueue.main.async {
                    completion(recommendations)
                }
            } catch {
                print("Error decoding response: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

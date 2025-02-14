//
//  TrackRecommendation.swift
//  SoundScape
//
//  Created by 오도영 on 2/14/25.
//

//import Foundation
//
//// 서버에서 응답받을 TrackRecommendation 모델 구조체 정의
//struct RecommendedTrack: Identifiable, Codable {
//    let id: String?
//    let name: String
//    let album: Album
//    let artists: [Artist]
////    
////    enum CodingKeys: String, CodingKey {
////        case id
////        case name
////        case album
////        case artists
////
////    }
//}
//
//    
////struct RecommendationResponse: Codable {
////    let tracks: [RecommendedTrack]  // tracks는 배열로 디코딩
////}
//struct RecommendationResponse: Codable {
//    var tracks: Tracks
//    
//    struct Tracks: Codable {
//        var items: [Track]
//    }
//    
//    struct Track: Codable {
//        var name: String
//    }
//}

import Foundation

struct RecommendedTrack: Identifiable, Codable {
    let id: String
    let name: String
    let album: Album
    let artists: [Artist]
}


struct RecommendationResponse: Codable {
    var tracks: Tracks
    
    struct Tracks: Codable {
        var items: [RecommendedTrack]
    }
}

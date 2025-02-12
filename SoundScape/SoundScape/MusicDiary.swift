//
//  MusicDiary.swift
//  SoundScape
//
//  Created by 오도영 on 2/11/25.
//

import Foundation

struct MusicDiaryEntry: Codable,Identifiable {
    var id: Int
    var loginId: String  // 로그인한 사용자 ID
//    var name: String
    //    var date: String
    var content: String
    var emotions: [String]?
    var albumId: String?  // 앨범 아이디
    var trackId: String?  // 트랙 아이디
    var createdAt: String
    var updatedAt: String
    
}


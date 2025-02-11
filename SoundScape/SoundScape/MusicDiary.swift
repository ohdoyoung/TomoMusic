//
//  MusicDiary.swift
//  SoundScape
//
//  Created by 오도영 on 2/11/25.
//

import Foundation

struct MusicDiaryEntry: Codable,Identifiable {
    var id: UUID
    var userId: String  // 로그인한 사용자 ID
    var name: String
    var date: String
    var text: String
    var emotions: [String]
}


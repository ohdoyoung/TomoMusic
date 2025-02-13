//
//  MyInfo.swift
//  SoundScape
//
//  Created by 오도영 on 2/13/25.
//

import Foundation

struct MyInfo: Codable,Identifiable {
    var id: Int64? // 내부 PK
    var loginId: String // 로그인용 ID
    var password: String
    var nickname: String?
    var createdAt: String // 생성일시
    
    // 초기화
    
     enum CodingKeys: String, CodingKey {
         case id
         case loginId
         case password
         case nickname
         case createdAt
     }
}

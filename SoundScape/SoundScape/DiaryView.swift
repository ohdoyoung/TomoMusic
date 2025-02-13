import SwiftUI

struct DiaryView: View {
    //    @Binding var name: String?
    @State private var musicCalText = "" // 일기 내용
    @State private var selectedEmotions: Set<String> = ["🙂"] // 선택된 감정들 (기본적으로 🙂 선택)
    @State private var diaryBackground: Color = Color.blue.opacity(0.1) // 일기 배경 색상
    
    let maxVisibleRows = 5 // 최대 표시할 줄 수
    let emotions = ["🙂", "😊", "😎", "😢", "😜", "🥳", "🤩", "😇", "🤔", "🤯",
                    "😈", "😱", "😷", "😳", "🥺", "😴", "💪", "❤️", "🔥", "😂",
                    "😭", "🥶", "🤪", "😡", "💀"]
    @Binding var albumId: String?  // 앨범 ID
    @Binding var trackId: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 감정 선택 아이콘
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) { // 5개씩 가로 정렬
                        ForEach(emotions.prefix(maxVisibleRows * 5), id: \.self) { emotion in
                            EmotionButton(emotion: emotion, selectedEmotions: $selectedEmotions)
                        }
                    }
                    .padding()
                }
                .frame(height: CGFloat(maxVisibleRows) * 18) // 1줄당 18 높이 적용
                .clipped()
                
                // 일기 입력창
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(diaryBackground)
                        .frame(height: 250)
                        .shadow(radius: 10)
                    
                    VStack {
                        TextEditor(text: $musicCalText)
                            .padding()
                            .foregroundColor(.primary)
                            .background(Color.white)
                            .cornerRadius(12)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                }
                
                // 일기 저장 버튼
                Button(action: {
                    // 오늘 날짜
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let todayString = dateFormatter.string(from: Date()) // 오늘 날짜를 문자열로 변환
                    
                    // 로그인된 사용자 아이디를 이용하여 바로 전송
                    let userId = UserInfo.shared.loginId // String 타입으로 바로 사용
                    
                    let emotionsJson = Array(selectedEmotions) // 감정들을 JSON 형식으로 변환
                    saveDiary(userId: userId, content: musicCalText, emotions: emotionsJson, date: todayString, trackId: trackId, albumId: albumId)
                }) {
                    Text("Scape")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    // 감정 아이콘 버튼
    func EmotionButton(emotion: String, selectedEmotions: Binding<Set<String>>) -> some View {
        Button(action: {
            if selectedEmotions.wrappedValue.contains(emotion) {
                selectedEmotions.wrappedValue.remove(emotion) // 이미 선택된 감정은 제거
            } else {
                selectedEmotions.wrappedValue.insert(emotion) // 선택되지 않은 감정은 추가
            }
        }) {
            Text(emotion)
                .font(.title)
                .padding(8)
                .background(selectedEmotions.wrappedValue.contains(emotion) ? Color.accentColor : Color.gray.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.primary)
        }
    }
    
    func saveDiary(userId: String, content: String, emotions: [String], date: String, trackId: String?, albumId: String?) {
        let url = URL(string: "http://192.168.219.94:8085/api/saveDiary")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [
            "loginId": userId,
            "content": content,
            "emotions": emotions, // 감정 배열
            "createdAt": date,
            "updatedAt": date
        ]
        
        // 트랙 아이디 또는 앨범 아이디가 존재하면 추가
        if let trackId = trackId {
            requestBody["trackId"] = trackId
            print("트랙 아이디: \(trackId)") // 디버깅 로그 추가
        } else {
            print("트랙 아이디가 없음") // 디버깅 로그 추가
        }
        
        if let albumId = albumId {
            requestBody["albumId"] = albumId
            print("앨범 아이디: \(albumId)") // 디버깅 로그 추가
        } else {
            print("앨범 아이디가 없음") // 디버깅 로그 추가
        }
        
        var jsonData: Data? = nil
        do {
            jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("일기 저장 실패: \(error.localizedDescription)")
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("일기 저장 성공")
                } else {
                    if let data = data,
                       let responseString = String(data: data, encoding: .utf8) {
                        print("일기 저장 실패: \(httpResponse.statusCode), 응답: \(responseString)")
                    } else {
                        print("일기 저장 실패: 상태 코드 \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
}

import SwiftUI

struct DiaryView: View {
    @State private var musicCalText = "" // 일기 내용
    @State private var selectedEmotions: Set<String> = ["🙂"] // 선택된 감정들
    @State private var diaryBackground: Color = Color.blue.opacity(0.1) // 일기 배경 색상
    @ObservedObject private var keyboardResponder = KeyboardResponder() // ✅ 키보드 감지 객체 추가

    let maxVisibleRows = 5
    let emotions = ["🙂", "😊", "😎", "😢", "😜", "🥳", "🤩", "😇", "🤔", "🤯",
                    "😈", "😱", "😷", "😳", "🥺", "😴", "💪", "❤️", "🔥", "😂",
                    "😭", "🥶", "🤪", "😡", "💀"]
    @Binding var albumId: String?
    @Binding var trackId: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 감정 선택 아이콘
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                        ForEach(emotions.prefix(maxVisibleRows * 5), id: \.self) { emotion in
                            EmotionButton(emotion: emotion, selectedEmotions: $selectedEmotions)
                        }
                    }
                    .padding()
                }
                .frame(height: CGFloat(maxVisibleRows) * 18)
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
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let todayString = dateFormatter.string(from: Date())

                    let userId = UserInfo.shared.loginId
                    let emotionsJson = Array(selectedEmotions)
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
            .padding(.bottom, keyboardResponder.keyboardHeight) // ✅ 키보드 높이만큼 패딩 추가
        }
        .padding()
        .onTapGesture {
            hideKeyboard() // ✅ 빈 화면 탭하면 키보드 숨김
        }
    }

    // 감정 아이콘 버튼
    func EmotionButton(emotion: String, selectedEmotions: Binding<Set<String>>) -> some View {
        Button(action: {
            if selectedEmotions.wrappedValue.contains(emotion) {
                selectedEmotions.wrappedValue.remove(emotion)
            } else {
                selectedEmotions.wrappedValue.insert(emotion)
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
        let url = URL(string: "http://localhost:8085/api/saveDiary")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var requestBody: [String: Any] = [
            "loginId": userId,
            "content": content,
            "emotions": emotions,
            "createdAt": date,
            "updatedAt": date
        ]

        if let trackId = trackId {
            requestBody["trackId"] = trackId
        }
        if let albumId = albumId {
            requestBody["albumId"] = albumId
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("일기 저장 실패: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("일기 저장 성공")
            } else {
                print("일기 저장 실패")
            }
        }
        task.resume()
    }
}

/// ✅ 키보드 감지를 위한 `KeyboardResponder`

/// ✅ 키보드 숨기기 기능
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

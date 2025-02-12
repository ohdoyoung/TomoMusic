import SwiftUI
struct CalendarView: View {
    @State private var selectedDate = Date() // 사용자가 선택한 날짜
    @State private var diaryEntries: [MusicDiaryEntry] = [] // 서버에서 불러온 일기 데이터
    let userId = UserInfo.shared.loginId // 로그인된 사용자 ID
    
    var body: some View {
        VStack {
            // 날짜 선택 캘린더
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            // 선택한 날짜의 일기 리스트
            List {
                let filteredEntries = diaryEntries.filter {
                    if let createdDate = stringToDate($0.createdAt) {
                        return formattedDate(selectedDate) == formattedDate(createdDate)
                    }
                    return false
                }
                
                ForEach(filteredEntries, id: \.id) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.content) // 일기 내용
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                        HStack {
                            ForEach(entry.emotions ?? [], id: \.self) { emotion in
                                Text(emotion) // 감정 이모지 출력
                            }
                        }
                    }
                    .padding(5)
                }
            }
            .overlay(
                diaryEntries.isEmpty ? Text("작성된 음악 일기가 없습니다").foregroundColor(.gray) : nil
            )
        }
        .onAppear {
            fetchDiaryEntries()
        }
    }

    // 날짜 형식 변환 (yyyy-MM-dd)
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // 서버에서 응답받은 String 형식의 날짜를 Date로 변환
    private func stringToDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // 서버에서 오는 날짜 형식에 맞춰 수정
        return formatter.date(from: string)
    }

    // 서버에서 음악 일기 불러오기
    private func fetchDiaryEntries() {
        guard let url = URL(string: "http://localhost:8085/api/entries?loginId=\(userId)") else { return }
        
        print("유저아이디는 이거임 ㅋ: \(userId)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // 서버 응답 로그 출력
                logResponseData(data)
                
                // 데이터 파싱 및 업데이트
                parseDiaryEntries(data)
            }
        }.resume()
    }

    // 서버 응답 데이터 로그 출력
    private func logResponseData(_ data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📌 서버 응답 JSON: \(jsonString)")
        }
    }

    // 데이터 파싱 및 diaryEntries 업데이트
    private func parseDiaryEntries(_ data: Data) {
        do {
            let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
            DispatchQueue.main.async {
                diaryEntries = decodedEntries
            }
        } catch {
            print("디코딩 오류: \(error)")
        }
    }

}

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
                let filteredEntries = diaryEntries.filter { $0.createdAt == formattedDate(selectedDate) }
                
                ForEach(filteredEntries, id: \.id) { entry in
                    VStack(alignment: .leading) {
                        Text(entry.name) // 앨범/트랙 이름
                            .font(.headline)
                        Text(entry.text) // 일기 내용
                            .font(.body)
                            .foregroundColor(.gray)
                        HStack {
                            ForEach(entry.emotions, id: \.self) { emotion in
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

    // 서버에서 음악 일기 불러오기
    private func fetchDiaryEntries() {
        guard let url = URL(string: "http://localhost:8085/api/entries?userId=\(userId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedEntries = try JSONDecoder().decode([MusicDiaryEntry].self, from: data)
                    DispatchQueue.main.async {
                        diaryEntries = decodedEntries
                    }
                } catch {
                    print("디코딩 오류: \(error)")
                }
            }
        }.resume()
    }
}

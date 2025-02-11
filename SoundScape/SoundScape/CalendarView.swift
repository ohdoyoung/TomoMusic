import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date  // 부모 뷰에서 전달받은 날짜
    @State private var diaryEntries: [MusicDiaryEntry] = []  // @State로 관리

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        VStack {
            DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

//            Button("불러오기") {
//                let dateString = dateFormatter.string(from: selectedDate)
//                // API 호출하여 일기 항목을 받아옵니다.
//                APIService.fetchDiaryByDate(date: dateString) { entries in
//                    DispatchQueue.main.async {
//                        self.diaryEntries = entries  // diaryEntries 상태를 수정
//                    }
//                }
//            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            List(diaryEntries) { entry in
                VStack(alignment: .leading) {
                    Text(entry.name)
                        .font(.headline)
                    Text("감정: \(entry.emotions.joined(separator: ", "))")
                }
                .padding()
            }
        }
        .navigationTitle("음악 달력")
    }
}

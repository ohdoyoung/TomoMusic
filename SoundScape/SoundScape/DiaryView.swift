import SwiftUI

struct DiaryView: View {
    @State private var musicCalText = "" // 일기 내용
    @State private var selectedEmotions: Set<String> = [] // 선택된 감정들 (기본적으로 🙂 선택)
    @State private var diaryBackground: Color = Color.blue.opacity(0.1) // 일기 배경 색상
    @State private var keyboardVisible = false // 키보드 상태 감지
    
    let maxVisibleRows = 5 // 최대 표시할 줄 수
    let emotions = ["🙂", "😊", "😎", "😢", "😜", "🥳", "🤩", "😇", "🤔", "🤯",
                    "😈", "😱", "😷", "😳", "🥺", "😴", "💪", "❤️", "🔥", "😂",
                    "😭", "🥶", "🤪", "😡", "💀"]
    @Binding var albumId: String?  // 앨범 ID
    @Binding var trackId: String?
    
    @FocusState private var isTextEditorFocused: Bool // TextEditor 포커스 상태

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
                            .focused($isTextEditorFocused) // 포커스 적용
                    }
                    .padding(.horizontal)
                }
                
                // 일기 저장 버튼
                Button(action: {
                    saveDiary()
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
            .padding()
            .padding(.bottom, keyboardVisible ? 200 : 0) // 키보드가 올라오면 아래 여백 추가
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            addKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    // 키보드 상태 감지
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            keyboardVisible = true
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardVisible = false
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func hideKeyboard() {
        isTextEditorFocused = false
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
    
    private func saveDiary() {
        print("일기 저장 로직 실행")
    }
}

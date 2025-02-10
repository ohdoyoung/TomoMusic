import SwiftUI

struct LoginView: View {
    
    @State private var loginId: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                // 로그인 아이디 입력 필드
                TextField("Login ID", text: $loginId)
                    .padding()
                //                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .font(.body)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // 비밀번호 필드
                SecureField("Password", text: $password)
                    .padding()
                //                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                // 에러 메시지 표시
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // 로그인 버튼
                Button("Login") {
                    login()
                }
                .padding()
                .frame(maxWidth: .infinity) // 버튼 크기를 화면에 맞게
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // 회원가입 버튼 (로그인 버튼과 동일한 디자인)
                NavigationLink(destination: SignupView()) {
                    Text("Sign Up")
                        .padding()
                        .frame(maxWidth: .infinity)  // 버튼 크기를 화면에 맞게
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 8)  // 버튼 간격 조정
                }
                Spacer()
            }
            .padding()
            .navigationTitle("로그인")
        }
    }
    
    func login() {
        // 로그인 요청 보내기
        let url = URL(string: "http://localhost:8085/api/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "loginId=\(loginId)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "로그인 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let data = data, let response = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                DispatchQueue.main.async {
                    if response.success {
                        // 로그인 성공 처리
                    } else {
                        errorMessage = "로그인 실패: \(response.message)"
                    }
                }
            }
        }
        
        task.resume()
    }
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

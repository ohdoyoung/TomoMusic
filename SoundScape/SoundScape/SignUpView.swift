import SwiftUI

struct SignupView: View {
    
    @State private var loginId: String = ""
    @State private var password: String = ""
    @State private var nickname: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isSignupSuccessful = false // 성공 여부 상태
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 로그인 ID 필드
                TextField("Login ID", text: $loginId)
                    .padding()
                    .keyboardType(.emailAddress)
                    .font(.body)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // 비밀번호 필드
                SecureField("Password", text: $password)
                    .padding()
                    .font(.body)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // 닉네임 필드
                TextField("Nickname", text: $nickname)
                    .padding()
                    .font(.body)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // 오류 메시지
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // 성공 메시지
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                // 가입 버튼
                Button(action: {
                    signup()
                }) {
                    Text("Sign Up")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("회원가입")
            .navigationDestination(isPresented: $isSignupSuccessful) {
                LoginView()
            }
        }
    }
    
    func signup() {
        // 회원가입 요청 보내기
        let url = URL(string: "http://192.168.219.94:8085/api/signup")!
//        let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/api/signup")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // 요청 본문에 데이터 추가 (아이디, 비밀번호, 닉네임)
        let body = "loginId=\(loginId)&password=\(password)&nickname=\(nickname)"
        request.httpBody = body.data(using: .utf8)
        
        // Content-Type 헤더 추가 (POST 요청의 경우)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "회원가입 실패: \(error.localizedDescription)"
                    print("회원가입 실패: \(error.localizedDescription)")  // 디버깅 로그
                }
                return
            }
            
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Received data: \(responseString ?? "No data")")
                self.isSignupSuccessful = true
            }
        }
        
        task.resume()
    }
}

struct SignupResponse: Codable {
    let success: Bool
    let message: String
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}

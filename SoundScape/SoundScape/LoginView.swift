import SwiftUI

struct LoginView: View {
    @State private var loginId: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var userInfo: UserInfo  // UserInfo를 환경 객체로 전달받음
    
    var body: some View {
        NavigationView{
            VStack {
                // 로그인 아이디 입력 필드
                if userInfo.isLoggedIn {
                    
                    TabbarView()
                }else{
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
                    
                    // 로그인 성공 후 HomeView로 이동하는 NavigationLink
                        .padding()
                }
                
            }
        }
    }
    
    func login() {
        // 로그인 요청 보내기
//        let url = URL(string: "http://192.168.219.94:8085/api/login")!
          let url = URL(string: "https://slim-dari-ohdoyoung-2098d088.koyeb.app/api/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "loginId=\(loginId)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(data)
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "로그인 실패: \(error.localizedDescription)"
                }
                return
            }
            
            else{// 로그인 성공 시
                DispatchQueue.main.async {
                    print("로그인 했다리 ㅋㅋ")
                    UserInfo.shared.loginId = self.loginId
                    userInfo.isLoggedIn = true
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


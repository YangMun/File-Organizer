import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    let emailAddress = "yang486741@gmail.com"
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("정보")) {
                        NavigationLink(destination: AppInfoView()) {
                            Label("앱 정보", systemImage: "info.circle")
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            Label("이용 약관", systemImage: "doc.text")
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Link(destination: URL(string: "mailto:\(emailAddress)")!) {
                            Label("광고 문의", systemImage: "envelope")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            .navigationTitle("설정")
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

// 앱 정보 뷰
struct AppInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 25) {
            Image("AppIcon") // Assets에 있는 앱 아이콘 이미지
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .padding(.top, 20)
            
            Text("File Organizer")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            VStack(spacing: 10) {
                Text("버전 1.0.0")
                    .foregroundColor(.secondary)
                
                Text("사용자가 추가한 파일을\n체계적으로 정리해주는 앱")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text("개발자: 양문경")
                    .foregroundColor(.secondary)
                
                Text("© 2025 File Organizer. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("앱 정보")
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

// 광고 문의 뷰
struct AdInquiryView: View {
    let emailAddress = "yang486741@gmail.com"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("광고 문의")
                .font(.title)
                .fontWeight(.bold)
            
            Link("이메일: \(emailAddress)",
                 destination: URL(string: "mailto:\(emailAddress)")!)
                .foregroundColor(.blue)
                .padding()
            
            Text("광고 문의는 위 이메일로 연락주시기 바랍니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle("광고 문의")
    }
}

// 이용 약관 뷰 추가
struct TermsOfServiceView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("이용 약관")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, 10)
                    
                    Text("1. 서비스 이용 약관")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("File Organizer는 사용자가 추가한 파일을 정리하는 서비스를 제공합니다. 본 서비스를 이용함으로써 사용자는 다음 약관에 동의하게 됩니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text("2. 개인정보 처리")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("본 앱은 사용자의 파일을 로컬 디바이스에서만 처리하며, 외부 서버로 전송하지 않습니다. 모든 파일 처리는 사용자의 기기 내에서만 이루어집니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text("3. 서비스 이용 제한")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("이 앱은 업로드 한 파일의 정리를 도와주는 앱이며, 파일을 수정, 삭제, 목적이 아닙니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                }
                
                Group {
                    Text("4. 책임 제한")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("File Organizer는 사용자가 추가한 파일의 손실이나 손상에 대해 책임지지 않습니다. 중요한 파일은 반드시 백업해두시기 바랍니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text("5. 저작권")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("본 앱의 모든 콘텐츠와 기능에 대한 저작권은 File Organizer에 있습니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}


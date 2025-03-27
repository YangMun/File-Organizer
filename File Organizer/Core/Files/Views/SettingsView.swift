import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false  // 언어 설정을 위한 상태 추가
    let emailAddress = "yang486741@gmail.com"
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text(isEnglish ? "Settings" : "정보")) {
                        NavigationLink(destination: AppInfoView()) {
                            Label(isEnglish ? "App Info" : "앱 정보", 
                                  systemImage: "info.circle")
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            Label(isEnglish ? "Terms of Service" : "이용 약관", 
                                  systemImage: "doc.text")
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Link(destination: URL(string: "mailto:\(emailAddress)")!) {
                            Label(isEnglish ? "Ad Inquiry" : "광고 문의", 
                                  systemImage: "envelope")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                    
                    // 언어 설정 섹션 수정
                    Section(header: Text(isEnglish ? "Language" : "언어 / Language")) {
                        Toggle(isOn: $isEnglish) {
                            Label {
                                Text("English / 영어")
                            } icon: {
                                Image(systemName: "globe")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEnglish ? "Settings" : "설정")
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

// 앱 정보 뷰
struct AppInfoView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(spacing: 10) {
                Text(isEnglish ? "Version 1.0.0" : "버전 1.0.0")
                    .foregroundColor(.secondary)
                
                Text(isEnglish ? 
                     "An app that systematically organizes\nfiles added by users" :
                     "사용자가 추가한 파일을\n체계적으로 정리해주는 앱")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Link(isEnglish ? "Provided: Icons by Icons8" : "제공: Icons by Icons8", 
                     destination: URL(string: "https://icons8.kr/")!)
                    .font(Font.custom("KCC-Hanbit", size: 15, relativeTo: .body))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Text(isEnglish ? "Developer: Mun Kyoung Yang" : "개발자: 양문경")
                    .foregroundColor(.secondary)
                
                Text("© 2025 File Organizer. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 30)
        }
        .navigationTitle(isEnglish ? "App Info" : "앱 정보")
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}

// 광고 문의 뷰
struct AdInquiryView: View {
    @AppStorage("isEnglish") private var isEnglish = false
    let emailAddress = "yang486741@gmail.com"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isEnglish ? "Ad Inquiry" : "광고 문의")
                .font(.title)
                .fontWeight(.bold)
            
            Link("Email: \(emailAddress)",
                 destination: URL(string: "mailto:\(emailAddress)")!)
                .foregroundColor(.blue)
                .padding()
            
            Text(isEnglish ? 
                 "Please contact us via email above for advertising inquiries." :
                 "광고 문의는 위 이메일로 연락주시기 바랍니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle(isEnglish ? "Ad Inquiry" : "광고 문의")
    }
}

// 이용 약관 뷰 추가
struct TermsOfServiceView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isEnglish") private var isEnglish = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text(isEnglish ? "Terms of Service" : "이용 약관")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.bottom, 10)
                    
                    Text(isEnglish ? "1. Terms of Service Usage" : "1. 서비스 이용 약관")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(isEnglish ? 
                         "File Organizer provides a service to organize files added by users. By using this service, users agree to the following terms." :
                         "File Organizer는 사용자가 추가한 파일을 정리하는 서비스를 제공합니다. 본 서비스를 이용함으로써 사용자는 다음 약관에 동의하게 됩니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text(isEnglish ? "2. Privacy Policy" : "2. 개인정보 처리")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(isEnglish ? 
                         "This app processes user files only on the local device and does not transmit them to external servers. All file processing takes place only within the user's device." :
                         "본 앱은 사용자의 파일을 로컬 디바이스에서만 처리하며, 외부 서버로 전송하지 않습니다. 모든 파일 처리는 사용자의 기기 내에서만 이루어집니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text(isEnglish ? "3. Service Limitations" : "3. 서비스 이용 제한")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(isEnglish ? 
                         "This app is designed to help organize uploaded files and is not intended for file modification or deletion purposes." :
                         "이 앱은 업로드 한 파일의 정리를 도와주는 앱이며, 파일을 수정, 삭제, 목적이 아닙니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                }
                
                Group {
                    Text(isEnglish ? "4. Limitation of Liability" : "4. 책임 제한")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(isEnglish ? 
                         "File Organizer is not responsible for any loss or damage to files added by users. Please make sure to backup important files." :
                         "File Organizer는 사용자가 추가한 파일의 손실이나 손상에 대해 책임지지 않습니다. 중요한 파일은 반드시 백업해두시기 바랍니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                    
                    Text(isEnglish ? "5. Copyright" : "5. 저작권")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text(isEnglish ? 
                         "All content and features of this app are copyrighted by File Organizer." :
                         "본 앱의 모든 콘텐츠와 기능에 대한 저작권은 File Organizer에 있습니다.")
                        .foregroundColor(colorScheme == .dark ? .gray : .black.opacity(0.7))
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
    }
}


//
//  SettingsView.swift
//  File Organizer
//
//  Created by 양문경 on 3/21/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("설정")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            List {
                Section(header: Text("일반")) {
                    Toggle(isOn: .constant(true)) {
                        Label("자동 정리", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    NavigationLink(destination: EmptyView()) {
                        Label("저장 위치", systemImage: "folder")
                    }
                }
                
                Section(header: Text("정보")) {
                    NavigationLink(destination: EmptyView()) {
                        Label("앱 정보", systemImage: "info.circle")
                    }
                }
            }
        }
    }
}


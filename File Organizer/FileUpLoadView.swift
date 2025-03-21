//
//  FileUpLoadView.swift
//  File Organizer
//
//  Created by 양문경 on 3/21/25.
//

import SwiftUI

struct FileUpLoadView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            
            Text("파일 업로드")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("기기에서 파일을 선택하거나\n이 영역에 파일을 끌어다 놓으세요")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: {
                // 파일 선택 액션 구현 예정
            }) {
                Text("파일 선택하기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}


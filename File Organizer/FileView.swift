//
//  File.swift
//  File Organizer
//
//  Created by 양문경 on 3/21/25.
//

import SwiftUI

struct FileTypeItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

struct FileView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let fileTypes = [
        FileTypeItem(imageName: "PDF", title: "PDF 파일"),
        FileTypeItem(imageName: "Word", title: "워드 문서"),
        FileTypeItem(imageName: "HWP", title: "한글 문서"),
        FileTypeItem(imageName: "Excel", title: "엑셀 파일"),
        FileTypeItem(imageName: "PPT", title: "PPT 파일")
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(fileTypes) { item in
                    Button(action: {
                        // 각 파일 타입 선택 시 동작
                    }) {
                        VStack {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(.bottom, 8)
                            
                            Text(item.title)
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6))
        .navigationTitle("File Organizer")
        .navigationBarItems(trailing: 
            Button(action: {
                // 새로고침 동작
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.black)
            }
        )
    }
}

#Preview {
    NavigationView {
        FileView()
    }
}


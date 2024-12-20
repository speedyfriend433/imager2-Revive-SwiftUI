//
//  ImageButtonView.swift
//  imager2
//
//  Created by speedy on 2024/12/20.
//

import SwiftUI

struct ImageButtonView: View {
    let systemName: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .font(.largeTitle)
            Text(text)
                .font(.caption)
        }
        .frame(width: 100, height: 100)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

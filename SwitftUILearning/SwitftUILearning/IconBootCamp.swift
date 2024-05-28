//
//  IconBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 16/04/24.
//

import SwiftUI

struct IconBootCamp: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .font(.system(size:200))
            .foregroundColor(.blue)


    }
}

#Preview {
    IconBootCamp()
}

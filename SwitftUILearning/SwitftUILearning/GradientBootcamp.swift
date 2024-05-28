//
//  GradientBootcamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 16/04/24.
//

import SwiftUI

struct GradientBootcamp: View {
    var body: some View {
        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
            .fill(
                LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: .leading, endPoint: .trailing)
                )
               .frame(width:300, height: 300)
    }
}

#Preview {
    GradientBootcamp()
}

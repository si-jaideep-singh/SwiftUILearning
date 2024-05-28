//
//  ColorBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 16/04/24.
//

import SwiftUI

struct ColorBootCamp: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(Color(UIColor.green))
        
            .frame(width: 300,height: 300)
            .shadow(color:Color.gray,radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ColorBootCamp()
}

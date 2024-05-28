//
//  SafeAreaBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct SafeAreaBootCamp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
            .background(Color.red)
            .edgesIgnoringSafeArea(.bottom)
         
    }
}

#Preview {
    SafeAreaBootCamp()
}

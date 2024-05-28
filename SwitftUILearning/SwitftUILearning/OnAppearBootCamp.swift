//
//  OnAppearBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 24/04/24.
//

import SwiftUI

struct OnAppearBootCamp: View {
    @State var myText:String = "Start Text."
    var body: some View {
        NavigationView {
            ScrollView 
            {
                Text(myText)
            }
            .onAppear()
        }
    }
}

#Preview {
    OnAppearBootCamp()
}

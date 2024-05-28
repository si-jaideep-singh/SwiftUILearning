//
//  NavigationLink.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 22/04/24.
//

import SwiftUI

struct NavigationLink: View {
    var body: some View {
        NavigationView{
            ScrollView{
                
             //   NavigationLink("Hello World", destination: MytherScreen())
                Text("Hello ,World")
                Text("Hello ,World")
                Text("Hello ,World")
                
            }
            .navigationTitle("All Inboxes")
            .navigationBarTitleDisplayMode(.large)
          //  .navigationBarBackButtonHidden()
        }
    }
}

struct MytherScreen : View {
    var body: some View {
        ZStack{
            Color.green.edgesIgnoringSafeArea(.all)
                .navigationTitle("Green Screen!")
         //   NavigationLink("Click here", destination: Text("3rd Screen"))
        }
    }
}

#Preview {
    NavigationLink()
}

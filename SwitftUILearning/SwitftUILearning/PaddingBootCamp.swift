//
//  PaddingBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct PaddingBootCamp: View {
    var body: some View {
        VStack(alignment:.leading) {
            Text("Hello This is Jaideeep")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.all,10)
                
            Text("sdfdsfdfljklnglnglsjkfgnsjnsfgjknsfgnsfgjsnfgjfngfjnfjnfjvnfjvnfsjfjffnfnjfsnfjnv")
            
            
            
            
            
            //        Text("Hello I am Jaideep")
            //            .background(Color.blue)
            //            .frame(width: 100,height: 100)
            //            .padding(.all,10)
            //            . padding(.bottom, 10)
            //            .background(Color.yellow)
            
        }
        
        .padding()
//        .padding(.vertical,20)
//        .padding(.horizontal,20)
        .background(Color.white.shadow(color:.black.opacity(0.3),radius: 5, x: 0.0, y: 0.0))
        .padding(.horizontal,10)
    }
}

#Preview {
    PaddingBootCamp()
}

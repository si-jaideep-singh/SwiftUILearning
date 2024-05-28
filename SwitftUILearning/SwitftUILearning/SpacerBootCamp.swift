//
//  SpacerBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct SpacerBootCamp: View {
    var body: some View {
        //        HStack(spacing:nil){
        //            Rectangle()
        //                .frame(width: 100,height: 100)
        //            Spacer()
        //                .frame(height: 10)
        //                .background(Color.green)
        //
        //            Rectangle()
        //                .fill(Color.red)
        //                .frame(width: 100,height: 100)
        //        }
        //        .background(Color.blue)
        
        VStack {
            HStack(spacing:0) {
                Image(systemName: "xmark")
                
                Spacer()
                //                    .frame(height:10)
                //                    .background(Color.red)
                
                Image(systemName: "gear")
                
            }
            //.padding(.top,10)
            .font(.title)
            .background(Color.yellow)
            // .padding(.horizontal)
            .background(Color.blue)
             Spacer()
                
            Rectangle()
                .frame(height: 55)
        }
      
        
        
    }
    
    
}

#Preview {
    SpacerBootCamp()
}

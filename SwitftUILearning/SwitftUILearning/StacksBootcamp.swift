//
//  StacksBootcamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 17/04/24.
//

import SwiftUI

struct StacksBootcamp: View {
    var body: some View {
        
        
        ZStack{
            Rectangle()
                .fill(Color.yellow)
                .frame(width: 350,height: 500,alignment: .center)
            
            
            VStack{
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 150,height: 150)
                Rectangle()
                    .fill(Color.green)
                    .frame(width:130 ,height: 130)
                Rectangle()
                    .fill(Color.orange)
                    .frame(width:100 ,height: 100)
                
            }
        }
        
        
        
        
//        ZStack(alignment: .topTrailing, /*spacing: nil */ content: {
//            Rectangle()
//                .fill(Color.red)
//                .frame(width: 150,height: 150)
//            Rectangle()
//                .fill(Color.green)
//                .frame(width:130 ,height: 130)
//            Rectangle()
//                .fill(Color.orange)
//                .frame(width:100 ,height: 100)
//            
//        })
        
//        VStack {
//            Rectangle()
//                .fill(Color.red)
//                .frame(width: 100,height: 100)
//            Rectangle()
//                .fill(Color.green)
//                .frame(width:100 ,height: 100)
//            
//            Rectangle()
//                .fill(Color.orange)
//                .frame(width:100 ,height: 100)
//        }
      
   }
}

#Preview {
    StacksBootcamp()
}

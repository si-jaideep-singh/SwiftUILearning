//
//  GridBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct GridBootCamp: View {
    
    let columns : [GridItem] = [
        GridItem(.adaptive(minimum: 50, maximum: 100), spacing: nil, alignment: nil),
        
        
        //        GridItem(.fixed(50), spacing: nil, alignment: nil),
        //        GridItem(.fixed(50), spacing: nil, alignment: nil),
        //        GridItem(.fixed(50), spacing: nil, alignment: nil),
        //        GridItem(.fixed(50), spacing: nil, alignment: nil),
        //        GridItem(.fixed(50), spacing: nil, alignment: nil),
        
        
    ]
    
    var body: some View {
        ScrollView {
            Rectangle()
                .fill(Color.white)
                .frame(height:400)
            LazyVGrid(columns:columns) {
                ForEach(0..<50) {
                    index in Rectangle()
                        .frame(height:150)
                }
            }
            
        }
    }
}

#Preview {
    GridBootCamp()
}

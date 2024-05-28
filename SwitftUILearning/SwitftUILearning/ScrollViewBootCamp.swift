//
//  ScrollViewBootCamp.swift
//  SwitftUILearning
//
//  Created by Jaideep Singh on 18/04/24.
//

import SwiftUI

struct ScrollViewBootCamp: View {
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.center){
                ForEach(0..<50) {
                    index in
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        LazyHStack{
                            ForEach(0..<20){
                                index in
                                RoundedRectangle(cornerRadius: 25.0)
                                
                                    .fill(Color.white)
                                    .frame(width:200,height: 200)
                                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                    .padding()
                            }
                           
                        }
                    })
                    
                }
            }
            
        }
        
    }
}
            
            
            
            #Preview {
                ScrollViewBootCamp()
            }

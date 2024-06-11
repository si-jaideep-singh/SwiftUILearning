//
//  VideoesView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//

import SwiftUI

struct VideoesView: View {
    var body: some View {
          
        VStack(spacing : 0){
            HStack{
                Text("Videos")
                    .padding()
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(AppImagesName.view_all.name)
                })
                .padding(10)
             
            }
            
            VideoslargeView()
            
            VideosSmallView()
            
        }
        
    
    }
}

#Preview {
    VideoesView()
}

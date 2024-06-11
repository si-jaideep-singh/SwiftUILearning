//
//  ShowcaseCard.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 03/06/24.
//

import SwiftUI

struct ShowcaseCard: View {
    var landmark : Landmark
    
    var body: some View {
        Image(landmark.imageName)
            .resizable()
            .aspectRatio(3/2,contentMode: .fit)
            .overlay {
               TextOverlay(landmark: landmark)
            }
           
    }
}

struct TextOverlay: View {
    
    var landmark : Landmark
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            gradient
            VStack(alignment: .leading) {
                Text("News")
//                    .font(.custom(CustomFont.rubikLight.name,size: 10))
                   .foregroundColor(.yellow)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                
                
                    .background {
                        Color.black
                        
                    }
                    .cornerRadius(15)
                   
                
                
                HStack {
                    Text(landmark.title)
//                        .font(.custom(CustomFonts.RubikLight.name, size: 30))
                    
                    Text(landmark.subtitle)
                        .font(.title)
                        .bold()
                }
                HStack {
                    Text("21 May,2024")
                    
                        .font(.subheadline)
                    Spacer()
                    Button(action: {}
                    ){
                        Image(systemName: "star.fill")
                        
                    }
                    
                    
                    Rectangle()
                        .frame(width: 2,height: 20)
                    Button(action: {}
                    ){
                        Image(systemName: "star.fill")
                        
                    }
               
                    
                }
                .padding(.leading,15)
                .padding(.bottom,15)
                .padding(.trailing,15)
                
                
            }
            .padding(.leading,15)
        }
        .foregroundColor(.white)
    }
}

#Preview {
    ShowcaseCard(landmark:landmarks[0])
}


//
//  VideosSmallView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//

import SwiftUI

struct VideosSmallView: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) { // Add a spacing between items
                ForEach(0..<10) { _ in
                    staticview
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 300)     }
}
var staticview :some View{
        ZStack(alignment: .leading) {
          VStack(alignment: .leading){
                ZStack(alignment: .bottomLeading){
                    
                    Image("virat")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 155, height: 155)
                        .cornerRadius(10)
                    
                    Image(AppImagesName.play_icon.name)
                        .padding(.bottom,60)
                        .padding(.leading,60)
                    
                    Text("Knights TV")
                        .foregroundColor(.yellow)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color(AppColorName.black_000000.name))
                        .cornerRadius(15)
                        .padding(.leading,15)
                        .padding(.bottom,15)
                        .font(.custom(CustomFonts.RubikLight.name, size: 10))
                       
                    
                }
                
                Text("KKR KKR KKR KKR KKR KKR")
                    .foregroundColor(Color(AppColorName.purple_3A225D.name))
                    .font(.custom(CustomFonts.RubikLight.name, size: 12))
                
                
                //            var titleAlias = newsDetailItem?.assetTitle
                //              print(titleAlias)
                //   Text(newsDetailItem?.assetTitle ?? "" )
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 5)
                
                
                HStack {
                    
                    Text("21 May, 2024")
                        .foregroundColor(Color(AppColorName.black_2A2A2A .name))
                        .font(.custom(CustomFonts.RubikLight.name, size: 10))
                    
                    Spacer()
                    
                    
                    Button(action: {
                        
                        print("First button tapped")
                    }) {
                        Image(AppImagesName.yellow_likebtn.rawValue)
                          
                    }
                    
                    
                    Rectangle()
                        .frame(width: 2, height: 20)
                        .foregroundColor(.gray)
                    
                    
                    Button(action: {
                        
                        print("Second button tapped")
                    }) {
                        Image(AppImagesName.btn_share.name)
                        
                    }
                }
                .padding(.top, 5)
            }
        }
        .frame(width: 155, height: 300)
        .padding()
    }


#Preview {
    VideosSmallView()
}

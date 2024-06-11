//
//  NewsItem.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 03/06/24.
//

import SwiftUI
struct NewsItem: View {
    
    
    var body: some View {
   
        VStack(alignment: .leading) {
           
            Image("virat")
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(10)
            
           
            Text("News")
                .foregroundColor(.yellow)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.gray)
                .cornerRadius(15)
            
           
            
            Text("KKR KKR KKR KKR KKR KKR")
            
//            var titleAlias = newsDetailItem?.assetTitle
//              print(titleAlias)
         //   Text(newsDetailItem?.assetTitle ?? "" )
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
            
         
            HStack {
               
                Text("21 May, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
               
                Button(action: {
                    
                    print("First button tapped")
                }) {
                    Image("like")
                        .foregroundColor(.yellow)
                }
                
                
                Rectangle()
                    .frame(width: 2, height: 20)
                    .foregroundColor(.gray)
                
               
                Button(action: {
                   
                    print("Second button tapped")
                }) {
                    Image("share")
                        .background(Color.black)
                        
                }
            }
            .padding(.top, 5)
        }
        .frame(width: 155, height: 300)
        .padding()
    }
}

#Preview {
    NewsItem()
}

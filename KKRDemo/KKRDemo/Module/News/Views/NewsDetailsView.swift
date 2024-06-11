//
//  NewsDetailsView.swift
//  SampleProjectSwiftUI
//
//  Created by Jaideep Singh on 07/06/24.
//

import SwiftUI

struct NewsDetailsView: View {
    var body: some View {
          ScrollView(.vertical) {
              VStack {
                  GeometryReader { geometry in
                      Image("virat")
                          .resizable()
                          .scaledToFill()
                          .frame(width: geometry.size.width, height: 375)
                          .clipped()
                          .ignoresSafeArea(.all)
                  }
                  .frame(height: 375)
                  
                  WebView(url: URL(string: "https://stg-kkr.sportz.io/corporate-governance?webview=true")!)
                      .frame(height: 500)
                  
                      .padding(.bottom,10)
                                      
                  RelatedNewsView()
                                                
              }
          }
      }
  }

struct RelatedNewsView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Related News")
                .padding(.leading,15)
                .font(.custom(CustomFonts.RubikBold.name, size: 25))
        
            ScrollView(.horizontal,showsIndicators: false){
                HStack {
                    ForEach(0..<10){
                        _ in NewsItem()
                    }
                }
            }
        
        }
    }
}
#Preview {
    NewsDetailsView()
}

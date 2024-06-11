//
//  NewsListingView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 04/06/24.
//

import SwiftUI

struct NewsListingView: View {
    var body: some View {
        ScrollView(.vertical){
            ForEach(0..<10) {
                _ in LisitngItem()
            }
            .padding(.vertical,10)
          
        }
      
    }
}



#Preview {
    NewsListingView()
}

//
//  PageView.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 03/06/24.
//

import SwiftUI

struct PageView<Page: View>: View {
    var pages: [Page]
    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageViewController(pages: pages, currentPage: $currentPage)
            PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                .frame(width: CGFloat(pages.count * 18))
                .padding(.trailing)
        }
        
        .aspectRatio(3/2, contentMode: .fit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(pages: [
            ShowcaseCard(landmark: landmarks[0]),
            ShowcaseCard(landmark: landmarks[1])
        ])
    }
}

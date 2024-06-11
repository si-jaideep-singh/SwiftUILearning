//
//  TabBar.swift
//  SampleProjectSwiftUI
//
//  Created by Jaideep Singh on 07/06/24.
//

import SwiftUI

struct TabBar: View {
    @State var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
              HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            NavigationView {
                Text("Bookmark Tab")
                    .font(.system(size: 30,weight: .bold,design: .rounded))
            }
            .tabItem {
                Image(systemName: "bookmark.circle.fill")
                Text("Bookmark")
            }
            .tag(1)
            
            NavigationView {
                Text("Video Tab")
                    .font(.system(size: 30,weight: .bold,design: .rounded))
            }
            .tabItem {
                Image(systemName: "video.circle.fill")
                Text("Video")
            }
            .tag(2)
            
            NavigationView {
                Text("More")
                    .font(.system(size: 30,weight: .bold,design: .rounded))
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("Profile")
            }
            .tag(3)
            
        }
        .accentColor(.red)
        .onAppear() {
            UITabBar.appearance().barTintColor = .white
        }
    }
       // .accentColor(.red)
//        .onAppear() {
//            UITabBar.appearance().barTintColor = .white
        }
    


#Preview {
    TabBar()
}

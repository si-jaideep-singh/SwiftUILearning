//
//  ContentView.swift
//  UIPractice
//
//  Created by Jaideep Singh on 09/05/24.
//



import SwiftUI

struct ContentView: View {
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
                Text("Profile Tab")
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
}

struct HomeView: View {
    var body: some View {
        List {
            Section(header: Text("Images")) {
                ScrollView(.horizontal, showsIndicators: false) {
                   LazyHStack(spacing: 20) {
                        ForEach(1...3, id: \.self) { index in
                            NavigationLink(destination:Image("virat")){
                                Image("virat")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .padding()
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
            }
            
            Section(header: Text("Videos")) {
                ForEach(4...6, id: \.self) { index in
                    NavigationLink(destination: Text("Item #\(index) Details")) {
                        Text("Item #\(index)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                }
            }
            
            Section(header: Text("News")) {
                ForEach(7...10, id: \.self) { index in
                    NavigationLink(destination: Text("Item #\(index) Details")) {
                        Text("Item #\(index)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("TabView Demo")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

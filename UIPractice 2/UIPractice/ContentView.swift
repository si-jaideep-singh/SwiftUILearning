//
//  ContentView.swift
//  UIPractice
//
//  Created by Jaideep Singh on 09/05/24.

       

import SwiftUI
import AVKit

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
                StandingView()
                Text("Bookmark Tab")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }
            .tabItem {
                Image(systemName: "bookmark.circle.fill")
                Text("Bookmark")
            }
            .tag(1)

            NavigationView {
                VideoListView()
                Text("Video Tab")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }
            .tabItem {
                Image(systemName: "video.circle.fill")
                Text("Video")
            }
            .tag(2)
            NavigationView {
                ProfileView()
                Text("Profile Tab")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
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
                            NavigationLink(destination: Image("virat")) {
                                Image("virat")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(10)
                                    .padding()
                            }
                        }
                    }
                }
            }

            Section(header: Text("Video")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(1...3, id: \.self) { index in
                            VideoListView()
                                .frame(width: 200, height: 200)
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }

            Section(header: Text("News")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(dummyNews, id: \.self) { newsItem in
                            NavigationLink(destination: NewsDetailView(news: newsItem)) {
                                NewsThumbnailView(news: newsItem)
                            }
                        }
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

struct NewsDetailView: View {
    var news: News
    var body: some View {
        Text(news.content)
            .padding()
            .navigationTitle(news.title)
    }
}

struct News: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var content: String
}

struct NewsThumbnailView: View {
    var news: News
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("virat")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .cornerRadius(8)
                .padding(.horizontal)
            Text(news.title)
            
                .font(.headline)
                .padding(.horizontal)
                .lineLimit(2)
            
        }
        .frame(width: 200)
    }
}

struct VideoListView: View {
    var body: some View {
        List {
            ForEach(videos, id: \.self) { video in
                NavigationLink(destination: VideoPlayerView(videourl: video.url)) {
                    Text(video.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
            }
        }
        .navigationTitle("Video List")
    }
}

struct VideoPlayerView: View {
    var videourl: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videourl))
            .ignoresSafeArea()
    }
}

struct Video: Hashable {
    var name: String
    var url: URL
}

let videos: [Video] = [
    Video(name: "Video 1", url: URL(string: "https://www.youtube.com/watch?v=jp2PbpzdZ9A")!)
    //  Video(name: "Video 2", url: URL(string: "https://www.youtube.com/watch?v=jp2PbpzdZ9A")!)
]

let dummyNews: [News] = [
    News(title: "Breaking News 1 Breaking News 1", content: "This is the content of breaking news 1."),
    News(title: "Sports Update", content: "Latest sports news and updates."),
    News(title: "Weather Report", content: "Forecast for the upcoming week."),
    
]



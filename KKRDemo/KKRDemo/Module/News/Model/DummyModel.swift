//
//  DummyModel.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 03/06/24.
//

import Foundation

struct Landmark:Identifiable {
    var id: Int
    var imageName: String
    var title: String
    var subtitle: String
}

let landmarks = [
    Landmark(id: 1, imageName: "virat", title: "Virat", subtitle: "Kohli"),
    Landmark(id: 2, imageName: "virat", title: "Sachin", subtitle: "Tendulkar")
    // Add more landmarks as needed
]

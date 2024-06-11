//
//  CustomFonts.swift
//  KKRDemo
//
//  Created by Jaideep Singh on 10/06/24.
//


import Foundation
import SwiftUI

enum CustomFonts: String, CaseIterable {
    case RubikBold = "Rubik-Bold"
    case RubikLight = "Rubik-Light"
    case RubikMedium = "Rubik-Medium"
    case RubikSemiBold = "Rubik-SemiBold"
    case RubikRegular = "Rubik-Regular"
    
    var name: String { self.rawValue }
}

enum CustomColor: String {
    
    case white_FAF6FF

    var name: String {self.rawValue}
}

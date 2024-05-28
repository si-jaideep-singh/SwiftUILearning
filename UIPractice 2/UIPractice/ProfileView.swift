//
//  ProfileView.swift
//  UIPractice
//
//  Created by Jaideep Singh on 13/05/24.
//

import SwiftUI
struct ProfileView: View {
  @State private var isEditing = false
  var body: some View {
    VStack {
      ProfileHeaderView()
        .padding()
      ProfileDetailsView(isEditing: $isEditing)
        .padding()
      Spacer()
    }
    .navigationBarTitle("Profile")
    .navigationBarItems(trailing:
      Button(action: {
        self.isEditing.toggle()
      }) {
        Text(isEditing ? "Done" : "Edit")
      }
    )
  }
}
struct ProfileHeaderView: View {
  var body: some View {
    Image("yuvi")
      .resizable()
      .frame(width: 120, height: 120)
      .padding()
      .foregroundColor(.blue)
  }
}
struct ProfileDetailsView: View {
  @Binding var isEditing: Bool
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Name: John Doe")
      Text("Email: john@example.com")
      Text("Age: 30")
      if isEditing {
        EditableProfileDetailsView()
      }
    }
  }
}
struct EditableProfileDetailsView: View {
  @State private var name = "John Doe"
  @State private var email = "john@example.com"
  @State private var age = "30"
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      TextField("Name", text: $name)
      TextField("Email", text: $email)
        .keyboardType(.emailAddress)
      TextField("Age", text: $age)
        .keyboardType(.numberPad)
    }
  }
}
#Preview {
  ProfileView()
}

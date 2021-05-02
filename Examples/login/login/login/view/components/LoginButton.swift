//
//  LoginButton.swift
//  Login
//
//  Created by Wellington Soares on 01/05/21.
//

import SwiftUI

struct LoginButton: View {
  let loginFormState: LoginFormState
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        if loginFormState == .submitting {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
        Text("LOGIN")
          .font(.headline)
          .foregroundColor(.white)
          .padding()

      }.frame(width: 220, height: 60)
        .background(Color.green)
        .cornerRadius(5.0)
        .padding()
    }.disabled(loginFormState == .submitting ? true : false)
  }
}

//
//  LoginTextField.swift
//  Login
//
//  Created by Wellington Soares on 01/05/21.
//

import SwiftUI


struct LoginInputField: View {
  let loginFormState: LoginFormState
  let isPassword: Bool
  let label: String
  let text: String
  let set: (String) -> ()
  let icon: Image

  init(label: String,
       loginFormState: LoginFormState,
       isPassword: Bool = false,
       icon: Image = Image(systemName: "person"),
       text: String,
       set: @escaping (String) -> ()
  ) {
    self.loginFormState = loginFormState
    self.isPassword = isPassword
    self.label = label
    self.text = text
    self.set = set
    self.icon = icon
  }


  var body: some View {
    HStack {
      icon
      if(isPassword) {
        SecureField(label, text: Binding(get: { text }, set: set))
      } else {
        TextField(label, text: Binding(get: { text }, set: set))
      }
    }.autocapitalization(.none)
      .disabled(loginFormState == .submitting ? true : false)
      .padding()
      .border(loginFormState == .retry ? Color.pink : Color.blue, width: 2)
      .background(Color(white: 0.9))
      .cornerRadius(5.0)
      .padding()
  }
}


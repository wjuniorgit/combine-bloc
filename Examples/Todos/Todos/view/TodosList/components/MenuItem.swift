//
//  MenuItem.swift
//  Todos
//
//  Created by Wellington Soares on 02/05/21.
//

import SwiftUI

struct MenuItem: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action, label: {
      HStack { Text(title)
        Image(systemName: isSelected ? "checkmark.circle" : "circle")
      }
    })
  }
}

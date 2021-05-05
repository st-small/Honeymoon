//
//  TitleModifier.swift
//  Honeymoon
//
//  Created by Stanly Shiyanovskiy on 26.04.2021.
//

import SwiftUI

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.pink)
    }
}

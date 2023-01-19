//
//  ActivityIndicatorView.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 25.10.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicatorView>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: .large)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicatorView>) {
        uiView.startAnimating()
    }
}

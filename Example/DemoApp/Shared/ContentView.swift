//
//  ContentView.swift
//  Shared
//
//  Created by Syed Saud Arif on 15/08/22.
//

import SwiftUI
import SSASwiftUIGifView

struct ContentView: View {
    var body: some View {
        if let u = Bundle.main.url(forResource: "1", withExtension: "gif") {
            SSASwiftUIGifView(source: u)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

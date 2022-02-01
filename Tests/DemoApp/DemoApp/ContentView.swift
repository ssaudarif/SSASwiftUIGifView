//
//  ContentView.swift
//  DemoApp
//
//  Created by Syed Saud Arif on 31/01/22.
//

import SwiftUI
import SSASwiftUIGifView

struct URLContainer : Identifiable {
    var id = UUID()
    let url:URL
}


struct ContentView: View {
    
    var gifs:[URLContainer]
    
    var body: some View {
        List() {
            ForEach(self.gifs)
                { gif in
                    RowView(url: gif.url)
            }
        }
    }
    
    init() {
        var urls = [URLContainer]()
        for _ in 1...20 {
        for index in 1...10 {
            if let u = Bundle.main.url(forResource: "\(index)", withExtension: "gif") {
                urls.append(URLContainer(url: u))
            }
        }
        }
        
        
        gifs = urls
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RowView:View {
    let url:URL
    
    var body: some View {
        return SSASwiftUIGifView(localFilePath: url, config:GifConfig.downsampleNoScaleConfig)
    }
    
}

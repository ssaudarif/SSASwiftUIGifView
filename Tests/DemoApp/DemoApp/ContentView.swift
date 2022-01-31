//
//  ContentView.swift
//  DemoApp
//
//  Created by Syed Saud Arif on 31/01/22.
//

import SwiftUI
import SSASwiftUIGifView

struct ContentView: View {
    
    var gifs:[URL]
    
    var body: some View {
        List() {
            ForEach(self.gifs, id: \.self)
                { gif in
                    RowView(url: gif)
            }
        }
    }
    
    init() {
        var urls = [URL]()
        for _ in 1...20 {
        for index in 1...10 {
            if let u = Bundle.main.url(forResource: "\(index)", withExtension: "gif") {
                urls.append(u)
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

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
    let url:URL?
    let data:Data?
    
    func getSource() -> GifWrapper {
        if let u = url {
            return u
        } else {
            return data
        }
    }
}


struct ContentView: View {
    
    var gifs:[URLContainer]
    
    var body: some View {
        List() {
            ForEach(self.gifs)
                { gif in
                    RowView(source: gif.getSource())
            }
        }
    }
    
    init() {
        var urls = [URLContainer]()
//        for _ in 1...20 {
        for index in 1...6 {
            if let u = Bundle.main.url(forResource: "\(index)", withExtension: "gif") {
                urls.append(URLContainer(url: u, data: nil))
                if let data = try? Data.init(contentsOf: u) {
                    urls.append(URLContainer(url: nil, data: data))
                }
            }
        }
//        }
        
        
        
        
        gifs = urls
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RowView:View {
    let source:GifWrapper
    
    var body: some View {
        return SSASwiftUIGifView(source: source)
    }
    
}

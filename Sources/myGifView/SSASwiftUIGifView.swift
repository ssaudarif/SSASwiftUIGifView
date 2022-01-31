
import SwiftUI




public struct SSASwiftUIGifView : View {
    
    @StateObject var animatingImg:AnimatingImage = AnimatingImage()
    private var config:GifConfig
    private let filePath:URL
    
    public var body: some View {
        if !animatingImg.isImageReadingStarted {
            animatingImg.setNewConfig(config)
            animatingImg.startReadingGif(filePath)
        }
        var i = animatingImg.image
        if i.size == CGSize.zero {
            i = animatingImg.getFirstFrame()
        }
        return makeImageViewAndAttachOverlay(i)
        
    }
    
    private func makeImageViewAndAttachOverlay(_ i : UIImage) -> some View {
        makeImageView(i)
            .background(
                GeometryReader { geometryProxy in
                    CaptureGeometry(geometryProxy)
                }
            )
    }
    
    private func CaptureGeometry(_ proxy:GeometryProxy) -> Color {
        if (animatingImg.imageReader?.config.frameSize == CGSize.zero) {
            var c = animatingImg.config
            c.frameSize = proxy.size
            animatingImg.setNewConfig(c)
//            print("proxySize : \(c.frameSize)")
        }
        return Color.clear
    }

        
    private func makeImageView(_ i : UIImage/*,_ geometry : GeometryProxy*/) -> some View {
        return Image.init(uiImage: i).resizable().aspectRatio(nil, contentMode: ContentMode.fit)
            .onDisappear {
                //print("Pausing")
                pause()
            }
            .onAppear {
                //print("Playing")
                play()
            }
    }
    
    
    func play() {
        //gifReader.play()
        animatingImg.play()
    }
    
    func pause() {
        animatingImg.pause()
    }

    public init(localFilePath: URL, config c: GifConfig = GifConfig.defaultConfig) {
        filePath = localFilePath
        config = c
//        animatingImg = AnimatingImage(initialImage: UIImage(named: placeHolderImageName, in: bundle, with: nil) ?? UIImage() )
    }
    
}


//extension Image {
//    func getFrameSize() -> CGSize {
//        self.fra
//    }
//}

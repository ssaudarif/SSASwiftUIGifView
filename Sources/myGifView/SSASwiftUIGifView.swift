
import SwiftUI



/// A Gif Renderer View that is made in SwiftUI
///
/// You can use this view like a `Image` view. Following is some ways to
/// Initiallize SSASwiftUIGifView.
///
/// If you have a local file. You can use filePath url to initialize.
///
///  ```
///     SSASwiftUIGifView(source: url)
///  ```
/// SSASwiftUIGifView currently does not support network URLs but,
/// It can be initiallized using file content's `Data`
///
/// ```
///     SSASwiftUIGifView(source: data)
/// ```
/// There are some configuration options that can be used to control memory
/// and cpu usage of SSASwiftUIGifView. See `GifConfig` class for more
/// Information.
/// The default Configuration applied is `GifConfig.defaultConfig`
///
/// The custom Config Can be provided during initiallization. For Example -
///
/// ```
///     SSASwiftUIGifView(source: data,
///                       config:GifConfig.downsampleConfig)
/// ```
///
///
public struct SSASwiftUIGifView : View {
    
    @StateObject var animatingImg:AnimatingImage = AnimatingImage()
    private var config:GifConfig
    private let gifSource:GifWrapper
    
    public var body: some View {
        if !animatingImg.isImageReadingStarted {
            animatingImg.setNewConfig(config)
            animatingImg.startReadingGif(gifSource)
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

    public init(source: GifWrapper, config c: GifConfig = GifConfig.defaultConfig) {
        gifSource = source
        config = c
//        animatingImg = AnimatingImage(initialImage: UIImage(named: placeHolderImageName, in: bundle, with: nil) ?? UIImage() )
    }
    
}


//extension Image {
//    func getFrameSize() -> CGSize {
//        self.fra
//    }
//}

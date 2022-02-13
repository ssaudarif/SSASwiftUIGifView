# SSASwiftUIGifView

A Gif Renderer View that is made in SwiftUI. 


<p align="center">
    </br>
    <img src="https://github.com/ssaudarif/SSASwiftUIGifView/blob/main/example.gif" align="center" />
</p>

## Features
- [x] SwiftUI based solution.
- [x] For mac and iOS Apps.
- [x] Easy usage.
- [x] Control playback.
- [x] Performance tuning using Configuration.


## Usage
You can use this view like a `Image` view. Following is some ways to
Initiallize SSASwiftUIGifView.

If you have a local file. You can use filePath url to initialize.

```swift
    SSASwiftUIGifView(source: url)
```

SSASwiftUIGifView currently does not support network URLs but,
It can be initiallized using file content's `Data`

```swift
    SSASwiftUIGifView(source: data)
```

There are some configuration options that can be used to control memory
and cpu usage of SSASwiftUIGifView. See `GifConfig` class for more
Information.
The default Configuration applied is `GifConfig.defaultConfig`

The custom Config Can be provided during initiallization. For Example -

```swift
    SSASwiftUIGifView(source: data,
                      config:GifConfig.downsampleConfig)
```

## TODOs [These functionalities needs to be added]
- [x] Add Image Options in SSASwiftUIGifView.
- [x] Add repeat count in config.
- [x] Delegate based events and error reporting.
- [x] Add cached images option in config.

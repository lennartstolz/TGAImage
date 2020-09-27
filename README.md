# TGAImage

Truevision TGA (**TARGA**) raster graphics support for Swift.

![Build](https://github.com/lennartstolz/TGAImage/workflows/Build/badge.svg)
[![codecov](https://codecov.io/gh/lennartstolz/TGAImage/branch/main/graph/badge.svg)](https://codecov.io/gh/lennartstolz/TGAImage)

## Requirements

- Swift 5.3

## About

This package provides a Swift interface for the Truevision TGA (**TARGA**) raster graphics file format.

## Usage

```swift
var image = TGAImage(width: 4, height: 1, color: .white)

// 🎨 Changing the color by pixel
image[0, 0] = .red
image[1, 0] = .green
image[2, 0] = .blue
image[3, 0] = TGAColor(r: 255, g: 165, b: 0)

// 💾 Writing the '.tga' data to disk
let data = image.tgaData()
data.write(to: url)
```

## Specification

This library follows the file format specification version [2.0](http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf) (January 1991).

### Supported Image Types

|  # | Description                                     | Support |
| --:| ------------------------------------------------| :-----: |
|  1 | Uncompressed, color-mapped images               |    ✖️    |
|  2 | Uncompressed, true-color images                 |    ✅    |
|  3 | Uncompressed, black and white (unmapped) images |    ✖️    |
|  9 | Run-length encoded, color-mapped images         |    ✖️    |
| 10 | Run-length encoded, true-color images           |    ✖️    |
| 11 | Run-length encoded, black and white images      |    ✖️    |

## License

TGAImage is MIT Licensed.

import Foundation

/// TGA FILE
///
/// [Specification](http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf)
///
/// This object takes care of providing the (raw) `Data` representation for a given `TGAImage` to be able to store the
/// image data as a "Targa Image File" (`.tga`) following the file specification (v2) from January 1991.
///
/// ## Implementation Details
///
/// This object only takes care of providing the minimal needed information for a valid `.tga` file. Relying on default
/// values wherever possible. Additionally, fields like the `ImageID` or the `Software ID` / `Software Name` aren't set.
struct TGAFile {

    /// The "TGA File Header" of the wrapped `TGAImage`.
    private let header: Header

    /// The "TGA Image Data" of the wrapped `TGAImage`.
    private let image: ImageData

    /// The "TGA File Footer" of the wrapped `TGAImage`.
    private let footer: Footer

    /// Creates a new "TGA File" wrapping the given image.
    ///
    /// - Parameters:
    ///     - image: The `TGAImage` which should be stored as a `.tga` file.
    init(_ image: TGAImage) {
        self.header = Header(width: image.width, height: image.height)
        self.image = ImageData(pixels: image.pixels)
        self.footer = Footer()
    }

    /// Returns the (raw) `Data` representation of the wrapped `TGAImage` following the TGA file specification(s).
    func data() -> Data {
        header.data() + image.data() + footer.data()
    }

}

// MARK: - TGAFile.Header

extension TGAFile {

    /// TGA FILE HEADER
    ///
    /// [Specification](http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf) Page 6 ff.
    struct Header {

        /// Image Type - Field 3 (1 byte)
        enum ImageType: UInt8 {
            /// Uncompressed, True-color Image
            case uncompressedTrueColor = 2
        }
        /// Image Specification - Field 5 (10 bytes)
        struct ImageSpecification {
            /// This field specifies the width of the image in pixels (2 bytes).
            let imageWidth: UInt16
            /// This field specifies the height of the image in pixels (2 bytes).
            let imageHeight: UInt16
            /// This field indicates the number of bits per pixel (1 byte).
            let pixelDepth: UInt8 = 24 // 8 * 3
            /// These bits specify the number of attribute bits perpixel (1 byte).
            let imageDescriptor: UInt8 = 32 // 8 * 4
        }

        /// The image type of the pixel data stored in the `ImageData` section of the `TGAFile`.
        private let imageType: ImageType

        /// The image specification of the corresponding `TGAImage`.
        private let imageSpecification: ImageSpecification

        /// Creates a "TGA File Header" for an uncompressed, true-color TGA image with the given dimensions.
        ///
        /// - Parameters:
        ///     - width:    The width of the image stored as the `TGAFile`.
        ///     - height:   The height of the image stored as the `TGAFile`.
        ///     - type:     The image type of the pixel data stored in the `ImageData` section of the `TGAFile`.
        init(width: Int, height: Int, type: ImageType = .uncompressedTrueColor) {
            imageType = type
            imageSpecification = ImageSpecification(imageWidth: UInt16(width), imageHeight: UInt16(height))
        }

        /// Returns the (raw) `Data` representation of the "TGA File Header".
        func data() -> Data {
            var data = Data(repeating: 0, count: 18)
            data[02] = imageType.rawValue
            data[12] = UInt8(truncatingIfNeeded: imageSpecification.imageWidth)
            data[13] = UInt8(truncatingIfNeeded: imageSpecification.imageWidth >> 8)
            data[14] = UInt8(truncatingIfNeeded: imageSpecification.imageHeight)
            data[15] = UInt8(truncatingIfNeeded: imageSpecification.imageHeight >> 8)
            data[16] = imageSpecification.pixelDepth
            data[17] = imageSpecification.imageDescriptor
            return data
        }

    }

}

// MARK: - TGAFile.ImageData

extension TGAFile {

    /// IMAGE DATA
    ///
    /// [Specification](http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf) Page 10 ff.
    struct ImageData {

        /// The pixels of the (wrapped) `TGAImage`.
        private let pixels: [TGAColor]

        /// Creates the "TGA IMAGE DATA" from the given pixel data.
        ///
        /// - Parameters:
        ///     - pixels: The pixels of the (wrapped) `TGAImage`.
        init(pixels: [TGAColor]) {
            self.pixels = pixels
        }

        /// Returns the (raw) `Data` representation of the "TGA IMAGE DATA".
        func data() -> Data {
            Data(bytes: pixels, count: MemoryLayout<TGAColor>.size * pixels.count)
        }

    }

}

// MARK: - TGAFile.Footer

extension TGAFile {

    /// TGA FILE FOOTER
    ///
    /// [Specification](http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf) Page 19 ff.
    struct Footer {

        /// Returns the (raw) `Data` representation of the "TGA File Footer".
        func data() -> Data {
            var data = Data(repeating: 0, count: 26)
            data[8...23] = Data("TRUEVISION-XFILE".utf8)
            data[24] = UInt8(ascii: ".")
            data[25] = 0x00
            return data
        }

    }

}

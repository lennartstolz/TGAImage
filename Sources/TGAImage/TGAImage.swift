import Foundation

/// An object to store pixel data (representing an image with the specified width and height).
///
/// The main interface of this object is the `subscript` method to modify the pixel at the specified position:
///
/// ```
/// var image = TGAImage(width: 3, height: 1, color: .white)
/// image[0, 0] = .red
/// image[1, 0] = .green
/// image[2, 0] = .blue
/// ```
///
/// Additionally, this object offers the `tgaData` method to store the `TGAImage` as a `.tga` file.
public struct TGAImage {

    /// The width of the image in pixels.
    public let width: Int

    /// The height of the image in pixels.
    public let height: Int

    /// The (flattened) pixel data of the image.
    ///
    /// The pixel values are stored by rows. E.g. `pixels[4]` describes the fifth pixel of the first row (4,0) of an
    /// image of five pixel width and `pixels[5]` the first pixel in the second row (0,1) of the same image.
    public private(set) var pixels: [TGAColor]

    /// Create a new image instance of the given dimension colored in the specified color.
    ///
    /// - Parameters:
    ///     - width:    The width of the image in pixels.
    ///     - height:   The height of the image in pixels.
    ///     - color:    The color in which the image should be (initially) colorized.
    public init(width: Int, height: Int, color: TGAColor = .black) {
        self.width = width
        self.height = height
        self.pixels = Array(repeating: color, count: width * height)
    }

    /// Create a new image instance of the given dimension and pixel data.
    ///
    /// - Parameters:
    ///     - width:    The width of the image in pixels.
    ///     - height:   The height of the image in pixels.
    ///     - pixels:   The (flattened) pixel data of the image.
    init(width: Int, height: Int, pixels: [TGAColor]) {
        assert(pixels.count == width * height)
        self.width = width
        self.height = height
        self.pixels = pixels
    }

    /// Accesses the pixel at the specified (x,y) position.
    ///
    /// - Parameters:
    ///     - x: The horizontal position of the pixel.
    ///     - y: The vertical position of the pixel.
    public subscript(x: Int, y: Int) -> TGAColor {
        get {
            assert(isValidIndex(x: x, y: y), "Invalid index (\(x),\(y)).")
            return pixels[(y * width) + x]
        }
        set {
            assert(isValidIndex(x: x, y: y), "Invalid index (\(x),\(y)).")
            pixels[(y * width) + x] = newValue
        }
    }

    /// Returns the raw data to store this image as a `.tga` file.
    public func tgaData() -> Data {
        TGAFile(self).data()
    }

    // MARK: Index Valiation

    private func isValidIndex(x: Int, y: Int) -> Bool {
        x >= 0 && x < width && y >= 0 && y < height
    }

}

// MARK: - Image Flipping

extension TGAImage {

    /// The supported directions to mirror/flip an image.
    public struct FlipDirection : OptionSet {

        /// Flips the image horizontally from the orientation of its original pixel data ("up mirror").
        static let vertically = Self(rawValue: 1 << 0)

        /// Flips the image vertically from the orientation of its original pixel data ("down mirror").
        static let horizontally = Self(rawValue: 1 << 1)

        // MARK: - OptionSet

        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

    }

    /// Mirror the image along the given direction(s).
    ///
    /// - Parameters:
    ///     - direction: The direction of the mirror/flip transformation.
    public mutating func flip(_ direction: FlipDirection) {
        switch direction {
        case .vertically:
            let rows = stride(from: 0, to: pixels.count, by: width).map { pixels[$0..<($0 + width)] }
            pixels = rows.reversed().flatMap { $0 }
        case .horizontally:
            let rows = stride(from: 0, to: pixels.count, by: width).map { pixels[$0..<($0 + width)] }
            pixels = rows.map { $0.reversed() }.flatMap { $0 }
        case [.vertically, .horizontally]:
            pixels = pixels.reversed()
        default:
            assertionFailure("No flip transformation specified for \(direction).")
        }
    }

    /// Returns a new version of the image that’s a mirror of the original image.
    ///
    /// - Parameters:
    ///     - direction: The direction of the mirror/flip transformation.
    ///
    /// - Returns: A new version of the image that’s a mirror of the original image.
    public func flipped(_ direction: FlipDirection) -> Self {
        var image = Self(width: width, height: width, pixels: pixels)
        image.flip(direction)
        return image
    }

}

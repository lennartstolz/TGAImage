import Foundation

/// An object that stores 8-bit RGB color data.
///
/// The order in which the RGB properties of this object are stored matters. They are stored in `(b,g,r)` which enables
/// us to use their `Data` representation to store the values directly in the `TGAImage` without rearranging the bytes.
public struct TGAColor : Equatable {

    /// The color depth of each RGB component of the color.
    public typealias ColorDepth = UInt8

    /// The "blue" color component as an 8-bit value (0-255).
    public let b: ColorDepth

    /// The "green" color component as an 8-bit value (0-255).
    public let g: ColorDepth

    /// The "red" color component as an 8-bit value (0-255).
    public let r: ColorDepth

    /// Creates a color object using the specified RGB component values.
    ///
    /// - Parameters:
    ///     - r: The "red" color component as an 8-bit value (0-255).
    ///     - g: The "green" color component as an 8-bit value (0-255).
    ///     - b: The "blue" color component as an 8-bit value (0-255).
    public init(r: ColorDepth, g: ColorDepth, b: ColorDepth) {
        self.r = r
        self.g = g
        self.b = b
    }

}

// MARK: - Fixed Colors

public extension TGAColor {

    /// A color object with RGB values of 255, 255, and 255, representing the "White" color (Hex: `#ffffff`).
    static let white = Self(r: 255, g: 255, b: 255)

    /// A color object with RGB values of 0, 0, and 0, representing the "Black" color (Hex: `#000000`).
    static let black = Self(r: 0, g: 0, b: 0)

    /// A color object with RGB values of 255, 0, and 0, representing the "Red" color (Hex: `#ff0000`).
    static let red = Self(r: 255, g: 0, b: 0)

    /// A color object with RGB values of 0, 255, and 0, representing the "Green" color (Hex: `#00ff00`).
    static let green = Self(r: 0, g: 255, b: 0)

    /// A color object with RGB values of 0, 0, and 255, representing the "Blue" color (Hex: `#0000ff`).
    static let blue = Self(r: 0, g: 0, b: 255)

}

// MARK: - ExpressibleByArrayLiteral

extension TGAColor : ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = ColorDepth

    /// Creates a color from the specified elements.
    ///
    /// - Precondition: `elements` need to have three elements.
    ///
    /// - Parameters:
    ///     - elements: The elements to construct the color.
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        guard elements.count == 3 else { preconditionFailure("Three elements expected, got \(elements.count).") }
        self.init(r: elements[0], g: elements[1], b: elements[2])
    }

}

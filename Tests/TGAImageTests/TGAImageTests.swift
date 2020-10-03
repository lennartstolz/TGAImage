import XCTest
@testable import TGAImage

final class TGAImageTests: XCTestCase {

    // MARK: Initializer Tests

    func testItShouldSetTheCorrectWidth() {
        let image = TGAImage(width: 100, height: 200)
        XCTAssertEqual(100, image.width)
    }

    func testItShouldSetTheCorrectHeight() {
        let image = TGAImage(width: 100, height: 200)
        XCTAssertEqual(200, image.height)
    }

    func testItShouldSetTheCorrectColor() {
        let image = TGAImage(width: 1, height: 1, color: .green)
        XCTAssertEqual(image[0, 0], .green)
    }

    func testItShouldAllocateThePixels() {
        let image = TGAImage(width: 100, height: 200)
        XCTAssertEqual(20_000, image.pixels.count)
    }

    // MARK: Subscript Tests

    func testItShouldSetAndGetTheGivenColor() {
        var image = TGAImage(width: 20, height: 10, color: .green)
        image[19, 9] = .blue
        XCTAssertEqual(image[19, 9], .blue)
    }

}

// MARK: - Data Tests

extension TGAImageTests {

    func testTheData() {
        let image = TGAImage(width: 2, height: 2, color: .red)
        let data = image.tgaData()
        XCTAssertEqual(56, data.count) // 18 bytes header + (4 * 3) bytes image data + 26 bytes footer
        // HEADER
        XCTAssertEqual(2, data[2]) // ImageType
        XCTAssertEqual(2, data[12...13].withUnsafeBytes({ $0.load(as: UInt16.self) })) // ImageWidth
        XCTAssertEqual(2, data[14...15].withUnsafeBytes({ $0.load(as: UInt16.self) })) // ImageHeight
        XCTAssertEqual(24, data[16]) // PixelDepth
        XCTAssertEqual(32, data[17]) // ImageDescriptor
        // IMAGE DATA
        let expectedData = Data([0, 0, 255, 0, 0, 255, 0, 0, 255, 0, 0, 255])
        XCTAssertEqual(expectedData, data[18...29]) // 4 `.red` colored pixels stored as (blue,greeb,red)
        // FOOTER
        XCTAssertEqual(Data(repeating: 0, count: 4), data[30...33]) // Extension Area
        XCTAssertEqual(Data(repeating: 0, count: 4), data[34...37]) // Developer Directory
        XCTAssertEqual("TRUEVISION-XFILE", String(data: data[38...53], encoding: .utf8)) // Signature
        XCTAssertEqual(UInt8(ascii: "."), data[54]) // Footer Ending '.'
        XCTAssertEqual(0x00, data[55]) // Footer Ending '0x00'
    }

}

// MARK: - Rendering Tests

extension TGAImageTests {

    func testWhiteImage() throws {
        let image = TGAImage(width: 100, height: 100, color: .white)
        let referenceData = try getReferenceImageData(named: "white-reference-image")
        XCTAssertEqual(image.tgaData(), referenceData)
    }

    func testBlackImage() throws {
        let image = TGAImage(width: 100, height: 100, color: .black)
        let referenceData = try getReferenceImageData(named: "black-reference-image")
        XCTAssertEqual(image.tgaData(), referenceData)
    }

    func testRGB() throws {
        var image = TGAImage(width: 150, height: 50, color: .black)
        image.colorize(from: (0, 0), to: (49, 49), .red)
        image.colorize(from: (50, 0), to: (99, 49), .green)
        image.colorize(from: (100, 0), to: (149, 49), .blue)
        let referenceData = try getReferenceImageData(named: "rgb-reference-image")
        XCTAssertEqual(image.tgaData(), referenceData)
    }

    func testComplexGradient() throws {
        var image = TGAImage(width: 256, height: 256, color: .black)
        for x in 0...255 {
            for y in 0...255 {
                image[x, y] = RGB(r: UInt8(x), g: UInt8(y), b: 255)
            }
        }
        let referenceData = try getReferenceImageData(named: "gradient-reference-image")
        XCTAssertEqual(image.tgaData(), referenceData)
    }

}

private extension TGAImageTests {

    /// Returns the raw data for the specified reference (`.tga`) image.
    ///
    /// - Parameters:
    ///     - name: The file name (without the `.tga` file extension) of the reference image.
    ///
    /// ## Implementation Details
    ///
    /// As outlined in the following Swift forum discussion(s) and the corresponding issue, loading a test asset from
    /// `Bundle.module` fails for the Swift 5.3 version. That's why this test helper method makes use of `#file` and
    /// local URLs. Once the bug is fixed it's highly recommended to switch back to the `module` bundle.
    ///
    /// - https://bugs.swift.org/browse/SR-12912
    /// - https://forums.swift.org/t/swift-5-3-spm-resources-in-tests-uses-wrong-bundle-path/37051/2
    func getReferenceImageData(named name: String) throws -> Data {
        var url = URL(fileURLWithPath: #file)
        url.deleteLastPathComponent()
        url.appendPathComponent("Resources", isDirectory: true)
        url.appendPathComponent("\(name).tga")
        return try Data(contentsOf: url)
    }

}

private extension TGAImage {

    /// The tuple specifing the (x,y) position of a pixel in `TGAImage`.
    typealias Point = (x: Int, y: Int)

    /// Helper method to colorize a rectangular area (defined by its upper left and lower right pixel) of the image.
    ///
    /// - Parameters:
    ///     - upperLeft:    The upper left pixel of the area which should be colorized.
    ///     - lowerRight:   The lower right pixel of the area which should be colorized.
    ///     - color:        The color in which the defined area should be colorized.
    mutating func colorize(from upperLeft: Point, to lowerRight: Point, _ color: RGB) {
        for x in upperLeft.x...lowerRight.x {
            for y in upperLeft.y...lowerRight.y {
                self[x, y] = color
            }
        }
    }

}

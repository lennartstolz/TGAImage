import XCTest
@testable import TGAImage

final class TGAFileTests: XCTestCase {

    func testTheFileSize() {
        let file = TGAFile(TGAImage(width: 2, height: 2, color: .red)).data()
        XCTAssertEqual(56, file.count) // 18 bytes header + (4 * 3) bytes image data + 26 bytes footer
    }

    func testTheFileSizeOfAnEmptyImage() {
        let file = TGAFile(TGAImage(width: 0, height: 0)).data()
        XCTAssertEqual(44, file.count)
    }

    func testTheHeader() {
        let file = TGAFile(TGAImage(width: 1024, height: 2048)).data()
        XCTAssertEqual(file[2], 2) // ImageType
        XCTAssertEqual(1024, file[12...13].withUnsafeBytes({ $0.load(as: UInt16.self) })) // ImageWidth
        XCTAssertEqual(2048, file[14...15].withUnsafeBytes({ $0.load(as: UInt16.self) })) // ImageHeight
        XCTAssertEqual(24, file[16]) // PixelDepth
        XCTAssertEqual(32, file[17]) // ImageDescriptor
    }

    func testTheImageData() {
        var image = TGAImage(width: 2, height: 2)
        image[0, 0] = .red
        image[1, 0] = .green
        image[0, 1] = .blue
        image[1, 1] = .white
        let data = TGAFile(image).data()
        let x0y0 = data[18...20].withUnsafeBytes { $0.load(as: TGAColor.self) }
        XCTAssertEqual(x0y0, .red)
        let x1y0 = data[21...23].withUnsafeBytes { $0.load(as: TGAColor.self) }
        XCTAssertEqual(x1y0, .green)
        let x0y1 = data[24...26].withUnsafeBytes { $0.load(as: TGAColor.self) }
        XCTAssertEqual(x0y1, .blue)
        let x1y1 = data[27...29].withUnsafeBytes { $0.load(as: TGAColor.self) }
        XCTAssertEqual(x1y1, .white)
    }

    func testTheFooter() {
        let file = TGAFile(TGAImage(width: 2, height: 2)).data()
        let offset = 18 + 12 // Header + ImageData of four Pixels
        XCTAssertEqual(file[offset+0...offset+3], Data(repeating: 0, count: 4)) // Extension Area
        XCTAssertEqual(file[offset+4...offset+7], Data(repeating: 0, count: 4)) // Developer Directory
        XCTAssertEqual(String(data: file[offset+8...offset+23], encoding: .utf8), "TRUEVISION-XFILE") // Signature
        XCTAssertEqual(file[offset+24], UInt8(ascii: ".")) // Footer Ending '.'
        XCTAssertEqual(file[offset+25], 0x00) // Footer Ending '0x00'
    }

}

// MARK: - TGAFile.Header Tests

extension TGAFileTests {

    func testTheHeaderSize() {
        let header = TGAFile.Header(width: 0, height: 0).data()
        XCTAssertEqual(18, header.count)
    }

    func testTheImageType() {
        let header = TGAFile.Header(width: 0, height: 0).data()
        XCTAssertEqual(header[2], 2)
    }

    func testTheWidth() {
        let header = TGAFile.Header(width: 1024, height: 0).data()
        let width = header[12...13].withUnsafeBytes { $0.load(as: UInt16.self) }
        XCTAssertEqual(1024, width)
    }

    func testTheHeight() {
        let header = TGAFile.Header(width: 0, height: 2048).data()
        let height = header[14...15].withUnsafeBytes { $0.load(as: UInt16.self) }
        XCTAssertEqual(2048, height)
    }

    func testThePixelDepth() {
        let header = TGAFile.Header(width: 42, height: 42).data()
        XCTAssertEqual(24, header[16])
    }

    func testTheImageDescriptor() {
        let header = TGAFile.Header(width: 42, height: 42).data()
        XCTAssertEqual(32, header[17])
    }

}

// MARK: - TGAFile.ImageData Tests

extension TGAFileTests {

    func testTheImageDataSize() {
        let data = TGAFile.ImageData(pixels: [.red, .green, .blue, .black, .white]).data()
        XCTAssertEqual(5*3, data.count)
    }

    func testTheImageDataSizeOfAnEmptyImage() {
        let data = TGAFile.ImageData(pixels: []).data()
        XCTAssertEqual(0, data.count)
    }

    func testTheColorComponents() {
        let data = TGAFile.ImageData(pixels: [TGAColor(r: 253, g: 254, b: 255)]).data()
        XCTAssertEqual(255, data[0])
        XCTAssertEqual(254, data[1])
        XCTAssertEqual(253, data[2])
    }

}

// MARK: - TGAFile.Footer Tests

extension TGAFileTests {

    func testTheFooterSize() {
        let footer = TGAFile.Footer().data()
        XCTAssertEqual(26, footer.count)
    }

    func testTheExtensionAreaOffset() {
        let footer = TGAFile.Footer().data()
        XCTAssertEqual(footer[0...3], Data(repeating: 0, count: 4))
    }

    func testTheDeveloperDirectoryOffset() {
        let footer = TGAFile.Footer().data()
        XCTAssertEqual(footer[4...7], Data(repeating: 0, count: 4))
    }

    func testTheSignature() {
        let footer = TGAFile.Footer().data()
        let signature = String(data: footer[8...23], encoding: .utf8)
        XCTAssertEqual(signature, "TRUEVISION-XFILE")
    }

    func testTheFooterEnding() {
        let footer = TGAFile.Footer().data()
        XCTAssertEqual(footer[24], UInt8(ascii: "."))
        XCTAssertEqual(footer[25], 0x00)
    }

}

import XCTest
@testable import TGAImage

final class TGAColorTests: XCTestCase {

    // MARK: Initializer Tests

    func testTheInitializer() {
        let color = TGAColor(r: 1, g: 2, b: 3)
        XCTAssertEqual(1, color.r)
        XCTAssertEqual(2, color.g)
        XCTAssertEqual(3, color.b)
    }

    // MARK: Data Tests

    func testTheFirstByteContainsBlue() {
        var color = TGAColor(r: 0, g: 0, b: 100)
        let data = Data(bytes: &color, count: MemoryLayout<TGAColor>.size)
        XCTAssertEqual(100, data[0])
    }

    func testTheSecondByteContainsGreen() {
        var color = TGAColor(r: 0, g: 100, b: 0)
        let data = Data(bytes: &color, count: MemoryLayout<TGAColor>.size)
        XCTAssertEqual(100, data[1])
    }

    func testTheThirdByteContainsRed() {
        var color = TGAColor(r: 100, g: 0, b: 0)
        let data = Data(bytes: &color, count: MemoryLayout<TGAColor>.size)
        XCTAssertEqual(100, data[2])
    }

    // MARK: Fixed Colors Tests

    func testTheFixedColorWhite() {
        let color: TGAColor = .white
        XCTAssertEqual(255, color.r)
        XCTAssertEqual(255, color.g)
        XCTAssertEqual(255, color.b)
    }

    func testTheFixedColorBlack() {
        let color: TGAColor = .black
        XCTAssertEqual(0, color.r)
        XCTAssertEqual(0, color.g)
        XCTAssertEqual(0, color.b)
    }

    func testTheFixedColorRed() {
        let color: TGAColor = .red
        XCTAssertEqual(255, color.r)
        XCTAssertEqual(0, color.g)
        XCTAssertEqual(0, color.b)
    }

    func testTheFixedColorGreen() {
        let color: TGAColor = .green
        XCTAssertEqual(0, color.r)
        XCTAssertEqual(255, color.g)
        XCTAssertEqual(0, color.b)
    }

    func testTheFixedColorBlue() {
        let color: TGAColor = .blue
        XCTAssertEqual(0, color.r)
        XCTAssertEqual(0, color.g)
        XCTAssertEqual(255, color.b)
    }

}

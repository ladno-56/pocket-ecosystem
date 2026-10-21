import XCTest
@testable import PocketEcosystem

final class WorldGridTests: XCTestCase {
    func testGeneratedWorldHasTerrainAndOpenSky() {
        let world = WorldGrid(width: 24, height: 18, seed: 7)
        let cells = (0..<world.height).flatMap { y in
            (0..<world.width).map { x in world[x, y] }
        }

        XCTAssertTrue(cells.contains(.grass))
        XCTAssertTrue(cells.contains(.soil))
        XCTAssertTrue(cells.contains(.empty))
    }

    func testToolsPlaceAndRemoveCells() {
        var world = WorldGrid(width: 20, height: 16, seed: 2)
        let emptyCell = (0..<world.height).flatMap { y in
            (0..<world.width).map { (x: $0, y: y) }
        }.first { world[$0.x, $0.y] == .empty }

        XCTAssertNotNil(emptyCell)
        guard let cell = emptyCell else { return }
        XCTAssertTrue(world.apply(.placeSoil, atX: cell.x, y: cell.y))
        XCTAssertNotEqual(world[cell.x, cell.y], .empty)
        XCTAssertTrue(world.apply(.remove, atX: cell.x, y: cell.y))
        XCTAssertEqual(world[cell.x, cell.y], .empty)
    }

    func testOutOfBoundsEditsAreRejected() {
        var world = WorldGrid(width: 12, height: 10, seed: 3)

        XCTAssertFalse(world.apply(.placeSoil, atX: -1, y: 0))
        XCTAssertFalse(world.apply(.remove, atX: world.width, y: 0))
    }
}

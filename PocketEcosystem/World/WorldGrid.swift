import Foundation

enum CellType: Int, CaseIterable, Equatable {
    case empty
    case grass
    case soil
    case stone
}

enum WorldTool: Equatable {
    case placeSoil
    case remove
}

struct WorldGrid {
    let width: Int
    let height: Int
    let seed: UInt64
    private(set) var cells: [CellType]

    init(width: Int = 48, height: Int = 30, seed: UInt64 = 42) {
        precondition(width > 0 && height >= 5, "A world must be at least five cells high.")
        self.width = width
        self.height = height
        self.seed = seed
        cells = Array(repeating: .empty, count: width * height)
        generateTerrain()
    }

    subscript(x: Int, y: Int) -> CellType {
        guard contains(x: x, y: y) else { return .empty }
        return cells[y * width + x]
    }

    @discardableResult
    mutating func apply(_ tool: WorldTool, atX x: Int, y: Int) -> Bool {
        guard contains(x: x, y: y) else { return false }
        let index = y * width + x
        switch tool {
        case .placeSoil:
            guard cells[index] == .empty else { return false }
            cells[index] = hasGrassNeighbor(x: x, y: y) ? .grass : .soil
        case .remove:
            guard cells[index] != .empty else { return false }
            cells[index] = .empty
        }
        return true
    }

    private func contains(x: Int, y: Int) -> Bool {
        (0..<width).contains(x) && (0..<height).contains(y)
    }

    private func hasGrassNeighbor(x: Int, y: Int) -> Bool {
        [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
            .contains { self[$0.0, $0.1] == .grass }
    }

    private mutating func generateTerrain() {
        let surfaceBase = max(5, height / 3)
        for x in 0..<width {
            let variation = Int(noise(x: x, y: 0) % 5) - 2
            let surface = min(height - 2, max(3, surfaceBase + variation))
            for y in 0..<surface {
                if y == surface - 1 {
                    cells[y * width + x] = .grass
                } else if y < 2 && noise(x: x, y: y) % 13 == 0 {
                    cells[y * width + x] = .stone
                } else {
                    cells[y * width + x] = .soil
                }
            }
        }
    }

    private func noise(x: Int, y: Int) -> UInt64 {
        var value = seed &+ UInt64(x &* 374_761_393) &+ UInt64(y &* 668_265_263)
        value = (value ^ (value >> 13)) &* 1_274_126_177
        return value ^ (value >> 16)
    }
}

import SpriteKit
import UIKit

enum PixelWorldRenderer {
    static let tileSize: CGFloat = 16

    static func makeTexture(for world: WorldGrid) -> SKTexture {
        let pixelWidth = world.width
        let pixelHeight = world.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = pixelWidth * 4
        let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        guard let context else {
            preconditionFailure("Unable to allocate the pixel-art world texture.")
        }

        for y in 0..<pixelHeight {
            for x in 0..<pixelWidth {
                context.setFillColor(color(for: world[x, y], x: x, y: y, seed: world.seed))
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }

        guard let image = context.makeImage() else {
            preconditionFailure("Unable to create the pixel-art world image.")
        }
        let texture = SKTexture(cgImage: image)
        texture.filteringMode = .nearest
        return texture
    }

    private static func color(for cell: CellType, x: Int, y: Int, seed: UInt64) -> CGColor {
        let variation = UInt8((x * 17 + y * 31 + Int(seed % 11)) % 13)
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        switch cell {
        case .empty:
            (red, green, blue) = (101, 160, 182)
        case .grass:
            (red, green, blue) = (UInt8(91 + variation), UInt8(151 + variation), 76)
        case .soil:
            (red, green, blue) = (UInt8(132 + variation), UInt8(91 + variation / 2), 59)
        case .stone:
            (red, green, blue) = (UInt8(108 + variation), UInt8(116 + variation), 121)
        }
        return UIColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        ).cgColor
    }
}

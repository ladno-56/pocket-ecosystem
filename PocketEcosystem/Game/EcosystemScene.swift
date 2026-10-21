import SpriteKit

final class EcosystemScene: SKScene {
    var selectedTool: WorldTool = .placeSoil
    let cameraNode = SKCameraNode()

    private var world = WorldGrid()
    private let worldSprite = SKSpriteNode()

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.35, green: 0.58, blue: 0.68, alpha: 1)
        camera = cameraNode
        addChild(cameraNode)

        worldSprite.size = CGSize(
            width: CGFloat(world.width) * PixelWorldRenderer.tileSize,
            height: CGFloat(world.height) * PixelWorldRenderer.tileSize
        )
        addChild(worldSprite)
        refreshWorld()
        centerCamera()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        if oldSize != .zero {
            centerCamera()
        }
    }

    func handleTap(at viewPoint: CGPoint) {
        let scenePoint = convertPoint(fromView: viewPoint)
        let localPoint = worldSprite.convert(scenePoint, from: self)
        let x = Int(floor((localPoint.x + worldSprite.size.width / 2) / PixelWorldRenderer.tileSize))
        let y = Int(floor((localPoint.y + worldSprite.size.height / 2) / PixelWorldRenderer.tileSize))
        guard world.apply(selectedTool, atX: x, y: y) else { return }

        refreshWorld()
        let feedback = SKShapeNode(rectOf: CGSize(width: 12, height: 12), cornerRadius: 2)
        feedback.fillColor = .white.withAlphaComponent(0.75)
        feedback.strokeColor = .clear
        feedback.position = CGPoint(
            x: (CGFloat(x) + 0.5) * PixelWorldRenderer.tileSize - worldSprite.size.width / 2,
            y: (CGFloat(y) + 0.5) * PixelWorldRenderer.tileSize - worldSprite.size.height / 2
        )
        feedback.setScale(0.4)
        feedback.alpha = 0.8
        worldSprite.addChild(feedback)
        feedback.run(.sequence([
            .group([.scale(to: 1.2, duration: 0.12), .fadeOut(withDuration: 0.22)]),
            .removeFromParent()
        ]))
    }

    private func refreshWorld() {
        worldSprite.texture = PixelWorldRenderer.makeTexture(for: world)
        worldSprite.texture?.filteringMode = .nearest
    }

    private func centerCamera() {
        cameraNode.position = .zero
        guard size.width > 0, size.height > 0 else { return }
        let fitScale = max(worldSprite.size.width / size.width, worldSprite.size.height / size.height)
        cameraNode.setScale(max(0.55, fitScale))
    }
}

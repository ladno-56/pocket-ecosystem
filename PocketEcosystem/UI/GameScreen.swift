import SpriteKit
import SwiftUI
import UIKit

struct GameScreen: View {
    @State private var selectedTool: WorldTool = .placeSoil
    @State private var scene = EcosystemScene()

    var body: some View {
        ZStack {
            PixelGameView(scene: scene)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("POCKET ECOSYSTEM")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .tracking(1.2)
                        Text("Создай свой маленький мир")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    Spacer()
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(red: 0.60, green: 0.83, blue: 0.48))
                        .padding(11)
                        .background(.black.opacity(0.28), in: Circle())
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)

                Spacer()

                HStack(spacing: 10) {
                    toolButton(.placeSoil, title: "Земля", symbol: "plus.square.fill")
                    toolButton(.remove, title: "Убрать", symbol: "minus.square.fill")
                }
                .padding(8)
                .background(.black.opacity(0.58), in: RoundedRectangle(cornerRadius: 18))
                .padding(.bottom, 12)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
        }
        .background(Color(red: 0.18, green: 0.28, blue: 0.33))
        .statusBarHidden()
    }

    private func toolButton(_ tool: WorldTool, title: String, symbol: String) -> some View {
        let isSelected = selectedTool == tool
        return Button {
            selectedTool = tool
            scene.selectedTool = tool
        } label: {
            Label(title, systemImage: symbol)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? Color(red: 0.10, green: 0.16, blue: 0.12) : .white)
                .background(
                    isSelected ? Color(red: 0.68, green: 0.86, blue: 0.53) : .clear,
                    in: RoundedRectangle(cornerRadius: 12)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct PixelGameView: UIViewRepresentable {
    let scene: EcosystemScene

    func makeUIView(context: Context) -> SKView {
        let view = GestureSKView()
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = true
        view.preferredFramesPerSecond = 30
        view.backgroundColor = UIColor(red: 0.35, green: 0.58, blue: 0.68, alpha: 1)
        view.presentScene(scene)
        context.coordinator.attach(to: view, scene: scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        if view.scene !== scene {
            view.presentScene(scene)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var scene: EcosystemScene?
        private var previousPan = CGPoint.zero
        private var previousPinchScale: CGFloat = 1

        func attach(to view: SKView, scene: EcosystemScene) {
            self.scene = scene

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))

            [tap, pan, pinch].forEach {
                $0.delegate = self
                $0.cancelsTouchesInView = false
                view.addGestureRecognizer($0)
            }
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            true
        }

        @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let view = recognizer.view as? SKView, let scene else { return }
            scene.handleTap(at: recognizer.location(in: view))
        }

        @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
            guard let view = recognizer.view, let scene else { return }
            let camera = scene.cameraNode
            let translation = recognizer.translation(in: view)
            if recognizer.state == .began {
                previousPan = .zero
            }
            let delta = CGPoint(x: translation.x - previousPan.x, y: translation.y - previousPan.y)
            previousPan = translation
            camera.position.x -= delta.x
            camera.position.y += delta.y
        }

        @objc private func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
            guard let scene else { return }
            let camera = scene.cameraNode
            if recognizer.state == .began {
                previousPinchScale = 1
            }
            let factor = recognizer.scale / previousPinchScale
            previousPinchScale = recognizer.scale
            camera.setScale(min(max(camera.xScale / factor, 0.55), 2.5))
            if recognizer.state == .ended || recognizer.state == .cancelled {
                previousPinchScale = 1
            }
        }
    }
}

private final class GestureSKView: SKView {}

import SwiftUI
import SpriteKit

struct BallPhysicsPoolView: View {
    let sessions: [PingPongSession]
    var isWelcomeDismissed: Bool = false
    var onSelectSession: ((PingPongSession) -> Void)? = nil
    var pendingDropSession: PingPongSession? = nil
    
    @StateObject private var sceneHolder = SceneHolder()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SpriteView(scene: sceneHolder.scene, options: [.allowsTransparency])
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.sketchLine, lineWidth: 3)
                )
                .onAppear {
                    sceneHolder.setupIfNeeded(sessions: sessions, isWelcomeDismissed: isWelcomeDismissed, onSelectSession: onSelectSession)
                }
                .onChange(of: sessions.map { $0.id }) { _, _ in
                    sceneHolder.syncSessions(sessions: sessions, isWelcomeDismissed: isWelcomeDismissed)
                }
                .onChange(of: isWelcomeDismissed) { _, newValue in
                    sceneHolder.syncSessions(sessions: sessions, isWelcomeDismissed: newValue)
                }
                .onChange(of: pendingDropSession?.id) { _, _ in
                    if let dropSession = pendingDropSession {
                        sceneHolder.dropBallWithDelay(dropSession, delay: 0.35)
                    }
                }
            
            HStack(spacing: 8) {
                // Interactive Chaos Button
                Button {
                    sceneHolder.scene.applyChaosImpulse()
                } label: {
                    HStack(spacing: 4) {
                        Text("⚡ 乱斗")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.sketchLine)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.stickerYellow)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.sketchLine, lineWidth: 2))
                    .shadow(color: .black.opacity(0.12), radius: 2, x: 1, y: 2)
                }
            }
            .padding(14)
        }
    }
}

@MainActor
final class SceneHolder: ObservableObject {
    let scene: MoodPhysicsScene
    private var isConfigured = false
    
    init() {
        self.scene = MoodPhysicsScene(size: CGSize(width: 350, height: 420))
    }
    
    func setupIfNeeded(sessions: [PingPongSession], isWelcomeDismissed: Bool, onSelectSession: ((PingPongSession) -> Void)?) {
        guard !isConfigured else { return }
        isConfigured = true
        scene.onSelectSession = onSelectSession
        scene.loadSessions(sessions, isWelcomeDismissed: isWelcomeDismissed)
    }
    
    func syncSessions(sessions: [PingPongSession], isWelcomeDismissed: Bool) {
        scene.updateSessions(sessions, isWelcomeDismissed: isWelcomeDismissed)
    }
    
    func dropBallWithDelay(_ session: PingPongSession, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.scene.dropNewBall(for: session)
        }
    }
    
    func triggerDemoDrop() {
        let sampleMoods: [MoodType] = MoodType.allCases
        let sampleSizes: [BallSize] = [.small, .medium, .jumbo]
        let demoSession = PingPongSession(
            sessionType: .casualMatch,
            mood: sampleMoods.randomElement() ?? .onFire,
            ballSize: sampleSizes.randomElement() ?? .jumbo
        )
        scene.dropNewBall(for: demoSession)
    }
}

class MoodPhysicsScene: SKScene, SKPhysicsContactDelegate {
    var onSelectSession: ((PingPongSession) -> Void)?
    
    private var sessionNodeMap: [UUID: SKNode] = [:]
    private var currentSessions: [PingPongSession] = []
    
    override init(size: CGSize) {
        super.init(size: size)
        self.scaleMode = .resizeFill
        self.backgroundColor = .clear
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8) // Realistic gravity
        
        // Fully enclosed boundary matching the visible frame so balls bounce smoothly off all 4 edges
        let containerPath = CGMutablePath()
        containerPath.move(to: CGPoint(x: 0, y: size.height))
        containerPath.addLine(to: CGPoint(x: 0, y: 0))
        containerPath.addLine(to: CGPoint(x: size.width, y: 0))
        containerPath.addLine(to: CGPoint(x: size.width, y: size.height))
        containerPath.addLine(to: CGPoint(x: 0, y: size.height)) // Top ceiling at exact top boundary
        
        let boundaryBody = SKPhysicsBody(edgeChainFrom: containerPath)
        boundaryBody.friction = 0.5
        boundaryBody.restitution = 0.65 // Smooth bouncy ceiling bounce
        boundaryBody.categoryBitMask = 0x1
        self.physicsBody = boundaryBody
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        for node in children {
            if let body = node.physicsBody, node.name != nil {
                // Extreme out-of-bounds safety net only (e.g. physics engine glitches far off-screen)
                if node.position.y < -50 || node.position.x < -50 || node.position.x > size.width + 50 || node.position.y > size.height + 150 {
                    let ballWidth = (node as? SKSpriteNode)?.size.width ?? 40
                    let radius = ballWidth / 2.0
                    let startX = CGFloat.random(in: (radius + 20)...(size.width - radius - 20))
                    node.position = CGPoint(x: startX, y: size.height - radius - 15)
                    body.velocity = CGVector(dx: 0, dy: -40)
                    body.angularVelocity = 0
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let welcomeSessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
    private var isUsingSampleSessions = false
    
    func loadSessions(_ sessions: [PingPongSession], isWelcomeDismissed: Bool) {
        if sessions.isEmpty {
            if !isWelcomeDismissed {
                isUsingSampleSessions = true
                let displaySessions = welcomeSessions()
                currentSessions = displaySessions
                addBallNode(for: displaySessions[0], initialY: size.height / 2, isNewDrop: false)
            } else {
                isUsingSampleSessions = false
                currentSessions = []
            }
        } else {
            isUsingSampleSessions = false
            currentSessions = sessions
            for (index, session) in sessions.enumerated() {
                addBallNode(for: session, initialY: 100 + CGFloat(index * 35), isNewDrop: false)
            }
        }
    }
    
    func updateSessions(_ newSessions: [PingPongSession], isWelcomeDismissed: Bool) {
        if newSessions.isEmpty {
            if isWelcomeDismissed {
                isUsingSampleSessions = false
                currentSessions = []
                for node in sessionNodeMap.values {
                    node.removeFromParent()
                }
                sessionNodeMap.removeAll()
            } else if !isUsingSampleSessions {
                isUsingSampleSessions = true
                let displaySessions = welcomeSessions()
                currentSessions = displaySessions
                addBallNode(for: displaySessions[0], initialY: size.height / 2, isNewDrop: false)
            }
        } else {
            if isUsingSampleSessions {
                isUsingSampleSessions = false
                for node in sessionNodeMap.values {
                    node.removeFromParent()
                }
                sessionNodeMap.removeAll()
            }
            currentSessions = newSessions
            // Sync nodes if needed
            let existingIDs = Set(sessionNodeMap.keys)
            let newIDs = Set(newSessions.map { $0.id })
            
            // Remove deleted
            for id in existingIDs.subtracting(newIDs) {
                if let node = sessionNodeMap[id] {
                    let shrinkAndFade = SKAction.group([
                        SKAction.scale(to: 0.01, duration: 0.25),
                        SKAction.fadeOut(withDuration: 0.25)
                    ])
                    let remove = SKAction.removeFromParent()
                    node.run(SKAction.sequence([shrinkAndFade, remove]))
                }
                sessionNodeMap.removeValue(forKey: id)
            }
            
            // Add new
            for session in newSessions where !existingIDs.contains(session.id) {
                addBallNode(for: session, initialY: size.height + 30, isNewDrop: true)
            }
        }
    }
    
    @MainActor
    private func addBallNode(for session: PingPongSession, initialY: CGFloat, isNewDrop: Bool) {
        // Prevent duplicate ball nodes for the same session ID
        guard sessionNodeMap[session.id] == nil else { return }
        
        let ballSize = session.ballSize
        let radius = ballSize.radius
        
        // Render texture using DoodleBallView
        let doodleView = DoodleBallView(mood: session.mood, size: ballSize)
            .environment(\.colorScheme, .light)
        
        let renderer = ImageRenderer(content: doodleView)
        renderer.scale = 2.0
        
        guard let image = renderer.uiImage else { return }
        let texture = SKTexture(image: image)
        
        let ballNode = SKSpriteNode(texture: texture, size: CGSize(width: radius * 2, height: radius * 2))
        ballNode.name = session.id.uuidString
        
        let startX = CGFloat.random(in: (radius + 30)...(size.width - radius - 30))
        let startY = isNewDrop ? (size.height - radius - 10) : initialY
        ballNode.position = CGPoint(x: startX, y: startY)
        
        // Physics Body
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.friction = 0.4
        body.restitution = 0.72 // Bouncy ping pong bounce!
        body.density = 1.0
        body.categoryBitMask = 0x2
        body.collisionBitMask = 0x1 | 0x2
        body.contactTestBitMask = 0x1 | 0x2
        body.allowsRotation = true
        
        ballNode.physicsBody = body
        
        if isNewDrop {
            // Drop down smoothly from top
            body.velocity = CGVector(dx: CGFloat.random(in: -20...20), dy: -120)
            body.angularVelocity = CGFloat.random(in: -2...2)
            
            // Drop highlight scale animation
            ballNode.setScale(1.2)
            ballNode.run(SKAction.scale(to: 1.0, duration: 0.4))
        }
        
        addChild(ballNode)
        sessionNodeMap[session.id] = ballNode
        
        if isNewDrop {
            playDropEffects(at: CGPoint(x: startX, y: size.height - 20))
        }
    }
    
    @MainActor
    func dropNewBall(for session: PingPongSession) {
        addBallNode(for: session, initialY: size.height - 30, isNewDrop: true)
    }
    
    func applyChaosImpulse() {
        for node in children {
            if let body = node.physicsBody, node.name != nil {
                let randomDx = CGFloat.random(in: -80...80)
                let randomDy = CGFloat.random(in: 150...280)
                body.applyImpulse(CGVector(dx: randomDx, dy: randomDy))
                body.applyAngularImpulse(CGFloat.random(in: -0.5...0.5))
            }
        }
    }
    
    private func playDropEffects(at point: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = nil
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 24
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.15
        emitter.particleSpeed = 140
        emitter.particleSpeedRange = 70
        emitter.emissionAngleRange = .pi * 2
        emitter.particleColor = UIColor(Color.pongOrange)
        emitter.position = point
        addChild(emitter)
        
        let remove = SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.removeFromParent()])
        emitter.run(remove)
    }
    
    // MARK: - Touch Interaction (Drag & Tap)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let name = node.name, let uuid = UUID(uuidString: name), let body = node.physicsBody {
                // Pulse on tap
                let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
                let scaleNormal = SKAction.scale(to: 1.0, duration: 0.1)
                node.run(SKAction.sequence([scaleUp, scaleNormal]))
                
                // Notify selection
                if let matchedSession = currentSessions.first(where: { $0.id == uuid }) {
                    onSelectSession?(matchedSession)
                }
                
                // Bounce impulse
                let impulse = CGVector(dx: CGFloat.random(in: -50...50), dy: 160)
                body.applyImpulse(impulse)
                break
            }
        }
    }
    
    private func welcomeSessions() -> [PingPongSession] {
        let welcomeSession = PingPongSession(
            sessionType: .practice,
            mood: .joyful,
            ballSize: .jumbo,
            note: "👋 欢迎来到 Pongie！记录打卡后，球池将实时掉落你的专属心情球 🏓"
        )
        welcomeSession.id = MoodPhysicsScene.welcomeSessionID
        return [welcomeSession]
    }
}

import SwiftUI
import AVFoundation
import Foundation

struct VoiceAgentView: View {
    @State private var isRecording = false
    @State private var status = "Tap button to start conversation"
    @State private var geminiStatus = "Waiting for voice input..."
    @State private var isConnected = false
    @State private var audioLevel: CGFloat = 0.0
    @State private var useLocalhost = false
    
    // WebSocket connection
    @State private var webSocket: URLSessionWebSocketTask?
    
    // Audio session
    private let audioSession = AVAudioSession.sharedInstance()
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode?
    
    // Audio player for Gemini responses
    @StateObject private var audioPlayer = AudioPlayer()
    
    init() {
        self.inputNode = audioEngine.inputNode
    }
    
    var body: some View {
        ZStack {
            // Dark background with subtle gradient edges
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black,
                    Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.1), // Lime green edge
                    Color(red: 1.0, green: 0.8, blue: 0.2).opacity(0.1)  // Yellow-orange edge
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // AI Buddy label and status
                VStack(spacing: 8) {
                    // AI Buddy pill
                    HStack {
                        Text("AI Buddy")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.2, green: 0.8, blue: 0.2)) // Lime green
                            )
                    }
                    
                    // Online status dot
                    HStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 6, height: 6)
                        Text("Online")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Animated amorphous blob avatar
                ZStack {
                    // Background glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .opacity(isRecording ? 0.8 : 0.4)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isRecording)
                    
                    // Main AI Assistant Avatar
                    ZStack {
                        // Background circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.6, blue: 1.0),
                                        Color(red: 0.4, green: 0.8, blue: 1.0),
                                        Color(red: 0.6, green: 0.9, blue: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .shadow(color: Color(red: 0.2, green: 0.6, blue: 1.0).opacity(0.4), radius: 20, x: 0, y: 10)
                        
                        // Inner circle for depth
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        // AI Brain/Neural Network Icon
                        VStack(spacing: 4) {
                            // Top row of dots
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                            
                            // Middle row with more dots
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                            }
                            
                            // Bottom row
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .scaleEffect(isRecording ? 1.2 : 1.0)
                        .opacity(isRecording ? 0.9 : 0.7)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                        
                        // Pulsing ring when recording
                        if isRecording {
                            Circle()
                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                .frame(width: 220, height: 220)
                                .scaleEffect(isRecording ? 1.3 : 1.0)
                                .opacity(isRecording ? 0.0 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: false),
                                    value: isRecording
                                )
                        }
                    }
                    .scaleEffect(isRecording ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: isRecording)
                    
                    // Subtle wavy lines pattern
                    if isRecording {
                        WavyLinesPattern()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 250, height: 250)
                            .scaleEffect(isRecording ? 1.3 : 1.0)
                            .opacity(isRecording ? 0.6 : 0.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isRecording)
                    }
                }
                .padding(.bottom, 40)
                
                // Query text area (placeholder for now)
                VStack(spacing: 8) {
                    Text("How to care for your pet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text("or find a lost animal?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text("Ask the voice assistant")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                Spacer()
                
                // Bottom control buttons
                HStack(spacing: 20) {
                    // Left button - folder/document
                    Button(action: {}) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "folder")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Center microphone button
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                .frame(width: 80, height: 80)
                            
                            // Main button
                            Circle()
                                .fill(Color(red: 0.2, green: 0.8, blue: 0.2)) // Lime green
                                .frame(width: 70, height: 70)
                                .shadow(color: Color(red: 0.2, green: 0.8, blue: 0.2).opacity(0.5), radius: 15, x: 0, y: 8)
                            
                            // Pulsing animation when recording
                            if isRecording {
                                Circle()
                                    .stroke(Color.red.opacity(0.6), lineWidth: 3)
                                    .frame(width: 90, height: 90)
                                    .scaleEffect(isRecording ? 1.3 : 1.0)
                                    .opacity(isRecording ? 0.0 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 1.5)
                                            .repeatForever(autoreverses: false),
                                        value: isRecording
                                    )
                            }
                            
                            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(isRecording ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRecording)
                    
                    // Right button - X/cancel
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Voice Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupAudioSession()
            connectWebSocket()
        }
        .onDisappear {
            disconnectWebSocket()
        }
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            // Check if running on simulator
            #if targetEnvironment(simulator)
            print("⚠️ Запущено в симуляторе - аудио может не работать корректно")
            status = "Симулятор: аудио ограничено"
            #else
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("✅ Аудио сессия настроена")
            #endif
        } catch {
            print("Ошибка настройки аудио сессии: \(error)")
            status = "Ошибка аудио: \(error.localizedDescription)"
        }
    }
    
    // MARK: - WebSocket Connection
    private func connectWebSocket() {
        // Use the correct WebSocket URL format - same as React app
        #if targetEnvironment(simulator)
        // For simulator, allow switching between localhost and external IP
        let wsURL = "ws://209.38.237.102:8667/listen"
        #else
        // For real device, use external IP
        let wsURL = "ws://209.38.237.102:8667/listen"
        #endif
        
        guard let url = URL(string: wsURL) else {
            status = "Invalid WebSocket URL"
            return
        }
        
        print("🔌 Attempting to connect to: \(url)")
//
//        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMjQyMmVhYzktY2I0MS00MjY0LWI0MjUtMmY4MWM4ZTM1ZGIxIiwiZXhwIjoxNzU0MDU5MDExfQ.f8vSzUb6LYbcLwLvuoqmjRei8adeOxlqUhWbtV_9PC0"

        var request = URLRequest(url: url)
        request.timeoutInterval = 120
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create URLSession with custom configuration for better error handling
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120.0
        config.timeoutIntervalForResource = 300.0
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        webSocket = session.webSocketTask(with: request)

        webSocket?.resume()
        // Start receiving messages
        receiveMessage()
        
//        Task {
//            let state = self.webSocket?.state
//            print("🧭 WebSocket state after resume: \(String(describing: state))")
//        }
//
//        status = "Connecting to voice agent..."
        
        
        // Send immediate ping to establish connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.webSocket?.sendPing { error in
                if let error = error {
                    print("Initial ping error: \(error)")
                    DispatchQueue.main.async {
                        self.isConnected = false
                        self.status = "Connection failed: \(error.localizedDescription)"
                    }
                } else {
                    print("✅ Initial ping sent successfully")
                    self.isConnected = true
                    self.status = "Connected to server"
                }
            }
        }
        
        // Set up ping to keep connection alive
        schedulePing()
        
        // Set connection timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            if !self.isConnected {
                self.status = "Connection timeout. Check network or server status."
                print("⚠️ WebSocket connection timeout")
            }
        }
    }
    
    private func schedulePing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.isConnected {
                self.webSocket?.sendPing { error in
                    if let error = error {
                        print("Ping error: \(error)")
                        DispatchQueue.main.async {
                            self.isConnected = false
                            self.status = "Соединение потеряно"
                        }
                    } else {
                        print("✅ Ping sent successfully")
                    }
                }
                // Schedule next ping only if still connected
                if self.isConnected {
                    self.schedulePing()
                }
            }
        }
    }
    
    private func disconnectWebSocket() {
        webSocket?.cancel(with: .normalClosure, reason: nil)
        webSocket = nil
        isConnected = false
        status = "Disconnected from server"
    }
    
    private func receiveMessage() {
        guard let webSocket = webSocket else { return }
        
        print("📡 Waiting for WebSocket message...")
        
        webSocket.receive { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("✅ WebSocket message received successfully!")
                    self.isConnected = true
                    self.status = "Connected to server"
                    
                    switch message {
                    case .data(let data):
                        print("📦 Received data message: \(data.count) bytes")
                        // Handle audio data
                        self.handleAudioData(data)
                    case .string(let text):
                        print("📝 Received text message: \(text)")
                        // Handle text message
                        self.geminiStatus = "Ответ: \(text)"
                    @unknown default:
                        print("❓ Received unknown message type")
                        break
                    }
                    
                    // Continue receiving messages only if still connected
                    if self.isConnected {
                        self.receiveMessage()
                    }
                    
                case .failure(let error):
                    print("❌ WebSocket error: \(error)")
                    print("❌ Error details: \(error.localizedDescription)")
                    print("❌ Error domain: \(error._domain)")
                    print("❌ Error code: \(error._code)")
                    
                    // Check specific error types
                    if let urlError = error as? URLError {
                        print("🌐 URL Error code: \(urlError.code.rawValue)")
                        switch urlError.code {
                        case .cannotConnectToHost:
                            self.status = "Cannot connect to server. Check network."
                        case .timedOut:
                            self.status = "Connection timed out."
                        case .notConnectedToInternet:
                            self.status = "No internet connection."
                        case .networkConnectionLost:
                            self.status = "Network connection lost."
                        case .cannotFindHost:
                            self.status = "Cannot find server host."
                        case .badServerResponse:
                            self.status = "Bad server response."
                        default:
                            self.status = "Connection error: \(urlError.localizedDescription)"
                        }
                    } else {
                        self.status = "Server unavailable. Contact administrator."
                    }
                    
                    self.isConnected = false
                }
            }
        }
    }
    
    // MARK: - Audio Handling
    private func handleAudioData(_ data: Data) {
        geminiStatus = "Playing response..."
        
        // Play the audio response from Gemini
        audioPlayer.playAudio(data: data)
        
        // Update status when audio finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.audioPlayer.isPlaying {
                self.geminiStatus = "Response played"
            }
        }
    }
    
    // MARK: - Recording Control
    private func startRecording() {
        guard isConnected else {
            status = "Connect to server first"
            return
        }
        
        // Request microphone permission
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.startRecordingWithPermission()
                } else {
                    self.status = "Microphone access denied"
                }
            }
        }
    }
    
    private func startRecordingWithPermission() {
        #if targetEnvironment(simulator)
        // Simulate recording for simulator since real audio doesn't work
        isRecording = true
        status = "Simulator: recording (audio not available)"
        geminiStatus = "Audio not available in simulator"
        
        // Simulate recording for 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.stopRecording()
            self.geminiStatus = "Simulator: recording completed"
        }
        #else
        do {
            try audioEngine.start()
            isRecording = true
            status = "Recording started..."
            
            // Start sending audio data
            startAudioCapture()
            
        } catch {
            print("Recording start error: \(error)")
            status = "Recording error: \(error.localizedDescription)"
        }
        #endif
    }
    
    private func stopRecording() {
        #if targetEnvironment(simulator)
        isRecording = false
        status = "Simulator: recording stopped"
        #else
        audioEngine.stop()
        isRecording = false
        status = "Recording stopped"
        geminiStatus = "Processing your message..."
        #endif
    }
    
    private func startAudioCapture() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Convert buffer to data and send via WebSocket
            let audioData = self.convertBufferToData(buffer)
            self.sendAudioData(audioData)
            
            // Update audio level for visualization
            let level = self.calculateAudioLevel(buffer)
            DispatchQueue.main.async {
                self.audioLevel = level
            }
        }
    }
    
//    private func convertBufferToData(_ buffer: AVAudioPCMBuffer) -> Data {
//        guard let channelData = buffer.floatChannelData?[0] else { return Data() }
//        let frameLength = Int(buffer.frameLength)
//        
//        // Convert to Int16 format for WebSocket
//        var int16Data = [Int16](repeating: 0, count: frameLength)
//        for i in 0..<frameLength {
//            let sample = channelData[i]
//            int16Data[i] = Int16(sample * 32767.0)
//        }
//        
//        return Data(bytes: int16Data, count: int16Data.count * MemoryLayout<Int16>.size)
//    }
//
    
    private func convertBufferToData(_ buffer: AVAudioPCMBuffer) -> Data {
        guard let channelData = buffer.floatChannelData?[0] else { return Data() }
        let frameLength = Int(buffer.frameLength)

        var int16Data = [Int16](repeating: 0, count: frameLength)
        for i in 0..<frameLength {
            var sample = channelData[i]
            
            // Clamp between -1.0 and 1.0
            sample = max(-1.0, min(1.0, sample))
            
            // Scale properly based on sign
            int16Data[i] = sample < 0 ? Int16(sample * 32768.0) : Int16(sample * 32767.0)
        }

        return Data(bytes: int16Data, count: int16Data.count * MemoryLayout<Int16>.size)
    }
    private func calculateAudioLevel(_ buffer: AVAudioPCMBuffer) -> CGFloat {
        guard let channelData = buffer.floatChannelData?[0] else { return 0.0 }
        let frameLength = Int(buffer.frameLength)
        
        var sum: Float = 0.0
        for i in 0..<frameLength {
            sum += abs(channelData[i])
        }
        
        let average = sum / Float(frameLength)
        return CGFloat(average * 100) // Scale for visualization
    }
    
    private func sendAudioData(_ data: Data) {
        let message = URLSessionWebSocketTask.Message.data(data)
        webSocket?.send(message) { error in
            if let error = error {
                print("Audio send error: \(error)")
            }
        }
    }
    
    // MARK: - Test Connection
    private func testConnection() {
        print("🧪 Testing WebSocket connection...")
        status = "Testing WebSocket connection..."
        
        // Try alternative connection method with explicit headers
        testAlternativeConnection()
        
        // Set a timeout to show if connection fails
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !self.isConnected {
                self.status = "WebSocket test failed - server not responding"
            }
        }
    }
    
    private func testAlternativeConnection() {
        #if targetEnvironment(simulator)
        let wsURL = useLocalhost ? "ws://209.38.237.102:8667/listen" : "ws://209.38.237.102:8667/listen"
        #else
        let wsURL = "ws://209.38.237.102:8667/listen"
        #endif
        
        guard let url = URL(string: wsURL) else {
            status = "Invalid WebSocket URL"
            return
        }
        
        print("🔌 Testing alternative connection to: \(url)")
        
//        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMjQyMmVhYzktY2I0MS00MjY0LWI0MjUtMmY4MWM4ZTM1ZGIxIiwiZXhwIjoxNzU0MDU5MDExfQ.f8vSzUb6LYbcLwLvuoqmjRei8adeOxlqUhWbtV_9PC0"

        var request = URLRequest(url: url)
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        request.setValue("x3JJHMbDL1EzLkh9GBhXDw==", forHTTPHeaderField: "Sec-WebSocket-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default)
        let testWebSocket = session.webSocketTask(with: request)
        
        testWebSocket.resume()
        
        // Test receive with timeout
        testWebSocket.receive { result in
            DispatchQueue.main.async {
                switch result {
                case .success( _):
                    print("✅ Alternative connection successful!")
                    self.isConnected = true
                    self.status = "Alternative connection successful"
                    self.webSocket = testWebSocket
                    self.receiveMessage()
                case .failure(let error):
                    print("❌ Alternative connection failed: \(error)")
                    self.status = "Alternative connection failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Test HTTP Connection
    private func testHTTPConnection() {
        print("🌐 Testing HTTP connection...")
        status = "Testing HTTP connection..."
        
        #if targetEnvironment(simulator)
        let host = useLocalhost ? "localhost" : "209.38.237.102"
        #else
        let host = "209.38.237.102"
        #endif
        
        let port: UInt16 = 8080
        let testURL = "http://\(host):\(port)/"
        
        guard let url = URL(string: testURL) else {
            status = "Invalid HTTP test URL"
            return
        }
        
        print("🌐 Testing HTTP to: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ HTTP test failed: \(error)")
                    self.status = "HTTP test failed: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ HTTP test successful: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("📄 Response: \(responseString)")
                        self.status = "HTTP OK: \(httpResponse.statusCode) - \(responseString)"
                    } else {
                        self.status = "HTTP OK: \(httpResponse.statusCode)"
                    }
                } else {
                    self.status = "HTTP test completed"
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Supporting Views
}

// MARK: - Supporting Views
struct AmorphousBlob: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2
        
        // Create amorphous blob with curved edges
        path.move(to: CGPoint(x: centerX - width * 0.4, y: centerY - height * 0.3))
        
        // Top curve
        path.addCurve(
            to: CGPoint(x: centerX + width * 0.4, y: centerY - height * 0.3),
            control1: CGPoint(x: centerX - width * 0.2, y: centerY - height * 0.5),
            control2: CGPoint(x: centerX + width * 0.2, y: centerY - height * 0.5)
        )
        
        // Right curve
        path.addCurve(
            to: CGPoint(x: centerX + width * 0.3, y: centerY + height * 0.4),
            control1: CGPoint(x: centerX + width * 0.6, y: centerY - height * 0.1),
            control2: CGPoint(x: centerX + width * 0.6, y: centerY + height * 0.2)
        )
        
        // Bottom curve
        path.addCurve(
            to: CGPoint(x: centerX - width * 0.3, y: centerY + height * 0.4),
            control1: CGPoint(x: centerX + width * 0.1, y: centerY + height * 0.6),
            control2: CGPoint(x: centerX - width * 0.1, y: centerY + height * 0.6)
        )
        
        // Left curve
        path.addCurve(
            to: CGPoint(x: centerX - width * 0.4, y: centerY - height * 0.3),
            control1: CGPoint(x: centerX - width * 0.6, y: centerY + height * 0.2),
            control2: CGPoint(x: centerX - width * 0.6, y: centerY - height * 0.1)
        )
        
        path.closeSubpath()
        return path
    }
}

struct WavyLinesPattern: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create multiple wavy lines
        for i in 0..<5 {
            let y = height * 0.2 + CGFloat(i) * height * 0.15
            let amplitude = 10.0
            let frequency = 0.02
            
            path.move(to: CGPoint(x: 0, y: y))
            
            for x in stride(from: 0, to: width, by: 2) {
                let waveY = y + sin(x * frequency) * amplitude
                path.addLine(to: CGPoint(x: x, y: waveY))
            }
        }
        
        return path
    }
}

struct SoftStatusCard: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with soft background
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.purple)
                
                Text(status)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct SoftButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.8))
                    .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DarkStatusCard: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        SoftStatusCard(
            title: title,
            status: status,
            icon: icon,
            color: color
        )
    }
}

struct DarkButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        SoftButton(
            title: title,
            icon: icon,
            color: color,
            action: action
        )
    }
}

struct ChatGPTButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        SoftButton(
            title: title,
            icon: icon,
            color: color,
            action: action
        )
    }
}

struct StatusCard: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        SoftStatusCard(
            title: title,
            status: status,
            icon: icon,
            color: color
        )
    }
}

#Preview {
    NavigationView {
        VoiceAgentView()
    }
}


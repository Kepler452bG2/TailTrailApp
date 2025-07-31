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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FED3A4"),
                    Color(hex: "FFE4B5")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image("made")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200)
                    
                    Text("Voice Assistant")
                        .font(.custom("Poppins-Bold", size: 28))
                        .foregroundColor(.black)
                    
                    Text("Ask questions about pet search")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Status cards
                VStack(spacing: 20) {
                                        // Connection status
                    StatusCard(
                        title: "Connection Status",
                        status: isConnected ? "Connected" : "Disconnected",
                        icon: isConnected ? "wifi" : "wifi.slash",
                        color: isConnected ? .green : .red
                    )
                    
                    // Recording status
                    StatusCard(
                        title: "Recording",
                        status: isRecording ? "Recording..." : "Waiting",
                        icon: isRecording ? "mic.fill" : "mic",
                        color: isRecording ? .red : .gray
                    )
                    
                    // Gemini response status
                    StatusCard(
                        title: "Assistant Response",
                        status: geminiStatus,
                        icon: "brain.head.profile",
                        color: .blue
                    )
                
                // Audio playback controls
                if audioPlayer.isPlaying {
                    HStack(spacing: 20) {
                        Button(action: {
                            audioPlayer.pauseAudio()
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            audioPlayer.stopAudio()
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.top, 10)
                }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Voice visualization
                if isRecording {
                    VoiceVisualizer(audioLevel: audioLevel)
                        .frame(height: 100)
                        .padding(.horizontal, 40)
                }
                
                // Main action button
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    ZStack {
                        // Pulsing animation for recording state
                        if isRecording {
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 4)
                                .frame(width: 140, height: 140)
                                .scaleEffect(isRecording ? 1.3 : 1.0)
                                .opacity(isRecording ? 0.0 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: false),
                                    value: isRecording
                                )
                        }
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8),
                                        isRecording ? Color.red : Color.blue
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
                
                Text(isRecording ? "Tap to stop" : "Tap to start recording")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.top, 10)
                
                // Connection status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(isConnected ? "Connected" : "Disconnected")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
                .padding(.top, 5)
                
                // Current URL info
                #if targetEnvironment(simulator)
                Text(useLocalhost ? "localhost:8080" : "209.38.237.102:8080")
                    .font(.custom("Poppins-Regular", size: 10))
                    .foregroundColor(.black.opacity(0.5))
                    .padding(.top, 2)
                #endif
                
                // Test button for simulator
                #if targetEnvironment(simulator)
                Button(action: {
                    geminiStatus = "Test response from assistant"
                }) {
                    Text("Test Response")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.top, 10)
                #endif
                
                // Manual reconnect button
                if !isConnected {
                    Button(action: {
                        connectWebSocket()
                    }) {
                        Text("Reconnect")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                    .padding(.top, 10)
                }
                
                // Test connection button
                Button(action: {
                    testConnection()
                }) {
                    Text("Test WebSocket")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(20)
                }
                .padding(.top, 10)
                
                // Test HTTP connection button
                Button(action: {
                    testHTTPConnection()
                }) {
                    Text("Test HTTP")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.teal)
                        .cornerRadius(20)
                }
                .padding(.top, 5)
                
                // Check server port button
                Button(action: {
                    checkServerPort()
                }) {
                    Text("Check Server Health")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.purple)
                        .cornerRadius(20)
                }
                .padding(.top, 5)
                
                // Localhost toggle for simulator
                #if targetEnvironment(simulator)
                HStack {
                    Text("Use Localhost:")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Toggle("", isOn: $useLocalhost)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .scaleEffect(0.8)
                        .onChange(of: useLocalhost) { _, _ in
                            // Disconnect and reconnect with new URL
                            disconnectWebSocket()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                connectWebSocket()
                            }
                        }
                }
                .padding(.top, 5)
                #endif
                
                Spacer()
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
        let wsURL = useLocalhost ? "ws://localhost:8080/ws/test" : "ws://209.38.237.102:8080/ws/test"
        #else
        // For real device, use external IP
        let wsURL = "ws://209.38.237.102:8080/ws/test"
        #endif
        
        guard let url = URL(string: wsURL) else {
            status = "Invalid WebSocket URL"
            return
        }
        
        print("🔌 Attempting to connect to: \(url)")
        
        // Create URLSession with custom configuration for better error handling
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        webSocket = session.webSocketTask(with: url)
        
        webSocket?.resume()
        status = "Connecting to voice agent..."
        
        // Start receiving messages
        receiveMessage()
        
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
        audioPlayer.playAudio(from: data)
        
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
    
    private func convertBufferToData(_ buffer: AVAudioPCMBuffer) -> Data {
        guard let channelData = buffer.floatChannelData?[0] else { return Data() }
        let frameLength = Int(buffer.frameLength)
        
        // Convert to Int16 format for WebSocket
        var int16Data = [Int16](repeating: 0, count: frameLength)
        for i in 0..<frameLength {
            let sample = channelData[i]
            int16Data[i] = Int16(sample * 32767.0)
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
        let wsURL = useLocalhost ? "ws://localhost:8080/ws/test" : "ws://209.38.237.102:8080/ws/test"
        #else
        let wsURL = "ws://209.38.237.102:8080/ws/test"
        #endif
        
        guard let url = URL(string: wsURL) else {
            status = "Invalid WebSocket URL"
            return
        }
        
        print("🔌 Testing alternative connection to: \(url)")
        
        var request = URLRequest(url: url)
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("13", forHTTPHeaderField: "Sec-WebSocket-Version")
        request.setValue("x3JJHMbDL1EzLkh9GBhXDw==", forHTTPHeaderField: "Sec-WebSocket-Key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default)
        let testWebSocket = session.webSocketTask(with: request)
        
        testWebSocket.resume()
        
        // Test receive with timeout
        testWebSocket.receive { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let _):
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
    
    // MARK: - Check Server Port
    private func checkServerPort() {
        print("🔍 Checking server health...")
        status = "Checking server health..."
        
        #if targetEnvironment(simulator)
        let host = useLocalhost ? "localhost" : "209.38.237.102"
        #else
        let host = "209.38.237.102"
        #endif
        
        let port: UInt16 = 8080
        
        // Try health check endpoint first
        let healthURL = "http://\(host):\(port)/health"
        guard let url = URL(string: healthURL) else {
            status = "Invalid health check URL"
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Health check failed: \(error)")
                    self.status = "Health check failed: \(error.localizedDescription)"
                    
                    // Fallback to simple port check
                    self.fallbackPortCheck(host: host, port: port)
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("Health check response: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        self.status = "✅ Server is healthy and running"
                    } else {
                        self.status = "⚠️ Server responded with status \(httpResponse.statusCode)"
                    }
                } else {
                    self.status = "Health check completed"
                }
            }
        }
        task.resume()
    }
    
    private func fallbackPortCheck(host: String, port: UInt16) {
        print("🔍 Fallback: checking port \(port)...")
        
        let task = URLSession.shared.dataTask(with: URL(string: "http://\(host):\(port)")!) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Port check failed: \(error)")
                    self.status = "Port \(port) not accessible: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("Port check response: \(httpResponse.statusCode)")
                    self.status = "Port \(port) is open (HTTP \(httpResponse.statusCode))"
                } else {
                    self.status = "Port \(port) check completed"
                }
            }
        }
        task.resume()
    }
}

// MARK: - Supporting Views
struct StatusCard: View {
    let title: String
    let status: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.black.opacity(0.8))
                
                Text(status)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.black.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(15)
        .background(Color.white.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

struct VoiceVisualizer: View {
    let audioLevel: CGFloat
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 4, height: max(4, audioLevel * CGFloat.random(in: 0.5...1.5)))
                    .animation(.easeInOut(duration: 0.1), value: audioLevel)
            }
        }
    }
}

#Preview {
    NavigationView {
        VoiceAgentView()
    }
} 
import Foundation
import AVFoundation

class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    
    let sampleRate: Double = 24000
    
    func playAudio(data: Data) {
        // Step 1: Convert to Int16 array
        let int16Count = data.count / MemoryLayout<Int16>.size
        guard int16Count > 0 else {
            print("❌ PCM data empty")
            return
        }

        let int16Array = data.withUnsafeBytes { ptr -> [Int16] in
            Array(ptr.bindMemory(to: Int16.self))
        }

        // Logging PCM stats
        let minPcm = int16Array.min() ?? 0
        let maxPcm = int16Array.max() ?? 0
        let avgPcm = int16Array.reduce(0.0) { $0 + Double($1) } / Double(int16Array.count)
        print("[PCM16] samples=\(int16Array.count), min=\(minPcm), max=\(maxPcm), avg=\(String(format: "%.2f", avgPcm))")

        // Step 2: Convert Int16 → Float32 (-1.0 to 1.0)
        let float32Array = int16Array.map { Float($0) / 32768.0 }

        let minF32 = float32Array.min() ?? 0
        let maxF32 = float32Array.max() ?? 0
        let avgF32 = float32Array.reduce(0.0, +) / Float(float32Array.count)
        let nonZeroCount = float32Array.filter { abs($0) > 0.0001 }.count
        print("[F32] samples=\(float32Array.count), min=\(String(format: "%.4f", minF32)), max=\(String(format: "%.4f", maxF32)), avg=\(String(format: "%.4f", avgF32)), nonZero=\(nonZeroCount)")
//asdasdasd
        if nonZeroCount < float32Array.count / 100 {
            print("⚠️ [F32] Data very quiet")
        }

        // Step 3: Setup AVAudioEngine and buffer
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(float32Array.count)) else {
            print("❌ Failed to allocate AVAudioPCMBuffer")
            return
        }

        buffer.frameLength = AVAudioFrameCount(float32Array.count)
        let channelData = buffer.floatChannelData![0]
        for i in 0..<float32Array.count {
            channelData[i] = float32Array[i]
        }

        // Step 4: Play
        do {
            try engine.start()
            print("🔊 Starting playback...")
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: {
                print("✅ Playback completed")
                engine.stop()
            })
        } catch {
            print("❌ Engine start error: \(error)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
} 

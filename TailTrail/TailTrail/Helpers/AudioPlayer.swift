import Foundation
import AVFoundation

class AudioPlayer: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ошибка настройки аудио сессии: \(error)")
        }
    }
    
    func playAudio(from data: Data) {
        do {
            // Stop any currently playing audio
            stopAudio()
            
            // Create audio player from data
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // Play the audio
            if audioPlayer?.play() == true {
                isPlaying = true
                print("🎵 Воспроизведение аудио началось")
            } else {
                print("❌ Не удалось начать воспроизведение")
            }
        } catch {
            print("Ошибка воспроизведения аудио: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        print("🛑 Воспроизведение остановлено")
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        isPlaying = false
        print("⏸️ Воспроизведение приостановлено")
    }
    
    func resumeAudio() {
        audioPlayer?.play()
        isPlaying = true
        print("▶️ Воспроизведение возобновлено")
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            print("✅ Воспроизведение завершено")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            print("❌ Ошибка декодирования аудио: \(error?.localizedDescription ?? "Неизвестная ошибка")")
        }
    }
} 
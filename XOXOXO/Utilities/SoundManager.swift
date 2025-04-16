import AVFoundation
import SwiftUI

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // Статус да ли су звукови и хаптика укључени
    var isSoundEnabled = true
    var isHapticEnabled = true
    
    private init() {
        // Приватни иницијализатор за синглтон
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        hapticFeedback.prepare()
    }
    
    // Учитавање звука из бандла по имену
    private func getAudioPlayer(for soundName: String, withExtension ext: String = "mp3") -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Unable to find sound file: \(soundName).\(ext)")
            
            // Креирамо програмски генерисан звук 
            return generateProgrammaticSound(for: soundName)
        }
        
        // Проверавамо да ли већ имамо учитан плејер за овај звук
        if let player = audioPlayers[url] {
            return player
        }
        
        // Креирамо нови плејер
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            audioPlayers[url] = player
            return player
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
            return generateProgrammaticSound(for: soundName)
        }
    }
    
    // Програмско генерисање звукова
    private func generateProgrammaticSound(for soundName: String) -> AVAudioPlayer? {
        let sampleRate = 44100.0 // стандардни sample rate
        
        // Креирамо звук у зависности од типа
        var soundData: Data?
        switch soundName {
        case "tap":
            soundData = generateClickSound(duration: 0.1, sampleRate: sampleRate)
        case "move":
            soundData = generatePopSound(duration: 0.15, sampleRate: sampleRate)
        case "win":
            soundData = generateWinSound(duration: 0.8, sampleRate: sampleRate)
        case "lose":
            soundData = generateLoseSound(duration: 0.6, sampleRate: sampleRate)
        case "draw":
            soundData = generateDrawSound(duration: 0.5, sampleRate: sampleRate)
        case "error":
            soundData = generateErrorSound(duration: 0.2, sampleRate: sampleRate)
        default:
            soundData = generateClickSound(duration: 0.1, sampleRate: sampleRate)
        }
        
        guard let data = soundData else { return nil }
        
        do {
            let player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            return player
        } catch {
            print("Error creating programmatic sound: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Различите функције за генерисање звукова
    private func generateClickSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.5
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * (1.0 - progress)
            let frequency: Float = 800 + 1200 * progress
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    private func generatePopSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.6
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * (1.0 - progress * progress)
            let frequency: Float = 600 + 1000 * (1.0 - progress)
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    private func generateWinSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.7
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * sin(Float.pi * progress)
            let frequency: Float = 400 + 800 * progress
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    private func generateLoseSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.6
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * (1.0 - progress)
            let frequency: Float = 500 - 400 * progress
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    private func generateDrawSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.5
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * (0.5 - 0.5 * cos(Float.pi * progress))
            let frequency: Float = 300 + 200 * sin(3.0 * Float.pi * progress)
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    private func generateErrorSound(duration: Double, sampleRate: Double) -> Data {
        let frameCount = Int(duration * sampleRate)
        let data = NSMutableData()
        let volume: Float = 0.5
        
        for i in 0..<frameCount {
            let progress = Float(i) / Float(frameCount)
            let amplitude = volume * (1.0 - progress)
            let frequency: Float = 200 + 500 * sin(10.0 * Float.pi * progress)
            
            let sample = sin(2.0 * Float.pi * frequency * Float(i) / Float(sampleRate)) * amplitude
            var intSample = Int16(sample * 32767)
            data.append(&intSample, length: 2)
        }
        
        return data as Data
    }
    
    // Прелодовање звука - позива се током стартапа апликације
    func preloadSound(_ sound: GameSound) {
        _ = getAudioPlayer(for: sound.rawValue)
    }
    
    // Пуштање звука по имену
    func playSound(_ sound: GameSound) {
        guard isSoundEnabled else { return }
        
        if let player = getAudioPlayer(for: sound.rawValue) {
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        }
    }
    
    // Пуштање хаптичке повратне информације
    func playHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // Тежа вибрација за важне догађаје
    func playHeavyHaptic() {
        guard isHapticEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // Лагана вибрација за суптилне интеракције
    func playLightHaptic() {
        guard isHapticEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// Енумерација са свим звуковима у игри
enum GameSound: String, CaseIterable {
    case tap = "tap"
    case win = "win"
    case lose = "lose"
    case draw = "draw"
    case move = "move"
    case error = "error"
} 
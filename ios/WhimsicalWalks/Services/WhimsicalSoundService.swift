import AVFoundation

@Observable
@MainActor
class WhimsicalSoundService {
    private var audioPlayer: AVAudioPlayer?
    private var tonePlayer: AVTonePlayer?

    func playOpenChime() {
        tonePlayer = AVTonePlayer()
        tonePlayer?.playWhimsicalChime()
    }
}

class AVTonePlayer: @unchecked Sendable {
    private var engine: AVAudioEngine?
    private var mixer: AVAudioMixerNode?

    func playWhimsicalChime() {
        let engine = AVAudioEngine()
        self.engine = engine

        let mainMixer = engine.mainMixerNode
        let sampleRate = mainMixer.outputFormat(forBus: 0).sampleRate
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        let notes: [(frequency: Double, delay: Double, duration: Double, volume: Float)] = [
            (783.99, 0.0, 0.4, 0.25),
            (1046.50, 0.12, 0.35, 0.20),
            (1318.51, 0.28, 0.5, 0.18),
        ]

        var allNodes: [AVAudioPlayerNode] = []

        for note in notes {
            let playerNode = AVAudioPlayerNode()
            engine.attach(playerNode)
            engine.connect(playerNode, to: mainMixer, format: format)
            allNodes.append(playerNode)

            let totalSamples = Int(note.duration * sampleRate)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples)) else { continue }
            buffer.frameLength = AVAudioFrameCount(totalSamples)

            let data = buffer.floatChannelData![0]
            for i in 0..<totalSamples {
                let t = Double(i) / sampleRate
                let envelope = Float(exp(-t * 5.0))
                let wave = Float(sin(2.0 * Double.pi * note.frequency * t))
                let harmonic = Float(sin(2.0 * Double.pi * note.frequency * 2.0 * t)) * 0.15
                data[i] = (wave + harmonic) * envelope * note.volume
            }

            let delaySamples = AVAudioFramePosition(note.delay * sampleRate)
            let startTime = AVAudioTime(sampleTime: delaySamples, atRate: sampleRate)

            playerNode.scheduleBuffer(buffer, at: startTime, options: [], completionHandler: nil)
        }

        do {
            try engine.start()
            for node in allNodes {
                node.play()
            }

            let totalDuration = (notes.last?.delay ?? 0) + (notes.last?.duration ?? 0) + 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
                for node in allNodes {
                    node.stop()
                }
                engine.stop()
                self?.engine = nil
            }
        } catch {
            self.engine = nil
        }
    }
}

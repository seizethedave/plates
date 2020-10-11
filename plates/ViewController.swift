//
//  ViewController.swift
//  plates
//
//  Created by David Grant on 10/9/20.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func plateAdded(_ sender: UITextField) {
        print(sender.text!)
        sender.text = ""
    }
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var audioInited = false
    
    func initAudioStuff() {
        if self.audioInited {
            return
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
        {
            buffer, _ in self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        self.audioInited = true
    }
    
    func recordAndRecognizeSpeech() {
        self.initAudioStuff()
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }

        self.recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in

            if let result = result {
                print(result.isFinal)
                let tokens = tokenize(result.bestTranscription.formattedString)
                
                if tokens.isEmpty {
                    return
                }
                
                switch (tokens.last!.type) {
                case TokenType.MetaNext:
                    print(tokens)
                    print("(next)")
                    self.recognitionTask?.finish()
                    break
                case TokenType.MetaDone:
                    print(tokens)
                    print("(done)")
                    self.recognitionTask?.finish()
                    break
                default:
                    break
                }
                
            } else if let error = error {
                print("error:", error)
            }
        })
    }

    @IBAction func speakTouched(_ sender: UIButton) {
        recordAndRecognizeSpeech()
    }
}

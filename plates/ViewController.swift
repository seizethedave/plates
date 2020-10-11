//
//  ViewController.swift
//  plates
//
//  Created by David Grant on 10/9/20.
//

import UIKit
import Speech

enum ViewState {
    case NotListening
    case Listening
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func plateAdded(_ sender: UITextField) {
        print(sender.text!)
        sender.text = ""
    }
    
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var speakButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    var request : SFSpeechAudioBufferRecognitionRequest? = nil
    var recognitionTask: SFSpeechRecognitionTask?
    var audioInited = false
    
    var viewState = ViewState.NotListening {
        didSet {
            if (self.viewState == oldValue) {
                return
            }
            DispatchQueue.main.async {
                switch self.viewState {
                case ViewState.Listening:
                    self.speakButton.isSelected = true
                    self.recordAndRecognizeSpeech()
                    break
                case ViewState.NotListening:
                    self.speakButton.isSelected = false
                    self.stopListening()
                    break
                }
            }
        }
    }
    
    func initAudioStuff() {
        if self.audioInited {
            return
        }
        self.audioInited = true
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat)
        {
            buffer, _ in
            if let req = self.request {
                req.append(buffer)
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
    }
    
    func displayTokens(_ tokens: [Token]) {
        assert(tokens.last!.type == TokenType.MetaDone || tokens.last!.type == TokenType.MetaNext)
        
        guard let plateToken = tokens.first(where: { $0.type == TokenType.PlateNumber }) else {
            print("malformed tokens", tokens)
            return
        }
        
        plateLabel.text = plateToken.value
    }
    
    func gotTaskResult(_ result: SFSpeechRecognitionResult?, _ error: Error?) {
        
        if let result = result {
            print(result.isFinal)
            let tokens = tokenize(result.bestTranscription.formattedString)
            
            if tokens.isEmpty {
                return
            }
            
            switch (tokens.last!.type) {
            case TokenType.MetaNext:
                displayTokens(tokens)
                self.viewState = ViewState.NotListening
                self.viewState = ViewState.Listening
                break
            case TokenType.MetaDone:
                displayTokens(tokens)
                self.viewState = ViewState.NotListening
                break
            default:
                break
            }
        } else if let error = error {
            print("error:", error)
        }
    }
    
    func recordAndRecognizeSpeech() {
        self.initAudioStuff()
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        
        self.request = SFSpeechAudioBufferRecognitionRequest()

        self.recognitionTask = myRecognizer.recognitionTask(with: self.request!, resultHandler: self.gotTaskResult)
    }
    
    func stopListening() {
        self.recognitionTask?.finish()
    }

    @IBAction func speakTouched(_ sender: UIButton) {
        self.viewState = self.viewState == ViewState.Listening ? ViewState.NotListening : ViewState.Listening
    }
}

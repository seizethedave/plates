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
    case FinishingListen
}

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var plateLabel: UILabel!
    @IBOutlet weak var speakButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    var request : SFSpeechAudioBufferRecognitionRequest? = nil
    var recognitionTask: SFSpeechRecognitionTask?
    var audioInited = false
    
    let synth = AVSpeechSynthesizer()
    
    var commandBuf = [PlateCommand]()
    var listenTimer : Timer?
    var willRecordAgain = false
    
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
                case ViewState.NotListening:
                    self.speakButton.isSelected = false
                    self.stopListening()
                case ViewState.FinishingListen:
                    self.listenTimer = Timer.scheduledTimer(
                        timeInterval: 0.1, target: self, selector: #selector(self.timerFired), userInfo:nil, repeats: false)
                }
            }
        }
    }
    
    @objc
    func timerFired() {
        print("TIMER FIRED")
        print(self.commandBuf)
        let cmds = self.commandBuf
        
        if let c = self.chooseBestCommand(cmds) {
            let plate = c.plate!.plateNumber
            print("BEST:", plate)
            
            let speechUtterance = AVSpeechUtterance(string: c.plate!.speakableString())
            speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 1.5
            speechUtterance.voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
            self.synth.speak(speechUtterance)
            
        } else {
            print("NO BEST")
        }
        
        self.commandBuf = []
        self.listenTimer?.invalidate()
        
        if self.willRecordAgain {
            self.viewState = ViewState.Listening
        } else {
            self.viewState = ViewState.NotListening
        }
    }
    
    func chooseBestCommand(_ commands: [PlateCommand]) -> PlateCommand? {
        commands.max { a, b in
            a.plate!.plateNumber.count < b.plate!.plateNumber.count
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
    
    func addCommand(_ command: PlateCommand) {
        if command.isComplete() {
            self.commandBuf.append(command)
        }
    }

    func gotTaskResult(_ result: SFSpeechRecognitionResult?, _ error: Error?) {
        if let result = result {
            let tokens = tokenize(result.bestTranscription.formattedString)
            let command = parseCommand(tokens)

            addCommand(command)
            plateLabel.text = command.plate?.plateNumber

            switch command.terminator {
            case CommandTerminator.Incomplete:
                break
                
            case CommandTerminator.Discard:
                plateLabel.text = "-"
                self.commandBuf = []
                self.willRecordAgain = true
                self.viewState = ViewState.NotListening
                self.viewState = ViewState.Listening

            case CommandTerminator.Next:
                self.willRecordAgain = true
                self.viewState = ViewState.FinishingListen
                
            case CommandTerminator.Done:
                self.willRecordAgain = false
                self.viewState = ViewState.FinishingListen
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

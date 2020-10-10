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
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        //guard let node = audioEngine.inputNode else {return}
        
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
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in

            if let result = result {
                print(self.translate(input: result.bestTranscription.formattedString))
                
            } else if let error = error {
                print("error:", error)
            }
        })
    }

    func translate(input: String) -> String {
        let nato = [
            "alpha": "a",
            "beta": "b",
            "charlie": "c",
            "delta": "d",
            "echo": "e",
            "foxtrot": "f",
        ]
        let numeric = [
            "one": "1",
            "two": "2",
            "three": "3",
        ]
        var output = ""

        for atom in input.lowercased().split(separator: " ") {
            if let char = nato[String(atom)] {
                output += char
            } else if let char = numeric[String(atom)] {
                output += char
            } else {
                // "128" or "1"
                for c in atom {
                    if c.isNumber {
                        output += String(c)
                    }
                }
            }
        }

        return output
    }

    @IBAction func speakTouched(_ sender: UIButton) {
        recordAndRecognizeSpeech()
    }
}

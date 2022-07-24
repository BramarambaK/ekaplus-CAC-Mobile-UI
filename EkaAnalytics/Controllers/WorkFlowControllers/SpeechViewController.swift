//
//  SpeechViewController.swift
//  Pre-Trade
//
//  Reference : https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio
//  Created by Shreeram on 14/02/19.
//  Copyright © 2019 GWL. All rights reserved.
//

import UIKit
import Speech

protocol MLdelegate {
    func MLProcessText(enteredText:String?)
}

class SpeechViewController: UIViewController,SFSpeechRecognizerDelegate {
    
    //MARK: - Variable
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: Locale.preferredLanguages[0]))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var delegate:MLdelegate?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lbtn_Microphone: UIButton!
    
    @IBOutlet weak var ltxf_TextView: UITextView!
    
    @IBOutlet weak var lbtn_Proceed: UIButton!
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the record buttons until authorization has been granted.
        lbtn_Microphone.isEnabled = false
        
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(doneButtonAction))
        
        
        toolbarDone.items = [spaceButton,barBtnDone] // You can even add cancel button too
        ltxf_TextView.inputAccessoryView = toolbarDone
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer!.delegate = self
        
        // Make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.lbtn_Microphone.isEnabled = true
                    
                case .denied:
                    self.lbtn_Microphone.isEnabled = false
                    self.lbtn_Microphone.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.lbtn_Microphone.isEnabled = false
                    self.lbtn_Microphone.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.lbtn_Microphone.isEnabled = false
                    self.lbtn_Microphone.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    @objc func doneButtonAction()
    {
        ltxf_TextView.resignFirstResponder()
    }
    
    
    //MARK: - IBAction
    
    
    @IBAction func process_Tapped(_ sender: Any) {
        self.delegate?.MLProcessText(enteredText: ltxf_TextView.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearbtn_Tapped(_ sender: Any) {
        self.ltxf_TextView.text = ""
    }
    
    
    @IBAction func skipbtn_Tapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Microphone_Tapped(_ sender: Any) {
        
        let recordButton:UIButton = sender as! UIButton
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            if ltxf_TextView.text == "What contract you want to create." {
                ltxf_TextView.text = ""
            }
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                ltxf_TextView.text = ""
                try startRecording()
                recordButton.setTitle("Stop Recording", for: [])
            } catch {
                recordButton.setTitle("Recording Not Available", for: [])
            }
        }
        
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.ltxf_TextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.lbtn_Microphone.isEnabled = true
                self.lbtn_Microphone.setTitle("Start Recording", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        ltxf_TextView.text = "What contract you want to create."
    }
    
    // MARK:- SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            lbtn_Microphone.isEnabled = true
            lbtn_Microphone.setTitle("Start Recording", for: [])
        } else {
            lbtn_Microphone.isEnabled = false
            lbtn_Microphone.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
}

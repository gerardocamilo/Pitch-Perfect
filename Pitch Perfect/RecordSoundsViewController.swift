//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Gerardo Camilo on 1/28/17.
//  Copyright © 2017 ___GRCS___. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Properties
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    
    override func viewWillAppear(_ animated: Bool) {
        //Disabling Stop Recording button at the beginning
        stopRecordingButton.isEnabled = false
    }

    /**
     Starts recording audio using the device's microphone.
     Does the necessary changes to the UI to reflect we're recording.
    */
    @IBAction func recordAudio(_ sender: Any) {
        recordingLabel.text = "Recording in progress"
        startRecordingButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        
        //Getting directory where the recorded audio file is going to be written
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        
        //Combining directory and filename to form a complete URL
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        //Getting audio session that provides access to the hardware
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        //Setting up audio recorder and starting the actual recording
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        recordingLabel.text = "Tap to record"
        startRecordingButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        
        if audioRecorder.isRecording {
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setActive(false)
        }
    }
    
    /**
     This function is called when the audio recording and file saving processes are finished.
    */
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        //If everything went well, we transition to our audio player view using performSegue() with identifier
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("File recording or saving failed")
        }
    }
    
    /**
     This function sets up some values before leaving this ViewController bases on what segue triggered this action.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioUrl = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioUrl
        }
    }
}

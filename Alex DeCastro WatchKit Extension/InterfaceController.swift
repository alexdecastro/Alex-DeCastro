//
//  InterfaceController.swift
//  Alex DeCastro WatchKit Extension
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var wordsLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        statusLabel.setText("Open the app on your iPhone to display a list of words.");
        
        wordsLabel.setText("After you see the list of words, then record your answer.");
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func startButtonPressed() {
        print("DEBUG:WK: InterfaceController: startButtonPressed:")

        let defaults = NSUserDefaults(suiteName: "group.com.alexdecastro.wordgame.v01")
        defaults?.synchronize()
        let appState = defaults!.stringForKey("kAppState")!
        if appState == "02-Record-Answer" {
            getVoiceInput()
        } else {
            statusLabel.setText("ERROR: Open the iPhone app to display a list of words.")
        }
    }
    
    func getVoiceInput() {
        print("DEBUG:WK: InterfaceController: getVoiceInput:")
        
        let suggestions = [ "robin yellow beer candy", "cow apple oak shirt" ];
        
        presentTextInputControllerWithSuggestions(suggestions, allowedInputMode: .Plain, completion: { (selectedAnswers) -> Void in

            if let spokenReply = selectedAnswers![0] as? String {
                print("DEBUG:WK: InterfaceController: getVoiceInput: \(spokenReply)")
                self.wordsLabel.setText(spokenReply)
                let inputSentence = spokenReply.lowercaseString
                self.checkAnswer(inputSentence)
            }
        })
        
    }
    
    func checkAnswer(inputSentence: String) {
        print("DEBUG:WK: InterfaceController: checkAnswer: \(inputSentence)")
        
        let sendDictionary = [
            "kMessageType" : "CheckAnswer",
            "kWordList" : inputSentence
        ]
        
        let tempWordList = sendDictionary["kWordList"]
        
        print("DEBUG:WK: InterfaceController: checkAnswer: sendDictionary: \(tempWordList)")
        
        WKInterfaceController.openParentApplication(sendDictionary,
            reply: {(reply, error) -> Void in
                print("DEBUG:WK: InterfaceController: checkAnswer: openParentApplication:")
        })
    }
}

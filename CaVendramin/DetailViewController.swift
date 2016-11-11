//
//  DetailViewController.swift
//  Wallpapers
//
/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore
import AVFoundation

class DetailViewController: UIViewController,AVSpeechSynthesizerDelegate {
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var pvSpeechProgress: UIProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var play: UIButton!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet weak var textScroll: UITextView!
    
    var totalUtterances: Int! = 0
    var currentUtterance: Int! = 0
    var totalTextLength: Int = 0
    var spokenTextLengths: Int = 0
    var previousSelectedRange: NSRange!
    var paper: Paper?
  
    override func viewDidLoad() {
        speechSynthesizer.delegate = self
        play.setBackgroundImage(#imageLiteral(resourceName: "play"), for: UIControlState.normal)
        stopButton.setBackgroundImage(#imageLiteral(resourceName: "stop"), for: UIControlState.normal)
        pauseButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: UIControlState.normal)
    }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let paper = paper {
      navigationItem.title = paper.caption
      imageView.image = UIImage(named: paper.imageName)
        textScroll.text = paper.text
    }
  }
    
    @IBAction func readText(_ sender: Any) {
        print("reading...")
        
        if !speechSynthesizer.isSpeaking {
             let textParagraphs = textScroll.text.components(separatedBy: "\n")
            totalUtterances = textParagraphs.count
            currentUtterance = 0
            totalTextLength = 0
            spokenTextLengths = 0
            for pieceOfText in textParagraphs {
                let speechUtterance = AVSpeechUtterance(string: pieceOfText)
                speechUtterance.postUtteranceDelay = 0.005
                totalTextLength = totalTextLength + pieceOfText.utf16.count
                speechSynthesizer.speak(speechUtterance)
            }
        }
        else{
            speechSynthesizer.continueSpeaking()
        }
        
        animateActionButtonAppearance(shouldHideSpeakButton: true)
    }
    @IBAction func stop(_ sender: Any) {
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        animateActionButtonAppearance(shouldHideSpeakButton: false)
    }
  
    @IBAction func pause(_ sender: Any) {
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
        animateActionButtonAppearance(shouldHideSpeakButton: false)
    }
    
    
    func animateActionButtonAppearance(shouldHideSpeakButton: Bool) {
        var speakButtonAlphaValue: CGFloat = 1.0
        var pauseStopButtonsAlphaValue: CGFloat = 0.0
        
        if shouldHideSpeakButton {
            speakButtonAlphaValue = 0.0
            pauseStopButtonsAlphaValue = 1.0
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.play.alpha = speakButtonAlphaValue
            
            self.stopButton.alpha = pauseStopButtonsAlphaValue
            
            self.pauseButton.alpha = pauseStopButtonsAlphaValue
        })
    }
    func unselectLastWord() {
        if let selectedRange = previousSelectedRange {
            // Get the attributes of the last selected attributed word.
            let currentAttributes = textScroll.attributedText.attributes(at: selectedRange.location, effectiveRange: nil)
            // Keep the font attribute.
            let fontAttribute: AnyObject? = currentAttributes[NSFontAttributeName] as AnyObject?
            
            // Create a new mutable attributed string using the last selected word.
            let attributedWord = NSMutableAttributedString(string: textScroll.attributedText.attributedSubstring(from: selectedRange).string)
            
            // Set the previous font attribute, and make the foreground color black.
            attributedWord.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, attributedWord.length))
            attributedWord.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, attributedWord.length))
            
            // Update the text storage property and replace the last selected word with the new attributed string.
            textScroll.textStorage.beginEditing()
            textScroll.textStorage.replaceCharacters(in: selectedRange, with: attributedWord)
            textScroll.textStorage.endEditing()
        }
    }
    
    // MARK: AVSpeechSynthesizerDelegate method implementation
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer!, didFinish utterance: AVSpeechUtterance!) {
        spokenTextLengths = spokenTextLengths + utterance.speechString.utf16.count + 1
        
        let progress: Float = Float(spokenTextLengths * 100 / totalTextLength)
        pvSpeechProgress.progress = progress / 100
        
        if currentUtterance == totalUtterances {
            animateActionButtonAppearance(shouldHideSpeakButton: false)
            
            unselectLastWord()
            previousSelectedRange = nil
        }
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer!, didStart utterance: AVSpeechUtterance!) {
        currentUtterance = currentUtterance + 1
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer!, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance!) {
        let progress: Float = Float(spokenTextLengths + characterRange.location) * 100 / Float(totalTextLength)
        pvSpeechProgress.progress = progress / 100
        
        
        // Determine the current range in the whole text (all utterances), not just the current one.
        let rangeInTotalText = NSMakeRange(spokenTextLengths + characterRange.location, characterRange.length)
        
        // Select the specified range in the textfield.
        textScroll.selectedRange = rangeInTotalText
        
        // Store temporarily the current font attribute of the selected text.
        let currentAttributes = textScroll.attributedText.attributes(at: rangeInTotalText.location, effectiveRange: nil)
        let fontAttribute: AnyObject? = currentAttributes[NSFontAttributeName] as AnyObject?
        
        // Assign the selected text to a mutable attributed string.
        let attributedString = NSMutableAttributedString(string: textScroll.attributedText.attributedSubstring(from: rangeInTotalText).string)
        
        // Make the text of the selected area orange by specifying a new attribute.
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: NSMakeRange(0, attributedString.length))
        
        // Make sure that the text will keep the original font by setting it as an attribute.
        attributedString.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, attributedString.string.utf16.count))
        
        // In case the selected word is not visible scroll a bit to fix this.
        textScroll.scrollRangeToVisible(rangeInTotalText)
        
        // Begin editing the text storage.
        textScroll.textStorage.beginEditing()
        
        // Replace the selected text with the new one having the orange color attribute.
        textScroll.textStorage.replaceCharacters(in: rangeInTotalText, with: attributedString)
        
        // If there was another highlighted word previously (orange text color), then do exactly the same things as above and change the foreground color to black.
        if let previousRange = previousSelectedRange {
            let previousAttributedText = NSMutableAttributedString(string: textScroll.attributedText.attributedSubstring(from: previousRange).string)
            previousAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, previousAttributedText.length))
            previousAttributedText.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, previousAttributedText.length))
            
            textScroll.textStorage.replaceCharacters(in: previousRange, with: previousAttributedText)
        }
        
        // End editing the text storage.
        textScroll.textStorage.endEditing()
        
        // Keep the currently selected range so as to remove the orange text color next.
        previousSelectedRange = rangeInTotalText
    }
}

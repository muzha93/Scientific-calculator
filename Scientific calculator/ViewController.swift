//
//  ViewController.swift
//  Scientific calculator
//
//  Created by luka on 10/11/2016.
//  Copyright © 2016 luka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction private func touchDigit(sender: UIButton) {
        
        var digit = sender.currentTitle!
        
        if userIsInTypingMode {
            if ((display.text!.range(of: ".") != nil) && (digit == ".")) {
                digit = ""
            }
            let textCurrentInDisplay = display.text!
            display.text = textCurrentInDisplay + digit
        }
        else {
            display.text = digit
            userIsInTypingMode = true
        }
    }
    
    @IBOutlet private weak var displayDescription: UILabel!
    

    private func updateDescription(){
        displayDescription.text! = brain.description
        if brain.isPartialResult{
            displayDescription.text!.append("...")
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTypingMode {
            brain.setOperand(operand: displayValue)
            userIsInTypingMode = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            updateDescription()
        }
        displayValue = brain.result

    }
    private var brain = CalculatorBrain()
    
    @IBOutlet  private weak var display: UILabel!
    
    private var userIsInTypingMode = false
    
    var savedProgram: CalculatorBrain.PropertyList?

    @IBAction func save(sender: UIButton) {
        brain.setOperand(operand: sender.currentTitle!)
    }
    
    @IBAction func restore(sender: UIButton) {
        let value = displayValue
        savedProgram = brain.program
        userIsInTypingMode = false
        if let program = savedProgram {
            brain.variablesName["M"] = value
            brain.program = program
            displayValue = brain.result
        }
    }
    
    @IBAction func backspaceTouched(_ sender: UIButton) {

        if userIsInTypingMode{
            display.text = display.text!.substring(to: (display.text?.index(before: (display.text?.endIndex)!))!)
            if display.text=="" {
                userIsInTypingMode = false
            }
        }else{
            brain.undo()
            updateDescription()
        }
    }
    
}


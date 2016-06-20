//
//  PitchPlayer.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 6/2/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import AVFoundation

class PitchPlayer {
    var ae: AVAudioEngine
    var sampler: AVAudioUnitSampler
    var mixer: AVAudioMixerNode
    
    let defaultNotes = [
        "CLow":60,
        "C":60,
        "C#":61,
        "Db":61,
        "D":62,
        "D#":63,
        "Eb":63,
        "E":64,
        "F":65,
        "F#":66,
        "Gb":66,
        "G":67,
        "G#":68,
        "Ab":68,
        "A":69,
        "A#":70,
        "Bb":70,
        "B":71,
        "CHigh":72
    ]
    
    var midiNoteForPitch = [
        "CLow":60,
        "C":60,
        "C#":61,
        "Db":61,
        "D":62,
        "D#":63,
        "Eb":63,
        "E":64,
        "F":65,
        "F#":66,
        "Gb":66,
        "G":67,
        "G#":68,
        "Ab":68,
        "A":69,
        "A#":70,
        "Bb":70,
        "B":71,
        "CHigh":72
    ]
    
    init(){
        
        ae = AVAudioEngine()
        mixer = ae.mainMixerNode
        
        sampler = AVAudioUnitSampler()
        
        ae.attachNode(sampler)
        ae.connect(sampler, to: mixer, format: nil)
        
//        loadSF2PresetIntoSampler()
        
        changeOctave()
        
        do {
            try ae.start()
        } catch {
            // handle errors
        }
        
    }
    
    func changeOctave() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let octave = defaults.doubleForKey("Octave")
        let diffFromDefault = octave - 4.0
        let offset = Int(12.0 * diffFromDefault)
        
        for (key, value) in defaultNotes {
            midiNoteForPitch[key] = value + offset
        }
    }
    
    func loadSF2PresetIntoSampler()  {
        
        guard let bankURL = NSBundle.mainBundle().URLForResource("TimGM6mb-MuseScoree", withExtension: "sf2") else {
            print("could not load sound font")
            return
        }
        
        do {
            try self.sampler.loadSoundBankInstrumentAtURL(bankURL,
                                                          program: 0,
                                                          bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                                                          bankLSB: UInt8(kAUSampler_DefaultBankLSB))
        } catch {
            print("error loading sound bank instrument")
        }
    }
    
    func play(note: String) {
        sampler.startNote(UInt8(midiNoteForPitch[note]!), withVelocity: 127, onChannel: 0)
    }
    
    func stop(note: String) {
        sampler.stopNote(UInt8(midiNoteForPitch[note]!), onChannel: 0)
    }
}

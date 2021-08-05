//
//  ContentView.swift
//  Eput
//
//  Created by 土井星太朗 on 2021/08/01.
//

import SwiftUI
import AVFoundation
struct TextArea: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        
        let myTextArea = UITextView()
        myTextArea.delegate = context.coordinator
        myTextArea.font = UIFont(name: "HelveticaNeue", size: 55)
        myTextArea.backgroundColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 1.0, alpha: 0.2)
        
        return myTextArea
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextArea
        
        init(_ uiTextView: TextArea) {
            self.parent = uiTextView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}
struct ContentView: View {
    @State var text = "アイウエオアイウエオアイウエオアイウエオ愛うおエアいうオエアイウエオ"
    var body: some View {
        VStack(spacing:50){
            Button(action: {
                do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
                        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    } catch {
                        print("audioSession properties weren't set because of an error.")
                    }

                let utterance = AVSpeechUtterance(string: self.text)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

                    let synth = AVSpeechSynthesizer()
                    synth.speak(utterance)

//                    defer {
//                        disableAVSession()
//                    }
            }){
                Text("start tts")
            }
//            func disableAVSession() {
//                do {
//                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//                } catch {
//                    print("audioSession properties weren't disable.")
//                }
//            }
            TextArea(
                text: $text
            ).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .font(.system(size:18))
        //        VStack {
        //            TextField("sdf"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant(""))
        //                .frame(width: 100.0)
        //            VStack {
        //                Button(action: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/{}/*@END_MENU_TOKEN@*/) {
        //                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Button")/*@END_MENU_TOKEN@*/
        //                }
        //            }
        //        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

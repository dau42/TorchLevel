//
//  ContentView.swift
//  TorchLevel
//
//  Created by David Uhen on 9/24/20.
//  Copyright © 2020 Uhen. All rights reserved.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var text: String = ""
    @State private var timer: Timer?
    @State var isLongPressing = false
    
    var body: some View {
        VStack(spacing: 15){
            TextField("TorchLevel: 0.0", text: $text)
                    .padding(.all, 20)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 24, weight: .bold, design: .rounded))
                  
            Button(action: {
                self.setFlashLightBrightness(brightness: 1.0)
            }) {
                HStack {
                    Text("Full Level")
                        .fontWeight(.semibold)
                        .font(.title)
                }
            }.buttonStyle(FlashlightButtonStyle())
            
            Button(action: {
                self.setFlashLightBrightness(brightness: 0.5)
            }) {
                    Text("Half Level")
                        .fontWeight(.semibold)
                        .font(.title)
            }.buttonStyle(FlashlightButtonStyle())
            
            Spacer()
                    .frame(height: 5)
                
            Button(action: {
                if(self.isLongPressing){
                    self.isLongPressing.toggle()
                    self.timer?.invalidate()
                }
                else {
                    self.increaseFlashLightBrightness()
                }
            }) {
               Text("Increase")
                        .fontWeight(.semibold)
                        .font(.title)
            }.buttonStyle(FlashlightButtonStyle())
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            print("long press")
                            self.isLongPressing = true
                            self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                                self.increaseFlashLightBrightness()
                            })
                        })
            
            Button(action: {
                if(self.isLongPressing){
                    self.isLongPressing.toggle()
                    self.timer?.invalidate()
                }
                else {
                    self.decreaseFlashLightBrightness()
                }
            }) {
                    Text("Decrease")
                        .fontWeight(.semibold)
                        .font(.title)
            }.buttonStyle(FlashlightButtonStyle())
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                            print("long press")
                            self.isLongPressing = true
                            self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                                self.decreaseFlashLightBrightness()
                            })
                        })
            
            Spacer()
                    .frame(height: 5)
            
            Button(action: {
                self.setFlashLightBrightness(brightness: 0)
            }) {
                    Text("Off")
                        .fontWeight(.semibold)
                        .font(.title)
            }.buttonStyle(FlashlightButtonStyle())
        }
    }
    
    private func setFlashLightBrightness(brightness: Double)
    {
        let captureDeviceInput: AVCaptureDeviceInput? = {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return nil } // Supports RAW.
            return try? AVCaptureDeviceInput(device: device)
        }()
        var bright = brightness

        if brightness < 0.0
        {
           bright = 0.0
        }
        
        if brightness > 1.0
        {
           bright = 1.0
        }
        
        let camera = captureDeviceInput!.device
        do {
            try camera.lockForConfiguration()
        } catch {
            return
        }
        bright = round(bright*1000)/1000
        if(bright > 0)
        {
            if( camera.torchMode != .on) {
                camera.torchMode = .on
            }
            do { try camera.setTorchModeOn(level: Float(bright)) } catch { }
            print("Brightness Level \(bright)")
        }
        else
        {
            print("Flashlight Off")
            if( camera.torchMode == .on) {
                camera.torchMode = .off
            }
        }
        text = "TorchLevel: \(NSString(format:"%.3f", bright))"
        camera.unlockForConfiguration()
    }
    
    private func increaseFlashLightBrightness()
    {
        let captureDeviceInput: AVCaptureDeviceInput? = {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return nil } // Supports RAW.
            return try? AVCaptureDeviceInput(device: device)
        }()

        let camera = captureDeviceInput!.device
        setFlashLightBrightness(brightness: Double(camera.torchLevel + 0.005))
    }
    
    private func decreaseFlashLightBrightness()
    {
        let captureDeviceInput: AVCaptureDeviceInput? = {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return nil } // Supports RAW.
            return try? AVCaptureDeviceInput(device: device)
        }()

        let camera = captureDeviceInput!.device
        setFlashLightBrightness(brightness: Double(camera.torchLevel - 0.005))
    }

}

extension Color {
    static let offWhite = Color(red: 225/255, green: 225/255, blue: 235/255)
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                    .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)

            } else {
                shape
                    .fill(LinearGradient(Color.offWhite, Color.darkStart))
                    .overlay(shape.stroke(Color.darkEnd, lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            }
        }
    }
}

struct LightBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.offWhite)
                    .overlay(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .stroke(Color.black, lineWidth: 4)
                            .blur(radius: 4)
                            .offset(x: 2, y: 2)
                            .mask(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/).fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                           .stroke(Color.white, lineWidth: 8)
                            .blur(radius: 4)
                            .offset(x: -2, y: -2)
                            .mask(RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/).fill(LinearGradient(Color.clear, Color.black)))
                    )
            } else {
                shape
                    .fill(Color.offWhite)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
        }
    }
}

struct DarkOrLightBackground<S: Shape>: View {
    @Environment(\.colorScheme) var colorScheme
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        VStack{
            if colorScheme == .dark {
                DarkBackground(isHighlighted: isHighlighted, shape: RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            } else {
                LightBackground(isHighlighted: isHighlighted, shape: RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            }
        }
    }
}

struct FlashlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: 200)
            .padding(.all, 20)
            .contentShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .background(
                DarkOrLightBackground(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  SegmentedCircularProgressBar.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.05.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct SegmentedCircularProgressBar: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow.progressBar
    
    @Binding private var progress: CGFloat
    
    init(progress: Binding<CGFloat>) {
        self._progress = progress
    }
    
    private var totalEmptySpaceAngle: Angle {
        settings.emptySpaceAngle * Double(settings.segments)
    }
    
    private var availableAngle: Angle {
        Angle(degrees: 360.0) - totalEmptySpaceAngle
    }
    
    private var segmentAngle: Angle {
        availableAngle / Double(settings.segments)
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<settings.segments) { index in
                segment(at: index)
            }
        }
        .rotationEffect(settings.rotationEffect)
        .frame(width: settings.size.width, height: settings.size.height)
    }
    
    private func segment(at index: Int) -> some View {
        let startAngle = Angle(degrees: Double(index) * (segmentAngle.degrees + settings.emptySpaceAngle.degrees))
        let endAngle = Angle(degrees: startAngle.degrees + segmentAngle.degrees)
        
        return Circle()
            .trim(from: CGFloat(startAngle.radians / (2 * .pi)), to: CGFloat(endAngle.radians / (2 * .pi)))
            .stroke(segmentColor(at: index),
                    style: StrokeStyle(lineWidth: settings.lineWidth, lineCap: .butt))
    }
    
    private func segmentColor(at index: Int) -> Color {
        let p = CGFloat((index + 1) * (10 / settings.segments)) * 0.1
        if  progress >= p {
            return settings.progressSegmentColor
        }
        return settings.segmentColor
    }
}

struct SegmentedCircularProgressBarContentView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            
            ZStack {
                
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                    .padding(settings.inboundPadding(showName: settings.isShowName))
                
                SegmentedCircularProgressBar(progress: $progress)
                    
            }
            
            Slider(value: $progress, in: 0...1)
                .padding()
        }
    }
}

struct SegmentedCircularProgressBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedCircularProgressBarContentView()
        SegmentedCircularProgressBarContentView()
            .preferredColorScheme(.dark)
    }
}

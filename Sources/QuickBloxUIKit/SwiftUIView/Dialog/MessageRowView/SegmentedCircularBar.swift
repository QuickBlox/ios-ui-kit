//
//  SegmentedCircularBar.swift
//  QuickBloxUIKit
//
//  Created by Injoit on 30.09.2023.
//  Copyright © 2023 QuickBlox. All rights reserved.
//

import SwiftUI

struct SegmentedCircularBar: View {
    var settings: ProgressBarSettingsProtocol
    @State private var currentSegment = 0
    
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
            ForEach(0..<settings.segments, id: \.self) { index in
                segment(at: index)
            }
        }
        .rotationEffect(settings.rotationEffect)
        .frame(width: settings.size.width, height: settings.size.height)
        .onAppear() {
            startAnimation()
        }
    }
    
    init(settings: ProgressBarSettingsProtocol) {
        self.settings = settings
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
        return index == currentSegment || index == nextIndex ? settings.progressSegmentColor : settings.segmentColor
    }
    
    var nextIndex: Int {
        let next = currentSegment + 1
        if next == settings.segments {
            return 0
        }
        return next
    }
    
    func startAnimation() {
        withAnimation {
            if currentSegment < settings.segments - 1 {
                currentSegment = currentSegment + 1
            } else {
                currentSegment = 0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + settings.segmentDuration) {
            startAnimation()
        }
    }
}

struct SegmentedCircularBarContentView: View {
    let settings = QuickBloxUIKit.settings.dialogScreen.messageRow
    
    var body: some View {
        VStack {
            
            ZStack {
                
                settings.progressBarBackground()
                    .frame(width: settings.attachmentSize.width,
                           height: settings.attachmentSize.height)
                    .cornerRadius(settings.attachmentRadius, corners: settings.inboundCorners)
                    .padding(settings.inboundPadding(showName: settings.isHiddenName))
                
                SegmentedCircularBar(settings: settings.aiProgressBar)
                
            }
        }
    }
}

struct SegmentedCircularBarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedCircularBarContentView()
        SegmentedCircularBarContentView()
            .preferredColorScheme(.dark)
    }
}

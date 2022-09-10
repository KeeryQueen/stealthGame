
//
//  PieChartRenderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
#endif

open class PieChartRenderer: DataRenderer
{
    @objc open weak var chart: PieChartView?

    @objc public init(chart: PieChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)

        self.chart = chart
    }

    open override func drawData(context: CGContext)
    {
        guard let chart = chart else { return }

        let pieData = chart.data

        if pieData != nil
        {
            // If we redraw the data, remove and repopulate accessible elements to update label values and frames
            accessibleChartElements.removeAll()

            for set in pieData!.dataSets as! [IPieChartDataSet]
                where set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }

    @objc open func calculateMinimumRadiusForSpacedSlice(
        center: CGPoint,
        radius: CGFloat,
        angle: CGFloat,
        arcStartPointX: CGFloat,
        arcStartPointY: CGFloat,
        startAngle: CGFloat,
        sweepAngle: CGFloat) -> CGFloat
    {
        let angleMiddle = startAngle + sweepAngle / 2.0

        // Other point of the arc
        let arcEndPointX = center.x + radius * cos((startAngle + sweepAngle).DEG2RAD)
        let arcEndPointY = center.y + radius * sin((startAngle + sweepAngle).DEG2RAD)

        // Middle point on the arc
        let arcMidPointX = center.x + radius * cos(angleMiddle.DEG2RAD)
        let arcMidPointY = center.y + radius * sin(angleMiddle.DEG2RAD)

        // This is the base of the contained triangle
        let basePointsDistance = sqrt(
            pow(arcEndPointX - arcStartPointX, 2) +
                pow(arcEndPointY - arcStartPointY, 2))

        // After reducing space from both sides of the "slice",
        //   the angle of the contained triangle should stay the same.
        // So let's find out the height of that triangle.
        let containedTriangleHeight = (basePointsDistance / 2.0 *
            tan((180.0 - angle).DEG2RAD / 2.0))

        // Now we subtract that from the radius
        var spacedRadius = radius - containedTriangleHeight

        // And now subtract the height of the arc that's between the triangle and the outer circle
        spacedRadius -= sqrt(
            pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
                pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2))

        return spacedRadius
    }

    /// Calculates the sliceSpace to use based on visible values and their size compared to the set sliceSpace.
    @objc open func getSliceSpace(dataSet: IPieChartDataSet) -> CGFloat
    {
        guard
            dataSet.automaticallyDisableSliceSpacing,
            let data = chart?.data as? PieChartData
            else { return dataSet.sliceSpace }

        let spaceSizeRatio = dataSet.sliceSpace / min(viewPortHandler.contentWidth, viewPortHandler.contentHeight)
        let minValueRatio = dataSet.yMin / data.yValueSum * 2.0

        let sliceSpace = spaceSizeRatio > CGFloat(minValueRatio)
            ? 0.0
            : dataSet.sliceSpace

        return sliceSpace
    }

    @objc open func drawDataSet(context: CGContext, dataSet: IPieChartDataSet)
    {
        guard let chart = chart else {return }

        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle

        let phaseX = animator.phaseX
        let phaseY = animator.phaseY

        let entryCount = dataSet.entryCount
        let drawAngles = chart.drawAngles
        let center = chart.centerCircleBox
        let radius = chart.radius
        let drawInnerArc = chart.drawHoleEnabled && !chart.drawSlicesUnderHoleEnabled
        let userInnerRadius = drawInnerArc ? radius * chart.holeRadiusPercent : 0.0

        var visibleAngleCount = 0
        for j in 0 ..< entryCount
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            if ((abs(e.y) > Double.ulpOfOne))
            {
                visibleAngleCount += 1
            }
        }

        let sliceSpace = visibleAngleCount <= 1 ? 0.0 : getSliceSpace(dataSet: dataSet)

        context.saveGState()

        // Make the chart header the first element in the accessible elements array
        // We can do this in drawDataSet, since we know PieChartView can have only 1 dataSet
        // Also since there's only 1 dataset, we don't use the typical createAccessibleHeader() here.
        // NOTE: - Since we want to summarize the total count of slices/portions/elements, use a default string here
        // This is unlike when we are naming individual slices, wherein it's alright to not use a prefix as descriptor.
        // i.e. We want to VO to say "3 Elements" even if the developer didn't specify an accessibility prefix
        // If prefix is unspecified it is safe to assume they did not want to use "Element 1", so that uses a default empty string
        let prefix: String = chart.data?.accessibilityEntryLabelPrefix ?? "Element"
        let description = chart.chartDescription?.text ?? dataSet.label ?? chart.centerText ??  "Pie Chart"

        let
        element = NSUIAccessibilityElement(accessibilityContainer: chart)
        element.accessibilityLabel = description + ". \(entryCount) \(prefix + (entryCount == 1 ? "" : "s"))"
        element.accessibilityFrame = chart.bounds
        element.isHeader = true
        accessibleChartElements.append(element)

        for j in 0 ..< entryCount
        {
            let sliceAngle = drawAngles[j]
            var innerRadius = userInnerRadius

            guard let e = dataSet.entryForIndex(j) else { continue }
            
            defer
            {
                // From here on, even when skipping (i.e for highlight),
                //  increase the angle
                angle += sliceAngle * CGFloat(phaseX)
            }

            // draw only if the value is greater than zero
            if abs(e.y) < Double.ulpOfOne { continue }
            
            // Skip if highlighted
            if dataSet.isHighlightEnabled && chart.needsHighlight(index: j)
            {
                continue
            }
        
            let accountForSliceSpacing = sliceSpace > 0.0 && sliceAngle <= 180.0

            context.setFillColor(dataSet.color(atIndex: j).cgColor)

            let sliceSpaceAngleOuter = visibleAngleCount == 1 ?
                0.0 :
                sliceSpace / radius.DEG2RAD
            let startAngleOuter = rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * CGFloat(phaseY)
            var sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * CGFloat(phaseY)
            if sweepAngleOuter < 0.0
            {
                sweepAngleOuter = 0.0
            }

            let arcStartPointX = center.x + radius * cos(startAngleOuter.DEG2RAD)
            let arcStartPointY = center.y + radius * sin(startAngleOuter.DEG2RAD)

            let path = CGMutablePath()

            path.move(to: CGPoint(x: arcStartPointX,
                                  y: arcStartPointY))

            path.addRelativeArc(center: center, radius: radius, startAngle: startAngleOuter.DEG2RAD, delta: sweepAngleOuter.DEG2RAD)

            if drawInnerArc &&
                (innerRadius > 0.0 || accountForSliceSpacing)
            {
                if accountForSliceSpacing
                {
                    var minSpacedRadius = calculateMinimumRadiusForSpacedSlice(
                        center: center,
                        radius: radius,
                        angle: sliceAngle * CGFloat(phaseY),
                        arcStartPointX: arcStartPointX,
                        arcStartPointY: arcStartPointY,
                        startAngle: startAngleOuter,
                        sweepAngle: sweepAngleOuter)
                    if minSpacedRadius < 0.0
                    {
                        minSpacedRadius = -minSpacedRadius
                    }
                    innerRadius = min(max(innerRadius, minSpacedRadius), radius)
                }

                let sliceSpaceAngleInner = visibleAngleCount == 1 || innerRadius == 0.0 ?
                    0.0 :
                    sliceSpace / innerRadius.DEG2RAD
                let startAngleInner = rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * CGFloat(phaseY)
                var sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * CGFloat(phaseY)
                if sweepAngleInner < 0.0
                {
                    sweepAngleInner = 0.0
                }
                let endAngleInner = startAngleInner + sweepAngleInner

                path.addLine(
                    to: CGPoint(
                        x: center.x + innerRadius * cos(endAngleInner.DEG2RAD),
                        y: center.y + innerRadius * sin(endAngleInner.DEG2RAD)))

                path.addRelativeArc(center: center, radius: innerRadius, startAngle: endAngleInner.DEG2RAD, delta: -sweepAngleInner.DEG2RAD)
            }
            else
            {
                if accountForSliceSpacing
                {
                    let angleMiddle = startAngleOuter + sweepAngleOuter / 2.0

                    let sliceSpaceOffset =
                        calculateMinimumRadiusForSpacedSlice(
                            center: center,
                            radius: radius,
                            angle: sliceAngle * CGFloat(phaseY),
                            arcStartPointX: arcStartPointX,
                            arcStartPointY: arcStartPointY,
                            startAngle: startAngleOuter,
                            sweepAngle: sweepAngleOuter)

                    let arcEndPointX = center.x + sliceSpaceOffset * cos(angleMiddle.DEG2RAD)
                    let arcEndPointY = center.y + sliceSpaceOffset * sin(angleMiddle.DEG2RAD)

                    path.addLine(
                        to: CGPoint(
                            x: arcEndPointX,
                            y: arcEndPointY))
                }
                else
                {
                    path.addLine(to: center)
                }
            }

            path.closeSubpath()

            context.beginPath()
            context.addPath(path)
            context.fillPath(using: .evenOdd)

            let axElement = createAccessibleElement(withIndex: j,
                                                    container: chart,
                                                    dataSet: dataSet)
            { (element) in
                element.accessibilityFrame = path.boundingBoxOfPath
            }

            accessibleChartElements.append(axElement)
        }

        // Post this notification to let VoiceOver account for the redrawn frames
        accessibilityPostLayoutChangedNotification()

        context.restoreGState()
    }

    open override func drawValues(context: CGContext)
    {
        guard
            let chart = chart,
            let data = chart.data
            else { return }

        let center = chart.centerCircleBox

        // get whole the radius
        let radius = chart.radius
        let rotationAngle = chart.rotationAngle
        let drawAngles = chart.drawAngles
        let absoluteAngles = chart.absoluteAngles

        let phaseX = animator.phaseX
        let phaseY = animator.phaseY

        var labelRadiusOffset = radius / 10.0 * 3.0

        if chart.drawHoleEnabled
        {
            labelRadiusOffset = (radius - (radius * chart.holeRadiusPercent)) / 2.0
        }

        let labelRadius = radius - labelRadiusOffset

        let dataSets = data.dataSets

        let yValueSum = (data as! PieChartData).yValueSum

        let drawEntryLabels = chart.isDrawEntryLabelsEnabled
        let usePercentValuesEnabled = chart.usePercentValuesEnabled

        var angle: CGFloat = 0.0
        var xIndex = 0

        context.saveGState()
        defer { context.restoreGState() }

        for i in 0 ..< dataSets.count
        {
            guard let dataSet = dataSets[i] as? IPieChartDataSet else { continue }

            let drawValues = dataSet.isDrawValuesEnabled

            if !drawValues && !drawEntryLabels && !dataSet.isDrawIconsEnabled
            {
                continue
            }

            let iconsOffset = dataSet.iconsOffset

            let xValuePosition = dataSet.xValuePosition
            let yValuePosition = dataSet.yValuePosition

            let valueFont = dataSet.valueFont
            let entryLabelFont = dataSet.entryLabelFont ?? chart.entryLabelFont
            let lineHeight = valueFont.lineHeight

            guard let formatter = dataSet.valueFormatter else { continue }

            for j in 0 ..< dataSet.entryCount
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                let pe = e as? PieChartDataEntry

                if xIndex == 0
                {
                    angle = 0.0
                }
                else
                {
                    angle = absoluteAngles[xIndex - 1] * CGFloat(phaseX)
                }

                let sliceAngle = drawAngles[xIndex]
                let sliceSpace = getSliceSpace(dataSet: dataSet)
                let sliceSpaceMiddleAngle = sliceSpace / labelRadius.DEG2RAD

                // offset needed to center the drawn text in the slice
                let angleOffset = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0

                angle = angle + angleOffset

                let transformedAngle = rotationAngle + angle * CGFloat(phaseY)

                let value = usePercentValuesEnabled ? e.y / yValueSum * 100.0 : e.y
                let valueText = formatter.stringForValue(
                    value,
                    entry: e,
                    dataSetIndex: i,
                    viewPortHandler: viewPortHandler)

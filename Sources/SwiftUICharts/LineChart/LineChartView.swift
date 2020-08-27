//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data:ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    
    public var formSize:CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 0 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot) {
                HapticFeedback.playSelection()
            }
            
        }
    }
    let frame = CGSize(width: 380, height: 120)
    private var rateValue: Int
    
    public init(data: [Double],
                title: String,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize? = ChartForm.large,
                rateValue: Int? = 14,
                dropShadow: Bool? = true,
                valueSpecifier: String? = "%.0f") {
        
        self.data = ChartData(points: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form!
        self.rateValue = rateValue!
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
    }
     
        //public let monthsChart = UserDefaults.standard.object(forKey: "monthsChart")
        public let monthsChartDic = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "monthsChart") as! Data) as! Dictionary<String,Double>
        //public let let monthsChartDic = monthsChartNSDic as Dictionary<String,Any>
        var dict = ["a": 1.1, "b": 2.0]
     
    public var body: some View {
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 0)
                 .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .frame(height: 140, alignment: .center)
               // .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
            VStack(alignment: .leading){
                
//                    HStack{
//
//                        if(self.currentValue == 0.0){
//                            Text("Transactions (1 an)")
//                            .font(.system(size: 14, weight: .regular, design: .default))
//                           // .offset(x: 0, y: 40)
//                        } else {
//                          Text("\(self.currentValue, specifier: self.valueSpecifier) XOF")
//                            .font(.system(size: 14, weight: .regular, design: .default))
//                            //.offset(x: 0, y: 40)
//                        }
//
//
//
//                    }
//                    .transition(.scale)
//                .background(Color.red)
                
                
                GeometryReader{ geometry in
                    Line(data: self.data,
                        frame: .constant(geometry.frame(in: .local)),
                        touchLocation: self.$touchLocation,
                        showIndicator: self.$showIndicatorDot,
                        minDataValue: .constant(nil),
                        maxDataValue: .constant(nil)
                    )
                               
                  //  if(self.currentValue == 0.0){
                 //      Text("\(self.monthsChartDic.keysForValue(value: 2.0))" as String)
                 //        .font(.system(size: 14, weight: .regular, design: .default))
                 //        .offset(x: 0, y: 8)
                 //   } else { 
                      Text("\(self.currentValue, specifier: self.valueSpecifier) XOF")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .offset(x: 10, y: 8)
                      Text("\(self.monthsChartDic.keysForValue(value: self.OneDecimal(self.currentValue))[0])" as String)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .offset(x: 10, y: 20)  
                 //   }
                }
            
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120, alignment: .topLeading)
               .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(x: 0, y: 0)
           // .border(Color.black, width: 1)
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120, alignment: .topLeading)
             
        }
        .gesture(DragGesture()
        .onChanged({ value in
            self.touchLocation = value.location
            self.showIndicatorDot = true
            self.getClosestDataPoint(toPoint: value.location, width:self.frame.width, height: self.frame.height)
        })
            .onEnded({ value in
                self.showIndicatorDot = false
            })
        )
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
    
    func OneDecimal(_ value: Double) ->  Double{
        
        let val = Double(String(format: "%.1f", value))!
        return val
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineChartView(data: [8,23,54,32,12,37,7,23,43], title: "Line chart", legend: "Basic")
                .environment(\.colorScheme, .light)
        }
    }
}

extension Dictionary where Value: Equatable {
    /// Returns all keys mapped to the specified value.
    /// “`
    /// let dict = ["A": 1, "B": 2, "C": 3]
    /// let keys = dict.keysForValue(2)
    /// assert(keys == ["B"])
    /// assert(dict["B"] == 2)
    /// “`
    func keysForValue(value: Value) -> [Key] {
        return flatMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}

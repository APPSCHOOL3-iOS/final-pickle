//
//  Font.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

public extension Font {
    static let pizzaTitle = Font.system(size: 28, weight: .regular)
    static let pizzaTitle2 = Font.system(size: 22, weight: .regular)
    static let pizzaTitle2Bold = Font.system(size: 22, weight: .bold)
    static let pizzaHeadlineBold = Font.system(size: 17, weight: .bold)
    
    static let pizzaTitleBold = chab
    static let pizzaHeadline = nanumEb
    static let pizzaBody = nanumBd
    static let pizzaDescription = nanumBdBody
    
    static let pizzaBoldSmallTitle = makeFont(name: "NanumSquareNeo-cBd", size: 18, style: .title3)
    static let pizzaRegularSmallTitle = makeFont(name: "NanumSquareNeo-bRg", size: 15, style: .subheadline)
    static let pizzaStoreMiddle = makeFont(name: "NanumSquareNeo-aLt", size: 16, style: .body)
    static let pizzaTimerNum = makeFont(name: "LOTTERIACHAB", size: 44, style: .title)
    static let pizzaRegularTitle = makeFont(name: "NanumSquareNeo-cBd", size: 24, style: .title)
    static let pizzaBoldTitle = makeFont(name: "NanumSquareNeo-dEb", size: 24, style: .title)
    static let pizzaBoldButtonTitle = makeFont(name: "NanumSquareNeo-cBd", size: 14, style: .title)
    static let pizzaBoldButtonTitle15 = makeFont(name: "NanumSquareNeo-cBd", size: 15, style: .title)
    
    static let liveActivityTargetTime = makeFont(name: "NanumSquareNeo-bRg", size: 12, style: .subheadline)
    static let liveActivityTitle = makeFont(name: "NanumSquareNeo-dEb", size: 28, style: .title)
    static let liveActivityLeading = makeFont(name: "LOTTERIACHAB", size: 16, style: .title)
    
    static let pizzaFootnote = Font.system(size: 13, weight: .regular)
    static let pizzaFootnoteBold = Font.system(size: 13, weight: .bold)
    static let pizzaCaption = Font.system(size: 11, weight: .regular)

    static let chab = Font.custom("LOTTERIACHAB", size: 28)
    static let nanumBd = Font.custom("NanumSquareNeo-cBd", size: 17, relativeTo: .body)
    static let nanumBdBody = Font.custom("NanumSquareNeo-cBd", size: 13, relativeTo: .body)

    static let nanumEbTitle = Font.custom("NanumSquareNeo-dEb", size: 21, relativeTo: .body)
    static let nanumEb = Font.custom("NanumSquareNeo-dEb", size: 17, relativeTo: .title3)
    static let nanumHv = Font.custom("NanumSquareNeo-eHv", size: 17, relativeTo: .title3)
    static let nanumLtBody = Font.custom("NanumSquareNeo-aLt", size: 17, relativeTo: .title3)
    static let nanumLt = Font.custom("NanumSquareNeo-aLt", size: 14, relativeTo: .title3)
    static let nanumRg = Font.custom("NanumSquareNeo-bRg", size: 17, relativeTo: .title3)
     
    static func makeFont(name: String,
                         size: CGFloat,
                         style: Font.TextStyle) -> Font {
        Font.custom("\(name)", size: size, relativeTo: style)
    }
}

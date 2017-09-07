//
//  UIMacro.h
//  Anniversary
//
//  Created by 小希 on 2017/8/31.
//  Copyright © 2017年 小希. All rights reserved.
//

#ifndef UIMacro_h
#define UIMacro_h

/*
 Valid format: #RGB #RGBA #RRGGBB #RRGGBBAA 0xRGB ...
 The `#` or "0x" sign is not required.
 Example: UIColorHex(0xF0F), UIColorHex(66ccff), UIColorHex(#66CCFF88)
 */
#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

/**
 *  Alpha parameter priority is higher
 */
#ifndef UIColorHexAlpha
#define UIColorHexAlpha(_hex_, a)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_)) alpha:a]
#endif

/// Size
#define UIImageNamed(imageName)  [UIImage imageNamed:@#imageName]


/**
 *  Main UIColor in Mico
 */
#define MCOrange      UIColorHex(ff7000)
#define MCRed         UIColorHex(ff4500)
#define MCGray        UIColorHex(cccccc)
#define MCDarkGray    UIColorHex(999999)
#define MCLightGray   UIColorHex(eeeeee)
#define MCWhite       UIColorHex(ffffff)
#define MCGreen       UIColorHex(00CC82)
#define MCBlue        UIColorHex(3296FB)

#define MCCardBackgroundColor   UIColorHex(f9f9f9)
#define MCBackgroundColor       UIColorHex(f4f4f4)
#define MCSubViewColor          UIColorHex(ffffff)
#define MCSectionSplitColor     UIColorHex(f1f1f6)
#define MCRowSplitColor         MCLightGray
#define MCMsgBubbleHLColor      UIColorHex(d9d9d9)

#define MCGrayBackground        UIColorHex(e2e2e2)
#define MCOrangeAlpha(a)        UIColorHexAlpha(ff7000, a)

#define MCCellSelectedColor     UIColorHex(f6f6f6)


/**
 *   Main Color in version 5.0 or later
 */
#define MCThemeColor            UIColorHex(6050FF)
#define MCBrandColor            UIColorHex(6050ff)
#define MCBrandAssistColor      UIColorHex(f72ece)
#define MCWarnRedColor          UIColorHex(ff3b30)
#define MCLikeColor             UIColorHex(f64b5d)
#define MCMainTitleColor        UIColorHex(1d212c)
#define MCSubTitleColor         UIColorHex(636b82)
#define MCContentColor          UIColorHex(a6b0bd)
#define MCArrowColor            UIColorHex(e6e8eb)
#define MCDisableColor          UIColorHex(e6e8eb)
#define MCSeperateColor         UIColorHex(f1f2f6)
#define MCBackgroundGrayColor   UIColorHex(f5f7f9)
#define MCBackgroundWhiteColor  UIColorHex(ffffff)
#define MCTipsYellowColor       UIColorHex(fffc0d)
#define MCVIPColor              UIColorHex(ff3b30)
#define MCOnlineColor           UIColorHex(33d000)

#define MCPurpleColor           UIColorHex(935bff)
#define MCGreenColor            UIColorHex(1fd5ad)
#define MCOrangeColor           UIColorHex(ff7d00)

/**
 *  Main Font in Mico
 *
 */
#define MCMainTitleFont     [UIFont aiqSemiboldFontOfSize:17]

/**
 *  Rectangle PopView or Button CornerRadius
 */
#define kSmallCornerRadius      2
#define kDefaultCornerRadius    4
#define kLargeCornerRadius      10

/**
 *  Regular size
 */
#define kAvatarLargeDiameter    65
#define kAvatarMidDiameter      55
#define kAvatarSmallDiameter    40
#define kAvatarTinyDiameter     35
#define kAvatarGridDiameter     PointAdapt(105)
#define kConversationAvatarSize 60

/**
 *  Cell Constant
 */
#define kCellPadding            10
#define kCellSystemPadding      15
#define kCellBottomPadding      14
#define kCellNameTopPadding     16
#define kCellTextTopPadding     10
#define kCellSubTextTopPadding  6
#define kCellIconTopPadding     8
#define kCellTextMidPadding     7

#define kCellImagePadding       5
#define kCellImageSmallPadding  3

#define kCellRowSmallHeight     45
#define kCellRowMidHeight       65
#define kCellRowLargeHeight     90
#define kChatCellRowHeight      75

#define kCellImageSmallHeight   50

#define kMessageViewGeneralPadding      15
#define kMessageCellTextFrameInset      14
#define kMessageCellMediaFrameInset     3
#define kMessageCellTranslateViewHeight 25
#define kMessageToolBarPanelHeight      237
#define kMessageNameLabelSpacing        4

#define kMessageCellHorizonalPadding    10
#define kMessageCellVerticalPadding     20
#define kMessageCellBubbleInnerInset    15
#define kMessageCellBubbleMediaInnerInset   3
#define kMsgBubbleCornerRadius          20

#define kMessageInputBarHeight          45
#define kMessageToolBarHeight           40
#define kMessageToolButtonWidth         40
#define kMessageKeyboardDefaultHeight   258

#define kMessageBarDefaultTotalHeight   (kMessageInputBarHeight + kMessageToolBarHeight)


#define kVisitorItemAdaptedSpacing     PointAdapt(15.f)

/**
 *  View Constant
 */
#define kTouchMinumSize     44
#define kSectionDefaultDistance 10
#define kFeaturedUserSectionHeight 45
#define kGenderAgeWidth     32
#define kGenderAgeHeight    14
#define kAudioIconSize  12
#define kNavigationItemNegativeSpac     -7
#define kLineOnePixelHeight    PointFromPixel(1)
#define kProfileVipIconWidth    28.f
#define kProfileVipIconHeight   14.f
#define kSegmentControlHeight   45.f

#endif /* UIMacro_h */

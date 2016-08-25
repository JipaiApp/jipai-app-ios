//
//  JPMacroDefines.h
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#ifndef Jipai_JPMacroDefines_h
#define Jipai_JPMacroDefines_h

#define Storyboard(theName)             [UIStoryboard storyboardWithName:theName bundle:nil]
#define MainStoryboard                  Storyboard(@"Main")
#define ViewController(storyboardID)    [MainStoryboard instantiateViewControllerWithIdentifier:storyboardID]

/**
 * Colors
 */
#define JPColorHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0 \
blue:((float)((rgbValue & 0x0000FF) >> 0)) / 255.0 \
alpha:1.0]

#define JPColorRed  [UIColor colorWithHex:0xf84b29]

#define JPColorTint JPColorRed
#define JPColorNavigationBarTint    JPColorRed
#define JPColorNavigationTitle      [UIColor whiteColor]
#define JPColorNavigationTint       [UIColor whiteColor]

#endif

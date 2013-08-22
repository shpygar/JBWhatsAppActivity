//
//  JBWhatsAppActivity.m
//  DemoProject
//
//  Created by Javier Berlana on 19/07/13.
//  Copyright (c) 2013 Sweetbits. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "JBWhatsAppActivity.h"

@interface JBWhatsAppActivity ()

@property (nonatomic, strong) WhatsAppMessage *message;

+(NSString*) encodedText:(NSString*)text;

@end


@implementation JBWhatsAppActivity

- (NSString *)activityType {
    return @"es.sweetbits.WHATSAPP";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"activity_whatsapp"];
}

- (NSString *)activityTitle
{
    return @"WhatsApp";
}

- (NSURL *)getURLFromMessage:(WhatsAppMessage *)message
{
    NSString *url = @"whatsapp://";
    
    if (_message.text)
    {
        url = [NSString stringWithFormat:@"%@send?text=%@",url, [JBWhatsAppActivity encodedText:_message.text]];
        
        if (_message.abid) {
            url = [NSString stringWithFormat:@"%@&abid=%@",url,_message.abid];
        }
    }
    
    return [NSURL URLWithString:url];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[WhatsAppMessage class]])
        {
            self.message = activityItem;
            NSURL *whatsAppURL = [self getURLFromMessage:_message];
            return [[UIApplication sharedApplication] canOpenURL: whatsAppURL];
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[WhatsAppMessage class]])
        {
            NSURL *whatsAppURL = [self getURLFromMessage:_message];
            
            if ([[UIApplication sharedApplication] canOpenURL: whatsAppURL]) {
                [[UIApplication sharedApplication] openURL: whatsAppURL];
            }
            
            break;
        }
    }
}

+(NSString*) encodedText:(NSString*)text{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                NULL,
                                                                (CFStringRef)text,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]", //The characters you want to replace go here
                                                                kCFStringEncodingUTF8 ));
}

@end

#pragma mark - WhatsAppMessage Class

@implementation WhatsAppMessage

- (id)init
{
    return [self initWithMessage:nil forABID:nil];
}

/** Designated initializer*/
- (id)initWithMessage:(NSString *)message forABID:(NSString *)abid
{
    self = [super init];
    
    if (self)
    {
        _text = message && message.length > 0 ? message : nil;
        _abid = abid && abid.length > 0 ? abid : nil;
    }
    
    return self;
}

@end

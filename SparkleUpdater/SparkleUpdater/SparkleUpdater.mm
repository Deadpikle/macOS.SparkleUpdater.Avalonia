//
//  SparkleUpdater.m
//  SparkleUpdater
//
//  Created by Deadpikle on 2/27/20.
//  Copyright © 2020 Deadpikle. All rights reserved.
//

#import "SparkleUpdater.h"

#import <Sparkle/Sparkle.h>

@interface Updater : NSObject <SUUpdaterDelegate>

+(void)initSparkle;
+(void)checkForSparkleUpdates;

@end

@implementation Updater

+(NSBundle*)bundle {
    return [NSBundle bundleForClass:[self class]];
}

+(BOOL)hasInfoPlistValues:(NSBundle*)bundle {
    if ([bundle.infoDictionary objectForKey:@"CFBundleVersion"] != nil &&
        [bundle.infoDictionary objectForKey:@"SUFeedURL"] != nil) {
        return YES;
    }
    return NO;
}

+(void)initSparkle {
    NSBundle *bundle = [Updater bundle];
    if ([Updater hasInfoPlistValues:bundle]) {
        SUUpdater *updater = [SUUpdater updaterForBundle:bundle];
        [updater checkForUpdatesInBackground];
    }
}

+(void)checkForSparkleUpdates {
    NSBundle *bundle = [Updater bundle];
    if ([Updater hasInfoPlistValues:bundle]) {
        [[SUUpdater updaterForBundle:bundle] checkForUpdates:self];
    }
}

@end

extern "C" void InitSparkle()
{
    [Updater initSparkle];
};

extern "C" void CheckForSparkleUpdates()
{
    [Updater checkForSparkleUpdates];
};


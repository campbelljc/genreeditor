//
//  Genre.m
//  
//
//  Created by Jonathan Campbell on 2015-08-20.
//
//

#import "Genre.h"

@implementation Genre

- (id)init {
    self = [super init];
    
    self.mediaKind = @"music";
    self.type = MUSIC;
    self.exactStringMatch = false;
    self.matchString = @"new-genre";
    
    return self;
}

- (id)initWithData:(id)data {
    self = [super init];
    
    self.mediaKind = @"music";
    self.type = MUSIC;
    self.exactStringMatch = false;
    
    NSArray *podcasts = [NSArray arrayWithObjects: @"action", @"adventure", @"animation", @"audiobook", @"book", @"business", @"documentary", @"drama", @"education", @"teaching", @"high", @"engineering", @"kids", @"family", @"finearts", @"fine arts", @"art", @"health", @"medicine", @"history", @"horror", @"humanities", @"independent", @"language", @"literature", @"math", @"music", @"nonfiction", @"reality", @"romance", @"scifi", @"sci fi", @"science fiction", @"fantasy", @"science", @"social science", @"short film", @"shorts", @"sports", @"teen", @"thriller", @"western", nil];
    
    for (id key in data) {
        if ([key isEqualToString:@"matchString"]) {
            self.matchString = [data objectForKey:key];
            for (NSString *title in podcasts) {
                if ([self.matchString isEqualToString:title]) {
                    self.mediaKind = @"podcast";
                    self.type = PODCAST;
                }
            }
        }
        else if ([key isEqualToString:@"resourceFile"]) {
            self.resourceFile = [data objectForKey:key];
        }
        else if ([key isEqualToString:@"kind"]) {
            self.mediaKind = [data objectForKey:key];
            if ([self.mediaKind isEqualToString:@"movie"]) {
                self.type = MOVIE;
            }
            else if ([self.mediaKind isEqualToString:@"tvshow"]) {
                self.type = TVSHOW;
            }
        }
        else if ([key isEqualToString:@"exactStringMatch"]) {
            self.exactStringMatch = [data objectForKey:key];
        }
    }
    
    [self refreshImagePath];
    
    return self;
}

- (void)refreshImagePath {
    self.imagePath = [NSString stringWithFormat:@"%@/%@", @"/Applications/iTunes.app/Contents/Resources", self.resourceFile];
}

- (void)updateGenreType {
    if ([self.mediaKind isEqualToString:@"music"]) {
        self.type = MUSIC;
    }
    else if ([self.mediaKind isEqualToString:@"podcast"]) {
        self.type = PODCAST;
    }
    else if ([self.mediaKind isEqualToString:@"movie"]) {
        self.type = MOVIE;
    }
    else if ([self.mediaKind isEqualToString:@"tvshow"]) {
        self.type = TVSHOW;
    }
}

@end

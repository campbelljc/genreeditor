//
//  Genre.h
//  
//
//  Created by Jonathan Campbell on 2015-08-20.
//
//

#import <Foundation/Foundation.h>

@interface Genre : NSObject

@property NSString *matchString;
@property NSString *resourceFile;
@property NSString *mediaKind;
@property bool exactStringMatch;
@property NSString *imagePath;

typedef enum {
    MUSIC = 0,
    PODCAST,
    MOVIE,
    TVSHOW
} GenreType;

@property GenreType type;

- (id)init;
- (id)initWithData:(id)data;
- (void)refreshImagePath;
- (void)updateGenreType;


@end

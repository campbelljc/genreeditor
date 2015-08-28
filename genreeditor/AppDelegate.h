//
//  AppDelegate.h
//  genrearteditor
//
//  Created by Jonathan Campbell on 2015-08-20.
//  Copyright (c) 2015 Jonathan Campbell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SecurityFoundation/SFAuthorization.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    SFAuthorization *authorization;
}

@property IBOutlet NSMutableArray *genres;
@property (strong) IBOutlet NSArrayController *arrayController;
@property IBOutlet NSTableView *tableView;
@property NSInteger showMusic;
@property NSInteger showPodcasts;
@property NSInteger showMovies;
@property NSInteger showTVShows;

- (void)setup;
- (IBAction) showLicense:(id)sender;
- (void)loadGenresPlist;
- (IBAction) addGenre;
- (IBAction) restoreDefaultGenres;
- (IBAction) save;
- (IBAction) delete:(id)sender;
- (IBAction) toggleGenre;
- (IBAction) changeImage;
- (IBAction) visitSite:(id)sender;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

- (void)protectedCopyFrom:(NSString*)source to:(NSString*)dest;

- (BOOL)checkForCompatibility:(BOOL)launched;
- (NSString*)md5Of:(NSString*)path;

@end


//
//  AppDelegate.h
//  genrearteditor
//
//  Created by Jonathan Campbell on 2015-08-20.
//  Copyright (c) 2015 Jonathan Campbell. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SecurityFoundation/SFAuthorization.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> { //, NSTableViewDataSource, NSTableViewDelegate> {
    SFAuthorization *authorization;
}

@property IBOutlet NSMutableArray *genres;
@property (strong) IBOutlet NSArrayController *arrayController;
@property IBOutlet NSTableView *tableView;
@property NSInteger showMusic;
@property NSInteger showPodcasts;
@property NSInteger showMovies;
@property NSInteger showTVShows;

- (void)loadGenresPlist;
- (void)addGenre:(id)key;
- (IBAction) restoreDefaultGenres;
- (IBAction) save;
- (IBAction) delete:(id)sender;
- (IBAction) toggleGenre;
- (IBAction) changeImage;

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

- (void)protectedCopyFrom:(NSString*)source to:(NSString*)dest;

@end


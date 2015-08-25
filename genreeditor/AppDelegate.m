//
//  AppDelegate.m
//  genrearteditor
//
//  Created by Jonathan Campbell on 2015-08-20.
//  Copyright (c) 2015 Jonathan Campbell. All rights reserved.
//

#import "AppDelegate.h"
#import "Genre.h"
#import "NSTask+OneLineTasksWithOutput.h"

NSString *const iTunesDir = @"/Applications/iTunes.app/Contents/Resources/";
NSString *const genresPlist =@"/Applications/iTunes.app/Contents/Resources/genres.plist";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *list;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMenu* edit = [[[[NSApplication sharedApplication] mainMenu] itemWithTitle: @"Edit"] submenu];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"orderFrontCharacterPalette:"))
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] action] == NSSelectorFromString(@"startDictation:"))
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    if ([[edit itemAtIndex: [edit numberOfItems] - 1] isSeparatorItem])
        [edit removeItemAtIndex: [edit numberOfItems] - 1];
    
    self.showMusic = self.showPodcasts = self.showMovies = self.showTVShows = 1;
    
    [self loadGenresPlist];
    
    [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:self.tableView];
    [self.tableView scrollRowToVisible:0];
    [self.arrayController setSelectedObjects:[NSArray arrayWithObjects:[self.genres objectAtIndex:0], nil]];
}

- (void)loadGenresPlist {
    // src : https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/SerializePlist/SerializePlist.html
    // src : http://stackoverflow.com/questions/6133951/ios-nspropertylistserialization-propertylistwithdata-produces-incompatible-conv
    NSData *plistData = [NSData dataWithContentsOfFile:genresPlist];
    NSError *error;
    NSPropertyListFormat format;
    NSDictionary *plist;
    
    plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
    
    if (!plist) {
        NSLog(error);
        NSLog(@"Couldn't load genres plist file.");
        return;
    }
    
    if (self.genres != nil) {
        for (Genre* genre in self.genres) {
            [genre removeObserver:self forKeyPath:@"resourceFile"];
            [genre removeObserver:self forKeyPath:@"mediaKind"];
        }
        [self.genres removeAllObjects];
    }
    self.genres = [[NSMutableArray alloc] initWithCapacity:106];
    
    for (id key in [plist objectForKey:@"entries"]) {
        [self.arrayController addObject:[[Genre alloc] initWithData:key]];
    }
    
    [self.arrayController rearrangeObjects];
    
    [self toggleGenre];
    
    for (Genre* genre in self.genres) {
        [genre addObserver:self forKeyPath:@"resourceFile" options:NSKeyValueObservingOptionNew context:nil];
        [genre addObserver:self forKeyPath:@"mediaKind" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"resourceFile"]) {
        [object refreshImagePath];
    }
    else if ([keyPath isEqualToString:@"mediaKind"]) {
        NSArray *kinds = [NSArray arrayWithObjects: @"music", @"podcast", @"movie", @"tvshow", nil];
        for (NSString *title in kinds) {
            if ([[object mediaKind] isEqualToString:title]) {
                [object updateGenreType];
                [self.arrayController rearrangeObjects];
                [self toggleGenre];
            }
        }
    }
}

- (IBAction) addGenre:(id)data {
    Genre *genre = [[Genre alloc] init];
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"jpg",@"jpeg"];
    panel.allowsMultipleSelection = NO;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *src = [[panel URLs] objectAtIndex:0];
            NSURL *dest;
            if ([[src lastPathComponent] containsString:@"genre-"]) {
                dest = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@%@", iTunesDir, [src lastPathComponent]]];
            }
            else {
                dest = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@genre-%@", iTunesDir, [src lastPathComponent]]];
            }
            
            [self protectedCopyFrom:[src path] to:[dest path]];
            
            genre.matchString = [src lastPathComponent];
            genre.resourceFile = [dest lastPathComponent];
            [genre refreshImagePath];
            
            [self.arrayController addObject:genre];
            [self.arrayController rearrangeObjects];
            [[[NSApplication sharedApplication] mainWindow] makeFirstResponder:self.tableView];
            [self.tableView scrollRowToVisible:[self.tableView numberOfRows] - 1];
            [self.arrayController setSelectedObjects:[NSArray arrayWithObjects:genre, nil]];
            
            [genre addObserver:self forKeyPath:@"resourceFile" options:NSKeyValueObservingOptionNew context:nil];
            [genre addObserver:self forKeyPath:@"mediaKind" options:NSKeyValueObservingOptionNew context:nil];

            [self save];
        }
    }];
    
//    [self.arrayController addObject:[[Genre alloc] initWithData:data]];
}

- (IBAction) restoreDefaultGenres {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"genres" ofType:@"plist"];

    NSURL *source = [[NSURL alloc] initFileURLWithPath:path];
    NSURL *dest = [[NSURL alloc] initFileURLWithPath:genresPlist];
    
    [self protectedCopyFrom:[source path] to:[dest path]];
    
    [self loadGenresPlist];
}

- (IBAction) toggleGenre {
    NSString* predStr = [NSString stringWithFormat:@"(type == 0 AND %d == 1) OR (type == 1 AND %d == 1) OR (type == 2 AND %d == 1) OR (type == 3 AND %d == 1)", self.showMusic, self.showPodcasts, self.showMovies, self.showTVShows];
//    NSLog(predStr);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predStr];
    [self.arrayController setFilterPredicate:predicate];
}

-(void)save {
    NSMutableArray *genreArray = [[NSMutableArray alloc] initWithCapacity:[self.genres count]];
    for (Genre *genre in self.genres) {
        NSMutableDictionary *gDict = [[NSMutableDictionary alloc] init];
        [gDict setValue:[genre matchString] forKey:@"matchString"];
        [gDict setValue:[genre resourceFile] forKey:@"resourceFile"];
        if ([genre exactStringMatch] == true)
            [gDict setValue:[NSNumber numberWithBool:[genre exactStringMatch]] forKey:@"exactStringMatch"];
        if (![[genre mediaKind] isEqualToString:@"music"]
          && ![[genre mediaKind] isEqualToString:@"podcast"])
            [gDict setValue:[genre mediaKind] forKey:@"kind"];
        [genreArray addObject:gDict];
    }
    NSMutableDictionary *root = [[NSMutableDictionary alloc] initWithObjectsAndKeys:genreArray, @"entries", nil];
    
    [root writeToFile:@"genres_new.plist" atomically:YES];
 
    NSURL *dest = [[NSURL alloc] initFileURLWithPath:genresPlist];
    
    [self protectedCopyFrom:@"genres_new.plist" to:[dest path]];
}

- (IBAction) delete:(id)sender {
    for (Genre *genre in self.arrayController.selectedObjects)
    {
        [genre removeObserver:self forKeyPath:@"resourceFile"];
        [genre removeObserver:self forKeyPath:@"mediaKind"];
        [self.arrayController removeObject:genre];
    }
    [self.arrayController rearrangeObjects];
}

- (IBAction) changeImage {
    for (Genre *genre in self.arrayController.selectedObjects)
    {
        NSOpenPanel* panel = [NSOpenPanel openPanel];
        panel.allowedFileTypes = @[@"jpg",@"jpeg"];
        panel.allowsMultipleSelection = NO;

        [panel beginWithCompletionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *src = [[panel URLs] objectAtIndex:0];
                NSURL *dest;
                if ([[src lastPathComponent] containsString:@"genre-"]) {
                    dest = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@%@", iTunesDir, [src lastPathComponent]]];
                }
                else {
                    dest = [[NSURL alloc] initFileURLWithPath:[NSString stringWithFormat:@"%@genre-%@", iTunesDir, [src lastPathComponent]]];
                }
                
                [self protectedCopyFrom:[src path] to:[dest path]];
                
//                for (Genre *genre2 in self.genres) {
  //                  if ([[genre2 resourceFile] isEqualToString:genre.resourceFile]) {
                        genre.resourceFile = [dest lastPathComponent];
                        [genre refreshImagePath];
    //                }
      //          }
                
                [self save];
                [self.arrayController rearrangeObjects];
            }
        }];
        
        return;
    }
}

- (void)protectedCopyFrom:(NSString*)source to:(NSString*)dest {
    NSError *error;
    
    // src : http://www.cocoawithlove.com/2009/05/invoking-other-processes-in-cocoa.html
    if (!authorization)
    {
        authorization = [SFAuthorization authorization];
        BOOL result =
        [authorization
         obtainWithRights:NULL
         flags:kAuthorizationFlagExtendRights
         environment:NULL
         authorizedRights:NULL
         error:&error];
        if (!result)
        {
            NSLog(@"SFAuthorization error: %@", [error localizedDescription]);
            authorization = nil;
            return;
        }
    }
    
    NSString *output =
    [NSTask
     stringByLaunchingPath:@"/bin/cp"
     withArguments:
     [NSArray arrayWithObjects:
      source,
      dest,
      nil]
     authorization:authorization
     error:&error];
    if (!output)
    {
        NSLog(@"Error from AuthorizationExecuteWithPrivileges: %ld",
              [error code]);
        return;
    }
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end

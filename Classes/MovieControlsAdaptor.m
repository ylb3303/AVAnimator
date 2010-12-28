//
//  MovieControlsAdaptor.m
//
//  Created by Moses DeJong on 12/17/10.
//

#import "MovieControlsAdaptor.h"

#import "AVAnimatorViewController.h"
#import "MovieControlsViewController.h"

@implementation MovieControlsAdaptor

@synthesize animatorViewController = m_animatorViewController;
@synthesize movieControlsViewController = m_movieControlsViewController;

// static ctor

+ (MovieControlsAdaptor*) movieControlsAdaptor
{
  MovieControlsAdaptor *obj = [[MovieControlsAdaptor alloc] init];
  [obj autorelease];
  return obj;
}

- (void)dealloc {
  self.animatorViewController = nil;
  self.movieControlsViewController = nil;
  [super dealloc];
}

- (void) startAnimating
{  
	// Put movie controls away (this needs to happen when the
	// loading is done)
  
	[self.movieControlsViewController hideControls];
  
	// Setup handlers for movie control notifications
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(movieControlsDoneNotification:) 
                                               name:MovieControlsDoneNotification 
                                             object:self.movieControlsViewController];	
  
	// Invoke pause or play action from movie controls
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(movieControlsPauseNotification:) 
                                               name:MovieControlsPauseNotification 
                                             object:self.movieControlsViewController];	
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(movieControlsPlayNotification:) 
                                               name:MovieControlsPlayNotification 
                                             object:self.movieControlsViewController];
  
	// Register callbacks to be invoked when the animator changes from
	// states between start/stop/done. The start/stop notification
	// is done at the start and end of each loop. When all loops are
	// finished the done notification is sent.
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(animationPreparedNotification:) 
                                               name:AVAnimatorPreparedToAnimateNotification 
                                             object:self.animatorViewController];
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(animationDidStartNotification:) 
                                               name:AVAnimatorDidStartNotification 
                                             object:self.animatorViewController];	
  
	[[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(animationDidStopNotification:) 
                                               name:AVAnimatorDidStopNotification 
                                             object:self.animatorViewController];
    
	// Kick off loading operation and disable user touch events until
	// finished loading.
  
	[self.movieControlsViewController disableUserInteraction];
  
	[self.animatorViewController prepareToAnimate];
  
  [self.animatorViewController startAnimating];
}

- (void) stopAnimating
{
	// Remove notifications from movie controls
  
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:MovieControlsDoneNotification
                                                object:self.movieControlsViewController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:MovieControlsPauseNotification
                                                object:self.movieControlsViewController];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:MovieControlsPlayNotification
                                                object:self.movieControlsViewController];	
  
	// Remove notifications from animator
  
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:AVAnimatorPreparedToAnimateNotification
                                                object:self.animatorViewController];	
  
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:AVAnimatorDidStartNotification
                                                object:self.animatorViewController];
  
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:AVAnimatorDidStopNotification
                                                object:self.animatorViewController];
    
	// Remove MovieControls and contained views, if the animator was just stopped
	// because all the loops were played then stopAnimating is a no-op.
  
	[self.animatorViewController stopAnimating];  
}

// Invoked when the Done button in the movie controls is pressed.
// This action will stop playback and halt any looping operation.
// This action will inform the animator that it should be done
// animating, then the animator will kick off a notification
// indicating that the animation is done.

- (void)movieControlsDoneNotification:(NSNotification*)notification {
	NSLog( @"movieControlsDoneNotification" );
  
	NSAssert(![self.animatorViewController isInitializing], @"animatorViewController isInitializing");
  
	[self.animatorViewController doneAnimating];
}

- (void)movieControlsPauseNotification:(NSNotification*)notification {
	NSLog( @"movieControlsPauseNotification" );
  
	NSAssert(![self.animatorViewController isInitializing], @"animatorViewController isInitializing");
  
	[self.animatorViewController pause];
}

- (void)movieControlsPlayNotification:(NSNotification*)notification {
	NSLog( @"movieControlsPlayNotification" );
  
	NSAssert(![self.animatorViewController isInitializing], @"animatorViewController isInitializing");
  
	[self.animatorViewController unpause];
}

// Invoked when the animation is ready to begin, meaning all
// resources have been initialized.

- (void)animationPreparedNotification:(NSNotification*)notification {
	NSLog( @"animationPreparedNotification" );
  
	[self.movieControlsViewController enableUserInteraction];
  
	[self.animatorViewController startAnimating];
}

// Invoked when an animation starts, note that this method
// can be invoked multiple times for an animation that loops.

- (void)animationDidStartNotification:(NSNotification*)notification {
	NSLog( @"animationDidStartNotification" );
}

// Invoked when an animation ends, note that this method
// can be invoked multiple times for an animation that loops.

- (void)animationDidStopNotification:(NSNotification*)notification {
	NSLog( @"animationDidStopNotification" );	
}

@end



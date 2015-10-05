//
//  ViewController.m
//  InstagramFirsFour
//
//  Created by Alexander Krupnik on 02/10/15.
//  Copyright (c) 2015 Alexander Krupnik. All rights reserved.
//

#import "ViewController.h"
static NSString *const  INSTAGRAM_QUERY = @"https://api.instagram.com/v1/media/popular?access_token=2218748617.ea3ed6e.b4f54912924d410cbabe0a2a97393a82";
static NSUInteger const IMGS_WIDTH = 240;
static NSUInteger const V_OFFSET = 60;
static NSUInteger const LANDSCAPE_V_SHIFT = 20;


@interface ViewController () {
  int picVertShift;
}
@property (strong, nonatomic) NSArray *sortedItems;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.sortedItems = nil;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    for (UIView *view in [self.view subviews]) {
        if([view isKindOfClass:[UIImageView class]] ) {
            [view removeFromSuperview];
        }
    }
    [self displayPictures];
    NSLog(@"orientation have changed");
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    [self loadFourPictures];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

-(void) loadFourPictures {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:INSTAGRAM_QUERY] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        //NSLog(@"%@",json);
        if(jsonError) {
            NSLog(@"JSON serialisation error = %@", error);
            return;
        }
        NSArray *items = [json objectForKey:@"data"];
        NSArray *sortedArray = [items sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = (int) [[a objectForKey:@"likes"] objectForKey:@"count"];
            int second = (int)[[b objectForKey:@"likes"] objectForKey:@"count"];
            return first <= second;
        }];
        self.sortedItems = sortedArray;
        [self displayPictures];
    }];
    [dataTask resume];
}

-(void) displayPictures {
    if(!self.sortedItems) return;
    NSURLSession *imageGetSession = [NSURLSession sharedSession];
    NSLog(@"display pictures");
    for(int i = 0; i < 4; i++) {
        id item = self.sortedItems[i];
        id imgUrl =[[[item objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
        NSURL *url = [NSURL URLWithString:imgUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"GET";
        NSURLSessionDataTask *getDataTask = [imageGetSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            // We want to update our UI so we switch to the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // Create image view using fetched image (or update an existing one)
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                CGRect outerFrame = self.view.frame;
                NSUInteger hSpace = (outerFrame.size.width - IMGS_WIDTH)/2;
                CGRect imgFrame = imageView.frame;
                imgFrame.origin.x += hSpace;
                imgFrame.origin.y += V_OFFSET;
                imgFrame.size.width = IMGS_WIDTH/2;
                imgFrame.size.height = IMGS_WIDTH/2;
                if (i == 1) {
                    imgFrame.origin.x += IMGS_WIDTH/2;
                }
                else if (i == 2) {
                    imgFrame.origin.y += IMGS_WIDTH/2;
                }
                else if (i == 3) {
                    imgFrame.origin.x += IMGS_WIDTH/2;
                    imgFrame.origin.y += IMGS_WIDTH/2;
                }
                UIInterfaceOrientation newOrientation =  [UIApplication sharedApplication].statusBarOrientation;
                if ((newOrientation == UIInterfaceOrientationLandscapeLeft || newOrientation == UIInterfaceOrientationLandscapeRight)) {
                    imgFrame.origin.y -= LANDSCAPE_V_SHIFT;
                }
                imageView.frame = imgFrame;
                [self.view addSubview:imageView];
            });
        }];//getDataTask
        [getDataTask resume];
    }//for
}

- (IBAction)refreshPictures:(id)sender {
    [self loadFourPictures];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

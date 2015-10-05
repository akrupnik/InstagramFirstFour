//
//  ViewController.h
//  InstagramFirsFour
//
//  Created by Alexander Krupnik on 02/10/15.
//  Copyright (c) 2015 Alexander Krupnik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate> {

NSMutableData *_responseData;

}

@property (weak, nonatomic) IBOutlet UIButton *adda;

- (IBAction)refreshPictures:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;

@end


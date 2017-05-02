
#import "UserDestination.h"

@implementation UserDestination
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]]) 
        return @"Unknown venue";
    else
        return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:self reuseIdentifier:@"customAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
    
}


@end

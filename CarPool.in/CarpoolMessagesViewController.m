//
//  CarpoolMessagesViewController.m
//  CarPool.in
//
//  Created by Ron Ramirez on 5/6/17.
//  Copyright © 2017 Ron Ramirez. All rights reserved.
//

#import "CarpoolMessagesViewController.h"
#import "DataService.h"
#import "JSQMessage.h"
#import "Message.h"

@interface CarpoolMessagesViewController()
@property (strong,nonatomic) NSMutableArray *messagesArray;
@end

@implementation CarpoolMessagesViewController



#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Initialize JSQ View Controller
    self.senderId = [FIRAuth auth].currentUser.uid;
    self.senderDisplayName = @"Patrick";
    self.title =@"Messages";
    NSLog(@"Drive Post ID - %@", self.currentDriverPost.drivePostID);
    
    //Initialzie Array
    self.messagesArray = [[NSMutableArray alloc] init];
    
    
    //Call Firebase to observe messages on this node
    [self observeMessages];
    
}

#pragma mark - Firebase Helper Functions
- (void) observeMessages {
    
    //Update messages based on messages key inside current post
    
    //Access keys in current user's userMessagesKey
    [[[[[DataService ds] driverPostsReference] child:self.currentDriverPost.drivePostID] child:@"messages"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * snapshot) {
        
        //Access each message on based on message key
        //Initialize and create message model
        NSDictionary *messageDictionary = snapshot.value;
        Message *message = [[Message alloc] initWithDict:messageDictionary];
        NSDate *date = [[NSDate alloc] init];
        

        //Create a JSQ message to display
        JSQMessage *JSQmessage = [[JSQMessage alloc] initWithSenderId:message.senderID
                                                    senderDisplayName:message.senderName
                                                                 date:date
                                                                 text:message.message];
        
        [self.messagesArray addObject:JSQmessage];
        [self.collectionView reloadData];
        NSLog(@"messageArray count - %lu", (unsigned long)[self.messagesArray count]);
    }];
}


#pragma mark - JSQMessageViewController Methods

- (void)didPressAccessoryButton:(UIButton *)sender {
    NSLog(@"Hello from Accessory Button");
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    NSLog(@"Sender Display Name - %@", senderDisplayName);
    NSLog(@"Sender ID %@", senderId);
    NSLog(@"Message Text - %@", text);
    NSLog(@"Date %@", date);
    
    //Message Dictionary to post
    NSDictionary *messageDict = @{@"senderID": senderId,
                                  @"senderName": senderDisplayName,
                                  @"message": text};
    
    //Update messages node
    [[[[[[DataService ds] driverPostsReference] child:self.currentDriverPost.drivePostID] child:@"messages"] childByAutoId] updateChildValues:messageDict];
    
    //Animates sending of message and clear textfield
    [self finishSendingMessage];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Current message
    JSQMessage *currentMessage = self.messagesArray[indexPath.row];
    
    //JSQ cell
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    //Set text based on current message
    cell.textView.text = currentMessage.text;
    
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messagesArray count];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messagesArray objectAtIndex:indexPath.item];
}


- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImage *bubbleImageData;
    
    //Get current message per index path row
    JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
    NSLog(@"messageBubbleImageDataForItemAtIndexPath - %@", message.senderId);
    
    //Determine color of bubble based on message sender id
    if ([message.senderId isEqualToString:self.senderId]) {
        bubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }else {
        bubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
    return bubbleImageData;
}

#pragma mark - TODO - Add avatar images per user

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] init];
    //    JSQMessagesAvatarImage *image = [[JSQMessagesAvatarImage alloc] initWithAvatarImage: highlightedImage: placeholderImage:];
    
    return nil;
    
}

@end

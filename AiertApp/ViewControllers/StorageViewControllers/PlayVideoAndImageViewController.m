

#import "PlayVideoAndImageViewController.h"
#import "DisplayImageView.h"
#import "VideoFrameExtractor.h"
#import "BasicDefine.h"
#import "AudioStreamer.h"
#include "G711Convert_HISI.h"

#import "ZMRecorderFileIndex.h"
#import "ZMRecorderFileIndexManage.h"
#import "Utilities.h"
#import "AppData.h"
#import "SVProgressHUD.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

#define kTag         400001

typedef NS_ENUM(NSInteger, PlayRecordState)
{
    PlayRecordStatePlaying = 0,
    PlayRecordStatePaused,
    PlayRecordStateStoped
};

@interface PlayVideoAndImageViewController ()
{
    dispatch_queue_t _playRecordQueue;
    
    BOOL _bNextDay;
    BOOL _bHasTurn; // 是否有日期交替
    
    BOOL _bAudioEnabled;
    
    __block NSInteger _playRecordState;
    
    long long _startTimeSys;
    long long _startPauseTime;
}

@property (strong, nonatomic) DisplayImageView *imageView;
@property (strong, nonatomic) VideoFrameExtractor *videoDecoder;
@property (strong, nonatomic) ZMRecorderFileIndex *recordIndex;
@property (strong, nonatomic) UISlider *progress;

- (void)createViewWithType:(NSInteger)aType;

- (void)createImageView;

- (void)createVideoView;

- (void)createBottomViewWithType:(NSInteger)aType;

@end

@implementation PlayVideoAndImageViewController

uint64_t getTickCount(void)
{
    static mach_timebase_info_data_t sTimebaseInfo;
    uint64_t machTime = mach_absolute_time();
    
    // Convert to nanoseconds - if this is the first time we've run, get the timebase.
    if (sTimebaseInfo.denom == 0 )
    {
        (void) mach_timebase_info(&sTimebaseInfo);
    }
    
    // Convert the mach time to milliseconds
    uint64_t millis = ((machTime / 1000000) * sTimebaseInfo.numer) / sTimebaseInfo.denom;
    return millis;
}

- (void)dealloc
{
    [VideoFrameExtractor releaseVideoFrameExtractor:_videoDecoder];
}

- (void)initWithDataArr:(id)aData {
    /*
     第一个: index
     第二个: value  也是ZMRecorderFileIndex数据
     */
    NSMutableArray *arr = (NSMutableArray *)aData;
    self.recordIndex = (ZMRecorderFileIndex *)[arr objectAtIndex:1];
    NSString *sIndex = [arr objectAtIndex:0];
    _curIndex = sIndex.intValue;
    
    if (StoragePlayBottomTypeImage == self.recordIndex.type) {
        self.title = NSLocalizedString(@"Images", @"Images");
    }
    else {
        self.title = NSLocalizedString(@"Video", @"Video");
    }
    [self createViewWithType:self.recordIndex.type];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _playRecordQueue = dispatch_queue_create("playRecordQueue", NULL);
    
    self.videoDecoder = [VideoFrameExtractor creatVideoFrameExtractor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)backButton_TouchUpInside:(id)sender {
    
    _playRecordState = PlayRecordStateStoped;
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)createImageView {
    float fOrgY = 88;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                           fOrgY,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.width*0.75)];
    
    NSString *imagePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId]
                                                    fileName:[NSString stringWithFormat:@"%@.png",self.recordIndex.recorderId]];
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    
    [self.view addSubview:imageView];
}

- (void)createVideoView {
    
    float fOrgY = 88;
    self.imageView = [[DisplayImageView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                        fOrgY,
                                                                        self.view.bounds.size.width,
                                                                        self.view.bounds.size.width*0.75)];
    [self.view addSubview:self.imageView];
    
    const float labelWidth = 55.0f;
    const float labelHeight = 30.0f;
    const float progressHeight = 30.0f;
    // startLabel
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 
                                                                    fOrgY+self.view.bounds.size.width*0.75+20,
                                                                    labelWidth, 
                                                                    labelHeight)];
    [startLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    
    
    NSMutableArray *startArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    for (int i=0; i<3; ++i) {
        [startArray addObject:[self.recordIndex.startTime substringWithRange:NSMakeRange(8+i*2, 2)]];
    }
    
    [startLabel setText:[NSString stringWithFormat:@"%@:%@:%@",startArray[0],startArray[1],startArray[2]]];
    [self.view addSubview:startLabel];
    
    // progress
    
    self.progress = [[UISlider alloc] initWithFrame:CGRectMake(labelWidth, startLabel.frame.origin.y+labelHeight*0.5f-progressHeight*0.5f, self.view.bounds.size.width-2*labelWidth, progressHeight)];
    [self.view addSubview:self.progress];
    
    [self.progress setUserInteractionEnabled:NO];
    
    float minValue = [startArray[0] intValue]*60*60 + [startArray[1] intValue]*60 + [startArray[2] intValue];
    
    [self.progress setMinimumValue:minValue];
    
    // endLabel
    
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.progress.frame.size.width+startLabel.frame.size.width, fOrgY+self.view.bounds.size.width*0.75+20, labelWidth, labelHeight)];
    [self.view addSubview:endLabel];
    
    NSMutableArray *endArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    for (int i=0; i<3; ++i) {
        [endArray addObject:[self.recordIndex.endTime substringWithRange:NSMakeRange(8+i*2, 2)]];
    }
    
    [endLabel setText:[NSString stringWithFormat:@"%@:%@:%@",endArray[0],endArray[1],endArray[2]]];
    [endLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
    
    float maxValue = [endArray[0] intValue]*60*60 + [endArray[1] intValue]*60 + [endArray[2] intValue];
    
    if (maxValue < minValue) {
        _bHasTurn = YES;
        maxValue += 24*60*60;
    }
    [self.progress setMaximumValue:maxValue];
    
    _playRecordState = PlayRecordStatePlaying;

    dispatch_async(_playRecordQueue, ^{
        [self startPlayRecord];
    });
}

- (void)createBottomViewWithType:(NSInteger)aType {
    
    float bottomView_Height = 49.0;
    float navigation_Height = 44.0;
    if (IOS7_OR_LATER) {
        navigation_Height = 0.0;
    }
    StoragePlayBottomView *bottomView = [[StoragePlayBottomView alloc] initWithType:CGRectMake(0,
                                                                                               self.view.bounds.size.height - bottomView_Height - navigation_Height,
                                                                                               self.view.bounds.size.width,
                                                                                               bottomView_Height) Type:aType];
    [bottomView setBackgroundColor:[UIColor clearColor]];
    self.playBottomView = bottomView;
    bottomView.delegate = self;
    [self.view addSubview:bottomView];
}

- (void)createViewWithType:(NSInteger)aType {
    switch (aType) {
        case StoragePlayBottomTypeImage:
            [self createImageView];
            break;
        case StoragePlayBottomTypeVideo:
            [self createVideoView];
            break;
    }
    [self createBottomViewWithType:aType];
}

- (void)showNoteMessageInPlayVideoAndImage:(NSString *)message Tag:(NSInteger)aTag {
    NSString *stitle = NSLocalizedString(@"Note", @"Note");
    if (IOS7_OR_LATER) {
        stitle = nil;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:stitle
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Sure", @"Sure")
                                              otherButtonTitles:NSLocalizedString(@"Cancel", @"Cancel"),nil];
    alertView.tag = aTag;
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ((kTag + 1) ==  alertView.tag || (kTag + 2) ==  alertView.tag) {
        if (0 == buttonIndex) {
            
            if(_playVideoAndImageViewControllerDelegate && [(id)_playVideoAndImageViewControllerDelegate respondsToSelector:@selector(deleteDataAtIndexInPlayVideoAndImageViewController:)])
                [_playVideoAndImageViewControllerDelegate deleteDataAtIndexInPlayVideoAndImageViewController:_curIndex];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark - StoragePlayBottomViewDelegate
- (void)clickButtonAtStoragePlayBottomView:(id)sender Index:(NSInteger)aIndex {
    NSLog(@"---- clickButtonAtStoragePlayBottomView ...aIndex:%d",aIndex);
    switch (self.recordIndex.type) {
        case StoragePlayBottomTypeImage: {
            switch (aIndex) {
                case 0:
                    [self showNoteMessageInPlayVideoAndImage:NSLocalizedString(@"Are you Sure Delete?", @"Are you Sure Delete?") Tag:kTag + 1];
                    break;
            }
        }
            break;
        case StoragePlayBottomTypeVideo: {
            switch (aIndex) {
                case 0:
                    [self showNoteMessageInPlayVideoAndImage:NSLocalizedString(@"Are you Sure Delete?", @"Are you Sure Delete?") Tag:kTag + 2];
                    break;
                case 1:
                {
                    UIImage *image;
                    
                    while (!image) {
                        
                        image = (UIImage *)[self.videoDecoder convertFrameToRGB];
                    }
                    
                    if ([ZMRecorderFileIndexManage saveScreenShotImage:image 
                                                              deviceId:self.recordIndex.deviceId 
                                                               channel:self.recordIndex.channel]) {
                        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Grab Image OK",
                                                                               @"Grab Image OK")];
                    } 
                }
                    break;
                case 2:
                {
                    if (PlayRecordStateStoped == _playRecordState) {
                        
                        _playRecordState = PlayRecordStatePlaying;

                        dispatch_async(_playRecordQueue, ^{
                            [self startPlayRecord];
                        });
                    }else if (PlayRecordStatePlaying == _playRecordState)
                    {
                        _playRecordState = PlayRecordStatePaused;
                        
                        _startPauseTime = getTickCount();
                        
                    }else if (PlayRecordStatePaused == _playRecordState)
                    {
                        long long endPauseTime = getTickCount();
                        
                        _startTimeSys += (endPauseTime - _startPauseTime); 
                        
                        _playRecordState = PlayRecordStatePlaying;
                    }
                }
                    break;
                case 3:
                {
                    if (_bAudioEnabled) {
                        [AudioStreamer stopPlayAudio];
                    }else
                    {
                        [AudioStreamer startPlayAudio];
                    }
                    _bAudioEnabled = !_bAudioEnabled;
                }
                    break;
            }
            
        }
            break;
    }
}

#pragma mark - ReadRecordVideo

- (void)startPlayRecord
{
    _startTimeSys = 0;
    
    long long startTimeVideo = 0;
    long long endTimeSys = 0;
    long long lVpts = 0;
    long long lastVPts = 0;
    long long pts = 0;
    
    long long v = 0;
    
    FILE *fp = NULL;
    
    unsigned char headBuffer[8];
    unsigned char videoBuffer[65535];
    unsigned char g711AudioBuffer[325];
    unsigned char pcmAudioBuffer[641];
    
    int nLen = 0;
    char hh = 0;
    char mm = 0;
    char ss = 0;
    
    fp = fopen([[Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId]
                                          fileName:self.recordIndex.recorderId] UTF8String], "rb");
    
    if (fp) {
        
        while (!feof(fp)) {
            
            
            if (PlayRecordStatePaused == _playRecordState) {
                continue;
            }if (PlayRecordStateStoped == _playRecordState) {
                return;
            }
            
            fread(headBuffer, 8, 1, fp);
            
            memcpy(&nLen, headBuffer+4, 4);
            
            DLog(@"readHeadData len :  %d",nLen);
                        
            if (0 == memcmp(headBuffer, "00dc", 4) || 0 == memcmp(headBuffer, "01dc", 4)) {
                
                DLog(@"readVideoData len :  %d",nLen);
                
                fread(videoBuffer, nLen+24, 1, fp);
                
                memcpy(&hh, videoBuffer, 1);
                memcpy(&mm, videoBuffer+1, 1);
                memcpy(&ss, videoBuffer+2, 1);
                
                if (0 == hh && _bHasTurn) {
                    hh += 24;
                }
                                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.progress setValue:hh*60*60+mm*60+ss];
                });
                
                
                memcpy(&lVpts, videoBuffer+8, 8);
                
                if(0 == lastVPts)
                {
                    lastVPts = lVpts;
                    _startTimeSys = getTickCount();
                    startTimeVideo = lVpts;
                }
                
//                DLog(@"lastVps -------------------- > %lld",lastVPts);
//                DLog(@"startTimeSys -----------------> %lld",_startTimeSys);
//                DLog(@"startVideoTime -----------------> %lld",startTimeVideo);
                
                pts = (lVpts - lastVPts) / 1000;
                
                if(pts < 20 || pts > 1000)
                {
                    lastVPts = lVpts;
                    startTimeVideo = lVpts;
                    _startTimeSys = getTickCount();
                    pts = 0;
                }
                
                pts = (lVpts - startTimeVideo) / 1000;
                
                while(1)
                {
                    endTimeSys = getTickCount();
                    
                    v = pts - (endTimeSys - _startTimeSys);
                    
                    if(v <= 3)
                    {
                        break;
                    }
                    usleep(100);
                }
                
                if(lastVPts != 0)
                {
                    lastVPts = lVpts;
                }
                
                if ([self.videoDecoder stepFrame:videoBuffer+24 length:nLen]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageView processFrameBuffer:self.videoDecoder.currentFrame];
                    });
                }
                
            }else if (0 == memcmp(headBuffer, "01wb", 4)) {
                
                DLog(@"readAudioData len :  %d",nLen);

                fread(g711AudioBuffer, nLen+8, 1, fp);
                
                //将标准的g711数据转换成pcm数据
                int nPcmLen = G711ABuf2PCMBuf_HISI((unsigned char*)pcmAudioBuffer,
                                                   641,
                                                   (const unsigned char*)g711AudioBuffer,
                                                   nLen,
                                                   G711_BIG_ENDIAN);
                
                int packetNum = nPcmLen/320;
                
                for (int i=0; i!=packetNum; ++i) {
                    
                    [AudioStreamer playAudioData:[NSData dataWithBytes:pcmAudioBuffer+i*320 length:320]];
                }                
            }
            
            memset(headBuffer, 0, 8);
            
        }
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _playRecordState = PlayRecordStateStoped;
        
        [self.progress setValue:self.progress.maximumValue];
    });
    
}


@end

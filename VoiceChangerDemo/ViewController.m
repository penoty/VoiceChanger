//
//  ViewController.m
//  VoiceChangerDemo
//
//  Created by yupao on 11/14/16.
//  Copyright © 2016 penoty. All rights reserved.
//

#import "ViewController.h"
#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"
#import "AERecorder.h"
#import "AENewTimePitchFilter.h"
#import "Masonry.h"
#import "AEBandpassFilter.h"
#import "AEHighPassFilter.h"


@interface ViewController () {
    NSMutableArray *recordArray;
}

@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, strong) AEAudioFilePlayer *audioPlayer;
@property (nonatomic, strong) AERecorder *audioRecorder;
@property (nonatomic, strong) AEPlaythroughChannel *playThroughChannel;
@property (nonatomic, strong) AENewTimePitchFilter *pitchFilter;


//UI
@property (nonatomic, strong) UILabel *pitchLabel;
@property (nonatomic, strong) UISlider *pitchSlider;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UISlider *volumeSlider;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *resetBtn;

//Control
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPlaying;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubviews];
    
    _audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.inputGain = 2.0f;
    [_audioController setEnableBluetoothInput:YES];
    [_audioController start:NULL];
    
    _pitchFilter = [[AENewTimePitchFilter alloc] init];
    [_pitchFilter setPitch:1.0f];
    [_pitchFilter setOverlap:32.0f];
    [_audioController addFilter:_pitchFilter];

    [self setupPlaythroughChannel];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init methods
- (void)initSubviews {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _volumeLabel = [[UILabel alloc] init];
    [_volumeLabel setTextAlignment:NSTextAlignmentCenter];
    [_volumeLabel setText:@"Volume"];
    [_volumeLabel setUserInteractionEnabled:YES];
    
    _volumeSlider = [[UISlider alloc] init];
    [_volumeSlider setValue:0.3];
    [_volumeSlider addTarget:self action:@selector(volumeValueChanged:) forControlEvents:UIControlEventValueChanged];

    
    _pitchLabel = [[UILabel alloc] init];
    [_pitchLabel setTextAlignment:NSTextAlignmentCenter];
    [_pitchLabel setText:@"Pitch"];
    [_pitchLabel setUserInteractionEnabled:YES];
    
    _pitchSlider = [[UISlider alloc] init];
    [_pitchSlider setMinimumValue:-1000];
    [_pitchSlider setMaximumValue:1000];
    [_pitchSlider setValue:1.0];
    [_pitchSlider addTarget:self action:@selector(pitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    _recordBtn = [[UIButton alloc] init];
    _isRecording = NO;
    [_recordBtn setTitle:@"Record" forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_recordBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_recordBtn addTarget:self action:@selector(recordBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _playBtn = [[UIButton alloc] init];
    _isPlaying = NO;
    [_playBtn setTitle:@"Play" forState:UIControlStateNormal];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_playBtn addTarget:self action:@selector(playBtnTapped:) forControlEvents:UIControlEventTouchUpInside];

    _resetBtn = [[UIButton alloc] init];
    [_resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    [_resetBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_resetBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_resetBtn addTarget:self action:@selector(resetBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_volumeLabel];
    [self.view addSubview:_volumeSlider];
    [self.view addSubview:_pitchLabel];
    [self.view addSubview:_pitchSlider];
    [self.view addSubview:_recordBtn];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_resetBtn];

    [self layoutSubviews];
}

- (void)layoutSubviews {
    
    [_volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(80);
    }];
    
    [_volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_volumeLabel);
        make.left.equalTo(_volumeLabel.mas_right);
        make.right.equalTo(self.view);
    }];

    
    [_pitchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_volumeLabel.mas_bottom);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(80);
    }];
    
    [_pitchSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_pitchLabel);
        make.left.equalTo(_pitchLabel.mas_right);
        make.right.equalTo(self.view);
    }];
    
    [_recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_pitchLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(60);
        make.right.equalTo(_playBtn.mas_left);
        make.top.height.width.equalTo(_playBtn);
        make.top.height.width.equalTo(_resetBtn);
    }];
    
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_resetBtn.mas_left);
    }];
    
    [_resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
    }];

}

#pragma mark - start/stop playing
- (void)startPlayingAudio:(NSURL *)url {
    if (_audioPlayer) {
        [_audioController removeChannels:@[_audioPlayer]];
        _audioPlayer = nil;
    }
    
    _audioPlayer = [[AEAudioFilePlayer alloc] initWithURL:url error:nil];
    __weak __typeof__(self) weakSelf = self;
    [_audioPlayer setCompletionBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [weakSelf playBtnTapped:strongSelf.playBtn];
    }];
    
    [_audioController addChannels:@[_audioPlayer]];
}

- (void)stopPlaying {
    if (_audioPlayer) {
        [_audioController removeChannels:@[_audioPlayer]];
        _audioPlayer = nil;
    }
}

#pragma mark - start/stop recording
- (void)startRecording {
    _audioRecorder = [[AERecorder alloc] initWithAudioController:_audioController];
    
    NSString *filePath = [self getFilePathWithFileName:@"test"];
    NSError *error = nil;
    if (![_audioRecorder beginRecordingToFileAtPath:filePath fileType:kAudioFileM4AType error:&error]) {
        return;
    }
    
    [_audioController addInputReceiver:_audioRecorder];
    [_audioController addOutputReceiver:_audioRecorder];
}

- (void)stopRecording {
    if (_audioRecorder) {
        [_audioRecorder finishRecording];
        [_audioController removeInputReceiver:_audioRecorder];
        [_audioController removeOutputReceiver:_audioRecorder];
        _audioRecorder = nil;
    }
}

#pragma mark - start/stop playing through
- (void)setupPlaythroughChannel {
    _playThroughChannel = [[AEPlaythroughChannel alloc] init];
    [_audioController addInputReceiver:_playThroughChannel];
    [_audioController addChannels:@[_playThroughChannel]];
}

- (void)stopPlaythrough {
    if (_playThroughChannel) {
        [_audioController removeInputReceiver:_playThroughChannel];
        [_audioController removeChannels:@[_playThroughChannel]];
        _playThroughChannel = nil;
    }
}

#pragma mark - volume/pitch control
- (void)volumeValueChanged:(UISlider *)sender {
    [_playThroughChannel setVolume:sender.value];
}

- (void)pitchValueChanged:(UISlider *)sender {
    [_pitchFilter setPitch:sender.value];
}

- (void)recordBtnTapped:(id)sender {
    if (!_isRecording) {
        //start recording
        [self startRecording];
    } else {
        //stop recording
        [self stopRecording];
    }
    _isRecording = !_isRecording;
    [_recordBtn setTitle:(_isRecording ? @"Stop" : @"Record") forState:UIControlStateNormal];
}

- (void)playBtnTapped:(id)sender {
    if (!_isPlaying) {
        //start playing
        [self startPlayingAudio:[NSURL URLWithString:[self getFilePathWithFileName:@"test"]]];
    } else {
        //stop playing
        [self stopPlaying];
    }
    _isPlaying = !_isPlaying;
    [_playBtn setTitle:(_isPlaying ? @"Stop" : @"Play") forState:UIControlStateNormal];
}

- (void)resetBtnTapped:(id)sender {
    [_pitchSlider setValue:1.0];
    [_volumeSlider setValue:0.3];
    [self volumeValueChanged:_volumeSlider];
    [self pitchValueChanged:_pitchSlider];
}

#pragma mark Helper Method
- (NSString *)getFilePathWithFileName:(NSString *)fileName {
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsFolder stringByAppendingPathComponent:fileName];
    return filePath;
}

@end

# AliyunLiveDemo
记录对接阿里云直播SDK的过程

推流SDK   ———> AlivcLiveVideo.framework
连麦SDK   ———> AlivcLibRtmp.framework , AlivcVideoChat.framework
直播间SDK ———> AlivcLiveChatRoom.framework

# 接入Demo时遇到的问题

1.  Enable Bitcode    设置为NO,  AlivcVideoChat.framework 不支持。
2. Xcode 解决日志打印不全问题,

新增一个输出宏，

```
#ifdef DEBUG
#define NSLog( s, ... ) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] );
#else
#define NSLog( s, ... )
#endif
```

3.  xcode9 pch

4. 添加相机，麦克风访问权限(开启预览失败-2)

在plist中增加，

```
<key>NSMicrophoneUsageDescription</key>
<string>microphoneDesciption</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>photoLibraryDesciption</string>
<key>NSCameraUsageDescription</key>
<string>cameraDesciption</string>
```

5. 加载预览视频的问题

```
- (void)loadView;

```

6. StartLiveViewController中创建直播的同时，需要创建房间。
方法是上传creatLive接口返回的MNSInfoModel到getMnsTopicInfo接口中，请求成功得到AlivcWebSocketInfoModel *infoModel参数；再将infoModel传入
joinChatRoomWithWebSocketInfoModel接口中，请求成功，则表明“加入直播间成功”。

注: mnsModel中roomTag与topic一致。
   [roomTag]: b25d203e6a11
   [topic]: b25d203e6a11

7. 导入AlivcLiveChatRoom.framework报错

Undefined symbols for architecture arm64:
  "_utf8_nextCharSafeBody", referenced from:
      -[QPWebSocket _innerPumpScanner] in AlivcLiveChatRoom(QPWebSocket.o)
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)

这是因为从 2.5.9 开始，AVOSCloud 增加了实时通信的功能， 会依赖 libicucore.dylib 。这里 列出了完整的依赖库。
https://segmentfault.com/q/1010000000586639

8. 很重要，决定了直播列表中是否存在正在直播的房间。

接入直播间(LiveRoomViewController)后，点击直播列表进入直播间后，再返回直播列表，会出现一个uid一样的重复直播数据。(eg. uid = 2867;) 并且在进入直播间时，未弹出直播中断的对话框。

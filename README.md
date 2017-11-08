# AliyunLiveDemo
记录对接阿里云直播SDK的过程

* 推流SDK   ———> AlivcLiveVideo.framework
* 连麦SDK   ———> AlivcLibRtmp.framework , AlivcVideoChat.framework
* 直播间SDK ———> AlivcLiveChatRoom.framework

# 接入Demo时遇到的问题

1.  Enable Bitcode 设置为NO,  AlivcVideoChat.framework 不支持。
2. Xcode 解决日志打印不全问题,

新增一个输出宏，

```objectivec
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

```objectivec
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

```
[self.publisherVideoCall startToPublish:self.rtmpURLString];

```

9. 很严重的一个问题

接入直播间(LiveRoomViewController)后，点击直播列表进入直播间后，再返回直播列表，会出现一个uid一样的重复直播数据。(eg. uid = 2867;) 并且在进入直播间时，未弹出直播中断的对话框。

返回的mns对象：

```
 mns = {
                roomTag = de857116795d;
                subscriptionName = de857116795d;
                topic = de857116795d;
                topicLocation = "http://125277.mns.cn-shanghai.aliyuncs.com/topics/de857116795d";
                userRoomTag = 1982;
       };
```

其中，userRoomTag与uid一致。

原因:  直播间(LiveRoomViewController)，在退出直播间时，未通知服务器，未关闭播放器；推流(StartLiveViewController)，在结束推流时，未发送退出直播请求，未完全关闭直播。

# demo中用于直播的账号及获取的当前直播列表

由于使用的是阿里云提供的<font color="1122ee">http://118.178.94.208:3000/</font>测试端口，因此，demo中的直播列表会存在很多无效的直播，想要在一大堆列表中找到自己新发起的直播会很费劲。因此，我在注册直播用户时，在用户名前加了一个名为<font color="1122ee">MyLive_</font>的前缀，最后上传服务器的用户名都会带这个前缀。在直播列表类（MainViewController）请求直播列表获取数据时，增加判断。

```
   for (RoomInfoModel* model in roomInfos) {
      if ([model.name rangeOfString:@"MyLive_"].location != NSNotFound) {
                [self.listDataArray addObject:model];
      }
   }
```

只将含有<font color="1122ee">MyLive_</font>前缀的列表数据加入到数据源中展示。

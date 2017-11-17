# AliyunLiveDemo
记录对接阿里云直播SDK的过程

* 推流SDK   ———> AlivcLiveVideo.framework
* 连麦SDK   ———> AlivcLibRtmp.framework , AlivcVideoChat.framework
* 直播间SDK ———> AlivcLiveChatRoom.framework

# 后期计划添加以下功能
- [-] 连麦时预览窗口切换(全屏切换)
- [ ] 添加几个简单的滤镜效果
- [ ] 增加帧率、视频码率、延时、丢包率的显示
- [ ] 增加分辨率、帧率、码率、视频清晰度(普通、720P、高清)调节的slider控件
- [ ] 特殊场景的处理(网络、电话、前后台切换)
- [ ] 即时通讯（聊天室）
- [ ] 二次封装

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

3.  添加xcode9 pch

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

10. 连麦时需要注意的地方： 
    * 连麦后对其他直播状态的影响；
    * 混流后的直播；
    * 连麦断开时的处理；
    * 主动发起连麦和收到连麦邀请；
    * 与连麦相关的请求的；
    * 每次退出直播或者退出房间时，需要判断当前是否开启了连麦，若正在连麦，则结束连麦。
    
    主麦端点击连麦按钮，读取观众列表；
    副麦端点击连麦按钮，发起连麦请求；
    
   服务器报错
   
>  Code = 2010
   访问用户信息失败
   
**结束连麦的场景:**

> 针对观众端连麦。主播断开连麦；混流失败结束连麦；离开连麦(连麦数不只一个时，其他连麦观众连麦被取消；或者当前连麦观众连麦被取消；需要移除对应的chatView的播放)；中断连麦(接收到断开连麦的消息代理)；
> 
> 针对主播端连麦(当前连麦列表)。主播结束连麦；混流失败结束连麦；中断连麦(接收到断开连麦的消息代理)；结束直播；离开连麦(观众主动断开连麦)；

11. 观众端结束连麦，主播端(StartLiveViewController)接收到断开连麦的代理消息：

```objectivec
- (void)onGetLeaveVideoChatMessage:(LiveInviteInfo*)inviteInfo;
```
关闭连麦窗口。在LiveInviteInfo(连麦人信息model)中定义方法：

```objectivec
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
```
未定义的key值，避免崩溃。

12. 连麦请求失败3002,

```
class: <0x1701d2c00 AlivcRequestManager.m:(36) > method: -[AlivcRequestManager requestWithHost:param:block:]_block_invoke 
host: videocall/feedback *** response:{
    code = 3002;
    data = 3;
    message = "\U8fde\U9ea6\U89c2\U4f17\U4e0d\U80fd\U8d85\U8fc73\U4e2a";
}
```

2017-11-09 17:21:18.864968+0800 ALiveDemo[1636:565919] message:连麦观众不能超过3个。

13. 经常会因为主播端未关闭直播而退出应用时，或崩溃时，造成直播列表中出现重复数据的情况。

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

Tusdk.VideoEditor.Demo
======================



## 1. Editor操作

### 1. 从Config创建

```objective-c

    //设置画布宽高
    TUPVEditor_Config* veconfig = [[TUPVEditor_Config alloc] init];
    veconfig.width = 600;
    veconfig.height = 800;


    TUPVEditor* editor = [[TUPVEditor alloc] init];
    ret = [editor createWithConfig:veconfig];


```

### 2. 从草稿创建

```objective-c

    //TUPVEditorEditorModel* model = editor.getModel;
    //file_content,从文件读取的字符串
    TUPVEditorEditorModel* model = [[TUPVEditorEditorModel alloc] initWithString:file_content];
   
    //...
    TUPVEditor* neditor = [[TUPVEditor alloc] init];
    ret = [neditor createWithModel:model];


```


### 3. 释放

```objective-c

    [editor destroy];

```

### 4. 更新画布大小

```objective-c

    TUPVEditor_Config* oconfig = editor.getConfig;
    oconfig.width = 1000;
    oconfig.height = 1000;
    ret = [editor updateWithConfig:oconfig];

```

### 5. 播放器


```objective-c

    // setup DisplayView
    //TUPDisplayView* displayView
    
    [displayView setup:nil];

    // setup player
    TUPVEditorPlayer* player = [editor newPlayer];

    ret = [player open];
    player.delegate = self;

    // 关联 DisplayView 和 Player
    [displayView attachPlayer:player];


    // ..............
    // ..............



    //释放顺序
    [displayView teardown];
    [player close];

    

```

### 6. 文件导出

```objective-c

    // setup player
    TUPVEditorProducer* producer = [editor newProducer];

    ///保存路径
    producer.savePath = outputPath;
    ///导出状态delegate
    producer.delegate = self;
    //[producer setOutputConfig:ocfg];
    ret = [producer open];

    ///开始导出
    ret = [producer start];

    
    // ..............
    // ..............

    ///取消导出
    [producer cancel];

    [producer close];

```



## 1. Clip

```objective-c

    //设置audio clip
    TUPConfig* config = [[TUPConfig alloc] init];
    [config setString:url2.absoluteString forKey:@"path"];
    [config setNumber:@(20000) forKey:@"trim-duration"];

    ///创建audio clip
    TUPVEditorClip* clip0 = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
    ///设置/更新Config
    ret = [clip0 setConfig:config];

    ///激活 clip, 如果返回错误, 则表示参数/文件有错误
    ret = clip0.activate;

    ///获取音/视频流信息(宽高帧率时长/采样率通道时长...)
    TUPStreamInfo* si = clip0.getStreamInfo;

    ///添加clip到layer
    ret = [alayer addClip:clip0 at:30];


    ///更新config;
    [config setNumber:@(25000) forKey:@"trim-duration"];
    ret = [clip0 setConfig:config];

```



## 2. Effect

```objective-c

    ///创建Effect
    TUPVEditorEffect* ee = [[TUPVEditorEffect alloc] init:ctx withType:TUPVECanvasResizeEffect_TYPE_NAME];
    ///如果该Effect需要Config,则设置Config
    ret = [ee setConfig:config];

    ///给clip设置Effect
    [clip.effects addEffect:ee at:111];
    ///也可以给layer设置Effect
    [layer.effects addEffect:ee at:111];

    ///之后也可以更新Config
    ret = [ee setConfig:config];


```


## 3. Layer

目前只要一种Layer类型: ClipLayer, 作为clip容器, 支持转场功能

```objective-c


    ///创建layer,然后设置参数
    TUPVEditorClipLayer* layer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
    TUPConfig* lconfig0 = [[TUPConfig alloc] init];
    
    //layer在Composition上的起始位置
    [lconfig0 setNumber:@(2000) forKey:TUPVEditorLayer_CONFIG_START_POS];
    //layer在Composition上的混合模式
    [lconfig0 setString:TUPVEditorLayerBlendMode_Screen forKey:TUPVEditorLayer_CONFIG_BLEND_MODE];

    layer.config = lconfig0;


    ///添加2个clip,clip0在clip1前, 根据index从小到大排列
    ret = [layer addClip:clip0 at:100];
    ret = [layer addClip:clip1 at:200];


    ///添加转场, 在index为200的clip头上添加转场
    TUPVEditorClipLayer_Transition transition;
    transition.duration = 2000;
    transition.name = @"fade";
    [layer setTransition:&transition at:200];


    //ret = layer.activate;
    

    ///将layer添加到Composition
    [videoComp addLayer:layer at:100];


    ///之后也可以更新Config
    ret = [layer setConfig:lconfig1];


```


## Player与Editor交互流程


1. Lock 播放器`player.lock`
1. 更新 Clip/Effect/Layer`[* setConfig:cfg]`
1. 重建 Editor`editor.build`
1. Unlock 播放器`player.unlock`
1. 播放器 Seek`[player seek:ts]`



## Property

用于对Clip/Effect/Layer设置属性,
Property与Config的不同之处在于,Config设置更新后,必须重建Editor(`editor.build`), Property设置后能立即生效


```objectivec


    //
    TUPVECanvasResizeEffect_PropertyBuilder* propBuilder = [[TUPVECanvasResizeEffect_PropertyBuilder alloc] init];
    propBuilder.color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
    propBuilder.panX = 0;
    propBuilder.panY = 0;

    TUPProperty* prop = [propBuilder makeProperty];
    [_effect setProperty:prop forKey:TUPVECanvasResizeEffect_PROP_PARAM];
    


```


## 其他说明

1. 所有Editor有关的接口,强制在同一个线程里调用
1. 
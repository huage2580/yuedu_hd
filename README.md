# 三目阅读 

## 声明
感谢 飞哥的开源项目[阅读](https://github.com/gedoor/legado)  
任何使用本项目二次开发的，均需开源且在关于页面和仓库readme注明  
https://github.com/gedoor/legado  
https://github.com/huage2580/yuedu_hd  


## releases
[安卓apk,和windows版本](https://github.com/huage2580/yuedu_hd/releases)  
[IOS](https://apps.apple.com/cn/app/%E9%98%85%E8%AF%BBHD/id1544754759) 也可以appstore 搜索'三目阅读'  


## 截图  
![1](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/1242x2688bb%201.png)
![1](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/1242x2688bb.png)
![1](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/1242x2688bb2.png)
![2](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/2732x2048bb%201.png)
![2](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/2732x2048bb.png)

## windows编译问题
release 模式可能无法编译  quickjs.c文件，添加上面两行pragma
```
#pragma function (ceil)
#pragma function (floor)

static const JSCFunctionListEntry js_math_funcs[] = {
```

## 支持下作者
![1](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/IMG_0781(20201217-231645).JPG)
![1](https://github.com/huage2580/yuedu_hd/raw/master/screenshot/IMG_0782(20201217-231834).JPG)


## 免责声明

三目阅读(以下简称为阅读)是一款提供网络文学搜索的工具，为广大网络文学爱好者提供一种方便、快捷舒适的试读体验。

当您搜索一本书的时，阅读会将该书的书名以关键词的形式提交到各个第三方网络文学网站。 各第三方网站返回的内容与阅读无关，阅读对其概不负责，亦不承担任何法律责任。 任何通过使用阅读而链接到的第三方网页均系他人制作或提供，您可能从第三方网页上获得其他服务， 阅读对其合法性概不负责，亦不承担任何法律责任。 第三方搜索引擎结果根据您提交的书名自动搜索获得并提供试读， 不代表阅读赞成或被搜索链接到的第三方网页上的内容或立场。 您应该对使用搜索引擎的结果自行承担风险。

阅读不做任何形式的保证：不保证第三方搜索引擎的搜索结果满足您的要求， 不保证搜索服务不中断，不保证搜索结果的安全性、正确性、及时性、合法性。 因网络状况、通讯线路、第三方网站等任何原因而导致您不能正常使用阅读， 阅读不承担任何法律责任。阅读尊重并保护所有使用阅读用户的个人隐私权。

阅读致力于最大程度地减少网络文学阅读者在自行搜寻过程中的无意义的时间浪费， 通过专业搜索展示不同网站中网络文学的最新章节。 阅读在为广大小说爱好者提供方便、快捷舒适的试读体验的同时， 也使优秀网络文学得以迅速、更广泛的传播，从而达到了在一定程度促进网络文学充分繁荣发展之目的。

阅读鼓励广大小说爱好者通过阅读发现优秀网络小说及其提供商， 并建议阅读正版图书。 任何单位或个人认为通过阅读搜索链接到的第三方网页内容可能涉嫌侵犯其信息网络传播权， 应该及时向阅读提出书面权力通知，并提供身份证明、权属证明及详细侵权情况证明。 阅读在收到上述法律文件后，将会依法尽快断开相关链接内容。


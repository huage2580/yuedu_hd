

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/settings/MoreStyleSettingsMenu.dart';

class PageSettings extends StatefulWidget{
  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Text('阅读设置',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  MoreStyleSettingsMenu(),
                  Container(margin: EdgeInsets.only(top: 10,bottom: 10),child: Text('关于',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),)),
                  AboutListTile(applicationName: '阅读HD',applicationVersion: 'ver 1.0.2',applicationLegalese: '开源地址\nhttps://github.com/huage2580/yuedu_HD\n参考实现[阅读安卓版]:\n https://github.com/gedoor/legado',),
                  ListTile(title: Text('用户协议'),trailing: Icon(Icons.arrow_forward_ios_rounded),onTap: (){
                    pushTextPage('用户协议', '''
4.10 您了解并同意，本平台不对因下述任一情况而导致您的任何损害赔偿承担责任，包括但不限于利润财产、商誉、数据等方面的损失或其它损失的损害赔偿(无论本平台是否已被告知该等损害赔偿的可能性)：
4.10.1 使用或未能使用本平台服务；
4.10.2 第三方未经批准或授权即使用您的账户或更改您的数据；
4.10.3 通过本平台服务获取任何产品、服务、数据、信息或进行与其他用户交易等行为或替代行为产生的费用及损失；
4.10.4 您对本平台服务的误解（由于您阅读平台协议或操作、使用本平台时因个人理解问题而造成的认知偏差）；
4.10.5 任何非因本平台的原因而引起的与本平台服务有关的其它损失。

4.11 在何种情况下，本平台均不对由于信息网络正常的设备维护，信息网络连接故障，电脑、通讯或其他系统的故障，电力故障，罢工，劳动争议，暴乱，起义，骚乱，生产力或生产资料不足，火灾，洪水，风暴，爆炸，战争，政府行为，司法行政机关的命令或第三方机构的不作为而造成的不能服务或延迟服务承担责任。
                    
                    ''');
                  },),
                  ListTile(title: Text('隐私协议'),trailing: Icon(Icons.arrow_forward_ios_rounded),onTap: (){
                    pushTextPage('阅读HD隐私政策', '''
阅读HD隐私政策
阅读HD尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，阅读HD会按照本隐私权政策的规定使用和披露您的个人信息。但阅读HD将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，阅读HD不会将这些信息对外披露或向第三方提供。阅读HD会不时更新本隐私权政策。您在同意阅读HD服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于阅读HD服务使用协议不可分割的一部分。

一：适用范围
在您注册阅读HD帐号时，您根据阅读HD要求提供的个人注册信息；

在您使用阅读HD网络服务，或访问阅读HD平台网页时，阅读HD自动接收并记录的您的浏览器和计算机上的信息，包括但不限于您的IP地址、浏览器的类型、使用的语言、访问日期和时间、软硬件特征信息及您需求的网页记录等数据；

阅读HD通过合法途径从商业伙伴处取得的用户个人数据。

您了解并同意，以下信息不适用本隐私权政策：

您在使用阅读HD平台提供的搜索服务时输入的关键字信息；

阅读HD收集到的您在阅读HD发布的有关信息数据，包括但不限于参与活动、成交信息及评价详情；

违反法律规定或违反阅读HD规则行为及阅读HD已对您采取的措施。

二：信息使用
阅读HD不会向任何无关第三方提供、出售、出租、分享或交易您的个人信息，除非事先得到您的许可，或该第三方和阅读HD（含阅读HD关联公司）单独或共同为您提供服务，且在该服务结束后，其将被禁止访问包括其以前能够访问的所有这些资料。

阅读HD亦不允许任何第三方以任何手段收集、编辑、出售或者无偿传播您的个人信息。任何阅读HD平台用户如从事上述活动，一经发现，阅读HD有权立即终止与该用户的服务协议。

为服务用户的目的，阅读HD可能通过使用您的个人信息，向您提供您感兴趣的信息，包括但不限于向您发出产品和服务信息，或者与阅读HD合作伙伴共享信息以便他们向您发送有关其产品和服务的信息（后者需要您的事先同意）。

三：信息披露
在如下情况下，阅读HD将依据您的个人意愿或法律的规定全部或部分的披露您的个人信息：

经您事先同意，向第三方披露；

为提供您所要求的产品和服务，而必须和第三方分享您的个人信息；

根据法律的有关规定，或者行政或司法机构的要求，向第三方或者行政、司法机构披露；

如您出现违反中国有关法律、法规或者阅读HD服务协议或相关规则的情况，需要向第三方披露；

如您是适格的知识产权投诉人并已提起投诉，应被投诉人要求，向被投诉人披露，以便双方处理可能的权利纠纷；

在阅读HD平台上创建的某一交易中，如交易任何一方履行或部分履行了交易义务并提出信息披露请求的，阅读HD有权决定向该用户提供其交易对方的联络方式等必要信息，以促成交易的完成或纠纷的解决。

其它阅读HD根据法律、法规或者网站政策认为合适的披露。

四：信息存储和交换
阅读HD收集的有关您的信息和资料将保存在阅读HD及（或）其关联公司的服务器上，这些信息和资料可能传送至您所在国家、地区或阅读HD收集信息和资料所在地的境外并在境外被访问、存储和展示。

五：Cookie的使用
在您未拒绝接受cookies的情况下，阅读HD会在您的计算机上设定或取用cookies，以便您能登录或使用依赖于cookies的阅读HD平台服务或功能。阅读HD使用cookies可为您提供更加周到的个性化服务，包括推广服务。

您有权选择接受或拒绝接受cookies。您可以通过修改浏览器设置的方式拒绝接受cookies。但如果您选择拒绝接受cookies，则您可能无法登录或使用依赖于cookies的阅读HD网络服务或功能。

通过阅读HD所设cookies所取得的有关信息，将适用本政策。

六：信息安全
阅读HD帐号均有安全保护功能，请妥善保管您的用户名及密码信息。阅读HD将通过对用户密码进行加密等安全措施确保您的信息不丢失，不被滥用和变造。尽管有前述安全措施，但同时也请您注意在信息网络上不存在“完善的安全措施”。

在使用阅读HD网络服务进行网上交易时，您不可避免的要向交易对方或潜在的交易对方披露自己的个人信息，如联络方式或者邮政地址。请您妥善保护自己的个人信息，仅在必要的情形下向他人提供。如您发现自己的个人信息泄密，尤其是阅读HD用户名及密码发生泄露，请您立即联络阅读HD客服，以便阅读HD采取相应措施。

Read HD privacy policy
Read HD respects and protects the personal privacy of all service users. In order to provide you with more accurate and personalized services, Reading HD will use and disclose your personal information in accordance with the provisions of this privacy policy. But reading HD will treat this information with a high degree of diligence and prudence. Except as otherwise provided in this privacy policy, reading HD will not disclose this information or provide it to a third party without your prior permission. Reading HD will update this privacy policy from time to time. When you agree to read the HD service use agreement, you are deemed to have agreed to the entire content of this privacy policy. This privacy policy is an integral part of the read HD service usage agreement.

One: scope of application
When you register for reading HD account, you provide personal registration information according to the requirements of reading HD;

When you use the reading HD network service or access the reading HD platform webpage, the information on your browser and computer that is automatically received and recorded by the reading HD, including but not limited to your IP address, browser type, and language used , Access date and time, software and hardware characteristics information and web page records you need;

Read the user's personal data obtained by HD from business partners through legal channels.

You understand and agree that the following information does not apply to this privacy policy:

The keyword information you enter when you use the search service provided by the HD platform;

Read the relevant information and data collected by HD that you are reading HD, including but not limited to participating activities, transaction information and evaluation details;

Violation of legal regulations or violations of the rules of reading HD and the measures taken against you by reading HD.

Two: Information Use
Reading HD will not provide, sell, rent, share or trade your personal information to any unrelated third party, unless you have obtained your permission in advance, or that third party and Reading HD (including Reading HD affiliates) will provide you individually or jointly Service, and after the service ends, it will be prohibited from accessing all these materials that it was able to access before.

Reading HD also does not allow any third party to collect, edit, sell or disseminate your personal information by any means. If any user of the reading HD platform engages in the above activities, once discovered, reading HD has the right to immediately terminate the service agreement with the user.

For the purpose of serving users, reading HD may use your personal information to provide you with information you are interested in, including but not limited to sending you product and service information, or sharing information with its partners so that they can send you Information about its products and services (the latter requires your prior consent).

Three: Information disclosure
Under the following circumstances, Read HD will disclose your personal information in whole or in part in accordance with your personal wishes or legal requirements:

With your prior consent, disclose to a third party;

In order to provide the products and services you request, you must share your personal information with third parties;

Disclosure to a third party or administrative or judicial institution in accordance with relevant provisions of the law or the requirements of administrative or judicial institutions;

If you violate relevant Chinese laws, regulations, or read the HD service agreement or related rules, you need to disclose to a third party;

If you are a qualified intellectual property complaint and have filed a complaint, you should disclose it to the respondent at the request of the respondent so that both parties can handle possible rights disputes;

In a transaction created on the Reading HD platform, if any party to the transaction fulfills or partially fulfills its transaction obligations and makes an information disclosure request, Reading HD has the right to decide to provide the user with the necessary information such as the contact information of the counterparty to the transaction. Facilitate the completion of the transaction or the settlement of disputes.

Other reading HD according to laws, regulations or website policies deem appropriate disclosures.

Four: Information storage and exchange
The information and data about you collected by reading HD will be stored on the servers of reading HD and/or its affiliates. These information and data may be transmitted to your country or region or abroad where the information and data collected by reading HD are located. Visited, stored and displayed outside the country.

Five: Use of Cookies
If you do not refuse to accept cookies, ReadHD will set or access cookies on your computer so that you can log in or use the ReadHD platform services or functions that rely on cookies. Reading HD using cookies can provide you with more thoughtful and personalized services, including promotional services.

You have the right to choose to accept or refuse to accept cookies. You can refuse to accept cookies by modifying your browser settings. But if you choose to refuse to accept cookies, you may not be able to log in or use the read HD network services or functions that rely on cookies.

This policy will apply to the relevant information obtained by reading the cookies set by HD.

Six: Information Security
Reading HD account has security protection function, please keep your user name and password information properly. Reading HD will ensure that your information is not lost, abused and altered by encrypting user passwords and other security measures. Despite the aforementioned security measures, please note that there is no "perfect security measure" on the information network.

When using the reading HD network service to conduct online transactions, you will inevitably disclose your personal information, such as contact information or postal address, to the counterparty or potential counterparty. Please properly protect your personal information and only provide it to others when necessary. If you find that your personal information has been leaked, especially when reading HD username and password are leaked, please contact the reading HD customer service immediately so that reading HD can take corresponding measures.
                    
                    ''');
                  },),
                  ListTile(title: Text('免责声明'),trailing: Icon(Icons.arrow_forward_ios_rounded),onTap: (){
                    pushTextPage('免责声明', '''
                    阅读HD(以下简称为阅读)是一款提供网络文学搜索的工具，为广大网络文学爱好者提供一种方便、快捷舒适的试读体验。

当您搜索一本书的时，阅读会将该书的书名以关键词的形式提交到各个第三方网络文学网站。 各第三方网站返回的内容与阅读无关，阅读对其概不负责，亦不承担任何法律责任。 任何通过使用阅读而链接到的第三方网页均系他人制作或提供，您可能从第三方网页上获得其他服务， 阅读对其合法性概不负责，亦不承担任何法律责任。 第三方搜索引擎结果根据您提交的书名自动搜索获得并提供试读， 不代表阅读赞成或被搜索链接到的第三方网页上的内容或立场。 您应该对使用搜索引擎的结果自行承担风险。

阅读不做任何形式的保证：不保证第三方搜索引擎的搜索结果满足您的要求， 不保证搜索服务不中断，不保证搜索结果的安全性、正确性、及时性、合法性。 因网络状况、通讯线路、第三方网站等任何原因而导致您不能正常使用阅读， 阅读不承担任何法律责任。阅读尊重并保护所有使用阅读用户的个人隐私权。

阅读致力于最大程度地减少网络文学阅读者在自行搜寻过程中的无意义的时间浪费， 通过专业搜索展示不同网站中网络文学的最新章节。 阅读在为广大小说爱好者提供方便、快捷舒适的试读体验的同时， 也使优秀网络文学得以迅速、更广泛的传播，从而达到了在一定程度促进网络文学充分繁荣发展之目的。

阅读鼓励广大小说爱好者通过阅读发现优秀网络小说及其提供商， 并建议阅读正版图书。 任何单位或个人认为通过阅读搜索链接到的第三方网页内容可能涉嫌侵犯其信息网络传播权， 应该及时向阅读提出书面权力通知，并提供身份证明、权属证明及详细侵权情况证明。 阅读在收到上述法律文件后，将会依法尽快断开相关链接内容。
                    
                    ''');
                  },),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pushTextPage(String title,String text){
    YDRouter.mainRouter.currentState.push(MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(title: Text(title),),
        body: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Container(margin: EdgeInsets.all(16),child: Text(text)),
          ),
        ),
      );
    }));
  }

}
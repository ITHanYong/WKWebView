# WKWebView
WKWebView的基本应用
一、WKWebView从头文件开始介绍
```
// webview 配置，具体看下面
@property (nonatomic, readonly, copy) WKWebViewConfiguration *configuration;
 
// 导航代理 
@property (nullable, nonatomic, weak) id <WKNavigationDelegate>navigationDelegate;
 
// 用户交互代理
@property (nullable, nonatomic, weak) id <WKUIDelegate> UIDelegate;
 
// 页面前进、后退列表
@property (nonatomic, readonly, strong) WKBackForwardList *backForwardList;
 
// 默认构造器
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_DESIGNATED_INITIALIZER;
 
// 已不再使用
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
 
// 与UIWebView一样的加载请求API
- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request;
 
// 加载URL
- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL NS_AVAILABLE(10_11, 9_0);
 
// 直接加载HTML
- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;
 
// 直接加载data
- (nullable WKNavigation *)loadData:(NSData *)data MIMEType:(NSString*)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL NS_AVAILABLE(10_11, 9_0);
 
// 前进或者后退到某一页面
- (nullable WKNavigation *)goToBackForwardListItem:(WKBackForwardListItem*)item;
 
// 页面的标题，这昆支持KVO的
@property (nullable, nonatomic, readonly, copy) NSString *title;
 
// 当前请求的URL，它是支持KVO的
@property (nullable, nonatomic, readonly, copy) NSURL *URL;
 
// 标识当前是否正在加载内容中，它是支持KVO的
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
 
// 当前加载的进度，范围为[0, 1]
@property (nonatomic, readonly) double estimatedProgress;
 
// 标识页面中的所有资源是否通过安全加密连接来加载，它是支持KVO的
@property (nonatomic, readonly) BOOL hasOnlySecureContent;
 
// 当前导航的证书链，支持KVO
@property (nonatomic, readonly, copy) NSArray *certificateChainNS_AVAILABLE(10_11, 9_0);
 
// 是否可以招待goback操作，它是支持KVO的
@property (nonatomic, readonly) BOOL canGoBack;
 
// 是否可以执行gofarward操作，支持KVO
@property (nonatomic, readonly) BOOL canGoForward;
 
// 返回上一页面，如果不能返回，则什么也不干
- (nullable WKNavigation *)goBack;
 
// 进入下一页面，如果不能前进，则什么也不干
- (nullable WKNavigation *)goForward;
 
// 重新载入页面
- (nullable WKNavigation *)reload;
 
// 重新从原始URL载入
- (nullable WKNavigation *)reloadFromOrigin;
 
// 停止加载数据
- (void)stopLoading;
 
// 执行JS代码
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler;
 
// 标识是否支持左、右swipe手势是否可以前进、后退
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;
 
// 自定义user agent，如果没有则为nil
@property (nullable, nonatomic, copy) NSString *customUserAgentNS_AVAILABLE(10_11, 9_0);
 
// 在iOS上默认为NO，标识不允许链接预览
@property (nonatomic) BOOL allowsLinkPreview NS_AVAILABLE(10_11, 9_0);
 
#if TARGET_OS_IPHONE
/*! @abstract The scroll view associated with the web view.
*/
@property (nonatomic, readonly, strong) UIScrollView *scrollView;
#endif
 
#if !TARGET_OS_IPHONE
// 标识是否支持放大手势，默认为NO
@property (nonatomic) BOOL allowsMagnification;
 
// 放大因子，默认为1
@property (nonatomic) CGFloat magnification;
 
// 根据设置的缩放因子来缩放页面，并居中显示结果在指定的点
- (void)setMagnification:(CGFloat)magnification centeredAtPoint:(CGPoint)point;
 
#endif
```
二、介绍涉及到的类
1、WKWebViewConfiguration 配置
```
// 设置偏好设置
config.preferences = [[WKPreferences alloc] init];
// 默认为0
config.preferences.minimumFontSize = 10;
// 默认认为YES
config.preferences.javaScriptEnabled = YES;
// 在iOS上默认为NO，表示不能自动通过窗口打开
config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
```
2、WKProcessPool 内容处理池
```
config.processPool = [[WKProcessPool alloc] init];
//该类没有可用的方法和属性
```
3、WKUserContentController 内容交互控制器
```
// 只读属性，所有添加的WKUserScript都在这里可以获取到
@property (nonatomic, readonly, copy) NSArray<WKUserScript *> *userScripts;
 
// 注入JS
- (void)addUserScript:(WKUserScript *)userScript;
 
// 移除所有注入的JS
- (void)removeAllUserScripts;
 
// 添加scriptMessageHandler到所有的frames中，则都可以通过
// window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
// 发送消息
// 比如，JS要调用我们原生的方法，就可以通过这种方式了
- (void)addScriptMessageHandler:(id<WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
 
// 根据name移除所注入的scriptMessageHandler
- (void)removeScriptMessageHandlerForName:(NSString *)name;
 
```
4、WKUserScript 在WKUserContentController中，所有使用到WKUserScript。WKUserContentController是用于与JS交互的类，而所注入的JS是WKUserScript对象。它的所有属性和方法如下
```
// JS源代码
@property (nonatomic, readonly, copy) NSString *source;
 
// JS注入时间
@property (nonatomic, readonly) WKUserScriptInjectionTime injectionTime;
 
// 只读属性，表示JS是否应该注入到所有的frames中还是只有main frame.
@property (nonatomic, readonly, getter=isForMainFrameOnly) BOOLforMainFrameOnly;
 
// 初始化方法，用于创建WKUserScript对象
// source：JS源代码
// injectionTime：JS注入的时间
// forMainFrameOnly：是否只注入main frame
- (instancetype)initWithSource:(NSString *)source injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
 
```
5、WKUserScriptInjectionTime
```
typedef NS_ENUM(NSInteger, WKUserScriptInjectionTime) {
    WKUserScriptInjectionTimeAtDocumentStart,
    WKUserScriptInjectionTimeAtDocumentEnd
} NS_ENUM_AVAILABLE(10_10, 8_0);
 //它是一个枚举类型，只有在文档开始加载时注入和加载结束时注入。

```
6、WKWebsiteDataStore 存储的Web内容
```
//iOS9.0以后才能使用这个类。它是代表webview不同的数据类型，包括cookies、disk、memory caches、WebSQL、IndexedDB数据库和本地存储。

//从这里看，要优化Webview好像可以通过它来实现，不过要求iOS9.0以上才能使用。现在6.0都没有抛弃的我，从来不能考虑这种最新的。

// 默认数据存储
+ (WKWebsiteDataStore *)defaultDataStore;
 
// 返回非持久化存储，数据不会写入文件系统
+ (WKWebsiteDataStore *)nonPersistentDataStore;
 
// 已经不可用
- (instancetype)init NS_UNAVAILABLE;
 
// 只读属性，表示是否是持久化存储
@property (nonatomic, readonly, getter=isPersistent) BOOL persistent;
 
// 获取所有web内容的数据存储类型集，比如cookies、disk等
+ (NSSet<NSString *> *)allWebsiteDataTypes;
 
// 获取某些指定数据存储类型的数据
- (void)fetchDataRecordsOfTypes:(NSSet<NSString *> *)dataTypescompletionHandler:(void (^)(NSArray<WKWebsiteDataRecord *>*))completionHandler;
 
// 删除某些指定类型的数据
- (void)removeDataOfTypes:(NSSet<NSString *> *)dataTypes forDataRecords:(NSArray<WKWebsiteDataRecord *> *)dataRecords completionHandler:(void (^)(void))completionHandler;
 
// 删除某些指定类型的数据且修改日期是指定的日期
- (void)removeDataOfTypes:(NSSet<NSString *> *)websiteDataTypes modifiedSince:(NSDate *)date completionHandler:(void (^)(void))completionHandler;
 
```
所有的dataTypes是下面这些系统所定义的：
```
WK_EXTERN NSString * const WKWebsiteDataTypeDiskCache NS_AVAILABLE(10_11, 9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeMemoryCache NS_AVAILABLE(10_11,9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeOfflineWebApplicationCacheNS_AVAILABLE(10_11, 9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeCookies NS_AVAILABLE(10_11, 9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeSessionStorage NS_AVAILABLE(10_11,9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeLocalStorage NS_AVAILABLE(10_11,9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeWebSQLDatabases NS_AVAILABLE(10_11,9_0);
 
WK_EXTERN NSString * const WKWebsiteDataTypeIndexedDBDatabasesNS_AVAILABLE(10_11, 9_0);
```
7、WKWebsiteDataRecord
//iOS9.0以后才可用。
//website的数据存储记录类型，它只有两个属性：
```
// 通常是域名
@property (nonatomic, readonly, copy) NSString *displayName;
 
// 存储的数据类型集
@property (nonatomic, readonly, copy) NSSet<NSString *> *dataTypes;
```
7、WKSelectionGranularity 选择粒度
//它表示在webview上选择内容的粒度，只有下面这两种类型
```
typedef NS_ENUM(NSInteger, WKSelectionGranularity) {
    WKSelectionGranularityDynamic,
    WKSelectionGranularityCharacter,
} NS_ENUM_AVAILABLE_IOS(8_0);

//它是用于webview内容交互时选择内容的粒度类型设置。比如说，当使用WKSelectionGranularityDynamic时，而所选择的内容是单个块，这时候granularity可能会是单个字符；当所选择的web内容不限制于某个块时，granularity可能会是单个块。

```
8、WKNavigationDelegate
```
@protocol WKNavigationDelegate <NSObject>
 
@optional
 
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接
// 单独处理。但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
 
// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
 
// 当main frame的导航开始请求时，会调用此方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
 
// 当main frame接收到服务重定向时，会回调此方法
- (void)webView:(WKWebView *)webViewdidReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation*)navigation;
 
// 当main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
 
// 当main frame的web内容开始到达时，会回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;
 
// 当main frame导航完成时，会回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;
 
// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;
 
// 这与用于授权验证的API，与AFN、UIWebView的授权验证API是一样的
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler;
 
// 当web content处理完成时，会回调
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0);
 
@end
```
9、WKNavigationActionPolicy 导航动作决定策略：
```
typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
    WKNavigationActionPolicyCancel,
    WKNavigationActionPolicyAllow,
} NS_ENUM_AVAILABLE(10_10, 8_0);

//它是枚举类型，只有Cancel和Allow这两种。设置为Cancel
```
10、总结
```
WKWebView：网页的渲染与展示，通过WKWebViewConfiguration可以进行自定义配置。
WKWebViewConfiguration：这个类专门用来配置WKWebView。
WKPreference:这个类用来进行相关webView设置。
WKProcessPool：这个类用来配置进程池，与网页视图的资源共享有关。
WKUserContentController：这个类主要用来做native与JavaScript的交互管理。
WKUserScript：用于进行JavaScript注入。
WKScriptMessageHandler：这个类专门用来处理JavaScript调用native的方法。
WKNavigationDelegate：网页跳转间的导航管理协议，这个协议可以监听网页的活动。
WKNavigationAction：网页某个活动的示例化对象。
WKUIDelegate：用于交互处理JavaScript中的一些弹出框。
WKBackForwardList：堆栈管理的网页列表。
WKBackForwardListItem：每个网页节点对象。

WKNavigationDelegate: 提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法。
WKUIDelegate: 提供用原生控件显示网页的方法回调。
WKScriptMessageHandler: 提供从网页中收消息的回调方法。
```

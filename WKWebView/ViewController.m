//
//  ViewController.m
//  WKWebView
//
//  Created by HanYong on 2020/7/9.
//  Copyright © 2020 HanYong. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, assign) BOOL shouldStartLoadWithRequest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 设置访问的URL
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

//实现WKScriptMessageHandler协议方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 判断是否是调用原生的
   if ([@"NativeMethod" isEqualToString:message.name]) {
       // 判断message的内容，然后做相应的操作
       if ([@"close" isEqualToString:message.body]) {
           
       }
   //注意：上面将当前ViewController设置为MessageHandler之后需要在当前ViewController销毁前将其移除，否则会造成内存泄漏。
       [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"NativeMethod"];
   }
}

#pragma mark - WKNavigationDelegate代理方法
/*
 如果实现了代理方法，一定要在decidePolicyForNavigationAction和decidePolicyForNavigationResponse方法中的回调设置允许跳转。
 typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
 WKNavigationActionPolicyCancel, // 取消跳转
 WKNavigationActionPolicyAllow, // 允许跳转
 } API_AVAILABLE(macosx(10.10), ios(8.0));
 */

// 1 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"1-------在发送请求之前，决定是否跳转  -->%@",navigationAction.request);
    if (self.shouldStartLoadWithRequest) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }else{
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
}

// 2 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"2-------页面开始加载时调用");
}

// 3 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
    NSLog(@"3-------在收到响应后，决定是否跳转");
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 4 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"4-------当内容开始返回时调用");
}

// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"5-------页面加载完成之后调用");
}

// 6 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"6-------页面加载失败时调用");
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"-------接收到服务器跳转请求之后调用");
}

// 数据加载发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"----数据加载发生错误时调用");
}

// 需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    //用户身份信息
    NSLog(@"----需要响应身份验证时调用 同样在block中需要传入用户身份凭证");
    NSURLCredential *newCred = [NSURLCredential credentialWithUser:@""
                                                          password:@""
                                                       persistence:NSURLCredentialPersistenceNone];
    // 为 challenge 的发送方提供 credential
    [[challenge sender] useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}

// 进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"----------进程被终止时调用");
}

#pragma mark - WKUIDelegate代理方法
/// web界面中有弹出警告框时调用
/// @param webView 实现该代理的webview
/// @param message 警告框中的内容
/// @param frame 弹窗的frame
/// @param completionHandler 警告框消失调用
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"-------web界面中有弹出警告框时调用");
}

// 创建新的webView时调用的方法
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {

    NSLog(@"-----创建新的webView时调用的方法");
    return webView;
}

// 关闭webView时调用的方法
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"----关闭webView时调用的方法");
}

// 下面这些方法是交互JavaScript的方法
// JavaScript调用confirm方法后回调的方法 confirm是js中的确定框，需要在block中把用户选择的情况传递进去
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"%@",message);
    completionHandler(YES);
}
// JavaScript调用prompt方法后回调的方法 prompt是js中的输入框 需要在block中把用户输入的信息传入
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    NSLog(@"%@",prompt);
    completionHandler(@"123");
}

//显示一个文件上传面板。completionhandler完成处理程序调用后打开面板已被撤销。通过选择的网址，如果用户选择确定，否则为零。如果不实现此方法，Web视图将表现为如果用户选择了取消按钮。
- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler {
    NSLog(@"----显示一个文件上传面板");
}

-(WKWebView *)webView{
    if (!_webView) {
        /*
         //简单使用，直接加载url地址
         _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
         [self.view addSubview:_webView];
         */
        
        // 创建UserContentController（提供JavaScript向webView发送消息的方法）
        WKUserContentController* userContent = [[WKUserContentController alloc] init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [userContent addScriptMessageHandler:self name:@"NativeMethod"];
        // 创建配置
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 将UserConttentController设置到配置文件
        config.userContentController = userContent;
        // 高端的自定义配置创建WKWebView
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

@end

//
//  ViewController.m
//  PopOnChatPalAUserSDK
//
//  Created by Yang on 2019/1/22.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * webview;

@property (nonatomic, strong) UIView    * progressView;
@property (nonatomic, weak)   UIButton  * reloadBtn;
@property (nonatomic, strong) NSTimer   * timer;

@end

@implementation ViewController {
    NSString * _url;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://manage.suanlimao.net"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    [self.webview loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadAnimation) userInfo:nil repeats:YES];
    self.progressView.alpha = 1;
    self.progressView.frame = CGRectMake(0, 0, 0, 3);
    self.reloadBtn.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self completeAnimation];

    if (!self.title || self.title.length == 0) self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self completeAnimation];
    
    NSDictionary *errorInfo = error.userInfo;
    NSString *failUrl = [NSString stringWithFormat:@"%@",[errorInfo valueForKey:@"NSErrorFailingURLKey"]];
    if ([failUrl containsString:@"rrcc://"]) return;
    self.reloadBtn.hidden = NO;
}

//MARK: - webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *semaphore = request.URL.absoluteString;
    NSLog(@"yangjing_%@: semaphore = %@", NSStringFromClass([self class]), semaphore);
  
    return YES;
}

- (void)loadAnimation {
    if (self.progressView.frame.size.width <= CGRectGetWidth([UIScreen mainScreen].bounds)*(2/3.0)) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = self.progressView.frame;
            rect.size.width += arc4random()%50;
            self.progressView.frame = rect;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)completeAnimation {
    if(self.timer) {
        [self.timer invalidate];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (self.progressView) {
                CGRect rect = self.progressView.frame;
                rect.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
                self.progressView.frame = rect;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                if (self.progressView) {
                    self.progressView.alpha = 0;
                }
            }];
        }];
    }
}

- (void)reloadWebview {
    if ([_url hasPrefix:@"http://"]||
        [_url hasPrefix:@"https://"]) {
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        [self.webview loadRequest:request];
    } else {
        [self.webview loadHTMLString:[NSString stringWithFormat:@"<h5>%@<h5>", _url] baseURL:nil];
    }
}

//MARK: - subview
- (void)addSubViews {
    [self.view addSubview:self.webview];
    self.webview.frame = self.view.bounds;
    
    [self.webview addSubview:self.reloadBtn];
    self.reloadBtn.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2-75, CGRectGetHeight([UIScreen mainScreen].bounds)/2-25, 150, 50);
    
    [self.webview addSubview:self.progressView];
    self.progressView.frame = CGRectMake(0, 0, 0, 3);
    
    self.reloadBtn.hidden = YES;
}

//MARK: - getter
- (UIWebView *)webview {
    if (!_webview) {
        _webview = [[UIWebView alloc] init];
        _webview.backgroundColor = [UIColor whiteColor];
        _webview.scalesPageToFit = YES;
        _webview.delegate = self;
    }
    return _webview;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor yellowColor];
    }
    return _progressView;
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [_reloadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_reloadBtn addTarget:self action:@selector(reloadWebview) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadBtn;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"yangjing_webview: dealloc");
}

@end

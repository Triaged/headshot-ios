//
//  DockedAPIClient.m
//  Docked-ios
//
//  Created by Charlie White on 9/19/13.
//  Copyright (c) 2013 Charlie White. All rights reserved.
//

#import "HeadshotAPIClient.h"
#import "CredentialStore.h"
#import "AppDelegate.h"
#import "Store.h"
#import "TRJSONResponseSerializerWithData.h"
#import "HTTPStatusCodes.h"

@implementation HeadshotAPIClient

+ (instancetype)sharedClient {
    static HeadshotAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *urlString = [[ConstantsManager sharedConstants] APIBaseURLString];
        _sharedClient = [[HeadshotAPIClient alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [TRJSONResponseSerializerWithData serializer];
        [self setAuthTokenHeader];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenChanged:)
                                                     name:@"token-changed"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HTTPOperationDidFinish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    }
    return self;
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification
{
//    log user out if authorization error
    NSError *error = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey];
    if (error) {
        NSHTTPURLResponse *httpResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        if (httpResponse.statusCode == kHTTPStatusCodeUnauthorized){
            [[NSNotificationCenter defaultCenter] postNotificationName:kRequestAuthorizationErrorNotification object:error userInfo:nil];
        }
    }
}

- (void)setAuthTokenHeader {
    CredentialStore *store = [[CredentialStore alloc] init];
    NSString *authToken = [store authToken];
    [self.requestSerializer setValue:authToken forHTTPHeaderField:@"authorization"];
}

- (void)tokenChanged:(NSNotification *)notification {
    [self setAuthTokenHeader];
}

- (void)setUploadProgressForTask:(NSURLSessionTask *)task
                      usingBlock:(void (^)(uint32_t bytesWritten, uint32_t totalBytesWritten, uint32_t totalBytesExpectedToWrite))block {
}

- (void)performMultipartFormRequestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> formData))block completion:(void (^)(id responseObject, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseURL, path];
    NSMutableURLRequest *multipartRequest = [self.requestSerializer multipartFormRequestWithMethod:method URLString:urlString parameters:parameters constructingBodyWithBlock:block error:nil];
    
    // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
    // bug in NSURLSessionTask.
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    [self.requestSerializer requestWithMultipartFormRequest:multipartRequest
                                writingStreamContentsToFile:tmpFileUrl
                                          completionHandler:^(NSError *error) {
                                              // Once the multipart form is serialized into a temporary file, we can initialize
                                              // the actual HTTP request using session manager.
                                              
                                              // Create default session manager.
                                              AFURLSessionManager *manager = [HeadshotAPIClient sharedClient];
                                              
                                              // Show progress.
                                              NSProgress *progress = nil;
                                              // Here note that we are submitting the initial multipart request. We are, however,
                                              // forcing the body stream to be read from the temporary file.
                                              NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:multipartRequest
                                                                                                         fromFile:tmpFileUrl
                                                                                                         progress:&progress
                                                                                                completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
                                                                                    {
                                                                                        // Cleanup: remove temporary file.
                                                                                        [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                                                        
                                                                                        if (completion) {
                                                                                            completion(responseObject, error);
                                                                                        }
                                                                                    }];
                                              [uploadTask resume];
                                          }];
    
}

@end

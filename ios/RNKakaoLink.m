#import "RNKakaoLink.h"
#import <React/RCTLog.h>

#import <KakaoLink/KakaoLink.h>
#import <KakaoMessageTemplate/KakaoMessageTemplate.h>

@implementation RNKakaoLink

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

/** 성공 Callback */
-(KLKTalkLinkSuccessHandler) success:(RCTPromiseResolveBlock) resolve {
    return ^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
        NSDictionary * response=[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"success", argumentMsg, @"argumentMsg", nil];
        resolve(response);
    };
};

/** 실패 Callback */
-(KLKTalkLinkFailureHandler) failure:(RCTPromiseRejectBlock) reject {
    return ^(NSError * _Nonnull error) {
        reject(@"Kakao Link Failure", @"",error);
    };
};

/** 템블릿 보내기 */
-(void) sendTemplate: (KMTTemplate *) template
        serverCallbackArgs:(NSDictionary*) serverCallbackArgs
        resolver: (RCTPromiseResolveBlock) resolve
        rejecter: (RCTPromiseRejectBlock) reject {

    if (serverCallbackArgs == nil) {
        [
            [KLKTalkLinkCenter sharedCenter]
                sendDefaultWithTemplate:template
                success: [self success: resolve]
                failure: [self failure: reject]
        ];
    } else {
        [
            [KLKTalkLinkCenter sharedCenter]
                sendDefaultWithTemplate:template
                serverCallbackArgs:serverCallbackArgs
                success: [self success: resolve]
                failure: [self failure: reject]
        ];
    }
}


/** 링크 생성 */
-(KMTLinkObject *) createKMTLinkObject : (NSDictionary *) link {

    /*
     webURL?                    : NSURL
     mobileWebURL?              : NSURL
     androidExecutionParams?    : NSString
     iosExecutionParams?        : NSString
     */

    KMTLinkObject * linkObject = [KMTLinkObject linkObjectWithBuilderBlock:^(KMTLinkBuilder * _Nonnull linkBuilder) {

        NSString * webURL = [[link objectForKey:@"webURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * mobileWebURL = [[link objectForKey:@"mobileWebURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (webURL != nil) linkBuilder.webURL =[NSURL URLWithString:webURL];
        if (mobileWebURL != nil) linkBuilder.mobileWebURL = [NSURL URLWithString:mobileWebURL];
        if ([link objectForKey:@"androidExecutionParams"] != nil) linkBuilder.androidExecutionParams = [link objectForKey:@"androidExecutionParams"];
        if ([link objectForKey:@"iosExecutionParams"] != nil) linkBuilder.iosExecutionParams = [link objectForKey:@"iosExecutionParams"];
    }];

    return linkObject;
}

/** 컨텐츠 생성 */
-(KMTContentObject *) createKMTContentObject : (NSDictionary *) content {

    /*
     title          : NSString
     link           : KMTLinkObject
     imageURL       : NSString
     desc?          : NSString
     imageWidth?    : NSNumber
     imageHeight?   : NSNumber
     */

    KMTContentObject * contentObject = [KMTContentObject contentObjectWithBuilderBlock:^(KMTContentBuilder * _Nonnull contentBuilder) {

        NSString * title = [content objectForKey:@"title"];
        NSString * imageURL = [[content objectForKey:@"imageURL"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        contentBuilder.title = title;
        contentBuilder.link = [self createKMTLinkObject: ([content objectForKey:@"link"])];
        contentBuilder.imageURL = [NSURL URLWithString:imageURL];

        if ([content objectForKey:@"desc"] != nil) contentBuilder.desc =[content objectForKey:@"desc"];
        if ([content objectForKey:@"imageWidth"] != nil) contentBuilder.imageWidth = [content objectForKey:@"imageWidth"];
        if ([content objectForKey:@"imageHeight"] != nil) contentBuilder.imageHeight = [content objectForKey:@"imageHeight"];
    }];

    return contentObject;
}

/** 버튼 생성 */
-(KMTButtonObject *) createKMTButtonObject : (NSDictionary *) button {

    /*
     title     :NSString
     link      :KMTLinkObject
     */

    KMTButtonObject * buttonObject = [KMTButtonObject buttonObjectWithBuilderBlock:^(KMTButtonBuilder * _Nonnull buttonBuilder) {
        buttonBuilder.title = [button objectForKey:@"title"];
        buttonBuilder.link = [self createKMTLinkObject:[button objectForKey:@"link"]];
    }];

    return buttonObject;
}

/** 템플릿 생성 */
-(KMTFeedTemplate *) createKMTTemplate : (NSDictionary *) options {

    /*
     content        : KMTContentObject
     social?        : KMTSocialObject
     buttonTitle?   : NSString
     buttons?       : NSArray<KMTButtonObject>
     */

    KMTFeedTemplate * feedTemplate = [KMTFeedTemplate feedTemplateWithBuilderBlock:^(KMTFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {

        feedTemplateBuilder.content = [self createKMTContentObject : [options objectForKey:@"content"]];

        // Social 기능은 사용하지 않는다.
        // if([options objectForKey:@"social"] != nil)
        //     feedTemplateBuilder.social = [self createKMTSocialObject:[options objectForKey:@"social"]];

        // 버튼 추가
        if ([options objectForKey:@"buttons"] != nil) {
            NSArray * buttons = [options objectForKey:@"buttons"];
            for (NSDictionary * btn in buttons) {
                [feedTemplateBuilder addButton:[self createKMTButtonObject:btn]];
            }
        }
    }];

    return feedTemplate;
}

/** KakaoLink Share */
RCT_EXPORT_METHOD(share:(NSDictionary *) options
    resolver: (RCTPromiseResolveBlock) resolve
    rejecter: (RCTPromiseRejectBlock) reject
) {
    @try {
        KMTTemplate * template = [self createKMTTemplate:options];
        NSDictionary * serverCallbackArgs = [options objectForKey:@"serverCallbackArgs"];

        [
            self sendTemplate:template
            serverCallbackArgs:serverCallbackArgs
            resolver:resolve
            rejecter:reject
        ];
    } @catch (NSException * e) {
        reject(@"메시지 템플릿을 확인해주세요.(custom 미지원)", @"Wrong Parameters", NULL);
    }
}
































@end

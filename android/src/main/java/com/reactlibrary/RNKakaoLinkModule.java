/**

본 파일의 내용은 https://github.com/shpongle2634/react-native-kakao-links 을 상당부분 참고하였습니다.

지속적 관리를 위하여 kickgoing-app 의 내부 모듈로 동작하도록 구성했습니다.

2019. 1. 10 박현도

 */

package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.WritableMap;

import com.kakao.kakaolink.v2.KakaoLinkService;
import com.kakao.kakaolink.v2.KakaoLinkResponse;
import com.kakao.message.template.FeedTemplate;
import com.kakao.message.template.LinkObject;
import com.kakao.message.template.ButtonObject;
import com.kakao.message.template.SocialObject;
import com.kakao.message.template.ContentObject;
import com.kakao.message.template.CommerceDetailObject;
import com.kakao.message.template.CommerceTemplate;
import com.kakao.util.helper.log.Logger;
import com.kakao.message.template.TemplateParams;
// import com.kakao.message.template.ListTemplate;
// import com.kakao.message.template.LocationTemplate;
// import com.kakao.message.template.TextTemplate;

import com.kakao.network.callback.ResponseCallback;
import com.kakao.network.ErrorResult;

import java.util.Map;
import java.util.HashMap;
import org.json.JSONObject;
import java.util.Iterator;

public class RNKakaoLinkModule extends ReactContextBaseJavaModule {

  class BasicResponseCallback<T> extends ResponseCallback<T>{

    private Promise promise;

    public BasicResponseCallback(Promise promise) {
      this.promise = promise;
    }

    @Override
    public void onFailure(ErrorResult errorResult) {
      Logger.e(errorResult.toString());
      promise.reject(errorResult.getException());
    }

    @Override
    public void onSuccess(T result) {
      // 템플릿 밸리데이션과 쿼터 체크가 성공적으로 끝남. 
      // 톡에서 정상적으로 보내졌는지 보장은 할 수 없다. 전송 성공 유무는 서버콜백 기능을 이용하여야 한다.
      WritableMap map = Arguments.createMap();
      map.putBoolean("success",true);

      KakaoLinkResponse kakaoResponse = (KakaoLinkResponse) result;
      map.putString("argumentMsg",kakaoResponse.getArgumentMsg().toString());
      promise.resolve(map);
    }
  }

  private final ReactApplicationContext reactContext;

  public RNKakaoLinkModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNKakaoLink";
  }

  /** 템플릿 보내기 */
  private void sendTemplate(TemplateParams params, Promise promise, Map<String,String> serverCallbackArgsMap) {
    KakaoLinkService service = KakaoLinkService.getInstance();

    if (serverCallbackArgsMap == null) {
      service.sendDefault(
        this.getCurrentActivity(),
        params,
        new BasicResponseCallback<KakaoLinkResponse>(promise)
      );
    } else {
      service.sendDefault(
        this.getCurrentActivity(),
        params,
        serverCallbackArgsMap,
        new BasicResponseCallback<KakaoLinkResponse>(promise)
      );
    }
  }

  /** 링크 생성 */
  private LinkObject createLinkObject(ReadableMap link) {
    LinkObject.Builder linkObject = LinkObject.newBuilder();

    if(link.hasKey("webURL")) linkObject.setWebUrl(link.getString("webURL"));
    if(link.hasKey("mobileWebURL")) linkObject.setMobileWebUrl(link.getString("mobileWebURL"));
    if(link.hasKey("androidExecutionParams"))  linkObject.setAndroidExecutionParams(link.getString("androidExecutionParams"));
    if(link.hasKey("iosExecutionParams")) linkObject.setIosExecutionParams(link.getString("iosExecutionParams"));

    return linkObject.build();
  }

  /** 컨텐츠 생성 */
  private ContentObject createContentObject(ReadableMap content) {
    ContentObject.Builder contentObject = ContentObject.newBuilder(
      content.getString("title"),
      content.getString("imageURL"),
      createLinkObject(content.getMap("link"))
    );

    if(content.hasKey("desc")) contentObject.setDescrption(content.getString("desc"));
    if(content.hasKey("imageHeight")) contentObject.setImageHeight(content.getInt("imageHeight"));
    if(content.hasKey("imageWidth")) contentObject .setImageWidth(content.getInt("imageWidth"));

    return contentObject.build();
  }

  /** 버튼 생성 */
  private ButtonObject createButtonObject(ReadableMap button) {
    ButtonObject buttonObject = new ButtonObject(
      button.getString("title"),
      createLinkObject(button.getMap("link"))
    );

    return buttonObject;
  }

  /** 템플릿 생성 */
  private FeedTemplate createTemplate(ReadableMap options) {
    FeedTemplate.Builder feedTemplate = FeedTemplate.newBuilder(
      createContentObject(options.getMap("content"))
    );

    // Social 기능은 사용하지 않는다.
    // if (options.hasKey("social")) feedTemplate.setSocial();

    // 버튼 추가
    ReadableArray buttons = options.getArray("buttons");
    if (buttons.size() > 0) {
      for (int i = 0; i < buttons.size(); i++){
        feedTemplate.addButton(createButtonObject(buttons.getMap(i)));
      }
    }

    return feedTemplate.build();
  }

  /** 에러 Map 생성 */
  private Map<String,String> createServerCallbackArgsMap(ReadableMap serverCallbackArgs) {
    Map<String, String> serverCallbackArgsMap = new HashMap<>();
    ReadableMapKeySetIterator serverCallbackArgsKeys = serverCallbackArgs.keySetIterator();

    while(serverCallbackArgsKeys.hasNextKey()) {
      String key = serverCallbackArgsKeys.nextKey();
      String value = serverCallbackArgs.getString(key);
      serverCallbackArgsMap.put(key,value);
    }

    return serverCallbackArgsMap;
  }

  /** KakaoLink Share */
  @ReactMethod
  public void share(final ReadableMap options, final Promise promise) {
    TemplateParams params = createTemplate(options);

    ReadableMap serverCallbackArgs = null;
    Map<String, String> serverCallbackArgsMap = null;

    if (options.hasKey("serverCallbackArgs")) {
      serverCallbackArgs = options.getMap("serverCallbackArgs");
      serverCallbackArgsMap = createServerCallbackArgsMap(serverCallbackArgs);
    }

    sendTemplate(params, promise, serverCallbackArgsMap);
  }
}
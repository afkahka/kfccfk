import { UserConstants } from '../common/constants/UserConstants'
import { common } from '@kit.AbilityKit'
import { LoginStateService } from '../common/service/LoginStateService'

PersistentStorage.persistProp('agreedState', 0)
PersistentStorage.persistProp('flag', false)

@Entry
@Component
struct Index {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @StorageLink('agreedState') agreedState: number = 0
  @State flag: boolean = true
  @State isShowAgreement: boolean = false
  @State isShowPolicy: boolean = false
  @State isShow: boolean = false
  @State isLoggedIn: boolean = false
  @State countdown: number = 3
  @State timerId: number = 0
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext

  aboutToAppear(): void {
    // 强制检查状态，确保不会重复显示
    if (this.agreedState === UserConstants.AGREED_STATE[1]) {
      // 用户已经同意过，直接跳转
      this.isShow = false; // 确保不显示隐私保护页面
      this.countdown = 0; // 重置倒计时
      this.flag = false; // 强制设置标志

      // 冷启动时先同步持久化数据到AppStorage
      LoginStateService.syncStorageData()
      // 然后读取AppStorage中的登录状态
      this.isLoggedIn = LoginStateService.isUserLoggedIn()
      if (this.isLoggedIn) {
        this.pathStack.replacePathByName(UserConstants.ROUTER[1], null)
      } else {
        this.pathStack.replacePathByName(UserConstants.ROUTER[0], null)
      }
      return; // 直接返回，不执行后续逻辑
    }

    // 用户未同意，启动倒计时
    this.startCountdown();
  }

  // 启动倒计时
  startCountdown(): void {
    this.countdown = 3;
    this.timerId = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        this.clearTimer();
        this.isShow = true;
      }
    }, 1000);
  }

  // 清除定时器
  clearTimer(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
  }

  // 跳过等待，直接显示用户隐私保护
  skipWait(): void {
    this.clearTimer();
    this.isShow = true;
  }

  // 处理同意后的状态重置
  handleAgree(): void {
    // 先更新状态
    this.agreedState = UserConstants.AGREED_STATE[1];
    this.isShow = false;
    this.clearTimer();
    this.countdown = 0;

    // 强制更新状态
    this.flag = false;

    // 延迟跳转，确保状态更新完成
    setTimeout(() => {
      try {
        this.pathStack.replacePathByName(UserConstants.ROUTER[0], null)
      } catch (error) {
        console.error('页面跳转失败:', error)
      }
    }, 200);
  }

  aboutToDisappear(): void {
    // 组件销毁时清理定时器
    this.clearTimer();
  }

  build() {
    Navigation(this.pathStack) {
      Stack() {
        Column() {
          Image($r('app.media.begin'))
            .layoutWeight(1)
            .objectFit(ImageFit.Cover)
        }
        .alignItems(HorizontalAlign.Center)
        .width(UserConstants.FULL_PERCENT)
        .height(UserConstants.FULL_PERCENT)

        // 右上角跳过按钮
        if (this.agreedState !== UserConstants.AGREED_STATE[1] && this.countdown > 0 && !this.isShow) {
          Button(`${this.countdown}秒跳过`)
            .fontSize('14fp')
            .fontColor(Color.White)
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            .borderRadius(20)
            .width('100vp')
            .height('36vp')
            .position({ x: '75%', y: '8%' })
            .onClick(() => {
              this.skipWait();
            })
        }
      }
      .bindSheet(this.isShow && this.agreedState !== UserConstants.AGREED_STATE[1], this.agreementAndPolicy, {
        height: SheetSize.FIT_CONTENT,
        preferType: SheetType.BOTTOM,
        showClose: false,
        blurStyle: BlurStyle.Regular,
        onWillDismiss: ((dismissSheetAction: DismissSheetAction) => {
          if (dismissSheetAction.reason === DismissReason.PRESS_BACK) {
            dismissSheetAction.dismiss();
            this.context.terminateSelf((err) => {
              if (err.code) {
                return;
              }
            })
            this.flag = true;
          }
        }),
        onDisappear: (() => {
          this.isShow = false;
        })
      })
      .width(UserConstants.FULL_PERCENT)
      .height(UserConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .hideTitleBar(true)
    .padding({
      top: 0,
      bottom: this.getUIContext().px2vp(this.bottomSafeHeight)
    })
  }

  @Builder
  agreementAndPolicy(): void {
    Column() {
      Row() {
        Column() {
          Image($r('app.media.handle'))
            .width('48vp')
            .height('4vp')
            .margin({ top: '8vp', bottom: '4vp' })
            .borderRadius(2)
          Image($r('app.media.protect_icon'))
            .width('40vp')
            .aspectRatio(1)
            .margin({ top: '16vp', bottom: '16vp' })
          Text('用户协议隐私保护')
            .fontSize('16fp')
            .fontWeight(FontWeight.Medium)
            .fontColor(UserConstants.FONT_COLOR[1])
            .lineHeight('21fp')
            .margin({ bottom: '16vp' })
        }
      }
      .width(UserConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)

      Stack() {
        Text(UserConstants.AGREEMENT_AND_PRIVACY_CONTENT)
          .fontSize('14fp')
          .fontWeight(FontWeight.Normal)
          .fontColor(UserConstants.FONT_COLOR[1])
          .lineHeight('19fp')
          .textAlign(TextAlign.JUSTIFY)
        Text(UserConstants.AGREEMENT_OR_PRIVACY[0])
          .fontSize('14fp')
          .fontWeight(FontWeight.Normal)
          .fontColor(UserConstants.FONT_COLOR[2])
          .lineHeight('19fp')
          .textAlign(TextAlign.JUSTIFY)
          .position({ x: UserConstants.AGREEMENT_POSTION[0], y: UserConstants.AGREEMENT_POSTION[1] })
          .onClick(() => {
            this.isShowAgreement = true;
          })
          .bindContentCover(this.isShowAgreement, this.userAgreementBuilder(), {
            onDisappear: (() => {
              this.isShowAgreement = false
            })
          })
        Text(UserConstants.AGREEMENT_OR_PRIVACY[1])
          .fontSize('14fp')
          .fontWeight(FontWeight.Normal)
          .fontColor(UserConstants.FONT_COLOR[2])
          .lineHeight('19fp')
          .textAlign(TextAlign.JUSTIFY)
          .position({ x: UserConstants.PRIVACY_POSTION[0], y: UserConstants.PRIVACY_POSTION[1] })
          .onClick(() => {
            this.isShowPolicy = true;
          })
          .bindContentCover(this.isShowPolicy, this.privacyPolicyBuilder(), {
            onDisappear: (() => {
              this.isShowPolicy = false
            })
          })
      }
      .width(UserConstants.FULL_PERCENT)
      .padding({ left: '16vp', right: '16vp' })
      .margin({ bottom: '16vp' })

      Row() {
        Button('取消')
          .fontColor(UserConstants.FONT_COLOR[2])
          .backgroundColor(UserConstants.BUTTON_COLOR)
          .width('156vp')
          .height('40vp')
          .onClick(() => {
            this.context.terminateSelf((err) => {
              if (err.code) {
                return
              }
            })
            this.flag = true
          })
        Button('同意')
          .fontColor(Color.White)
          .backgroundColor(UserConstants.BUTTON_COLOR)
          .width('156vp')
          .height('40vp')
          .onClick(() => {
            this.handleAgree();
          })
      }
      .width(UserConstants.FULL_PERCENT)
      .padding({ left: '16vp', right: '16vp' })
      .margin({ bottom: '16vp' })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .margin({ bottom: '16vp' })
    .width(UserConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Color.White)
  }

  @Builder
  privacyPolicyBuilder() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width('40vp')
          .aspectRatio(1)
          .margin({ right: '8vp' })
          .onClick(() => this.isShowPolicy = false)
        Text('隐私政策')
          .fontSize('20fp')
          .fontWeight(FontWeight.Bold)
          .fontColor(UserConstants.FONT_COLOR[1])
          .lineHeight('27fp')
      }
      .height('56vp')

      Scroll() {
        Text() {
          Span(UserConstants.AGREEMENT_DETAIL[0])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[1])
          Span(UserConstants.AGREEMENT_DETAIL[2])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[3])
          Span(UserConstants.AGREEMENT_DETAIL[4])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[5])
          Span(UserConstants.AGREEMENT_DETAIL[6])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[7])
          Span(UserConstants.AGREEMENT_DETAIL[8])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[9])
          Span(UserConstants.AGREEMENT_DETAIL[10])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[11])
          Span(UserConstants.AGREEMENT_DETAIL[12])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[13])
          Span(UserConstants.AGREEMENT_DETAIL[14])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[15])
          Span(UserConstants.AGREEMENT_DETAIL[16])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[17])
          Span(UserConstants.AGREEMENT_DETAIL[18])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[19])
        }
        .fontSize('14fp')
        .fontWeight(FontWeight.Normal)
        .fontColor(UserConstants.FONT_COLOR[1])
        .lineHeight('19fp')
        .textAlign(TextAlign.JUSTIFY)
      }
      .scrollBar(BarState.Off)
    }
    .width(UserConstants.FULL_PERCENT)
    .height('900vp')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F1F3F5')
    .padding({
      top: this.getUIContext().px2vp(this.topSafeHeight),
      bottom: this.getUIContext().px2vp(this.bottomSafeHeight),
      left: '16vp',
      right: '16vp'
    })
  }

  @Builder
  userAgreementBuilder() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width('40vp')
          .aspectRatio(1)
          .margin({ right: '8vp' })
          .onClick(() => this.isShowAgreement = false)
        Text('用户协议')
          .fontSize('20fp')
          .fontWeight(FontWeight.Bold)
          .fontColor(UserConstants.FONT_COLOR[1])
          .lineHeight('27fp')
      }
      .height('56vp')

      Scroll() {
        Text() {
          Span(UserConstants.AGREEMENT_DETAIL[0])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[1])
          Span(UserConstants.AGREEMENT_DETAIL[2])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[3])
          Span(UserConstants.AGREEMENT_DETAIL[4])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[5])
          Span(UserConstants.AGREEMENT_DETAIL[6])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[7])
          Span(UserConstants.AGREEMENT_DETAIL[8])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[9])
          Span(UserConstants.AGREEMENT_DETAIL[10])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[11])
          Span(UserConstants.AGREEMENT_DETAIL[12])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[13])
          Span(UserConstants.AGREEMENT_DETAIL[14])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[15])
          Span(UserConstants.AGREEMENT_DETAIL[16])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[17])
          Span(UserConstants.AGREEMENT_DETAIL[18])
            .fontWeight(UserConstants.FONT_WEIGHT_600)
          Span(UserConstants.AGREEMENT_DETAIL[19])
        }
        .fontSize('14fp')
        .fontWeight(FontWeight.Normal)
        .fontColor(UserConstants.FONT_COLOR[1])
        .lineHeight('19fp')
        .textAlign(TextAlign.JUSTIFY)
      }
      .scrollBar(BarState.Off)
    }
    .width(UserConstants.FULL_PERCENT)
    .height('900vp')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F1F3F5')
    .padding({
      top: this.getUIContext().px2vp(this.topSafeHeight),
      bottom: this.getUIContext().px2vp(this.bottomSafeHeight),
      left: '16vp',
      right: '16vp'
    })
  }
}
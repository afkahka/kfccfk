import { LoginStateService } from '../common/service/LoginStateService'

@Builder
export function SettingBuilder() {
  Setting()
}

interface SettingItem {
  icon: Resource
  title: string
  subtitle: string
  hasSwitch?: boolean
  switchValue?: boolean
  onClick?: () => void
}

@Component
export struct Setting {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State isDarkMode: boolean = false
  @State isNotificationEnabled: boolean = true
  @State isSoundEnabled: boolean = true

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .fillColor('#333333')
            .onClick(() => {
              this.pathStack.pop()
            })

          Text('设置')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 16 })

          Blank()
        }
        .width('100%')
        .height(56+this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor('#FFF')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            this.SettingSection('账户设置', [
              { 
                icon: $r('app.media.ic_mine_new'), 
                title: '个人资料', 
                subtitle: '修改头像、昵称等信息',
                onClick: () => {
                  this.pathStack.pushPathByName("ProfileEditPage", null)
                }
              },
              { icon: $r('app.media.ic_privacy_policy'), title: '隐私设置', subtitle: '数据使用和隐私保护' }
            ])

            this.SettingSection('应用设置', [
              {
                icon: $r('app.media.ic_help'),
                title: '消息通知',
                subtitle: '推送通知设置',
                hasSwitch: true,
                switchValue: this.isNotificationEnabled
              },
              {
                icon: $r('app.media.ic_gift'),
                title: '声音设置',
                subtitle: '应用音效和提示音',
                hasSwitch: true,
                switchValue: this.isSoundEnabled
              },
              {
                icon: $r('app.media.ic_store'),
                title: '深色模式',
                subtitle: '自动跟随系统',
                hasSwitch: true,
                switchValue: this.isDarkMode
              }
            ])

            this.SettingSection('其他', [
              { icon: $r('app.media.ic_help'), title: '帮助与反馈', subtitle: '常见问题和使用帮助' },
              { icon: $r('app.media.ic_setting'), title: '关于我们', subtitle: '版本信息和应用介绍' }
            ])
          }
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .backgroundColor('#F8F9FA')

        Button('退出登录', { type: ButtonType.Normal })
          .width('90%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF4757')
          .fontColor('#FFF')
          .borderRadius(24)
          .margin({top:30})
          .onClick(() => {
            LoginStateService.clearUserLoginInfo()
            this.pathStack.replacePathByName("LoginPage",null)
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        bottom: this.getUIContext().px2vp(this.bottomSafeHeight)
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  SettingSection(title: string, items: SettingItem[]) {
    Column() {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .margin({ top: 24, bottom: 12, left: 4 })
        .alignSelf(ItemAlign.Start)

      Column() {
        ForEach(items, (item: SettingItem, index: number) => {
          Row() {
            Image(item.icon)
              .width(24)
              .height(24)
              .fillColor('#666666')
              .margin({ right: 16 })

            Column() {
              Text(item.title)
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .fontColor('#333333')
                .margin({ bottom: 4 })
              
              Text(item.subtitle)
                .fontSize(14)
                .fontColor('#999999')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            if (item.hasSwitch) {
              Toggle({ type: ToggleType.Switch, isOn: item.switchValue })
                .onChange((isOn: boolean) => {
                  if (item.title === '消息通知') {
                    this.isNotificationEnabled = isOn
                  } else if (item.title === '声音设置') {
                    this.isSoundEnabled = isOn
                  } else if (item.title === '深色模式') {
                    this.isDarkMode = isOn
                  }
                })
            } else {
              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
                .fillColor('#CCCCCC')
            }
          }
          .width('100%')
          .height(64)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFF')
          .borderRadius(8)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          .margin({ bottom: index === items.length - 1 ? 0 : 1 })
          .onClick(() => {
            if (item.onClick) {
              item.onClick()
            }
          })
        })
      }
      .backgroundColor('#FFF')
      .borderRadius(12)
      .margin({ bottom: 16 })
    }
  }
}
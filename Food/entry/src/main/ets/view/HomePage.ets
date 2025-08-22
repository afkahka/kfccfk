import MainPageViewModel, { Images, MenberIcon } from "../viewmodel/MainPageViewModel"
import { LoginStateService } from "../common/service/LoginStateService"
import { RcpUtilsService } from "../common/service/RcpUtilsService"

@Component
export struct HomePage {
  @StorageProp('topSafeHeight') topSafeHeight:number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight:number = 0
  @State lastAccount: string = ''
  @State userName: string = ''
  @State userAvatar: string = ''
  @State isLoggedIn: boolean = false
  @State memberLevelName: string = ''
  @State userLevelType: number = 0
  @Prop currentIndex: number = 0
  onTabChange?: (index: number) => void


  aboutToAppear() {
    this.loadUserPreferences()
  }

  async loadUserPreferences() {
    try {
      // 先同步持久化数据
      LoginStateService.syncStorageData()
      this.lastAccount = LoginStateService.getLastLoginAccount()
      this.userName = LoginStateService.getUserName()
      this.userAvatar = LoginStateService.getUserAvatar()
      this.isLoggedIn = LoginStateService.isUserLoggedIn()
      this.userLevelType = LoginStateService.getUserLevelType()
      this.loadMemberLevelName()
    } catch (error) {
      console.error('HomePage: 获取用户登录状态失败:', error)
    }
  }

  async loadMemberLevelName() {
    try {
      if (this.userLevelType && this.userLevelType > 0) {
        const detail = await RcpUtilsService.fetchMemberLevelDetail(this.userLevelType)
        this.memberLevelName = detail?.name ?? ''
      }
      if (!this.memberLevelName) {
        const levels = await RcpUtilsService.fetchMemberLevels()
        const match = levels.find(l => l.level_type === this.userLevelType)
        this.memberLevelName = match ? match.name : (levels.length > 0 ? (levels[0].name || '') : '')
      }
    } catch (e) {
      this.memberLevelName = ''
    }
  }

  build() {
    Scroll(){
      Column() {
        Stack({alignContent:Alignment.Top}){
          Swiper(){
            ForEach(MainPageViewModel.getBannerImage(),(item:Images)=>{
              Image(item.image)
                .width("100%")
                .height(400)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
            },(item:Images,index:number)=>JSON.stringify(item.id+index))
          }
          .loop(true)
          .autoPlay(false)
          .indicator(false)

          Row(){
            Column(){
              this.memberHeaderBuilder()
              Row(){
                this.myCardBuilder($r('app.media.ic_home_takeout'),'外卖',1)
                this.myCardBuilder($r('app.media.ic_home_dinein'),'堂食',1)
              }
              .width('100%')
              .margin({ top:12 })
              .justifyContent(FlexAlign.SpaceBetween)
              Row(){
                ForEach(MainPageViewModel.getMenberIcon(),(item:MenberIcon)=>{
                  Column(){
                    Image(item.image)
                      .width(26)
                      .height(26)
                      .objectFit(ImageFit.Contain)
                    Text(item.title)
                      .fontSize(14)
                      .fontColor('#333333')
                      .margin({ top: 6 })
                    Text(item.text)
                      .fontSize(12)
                      .fontColor('#999999')
                      .margin({ top: 2 })
                  }
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .layoutWeight(1)
                })
              }
              .width('100%')
              .margin({ top: 16 })
            }
            .width("90%")
            .padding(12)
            .backgroundColor(Color.White)
            .border({ width: 1, color: '#F0F0F0' })
            .borderRadius(12)
            .clip(true)
          }
          .width('100%')
          .offset({ y: 340 })
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  myCardBuilder(image:Resource|string,title:string,currentIndex:number){
    Column(){
      Image(image)
        .width(64)
        .height(64)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 8 })
    }
    .width('48%')
    .height(120)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor('#F5F7F8')
    .borderRadius(12)
    .clip(true)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(()=>{
      this.onTabChange?.(currentIndex)
    })
  }

  // 会员信息头部布局骨架
  @Builder
  memberHeaderBuilder(){
    Column(){
      Row(){
        Row({ space: 10 }){
          if (this.userAvatar && this.userAvatar.trim() !== '') {
            Image(this.userAvatar)
              .width(32).height(32)
              .borderRadius(16)
              .backgroundColor('#EEEEEE')
              .alt($r('app.media.logo'))
          } else {
            Image($r('app.media.logo'))
              .width(32).height(32)
              .borderRadius(16)
              .backgroundColor('#EEEEEE')
          }
          Text(this.userName || this.lastAccount)
            .fontSize(18)
            .fontColor('#222222')
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(VerticalAlign.Center)
        .layoutWeight(1)

        Text(this.memberLevelName || '会员')
          .fontSize(12)
          .fontColor('#F3A100')
          .backgroundColor('#FFF4D6')
          .padding({ left:10, right:10, top:4, bottom:4 })
          .borderRadius(12)
      }
      .width('100%')

      Row(){
        Blank().height(6).layoutWeight(1).backgroundColor('#FFE4E4').borderRadius(3)
        Row(){ Blank() }
          .height(6)
          .width('60%')
          .backgroundColor('#FF5252')
          .borderRadius(3)
          .position({ x: 0 })
      }
      .width('100%')
      .margin({ top: 8 })

      Row(){
        Column(){ Text('637').fontSize(18).fontColor('#222222'); Text('雪王币').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
        Column(){ Text('0').fontSize(18).fontColor('#222222'); Text('优惠券').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
        Column(){ Text('—').fontSize(18).fontColor('#222222'); Text('其他').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 8 })

      Row(){
        Text('会员特权').fontSize(16).fontColor('#222222').fontWeight(FontWeight.Medium)
        Text('周三会员日，满12元减2元').fontSize(14).fontColor('#666666').margin({ left: 8 }).layoutWeight(1)
        Text('>').fontSize(16).fontColor('#C0C0C0')
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#FFF7F7')
      .borderRadius(8)
      .margin({ top: 10 })
    }
    .width('100%')
    .padding({ left:12, right:12, top:12, bottom:12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .border({ width:1, color:'#F0F0F0' })
  }
}
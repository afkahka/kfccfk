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
  @State userCoins: number = 0
  @State userCoupons: number = 0
  @State userGrowthValue: number = 0
  @State levelGrowthMin: number = 0
  @State levelGrowthMax: number = 100
  @State levelProgress: number = 0 // 0~1
  @State memberRightText: string = ''
  @Prop currentIndex: number = 0
  onTabChange?: (index: number) => void


  aboutToAppear() {
    this.loadUserPreferences()
  }

  onPageShow() {
    this.loadUserPreferences()
    this.loadMemberRightText()
    

  }

  async loadUserPreferences() {
    try {
      LoginStateService.syncStorageData()
      this.lastAccount = LoginStateService.getLastLoginAccount()
      this.userName = LoginStateService.getUserName()
      this.userAvatar = LoginStateService.getUserAvatar()
      this.isLoggedIn = LoginStateService.isUserLoggedIn()
      this.userLevelType = LoginStateService.getUserLevelType()
      if (this.isLoggedIn) {
        const phone = LoginStateService.getUserPhone()
        if (phone) {
          const user = await RcpUtilsService.getUserByPhone(phone)
          if (user) {
            this.userCoins = Number(user.coins ?? 0)
            this.userCoupons = Number(user.coupons ?? 0)
            this.userGrowthValue = Number(user.growth_value ?? 0)
            this.updateLevelProgress()
          }
        }
      }
      this.loadMemberLevelName()
      this.loadMemberRightText()
      
      
    } catch (error) {
      console.error('HomePage: 获取用户登录状态失败:', error)
    }
  }

  async loadMemberLevelName() {
    try {
      if (this.userLevelType && this.userLevelType > 0) {
        const detail = await RcpUtilsService.fetchMemberLevelDetail(this.userLevelType)
        this.memberLevelName = detail?.name ?? ''
        if (detail) {
          this.levelGrowthMin = Number(detail.growth_value_min ?? 0)
          this.levelGrowthMax = Number(detail.growth_value_max ?? 100)
          this.updateLevelProgress()
        }
      }
      if (!this.memberLevelName) {
        const levels = await RcpUtilsService.fetchMemberLevels()
        const match = levels.find(l => l.level_type === this.userLevelType)
        this.memberLevelName = match ? match.name : (levels.length > 0 ? (levels[0].name || '') : '')
        if (match) {
          this.levelGrowthMin = Number(match.growth_value_min ?? 0)
          this.levelGrowthMax = Number(match.growth_value_max ?? 100)
          this.updateLevelProgress()
        }
      }
    } catch (e) {
      this.memberLevelName = ''
    }
  }

  updateLevelProgress() {
    const min: number = Math.max(0, this.levelGrowthMin)
    const max: number = Math.max(min + 1, this.levelGrowthMax)
    const gv: number = Math.max(0, this.userGrowthValue)
    const ratio: number = Math.min(1, Math.max(0, (gv - min) / (max - min)))
    this.levelProgress = ratio

    if (ratio >= 1 && this.userLevelType > 0) {
      this.tryPromoteLevel()
    }
  }

  async tryPromoteLevel() {
    try {
      const levels = await RcpUtilsService.fetchMemberLevels()
      const idx = levels.findIndex(l => l.level_type === this.userLevelType)
      const next = idx >= 0 && idx + 1 < levels.length ? levels[idx + 1] : null
      if (next) {
        const updated = await RcpUtilsService.updateUserLevel(LoginStateService.getUserId(), next.level_type)
        if (updated) {
          LoginStateService.setUserLevelType(next.level_type)
          this.userLevelType = next.level_type
          this.memberLevelName = next.name
          this.levelGrowthMin = Number(next.growth_value_min ?? 0)
          this.levelGrowthMax = Number(next.growth_value_max ?? 100)
          this.updateLevelProgress()
        }
      }
    } catch (_e) {}
  }

  async loadMemberRightText() {
    try {
      if (this.userLevelType && this.userLevelType > 0) {
        const rights = await RcpUtilsService.fetchMainRightsByLevel(this.userLevelType)
        if (rights && rights.length > 0) {
          const first = rights.find(r => r.showInMainPage) || rights[0]
          this.memberRightText = first.assistDesc || first.name || ''
          return
        }
      }
      const byCategory = await RcpUtilsService.fetchRightsByCategory(1)
      if (byCategory && byCategory.length > 0) {
        const first = byCategory.find(r => r.showInMainPage) || byCategory[0]
        this.memberRightText = first.assistDesc || first.name || ''
      }
    } catch (_e) {
      this.memberRightText = ''
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
          .autoPlay(true)
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
          .width(`${Math.round(this.levelProgress * 100)}%`)
          .backgroundColor('#FF5252')
          .borderRadius(3)
          .position({ x: 0 })
      }
      .width('100%')
      .margin({ top: 8 })

      Row(){
        Column(){ Text(String(this.userCoins)).fontSize(18).fontColor('#222222'); Text('迪奥币').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
        Column(){ Text(String(this.userCoupons)).fontSize(18).fontColor('#222222'); Text('优惠券').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
        Column(){ Text(String(this.userGrowthValue)).fontSize(18).fontColor('#222222'); Text('成长值').fontSize(12).fontColor('#888888') }
          .alignItems(HorizontalAlign.Center).layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 8 })

      Row(){
        Text('会员特权').fontSize(16).fontColor('#222222').fontWeight(FontWeight.Medium)
        Text(this.memberRightText || '').fontSize(14).fontColor('#666666').margin({ left: 8 }).layoutWeight(1)
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
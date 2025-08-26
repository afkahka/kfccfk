import { LoginStateService } from '../common/service/LoginStateService'
import { RcpUtilsService, MemberLevel, RightCategory, RightItem } from '../common/service/RcpUtilsService'
import MainPageViewModel, { MineIcon } from '../viewmodel/MainPageViewModel'


@Component
export struct MinePage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @State isLoading: boolean = true
  @StorageLink('userName') userName: string = ''
  @StorageLink('userPhone') userPhone: string = ''
  @StorageLink('userAvatar') userAvatar: string = ''
  @StorageLink('userLevelType') userLevelType: number = 0
  @State memberLevels: MemberLevel[] = []
  @State levelSwiperIndex: number = 0
  @State rightsOfActiveLevel: RightItem[] = []
  @State rightCategories: RightCategory[] = []
  @State activeCategory: number = 0
  @State rightsByCategory: RightItem[] = []
  @State unlockedCount: number = 0
  @Consume('pathStack') pathStack: NavPathStack

  aboutToAppear() {
    this.initFromLoginState()
    this.loadAll()
  }

  onPageShow() {
    console.info('MinePage: 页面重新显示，同步用户信息')
    this.initFromLoginState()
  }

  initFromLoginState() {
    LoginStateService.syncStorageData()

  }

  async loadAll() {
    try {
      this.isLoading = true
      await this.loadLevelsAndRights()
      await this.loadRightCategoriesAndList()
    } finally {
      this.isLoading = false
    }
  }

  async loadLevelsAndRights() {
    const levels = await RcpUtilsService.fetchMemberLevels()
    this.memberLevels = levels

    const idx = levels.findIndex(l => l.level_type === this.userLevelType)
    this.levelSwiperIndex = idx >= 0 ? idx : 0

    await this.reloadRightsForCurrentLevel()
  }

  async loadRightCategoriesAndList() {
    const cats = await RcpUtilsService.fetchRightCategories()
    this.rightCategories = cats
    if (cats && cats.length > 0) {
      this.activeCategory = cats[0].category
      await this.loadRightsByCategory(this.activeCategory)
    } else {
      this.activeCategory = 0
      this.rightsByCategory = []
    }
  }

  async loadRightsByCategory(category: number) {
    this.activeCategory = category
    this.rightsByCategory = await RcpUtilsService.fetchRightsByCategory(category)
  }

  async reloadRightsForCurrentLevel() {
    const rights = await RcpUtilsService.fetchRightsByLevel(this.userLevelType)
    this.unlockedCount = rights.length
    this.rightsOfActiveLevel = rights

    try {
      const mainRights = await RcpUtilsService.fetchMainRightsByLevel(this.userLevelType)
      this.rightsByCategory = mainRights
    } catch (_e) {
      this.rightsByCategory = rights.slice(0, 10)
    }

    try {
      const cats = await RcpUtilsService.fetchRightCategories()
      this.rightCategories = cats
      if (cats && cats.length > 0) {
        this.activeCategory = cats[0].category
        this.rightsByCategory = await RcpUtilsService.fetchRightsByCategory(this.activeCategory)
      } else {
        this.activeCategory = 0
      }
    } catch (_e) {
    }
  }

  async onLevelIndexChange(index: number) {
    this.levelSwiperIndex = index
    const selected = this.memberLevels[index]
    if (selected) {
      this.userLevelType = selected.level_type
      await this.reloadRightsForCurrentLevel()
    }
  }

  private getLevelBg(levelType: number): string {
    switch (levelType) {
      case 1:
        return '#4AA8FF'
      case 2:
        return '#FFA726'
      case 3:
        return '#9C6CFF'
      case 4:
        return '#2B2623'
      default:
        return '#FFA726'
    }
  }

  @Builder
  levelCard(level: MemberLevel) {
    Column() {
      Column() {
        Text(level.name || '会员')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFF')
          .alignSelf(ItemAlign.Start)

        Text(level.current_level_txt ? level.current_level_txt :
          (level.next_level_txt ? `升级可享【${level.next_level_txt}】等权益` : ''))
          .fontSize(14)
          .fontColor('#FFFFFFCC')
          .margin({ top: 6 })
          .alignSelf(ItemAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.End)

      Image($r('app.media.ic_gift')).width(80).height(80).alignSelf(ItemAlign.End)

    }
    .padding(16)
    .backgroundColor(this.getLevelBg(level.level_type))
    .borderRadius(12)
  }

  @Builder
  rightItemCard(item: RightItem) {
    Column() {
      Image(item.image || $r('app.media.ic_gift'))
        .width(32).height(32).margin({ bottom: 8 })
      Text(item.name)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
      if (item.assistDesc) {
        Text(item.assistDesc)
          .fontSize(12)
          .fontColor('#777777')
          .margin({ top: 2 })
      }
    }
    .width(96)
    .height(96)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin({ right: 12 })
  }

  @Builder
  otherServices() {
    Column() {
      Row() {
        Text('其他服务')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Blank().layoutWeight(1)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 12
      })

      Grid() {
        ForEach(MainPageViewModel.getMineIcon(), (item: MineIcon) => {
          GridItem() {
            this.serviceItem(item)
          }
        }, (item: MineIcon, index: number) => JSON.stringify(index + item.id))
      }
      .columnsTemplate('1fr 1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ top: 10 })
  }

  @Builder
  serviceItem(item: MineIcon) {
    Column() {
      Row() {
        Image(item.image)
          .width(24)
          .aspectRatio(1)
          .fillColor('#666666')
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      Text(item.title)
        .fontSize(14)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      if (item.id === 1) {
        this.pathStack.pushPathByName("Setting", null)
      } else {
        console.info(`点击了${item.title}`)
      }
    })
  }

  build() {
    Column() {
      Row() {
        Image(this.userAvatar || $r('app.media.ic_mine_new_selected'))
          .width(40).height(40).borderRadius(20)
          .backgroundColor('#EEE')
        Column() {
          Text(this.userName || this.userPhone || '未登录')
            .fontSize(18).fontWeight(FontWeight.Medium).fontColor('#222')
          if (this.userPhone) {
            Text(this.userPhone)
              .fontSize(12).fontColor('#999').margin({ top: 2 })
          }
        }
        .margin({ left: 6 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Button('签到')
          .width(60)
          .height(28)
          .fontSize(12)
          .fontColor('#666')
          .backgroundColor('#FFF')
          .border({ width: 1, color: '#E0E0E0' })
          .borderRadius(14)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 16 + this.getUIContext().px2vp(this.topSafeHeight),
        bottom: 12
      })
      .backgroundColor(Color.White)

      Column() {
        if (this.memberLevels && this.memberLevels.length > 0) {
          Swiper() {
            ForEach(this.memberLevels, (lv: MemberLevel) => {
              Row() {
                this.levelCard(lv)
              }
            })
          }
          .index(this.levelSwiperIndex)
          .autoPlay(false)
          .loop(false)
          .indicator(false)
          .onChange((idx: number) => {
            this.onLevelIndexChange(idx)
          })
          .width('100%')
          .height(190)
          .padding({ left: 12, right: 12 })
        }
      }
      .width('100%')
      .backgroundColor('#FFF6E6')

      Column() {
        Row() {
          Text('会员权益')
            .fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333')
          Blank().layoutWeight(1)
          Text(`已解锁${this.unlockedCount}项 >`).fontSize(12).fontColor('#999')
        }
        .width('100%')
        .padding({
          left: 12,
          right: 12,
          top: 8,
          bottom: 6
        })

        Row({ space: 10 }) {
          ForEach(this.rightCategories, (c: RightCategory) => {
            Text(c.category_name)
              .fontSize(14)
              .fontColor(this.activeCategory === c.category ? '#fff' : '#666')
              .backgroundColor(this.activeCategory === c.category ? '#FFA726' : '#F1F1F1')
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .borderRadius(16)
              .onClick(() => this.loadRightsByCategory(c.category))
          })
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 8 })

        List() {
          ForEach(this.rightsByCategory, (r: RightItem) => {
            ListItem() {
              this.rightItemCard(r)
            }
          })
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .height(120)
        .padding({ left: 12, right: 12 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 10 })

      this.otherServices()

      Blank().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ bottom: this.getUIContext().px2vp(this.bottomSafeHeight) })
  }
}
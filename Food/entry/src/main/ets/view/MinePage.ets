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
  @State userGrowthValue: number = 0
  @State userCoins: number = 0
  @State levelGrowthMin: number = 0
  @State levelGrowthMax: number = 100
  @State levelProgress: number = 0 // 0~1
  @State currentLevelName: string = ''
  @State nextLevelName: string = ''
  
  // 签到相关状态
  @State canSignIn: boolean = true
  @State lastSignInDate: string = ''
  @State showSignInDialog: boolean = false
  @State earnedCoins: number = 0
  
  @Consume('pathStack') pathStack: NavPathStack

  aboutToAppear() {
    this.initFromLoginState()
    this.loadAll()
    this.checkSignInStatus()
  }

  onPageShow() {
    console.info('MinePage: 页面重新显示，同步用户信息')
    this.initFromLoginState()
    this.checkSignInStatus()
  }

  initFromLoginState() {
    LoginStateService.syncStorageData()
  }

  // 检查签到状态
  checkSignInStatus() {
    const today = new Date().toDateString()
    const lastSignIn = LoginStateService.getLastSignInDate()
    
    if (lastSignIn === today) {
      this.canSignIn = false
      this.lastSignInDate = lastSignIn
    } else {
      this.canSignIn = true
      this.lastSignInDate = ''
    }
  }

  // 执行签到
  async performSignIn() {
    if (!this.canSignIn) {
      return
    }

    try {
      const userId = LoginStateService.getUserId()
      if (!userId) {
        console.error('用户未登录，无法签到')
        return
      }

      // 生成随机雪王币 (10-50之间)
      const randomCoins = Math.floor(Math.random() * 41) + 10
      this.earnedCoins = randomCoins

      // 更新用户雪王币
      await RcpUtilsService.incrementUserStats(userId, randomCoins, 0)

      // 记录签到日期
      const today = new Date().toDateString()
      LoginStateService.setLastSignInDate(today)
      
      // 更新签到状态
      this.canSignIn = false
      this.lastSignInDate = today

      // 更新本地雪王币数量
      this.userCoins += randomCoins

      // 显示签到成功弹窗
      this.showSignInDialog = true

      // 刷新用户信息
      await this.loadUserGrowthInfo()

    } catch (error) {
      console.error('签到失败:', error)
    }
  }



  async loadAll() {
    try {
      this.isLoading = true
      await this.loadLevelsAndRights()
      await this.loadRightCategoriesAndList()
      await this.loadUserGrowthInfo()
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

  async loadUserGrowthInfo() {
    try {
      if (this.userPhone) {
        const user = await RcpUtilsService.getUserByPhone(this.userPhone)
        if (user) {
          this.userGrowthValue = Number(user.growth_value ?? 0)
          this.userCoins = Number(user.coins ?? 0)
          await this.updateLevelProgress()
        }
      }
    } catch (error) {
      console.error('MinePage: 获取用户成长值失败:', error)
    }
  }

  async updateLevelProgress() {
    try {
      if (this.memberLevels && this.memberLevels.length > 0) {
        const currentLevel = this.memberLevels.find(l => l.level_type === this.userLevelType)
        if (currentLevel) {
          this.currentLevelName = currentLevel.name || ''
          this.levelGrowthMin = Number(currentLevel.growth_value_min ?? 0)
          this.levelGrowthMax = Number(currentLevel.growth_value_max ?? 100)
          
          const min: number = Math.max(0, this.levelGrowthMin)
          const max: number = Math.max(min + 1, this.levelGrowthMax)
          const gv: number = Math.max(0, this.userGrowthValue)
          const ratio: number = Math.min(1, Math.max(0, (gv - min) / (max - min)))
          this.levelProgress = ratio

          if (ratio >= 1 && this.userLevelType > 0) {
            await this.tryPromoteLevel()
          }

          const currentIndex = this.memberLevels.findIndex(l => l.level_type === this.userLevelType)
          if (currentIndex >= 0 && currentIndex + 1 < this.memberLevels.length) {
            this.nextLevelName = this.memberLevels[currentIndex + 1].name || ''
          } else {
            this.nextLevelName = ''
          }
        }
      }
    } catch (error) {
      console.error('MinePage: 更新等级进度失败:', error)
    }
  }

  async tryPromoteLevel() {
    try {
      const levels = await RcpUtilsService.fetchMemberLevels()
      const idx = levels.findIndex(l => l.level_type === this.userLevelType)
      const next = idx >= 0 && idx + 1 < levels.length ? levels[idx + 1] : null
      if (next) {
        const userId = LoginStateService.getUserId()
        if (userId) {
          const updated = await RcpUtilsService.updateUserLevel(userId, next.level_type)
          if (updated) {
            LoginStateService.setUserLevelType(next.level_type)
            this.userLevelType = next.level_type
            this.levelSwiperIndex = idx + 1
            await this.reloadRightsForCurrentLevel()
            await this.updateLevelProgress()
          }
        }
      }
    } catch (error) {
      console.error('MinePage: 等级升级失败:', error)
    }
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
      await this.updateLevelProgress()
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
  levelProgressBuilder() {
    Column() {
      Row() {
        Text('等级进度')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333')
        Blank().layoutWeight(1)
        Text(`${this.currentLevelName} → ${this.nextLevelName || '已满级'}`)
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      Row() {
        Text('成长值')
          .fontSize(14)
          .fontColor('#666')
        Blank().layoutWeight(1)
        Text(`${this.userGrowthValue}`)
          .fontSize(14)
          .fontColor('#333')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })

      Row() {
        Blank()
          .height(8)
          .layoutWeight(1)
          .backgroundColor('#F0F0F0')
          .borderRadius(4)
        
        Row() { Blank() }
          .height(8)
          .width(`${Math.round(this.levelProgress * 100)}%`)
          .backgroundColor('#FFA726')
          .borderRadius(4)
          .position({ x: 0 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })

      if (this.levelProgress >= 1 && this.nextLevelName) {
        Row() {
          Text('🎉 恭喜！已达到升级条件')
            .fontSize(14)
            .fontColor('#FF6B35')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: 16 })
      }
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 10 })
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
      .columnsTemplate('1fr 1fr 1fr 1fr')
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
          .width(18)
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

        Button(this.canSignIn ? '签到' : '已签到')
          .width(60)
          .height(28)
          .fontSize(12)
          .fontColor(this.canSignIn ? '#666' : '#999')
          .backgroundColor(this.canSignIn ? '#FFF' : '#F5F5F5')
          .border({ width: 1, color: this.canSignIn ? '#E0E0E0' : '#E0E0E0' })
          .borderRadius(14)
          .onClick(() => this.performSignIn())
          .enabled(this.canSignIn)
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

      this.levelProgressBuilder()

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

      // 签到弹窗
      if (this.showSignInDialog) {
        Stack() {
          Column() {
            Column() {
              Image($r('app.media.ic_gift'))
                .width(60)
                .height(60)
                .margin({ bottom: 16 })

              Text('签到成功！')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333')
                .margin({ bottom: 8 })

              Text(`恭喜获得 ${this.earnedCoins} 迪奥币`)
                .fontSize(16)
                .fontColor('#FF6B35')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 24 })

              Button('确定')
                .width(120)
                .height(40)
                .fontSize(16)
                .fontColor(Color.White)
                .backgroundColor('#C8A07B')
                .borderRadius(20)
                .onClick(() => {
                  this.showSignInDialog = false
                })
            }
            .width(280)
            .padding(24)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.showSignInDialog = false
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ bottom: this.getUIContext().px2vp(this.bottomSafeHeight) })
  }
}
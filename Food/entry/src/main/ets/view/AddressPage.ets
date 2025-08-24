import { RcpUtilsService, Address } from '../common/service/RcpUtilsService'
import { AddressEditService } from '../common/service/AddressEditService'

@Builder
export function AddressPageBuilder() {
  AddressPage()
}

@Component
export struct AddressPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State addresses: Address[] = []
  @State isLoading: boolean = true
  // 监听地址变更以便及时刷新
  private addressChangedHandler: () => void = () => {
    this.loadAddresses()
  }

  aboutToAppear() {
    console.info('AddressPage: aboutToAppear')
    this.loadAddresses()
    // 注册地址变更监听
    AddressEditService.addAddressChangeListener(this.addressChangedHandler)
  }

  aboutToBeDeleted() {
    // 组件销毁时再取消监听，避免在子页打开时丢失监听
    AddressEditService.removeAddressChangeListener(this.addressChangedHandler)
  }

  onPageShow() {
    console.info('AddressPage: onPageShow 刷新列表')
    // 页面显示时始终刷新，确保新增/编辑后列表立即更新
    this.loadAddresses()
    // 如存在刷新标志则清除，避免无意义的后续刷新
    if (AddressEditService.needRefreshList()) {
      AddressEditService.clearRefreshFlag()
    }
  }

  async loadAddresses() {
    try {
      this.isLoading = true
      this.addresses = await RcpUtilsService.fetchAddresses()
      console.info(`AddressPage: 加载到 ${this.addresses.length} 个地址`)
    } catch (error) {
      console.error('AddressPage: 加载地址失败:', error)
      // 如果服务器没有数据，显示空状态
      this.addresses = []
    } finally {
      this.isLoading = false
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部棕色导航栏
        Row() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.pathStack.pop()
            })
          Text('选择收货地址')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(56 + this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor('#8B4513') // 棕色背景

        // 白色地址列表区域
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(32)
              .height(32)
              .color('#8B4513')
            Text('加载中...')
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 12 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(Color.White)
        } else if (this.addresses.length === 0) {
          // 空状态
          Column() {
            Image($r('app.media.logo'))
              .width(80)
              .height(80)
              .opacity(0.3)
            Text('暂无收货地址')
              .fontSize(16)
              .fontColor('#999999')
              .margin({ top: 16 })
            Text('点击底部按钮添加新地址')
              .fontSize(14)
              .fontColor('#CCCCCC')
              .margin({ top: 8 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(Color.White)
        } else {
          List() {
            ForEach(this.addresses, (address: Address, index: number) => {
              ListItem() {
                this.addressItemBuilder(address, index)
              }
            }, (address: Address) => `${address.id}-${address.updated_at}`)
          }
          .layoutWeight(1)
          .backgroundColor(Color.White)
        }

        Button('添加地址')
          .width('90%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor('#8B4513')
          .borderRadius(24)
          .margin({ bottom: 16 })
          .onClick(() => {
            // 清除编辑状态，确保进入新增模式
            AddressEditService.clearEditState()
            this.pathStack.pushPathByName('AddAddressPage', null)
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .padding({ bottom: this.getUIContext().px2vp(this.bottomSafeHeight) })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  addressItemBuilder(address: Address, index: number) {
    Column() {
      Row() {
        Column() {
          // 第一行：地址信息
          Text(this.formatAddress(address))
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          // 第二行：联系人信息
          Text(`${address.contact_person} ${address.phone_number}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          // 选择该地址并返回上一个页面
          AddressEditService.setSelectedAddress(address)
          // 触发地址变更事件，用于其他页面实时更新
          AddressEditService.emitAddressChanged()
          this.pathStack.pop()
        })

        // 右侧编辑图标
        Image($r('app.media.edit'))
          .width(20)
          .height(20)
          .opacity(0.6)
          .onClick(() => {
            // 先设置编辑状态，然后跳转到编辑地址页面
            console.info('AddressPage: 点击编辑按钮，设置编辑状态:', address)
            AddressEditService.setEditAddress(address)
            this.pathStack.pushPathByName('AddAddressPage', null)
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      // 分割线（除了最后一个项目）
      if (index < this.addresses.length - 1) {
        Divider()
          .width('100%')
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })
      }
    }
  }

  // 格式化地址显示
  formatAddress(address: Address): string {
    if (address.house_number && address.house_number.trim() !== '') {
      return `${address.address}, ${address.house_number}`
    }
    return address.address
  }
}
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
  private addressChangedHandler: () => void = () => {
    this.loadAddresses()
  }

  aboutToAppear() {
    console.info('AddressPage: aboutToAppear')
    this.loadAddresses()
    AddressEditService.addAddressChangeListener(this.addressChangedHandler)
  }

  aboutToBeDeleted() {
    AddressEditService.removeAddressChangeListener(this.addressChangedHandler)
  }

  onPageShow() {
    console.info('AddressPage: onPageShow 刷新列表')
    this.loadAddresses()
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
      this.addresses = []
    } finally {
      this.isLoading = false
    }
  }

  build() {
    NavDestination() {
      Column() {
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
            .fontColor(Color.Black)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(56 + this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor(Color.White)

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
          Text(this.formatAddress(address))
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)

          Text(`${address.contact_person} ${address.phone_number}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          AddressEditService.setSelectedAddress(address)
          AddressEditService.emitAddressChanged()
          this.pathStack.pop()
        })

        Image($r('app.media.edit'))
          .width(20)
          .height(20)
          .opacity(0.6)
          .onClick(() => {
            console.info('AddressPage: 点击编辑按钮，设置编辑状态:', address)
            AddressEditService.setEditAddress(address)
            this.pathStack.pushPathByName('AddAddressPage', null)
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (index < this.addresses.length - 1) {
        Divider()
          .width('100%')
          .color('#F0F0F0')
          .margin({ left: 16, right: 16 })
      }
    }
  }

  formatAddress(address: Address): string {
    if (address.house_number && address.house_number.trim() !== '') {
      return `${address.address}, ${address.house_number}`
    }
    return address.address
  }
}
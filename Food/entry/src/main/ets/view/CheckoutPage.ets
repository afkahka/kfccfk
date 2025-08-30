import { Address } from "../common/service/RcpUtilsService"
import { RcpUtilsService } from "../common/service/RcpUtilsService"
import { LoginStateService } from "../common/service/LoginStateService"
import { CheckoutService, CheckoutItemData } from "../common/service/CheckoutService"
import { OrderService } from "../common/service/OrderService"

export interface CheckoutItem {
  id: number
  title: string
  image: string
  price: number
  count: number
}

@Builder
export function CheckoutPageBuilder() {
  CheckoutPage()
}

@Component
export struct CheckoutPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State address: Address | null = null
  @State items: CheckoutItem[] = []
  @State totalAmount: number = 0
  @State payMethod: 'wechat' | 'alipay' = 'wechat'
  @State isExpanded: boolean = false
  // 雪王币抵扣
  @State userCoins: number = 0
  @State useCoins: boolean = false
  @State discountByCoins: number = 0

  aboutToAppear() {
    const addr = CheckoutService.getAddress()
    const list = CheckoutService.getItems() as CheckoutItemData[]
    const amount = CheckoutService.getTotalAmount()
    this.address = addr
    this.items = list
    this.totalAmount = amount
    try {
      const userId = LoginStateService.getUserId()
      if (userId) {
        RcpUtilsService.getUserById(userId).then((u)=>{
          this.userCoins = Number(u?.coins ?? 0)
          this.recalcDiscount()
        })
      }
    } catch (_e) {}
  }
  // 计算雪王币抵扣
  recalcDiscount() {
    if (!this.useCoins || this.userCoins <= 0) {
      this.discountByCoins = 0
      return
    }
    // 支持不足100币的按比例折算（如63币=¥0.63）
    const maxDiscountByCoins = this.userCoins / 100
    const payable = Math.max(0, this.totalAmount)
    this.discountByCoins = Math.min(maxDiscountByCoins, payable)
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.back')).width(24).height(24).onClick(() => this.pathStack.pop())
          Text('订单结算')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width('100%').height(56 + this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor('#C8A07B')

        // 可滚动内容区域
        Scroll() {
          Column() {
            Column() {
              Text('配送')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#8B5E3C')
                .textAlign(TextAlign.Start)
              Text(this.address ?
                `${this.address.address}${this.address.house_number ? ' ' + this.address.house_number : ''}` :
                '请选择收货地址')
                .fontSize(16)
                .fontColor('#222222')
                .margin({ top: 8 })
                .textAlign(TextAlign.Start)
            }
            .width('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Color.White)
            .border({ width: { bottom: 1 }, color: '#F0F0F0' })

            Column() {
              ForEach(this.items.slice(0, this.isExpanded ? this.items.length : Math.min(2, this.items.length)),
                (it: CheckoutItem) => {
                  Row() {
                    Image(it.image).width(56).height(56).borderRadius(8).objectFit(ImageFit.Cover)
                    Column() {
                      Text(it.title).fontSize(16).fontColor('#222222')
                      Text(`x ${it.count}`).fontSize(12).fontColor('#888888').margin({ top: 4 })
                    }.layoutWeight(1).margin({ left: 12 })

                    Text(`¥ ${it.price}`).fontSize(16).fontColor('#222222')
                  }
                  .width('100%')
                  .padding({
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 12
                  })
                })
              if (this.items.length > 2) {
                Row() {
                  Blank().layoutWeight(1)
                  Text(this.isExpanded ? '收起' : '查看更多')
                    .fontSize(14)
                    .fontColor('#666666')
                    .onClick(() => {
                      this.isExpanded = !this.isExpanded
                    })
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 8
                })
              }
            }
            .backgroundColor(Color.White)
            .margin({ top: 10 })

            Row() {
              Text('优惠券').fontSize(16).fontColor('#222222')
              Blank().layoutWeight(1)
              Text('暂无可用').fontSize(14).fontColor('#BBBBBB')
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 14,
              bottom: 14
            })
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            // 雪王币抵扣
            Row() {
              Row(){
                Text('迪奥币抵扣').fontSize(16).fontColor('#222222')
                if (this.userCoins > 0) {
                  Text(`可用${this.userCoins}币，100币抵1元`).fontSize(12).fontColor('#999999').margin({ left: 8 })
                } else {
                  Text('暂无可用').fontSize(12).fontColor('#BBBBBB').margin({ left: 8 })
                }
              }.layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.useCoins })
                .onChange((on:boolean)=>{
                  this.useCoins = on && this.userCoins > 0
                  this.recalcDiscount()
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor(Color.White)
            .margin({ top: 8 })

            Row() {
              Blank().layoutWeight(1)
              Text(`共${this.items.reduce((sum: number, it: CheckoutItem) => sum + it.count,
                0)}件，合计 ¥ ${this.totalAmount.toFixed(2)}，抵扣 ¥ ${this.discountByCoins.toFixed(2)}`)
                .fontSize(16)
                .fontColor('#222222')
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .backgroundColor(Color.White)
            .border({ width: { top: 1 }, color: '#F5F5F5' })
            .margin({ bottom: 10 })

            Column() {
              Text('支付方式').fontSize(16).fontColor('#222222').fontWeight(FontWeight.Medium).textAlign(TextAlign.Start)
              Row() {
                Row() {
                  Image($r('app.media.wechat')).width(22).height(22).objectFit(ImageFit.Contain)
                  Text('微信').fontSize(14).fontColor('#333333').margin({ left: 8 })
                }
                .alignItems(VerticalAlign.Center)
                .layoutWeight(1)

                Radio({ value: 'wechat', group: 'pay' })
                  .checked(this.payMethod === 'wechat')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.payMethod = 'wechat'
                    }
                  })
              }
              .width('100%')
              .margin({ top: 12 })

              Row() {
                Row() {
                  Image($r('app.media.qq')).width(22).height(22).objectFit(ImageFit.Contain)
                  Text('支付宝').fontSize(14).fontColor('#333333').margin({ left: 8 })
                }
                .alignItems(VerticalAlign.Center)
                .layoutWeight(1)

                Radio({ value: 'alipay', group: 'pay' })
                  .checked(this.payMethod === 'alipay')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.payMethod = 'alipay'
                    }
                  })
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%').padding(16)
            .backgroundColor(Color.White)
            .margin({ top: 10, bottom: 20 })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 固定底部按钮
        Row() {
          Text(`实付: ¥ ${(Math.max(0, this.totalAmount - this.discountByCoins)).toFixed(2)}`).fontSize(16).fontColor('#222222')
          Blank().layoutWeight(1)
          Button('确认支付')
            .backgroundColor('#C8A07B')
            .fontColor(Color.White)
            .padding({
              left: 20,
              right: 20,
              top: 10,
              bottom: 10
            })
            .borderRadius(22)
            .onClick(async () => {
              const rec = OrderService.createFromCheckout(this.payMethod)
              try {
                const userId = LoginStateService.getUserId()
                if (userId && this.totalAmount > 0) {
                  const usedCoins = this.useCoins ? Math.min(this.userCoins, this.totalAmount * 100) : 0
                  if (usedCoins > 0) {
                    await RcpUtilsService.resetUserCoinsToZero(userId)
                  }
                  const payAmount: number = Math.max(0, this.totalAmount - usedCoins / 100)
                  const coinsDelta: number = Math.floor(payAmount)
                  const growthDelta: number = Math.floor(this.totalAmount)
                  await RcpUtilsService.incrementUserStats(userId, coinsDelta, growthDelta)
                }
              } catch (_e) {}
              try {
                if (this.address) {
                  CheckoutService.setCheckoutData(this.address, this.items as CheckoutItemData[], this.totalAmount, this.discountByCoins)
                }
              } catch (_e) {}
              this.pathStack.replacePathByName('OrderDetailPage', null, true)
            })
        }
        .width('100%')
        .height(56 + this.getUIContext().px2vp(this.bottomSafeHeight))
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%').height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}



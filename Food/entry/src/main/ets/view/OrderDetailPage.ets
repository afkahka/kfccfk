import { Address } from "../common/service/RcpUtilsService"
import { CheckoutService, CheckoutItemData } from "../common/service/CheckoutService"

@Builder
export function OrderDetailPageBuilder() {
  OrderDetailPage()
}

@Component
export struct OrderDetailPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State address: Address | null = null
  @State items: CheckoutItemData[] = []
  @State totalAmount: number = 0
  @State orderId: string = ''
  @State pickupCode: string = ''
  @State createdAt: number = 0
  @State isExpanded: boolean = false

  aboutToAppear() {
    // 复用结算数据以展示详情
    this.address = CheckoutService.getAddress()
    this.items = CheckoutService.getItems()
    this.totalAmount = CheckoutService.getTotalAmount()
    this.orderId = CheckoutService.getOrderId()
    this.pickupCode = CheckoutService.getPickupCode()
    this.createdAt = CheckoutService.getCreatedAt()
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部：完成提示 + 取餐码 + 副标题
        Column() {
          Row() {
            Image($r('app.media.back')).width(24).height(24).onClick(() => this.pathStack.pop())
          }
          .width('100%')

          Text(`订单已完成  取餐码：${this.pickupCode}`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .margin({ top: 6 })
          Text('感谢您的购买，期待您的再次光临！')
            .fontSize(12)
            .fontColor('#F7EDE3')
            .textAlign(TextAlign.Center)
            .margin({ top: 6, bottom: 10 })
        }
        .width('100%').height(86 + this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor('#C8A07B')

        // 配送地址卡片（撑满容器）
        Row() {
          Column() {
            Row() {
              Text('配送至')
                .fontSize(14)
                .fontColor('#8B5E3C')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')

            Text(this.address ?
              `${this.address.address}${this.address.house_number ? ' ' + this.address.house_number : ''}` : '')
              .fontSize(16)
              .fontColor('#222222')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 1, color: '#F0F0F0' })
        }
        .width('100%')
        .padding({ top: 12 })

        // 商品列表（默认展示2条，可展开/收起；可滚动）
        Column() {
          ForEach(this.items.slice(0, this.isExpanded ? this.items.length : Math.min(2, this.items.length)),
            (it: CheckoutItemData) => {
              Row() {
                Image(it.image).width(56).height(56).borderRadius(8).objectFit(ImageFit.Cover)
                Column() {
                  Text(it.title).fontSize(16).fontColor('#222222')
                  Text('正常冰/正常糖').fontSize(12).fontColor('#888888').margin({ top: 4 })
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

        // 优惠券与合计
        Row() {
          Text('优惠券').fontSize(16).fontColor('#222222')
          Blank().layoutWeight(1)
          Text('-  ¥ 0').fontSize(16).fontColor('#C0C0C0')
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 14,
          bottom: 14
        })
        .backgroundColor(Color.White)

        Row() {
          Blank().layoutWeight(1)
          Text(`共${this.items.reduce((s: number, i: CheckoutItemData) => s + i.count,
            0)}件， 微信  ¥ ${this.totalAmount.toFixed(2)}`)
            .fontSize(16).fontColor('#222222')
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 12
        })
        .backgroundColor(Color.White)
        .margin({ bottom: 10 })

        // 订单信息
        Column() {
          this.infoRow('下单时间', this.formatTime(this.createdAt))
          this.infoRow('订单号码', this.orderId)
          this.infoRow('取餐码', this.pickupCode)
          this.infoRow('是否打包', '需要打包袋')
          this.infoRow('备注', '无')
        }
        .width('100%').padding(16)
        .backgroundColor(Color.White)

        // 底部：再来一单
        Row() {
          Blank().layoutWeight(1)
          Button('再来一单')
            .backgroundColor('#C8A07B')
            .fontColor(Color.White)
            .padding({
              left: 20,
              right: 20,
              top: 10,
              bottom: 10
            })
            .borderRadius(22)
            .onClick(() => {
              if (this.address) {
                CheckoutService.setCheckoutData(this.address, this.items, this.totalAmount)
              }
              this.pathStack.pushPathByName('CheckoutPage', null)
            })
        }
        .width('100%')
        .height(56 + this.getUIContext().px2vp(this.bottomSafeHeight))
        .padding({ left: 16, right: 16, bottom: this.getUIContext().px2vp(this.bottomSafeHeight) })
        .backgroundColor('#F5F5F5')
      }
      .width('100%').height('100%')
      .backgroundColor('#F5F5F5')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#666666')
      Blank().layoutWeight(1)
      Text(value).fontSize(14).fontColor('#222222')
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  private formatTime(ts: number): string {
    const date = new Date(ts)
    const pad = (n: number) => (n < 10 ? '0' + n : String(n))
    return `${date.getFullYear()}.${pad(date.getMonth() +
      1)}.${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  }
}



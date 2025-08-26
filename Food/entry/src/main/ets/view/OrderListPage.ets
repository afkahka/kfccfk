import { OrderService, OrderRecord } from "../common/service/OrderService"
import { CheckoutService } from "../common/service/CheckoutService"

@Component
export struct OrderListPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State orders: OrderRecord[] = []
  @State refreshing: boolean = false

  aboutToAppear() {
    this.orders = OrderService.getOrders()
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text('订单')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#222222')
        }
        .width('100%')
        .height(56 + this.getUIContext().px2vp(this.topSafeHeight))
        .padding({ left: 16, right: 16, top: this.getUIContext().px2vp(this.topSafeHeight) })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })

        Refresh({ refreshing: this.refreshing }) {
          List() {
            ForEach(this.orders, (o: OrderRecord) => {
              ListItem() {
                this.orderCard(o)
              }
            })
          }
          .backgroundColor('#F5F5F5')
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .onRefreshing(() => {
          this.refreshing = true
          this.orders = OrderService.getOrders()
          setTimeout(() => {
            this.refreshing = false
          }, 500)
        })
      }
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .padding({ bottom: this.getUIContext().px2vp(this.bottomSafeHeight) })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  orderCard(o: OrderRecord) {
    Column() {
      Row() {
        Text('外送')
          .fontSize(12)
          .fontColor('#C8A07B')
          .backgroundColor('#FFF2E6')
          .padding({
            left: 6,
            right: 6,
            top: 2,
            bottom: 2
          })
          .borderRadius(4)
        Text(o.address.address)
          .fontSize(14).fontColor('#222222').margin({ left: 8 }).layoutWeight(1)
        Text('已完成').fontSize(12).fontColor('#BBBBBB')
      }
      .width('100%').padding({ left: 12, right: 12, top: 10 })

      Row() {
        Text(this.formatTime(o.createdAt)).fontSize(12).fontColor('#999999')
        Blank().layoutWeight(1)
        Text(`共${o.items.length}件  ￥${o.totalAmount.toFixed(2)}`).fontSize(12).fontColor('#999999')
      }
      .width('100%').padding({ left: 12, right: 12, top: 6 })

      Row() {
        Blank().layoutWeight(1)
        Button('再来一单')
          .backgroundColor('#C8A07B')
          .fontColor(Color.White)
          .padding({
            left: 16,
            right: 16,
            top: 6,
            bottom: 6
          })
          .borderRadius(20)
          .onClick(() => {
            CheckoutService.setCheckoutData(o.address, o.items, o.totalAmount)
            this.pathStack.pushPathByName('CheckoutPage', null)
          })
      }
      .width('100%')
      .padding({
        left: 12,
        right: 12,
        top: 10,
        bottom: 10
      })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 12, right: 12, top: 12 })
  }

  private formatTime(ts: number): string {
    const d = new Date(ts)
    const pad = (n: number) => n < 10 ? '0' + n : String(n)
    return `${d.getFullYear()}.${pad(d.getMonth() +
      1)}.${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
  }
}
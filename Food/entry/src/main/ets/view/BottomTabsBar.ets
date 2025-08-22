@Component
export struct BottomTabsBar {
  @Prop currentIndex: number = 0
  onTabChange?: (index: number) => void

  build() {
    Row() {
      this.myTabsBar(0, $r('app.media.ic_home_new_selected'), $r('app.media.ic_home_new'), '首页')
      this.myTabsBar(1, $r('app.media.ic_food_new_selected'), $r('app.media.ic_food_new'), '点餐')
      this.myTabsBar(2, $r('app.media.ic_order_new_selected'), $r('app.media.ic_order_new'), '订单')
      this.myTabsBar(3, $r('app.media.ic_mine_new_selected'), $r('app.media.ic_mine_new'), '我的')
    }
    .width('100%')
    .height(60)
    .backgroundColor('#FFF')
    .border({ width: { top: 1 }, color: '#F0F0F0' })
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  myTabsBar(currentIndex: number, isCheck: Resource | string, Check: Resource | string, title: string) {
    Column() {
      Image(this.currentIndex === currentIndex ? isCheck : Check)
        .width(24)
        .height(24)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === currentIndex ? '#4CAF50' : '#999999')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .onClick(() => {
      this.onTabChange?.(currentIndex)
    })
  }
}

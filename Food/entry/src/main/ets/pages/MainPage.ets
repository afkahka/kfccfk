import { BottomTabsBar } from "../view/BottomTabsBar"
import { HomePage } from "../view/HomePage"
import { MinePage } from "../view/MinePage"
import { OrderListPage } from "../view/OrderListPage"
import { OrderPage } from "../view/OrderPage"

@Builder
export function MainPageBuilder() {
  MainPage()
}

@Component
export struct MainPage {
  @State currentIndex: number = 0

  build() {
    NavDestination() {
      Column() {
        Stack() {
          if (this.currentIndex == 0) {
            HomePage({
              currentIndex: this.currentIndex,
              onTabChange: (index) => this.currentIndex = index
            })
          } else if (this.currentIndex == 1) {
            OrderPage()
          } else if (this.currentIndex ==
            2) {
            OrderListPage()
          } else {
            MinePage()
          }
        }
        .layoutWeight(1)

        BottomTabsBar({
          currentIndex: this.currentIndex,
          onTabChange: (index) => this.currentIndex = index
        })
      }
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  onPageShow() {
    // 接收其他页面请求切换的 tab 索引（例如从订单列表返回到点餐页）
    const targetIdx = AppStorage.get<number>('switchTabIndex')
    if (targetIdx !== undefined && targetIdx !== null && targetIdx >= 0) {
      this.currentIndex = targetIdx
      // 清空标记，避免再次切换
      AppStorage.setOrCreate('switchTabIndex', -1)
    }
  }
}
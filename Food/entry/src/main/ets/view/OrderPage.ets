import { RcpUtilsService, CoffeeCategory, CoffeeItem } from "../common/service/RcpUtilsService"
import { AddressEditService, Address } from "../common/service/AddressEditService"
import { CheckoutService } from "../common/service/CheckoutService"


interface FlatNode {
  key: string
  type: 'header' | 'item'
  categoryId: number
  item?: CoffeeItem
}

interface CheckoutItemParam {
  id: number
  title: string
  image: string
  price: number
  count: number
}

@Component
export struct OrderPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State totalPrice: number = 0
  @State categories: CoffeeCategory[] = []
  @State coffees: CoffeeItem[] = []
  @State activeCategoryId: number | null = null
  @State allCoffees: CoffeeItem[] = []
  @State filteredCoffees: CoffeeItem[] = []
  @State flatList: FlatNode[] = []
  @State cartMap: Map<number, number> = new Map()
  @State totalCount: number = 0
  @State selectedAddress: Address | null = null
  @State searchQuery: string = ''
  private addressChangedHandler: () => void = () => {
    const addr = AddressEditService.getSelectedAddress()
    console.info('OrderPage: 收到地址变更事件，更新UI', JSON.stringify(addr))
    this.selectedAddress = addr
  }
  private rightScroller: Scroller = new Scroller()
  private categoryIdToHeaderIndex: Map<number, number> = new Map()
  private indexToCategoryId: number[] = []

  async aboutToAppear() {
    try {
      this.categories = await RcpUtilsService.fetchCoffeeCategories()
      if (this.categories.length > 0) {
        this.activeCategoryId = this.categories[0].id
      }

      this.allCoffees = await RcpUtilsService.fetchCoffees()
      this.filteredCoffees = this.allCoffees
      this.coffees = this.filterByCategory(this.activeCategoryId)
      this.rebuildFlatList()
      this.selectedAddress = AddressEditService.getSelectedAddress()
      AddressEditService.addAddressChangeListener(this.addressChangedHandler)
    } catch (e) {
      console.error(`OrderPage fetch error: ${JSON.stringify(e)}`)
    }
  }

  onPageShow() {
    const addr = AddressEditService.getSelectedAddress()
    if (addr) {
      this.selectedAddress = addr
    }
  }

  aboutToBeDeleted() {
    AddressEditService.removeAddressChangeListener(this.addressChangedHandler)
  }

  private rebuildFlatList() {
    const flat: FlatNode[] = []
    this.categoryIdToHeaderIndex.clear()
    this.indexToCategoryId = []
    for (let i = 0; i < this.categories.length; i++) {
      const cat = this.categories[i]
      const items = this.filteredCoffees.filter((c: CoffeeItem) => c.parentId === cat.id)
      if (items.length > 0) {
        const headerIndex = flat.length
        this.categoryIdToHeaderIndex.set(cat.id, headerIndex)
        this.indexToCategoryId[headerIndex] = cat.id
        flat.push({ key: `h-${cat.id}`, type: 'header', categoryId: cat.id })
        for (let j = 0; j < items.length; j++) {
          const it = items[j]
          const idx = flat.length
          this.indexToCategoryId[idx] = cat.id
          flat.push({
            key: `i-${cat.id}-${it.id}`,
            type: 'item',
            categoryId: cat.id,
            item: it
          })
        }
      }
    }
    this.flatList = flat
  }

  private applyFilters(): void {
    const query: string = (this.searchQuery || '').trim().toLowerCase()
    if (query === '') {
      this.filteredCoffees = this.allCoffees
    } else {
      this.filteredCoffees = this.allCoffees.filter((c: CoffeeItem) => {
        const title = (c.title || '').toLowerCase()
        return title.includes(query)
      })
    }
  }

  private filterByCategory(categoryId: number | null): CoffeeItem[] {
    if (categoryId === null) {
      return this.allCoffees
    }
    return this.allCoffees.filter((c: CoffeeItem) => c.parentId === categoryId)
  }

  private getItemCount(itemId: number): number {
    const count: number | undefined = this.cartMap.get(itemId)
    return count !== undefined ? count : 0
  }

  private increaseItem(item: CoffeeItem): void {
    const id: number = item.id
    const oldCount: number = this.getItemCount(id)
    const updated: Map<number, number> = new Map(this.cartMap)
    updated.set(id, oldCount + 1)
    this.cartMap = updated
    this.totalCount = this.totalCount + 1
    this.totalPrice = this.totalPrice + item.price
  }

  private decreaseItem(item: CoffeeItem): void {
    const id: number = item.id
    const oldCount: number = this.getItemCount(id)
    if (oldCount <= 0) {
      return
    }
    const nextCount: number = oldCount - 1
    const updated: Map<number, number> = new Map(this.cartMap)
    if (nextCount === 0) {
      updated.delete(id)
    } else {
      updated.set(id, nextCount)
    }
    this.cartMap = updated
    this.totalCount = this.totalCount - 1
    this.totalPrice = this.totalPrice - item.price
  }

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            TextInput({ placeholder: '搜索饮品', text: this.searchQuery })
              .onChange((v: string) => {
                this.searchQuery = v
                this.applyFilters()
                this.rebuildFlatList()
              })
          }
          .margin({ bottom: 10 })

          if (this.selectedAddress) {
            Text(this.formatShortAddress(this.selectedAddress))
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#222222')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Start)
              .onClick(() => {
                this.pathStack.pushPathByName('AddressPage', null)
              })
          } else {
            Text('选择收货地址')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#222222')
              .textAlign(TextAlign.Start)
              .onClick(() => {
                this.pathStack.pushPathByName('AddressPage', null)
              })
            Text('公告 占位文案，按需点餐~')
              .fontSize(12)
              .fontColor('#888888')
              .margin({ top: 4 })
              .textAlign(TextAlign.Start)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 12,
        bottom: 12
      })
      .backgroundColor(Color.White)
      .border({ width: 1, color: '#F0F0F0' })

      Row() {
        List() {
          ForEach(this.categories, (cat: CoffeeCategory) => {
            ListItem() {
              Column() {
                Text(cat.title)
                  .fontSize(14)
                  .fontColor(this.activeCategoryId === cat.id ? '#E65C00' : '#333333')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
              .padding({ top: 12, bottom: 12 })
              .backgroundColor(this.activeCategoryId === cat.id ? '#FFF2E6' : '#F7F8F9')
              .borderRadius(12)
              .onClick(() => {
                if (this.activeCategoryId === cat.id) {
                  return
                }
                this.activeCategoryId = cat.id
                this.coffees = this.filterByCategory(cat.id)
                const headerIndex = this.categoryIdToHeaderIndex.get(cat.id)
                if (headerIndex !== undefined) {
                  try {
                    this.rightScroller.scrollToIndex(headerIndex)
                  } catch (err) {
                    console.error(`scrollToIndex failed: ${JSON.stringify(err)}`)
                  }
                }
              })
            }
            .padding({
              left: 8,
              right: 8,
              top: 6,
              bottom: 6
            })
          })
        }
        .scrollBar(BarState.Off)
        .width(96)
        .height('100%')
        .backgroundColor(Color.White)

        Column() {
          if (this.activeCategoryId !== null) {
            Row() {
              Text((this.categories.find((c: CoffeeCategory) => c.id ===
              this.activeCategoryId) as CoffeeCategory)?.title || '')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .margin({ bottom: 4 })
          }

          List({ scroller: this.rightScroller }) {
            ForEach(this.flatList, (node: FlatNode) => {
              ListItem() {
                if (node.type === 'header') {
                  Row() {
                    Row() {
                    }
                    .width(3)
                    .height(14)
                    .backgroundColor('#E65C00')
                    .borderRadius(2)

                    Text((this.categories.find((c: CoffeeCategory) => c.id ===
                    node.categoryId) as CoffeeCategory)?.title || '')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .margin({ left: 8 })
                    Blank().layoutWeight(1)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                } else {
                  Row() {
                    Image((node.item as CoffeeItem).image)
                      .width(96)
                      .height(96)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                    Column() {
                      Text((node.item as CoffeeItem).title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#222222')
                        .textAlign(TextAlign.Start)
                        .maxLines(1)
                      Text(`原价 ¥ ${(node.item as CoffeeItem).oldprice}`)
                        .fontSize(12)
                        .fontColor('#888888')
                        .margin({ top: 4 })
                        .textAlign(TextAlign.Start)
                        .maxLines(1)
                      Row() {
                        Text(`¥ ${(node.item as CoffeeItem).price}`)
                          .fontSize(16)
                          .fontColor('#E65C00')
                          .fontWeight(FontWeight.Medium)
                        Blank().layoutWeight(1)
                        if (this.getItemCount((node.item as CoffeeItem).id) > 0) {
                          Row() {
                            Text('-').fontSize(18).fontColor('#E65C00')
                          }
                          .width(28)
                          .height(28)
                          .backgroundColor('#FFF2E6')
                          .borderRadius(14)
                          .justifyContent(FlexAlign.Center)
                          .onClick(() => {
                            this.decreaseItem(node.item as CoffeeItem)
                          })

                          Text(String(this.getItemCount((node.item as CoffeeItem).id)))
                            .fontSize(14)
                            .fontColor('#333333')
                            .margin({ left: 8, right: 8 })
                          Row() {
                            Text('+').fontSize(18).fontColor('#E65C00')
                          }
                          .width(28)
                          .height(28)
                          .backgroundColor('#FFF2E6')
                          .borderRadius(14)
                          .justifyContent(FlexAlign.Center)
                          .onClick(() => {
                            this.increaseItem(node.item as CoffeeItem)
                          })
                        } else {
                          Row() {
                            Text('+').fontSize(18).fontColor('#E65C00')
                          }
                          .width(28)
                          .height(28)
                          .backgroundColor('#FFF2E6')
                          .borderRadius(14)
                          .justifyContent(FlexAlign.Center)
                          .onClick(() => {
                            this.increaseItem(node.item as CoffeeItem)
                          })
                        }
                      }
                      .margin({ top: 8 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                  }
                  .width('100%')
                  .padding({
                    left: 12,
                    right: 12,
                    top: 12,
                    bottom: 12
                  })
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: '#F0F0F0' })
                  .borderRadius(12)
                }
              }
              .margin({ bottom: 12 })
            })
          }
          .onScrollIndex((first: number, _last: number) => {
            const catId = this.indexToCategoryId[first]
            if (catId !== undefined && catId !== null && this.activeCategoryId !== catId) {
              this.activeCategoryId = catId
            }
          })
          .layoutWeight(1)
          .padding({ left: 8, right: 12 })
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
      .backgroundColor('#F5F5F5')

      Row() {
        Row() {
          Image($r('app.media.shop_car')).width(20).aspectRatio(1).objectFit(ImageFit.Cover)
          if (this.totalCount > 0) {
            Text(String(this.totalCount))
              .fontSize(12)
              .fontColor(Color.White)
              .backgroundColor('#E65C00')
              .padding({
                left: 6,
                right: 6,
                top: 2,
                bottom: 2
              })
              .borderRadius(10)
              .margin({ left: 6 })
          }
          Text(`合计:￥${this.totalPrice.toFixed(2)}`)
            .fontSize(16)
            .fontColor('#222222')
            .margin({ left: 12 })
        }
        .layoutWeight(1)
        .alignItems(VerticalAlign.Center)

        Text('去结算')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.totalCount > 0 ? '#F0B24A' : '#F5DDB0')
          .opacity(this.totalCount > 0 ? 1 : 0.6)
          .padding({
            left: 24,
            right: 24,
            top: 10,
            bottom: 10
          })
          .borderRadius(22)
          .onClick(() => {
            if (this.totalCount > 0) {
              this.handleCheckout()
            }
          })
      }
      .width('100%')
      .height(56 + this.getUIContext().px2vp(this.bottomSafeHeight))
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)
      .border({ width: 1, color: '#EDEDED' })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding({
      top: this.getUIContext().px2vp(this.topSafeHeight),
      bottom: 0
    })
    .backgroundColor(Color.White)
  }

  private formatShortAddress(addr: Address): string {
    const house: string = addr.house_number && addr.house_number.trim() !== '' ? `, ${addr.house_number}` : ''
    return `${addr.address}${house}`
  }

  private handleCheckout(): void {
    if (!this.selectedAddress) {
      AlertDialog.show({
        title: '请选择收货地址',
        message: '结算前请先选择收货地址',
        confirm: {
          value: '去选择',
          action: () => {
            this.pathStack.pushPathByName('AddressPage', null)
          }
        }
      })
      return
    }

    const items: CheckoutItemParam[] = Array.from(this.cartMap.entries()).map((entry) => {
      const id: number = entry[0]
      const count: number = entry[1]
      const item: CoffeeItem = this.allCoffees.find((c: CoffeeItem) => c.id === id) as CoffeeItem
      const resultItem: CheckoutItemParam = {
        id: id,
        title: item.title,
        image: item.image,
        price: item.price * count,
        count: count
      }
      return resultItem
    })
    CheckoutService.setCheckoutData(this.selectedAddress as Address, items, this.totalPrice)
    this.cartMap = new Map<number, number>()
    this.totalCount = 0
    this.totalPrice = 0
    this.pathStack.pushPathByName('CheckoutPage', null, true)
  }
}
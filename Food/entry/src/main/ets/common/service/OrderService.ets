import { Address } from './RcpUtilsService'
import { CheckoutService, CheckoutItemData } from './CheckoutService'

export interface OrderRecord {
  orderId: string
  pickupCode: string
  createdAt: number
  address: Address
  items: CheckoutItemData[]
  totalAmount: number
  payMethod: 'wechat' | 'alipay'
  status: 'completed'
}

export class OrderService {
  private static readonly KEY_ORDERS = 'ordersJson'
  private static readonly KEY_ORDERS_TS = 'ordersSavedAt'
  private static orders: OrderRecord[] = []
  private static loaded: boolean = false

  private static loadOrders(): void {
    if (OrderService.loaded) {
      return
    }
    // 确保将 AppStorage key 与持久化存储建立绑定关系
    try {
      PersistentStorage.persistProp(OrderService.KEY_ORDERS, '[]')
    } catch (_e) {

    }
    try {
      PersistentStorage.persistProp(OrderService.KEY_ORDERS_TS, 0)
    } catch (_e) {

    }
    const json = AppStorage.get<string>(OrderService.KEY_ORDERS)
    const savedAt = AppStorage.get<number>(OrderService.KEY_ORDERS_TS) || 0
    const now = Date.now()
    const sevenDays = 7 * 24 * 60 * 60 * 1000
    if (savedAt > 0 && now - savedAt > sevenDays) {
      // 过期：清理缓存
      AppStorage.setOrCreate(OrderService.KEY_ORDERS, '[]')
      AppStorage.setOrCreate(OrderService.KEY_ORDERS_TS, now)
      PersistentStorage.persistProp(OrderService.KEY_ORDERS, '[]')
      PersistentStorage.persistProp(OrderService.KEY_ORDERS_TS, now)
      OrderService.orders = []
      OrderService.loaded = true
      return
    }
    if (json && json.length > 0) {
      try {
        const arr: OrderRecord[] = JSON.parse(json) as OrderRecord[]
        OrderService.orders = Array.isArray(arr) ? arr : []
      } catch (_e) {
        OrderService.orders = []
      }
    }
    OrderService.loaded = true
  }

  private static saveOrders(): void {
    const json: string = JSON.stringify(OrderService.orders)
    AppStorage.setOrCreate(OrderService.KEY_ORDERS, json)
    PersistentStorage.persistProp(OrderService.KEY_ORDERS, json)
    const ts: number = Date.now()
    AppStorage.setOrCreate(OrderService.KEY_ORDERS_TS, ts)
    PersistentStorage.persistProp(OrderService.KEY_ORDERS_TS, ts)
  }

  static createFromCheckout(payMethod: 'wechat' | 'alipay'): OrderRecord | null {
    OrderService.loadOrders()
    const addr = CheckoutService.getAddress()
    const items = CheckoutService.getItems()
    const amount = CheckoutService.getTotalAmount()
    // 每次支付生成新的时间、订单号与取餐码
    const createdAt = Date.now()
    const orderId = OrderService.generateOrderId(createdAt)
    const pickupCode = OrderService.generatePickupCode()
    if (!addr || !items) {
      return null
    }
    const rec: OrderRecord = {
      orderId: orderId,
      pickupCode: pickupCode,
      createdAt: createdAt,
      address: addr,
      items: items,
      totalAmount: amount,
      payMethod: payMethod,
      status: 'completed'
    }
    OrderService.orders.unshift(rec)
    OrderService.saveOrders()
    return rec
  }

  static getOrders(): OrderRecord[] {
    OrderService.loadOrders();
    return OrderService.orders
  }

  private static generateOrderId(ts: number): string {
    const date = new Date(ts)
    const pad = (n: number) => (n < 10 ? '0' + n : String(n))
    const y = date.getFullYear()
    const M = pad(date.getMonth() + 1)
    const d = pad(date.getDate())
    const h = pad(date.getHours())
    const m = pad(date.getMinutes())
    const s = pad(date.getSeconds())
    const rand = Math.floor(Math.random() * 9000) + 1000
    return `${y}${M}${d}${h}${m}${s}${rand}`
  }

  private static generatePickupCode(): string {
    return String(Math.floor(1000 + Math.random() * 9000))
  }
}



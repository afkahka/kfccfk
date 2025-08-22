import { Address } from './RcpUtilsService'

export interface CheckoutItemData {
  id: number
  title: string
  image: string
  price: number
  count: number
}

export class CheckoutService {
  private static address: Address | null = null
  private static items: CheckoutItemData[] = []
  private static totalAmount: number = 0
  private static orderId: string = ''
  private static pickupCode: string = ''
  private static createdAt: number = 0 // epoch ms

  static setCheckoutData(address: Address, items: CheckoutItemData[], totalAmount: number): void {
    CheckoutService.address = address
    CheckoutService.items = items
    CheckoutService.totalAmount = totalAmount
    // 生成订单号、取餐码与时间
    const now: number = Date.now()
    CheckoutService.createdAt = now
    CheckoutService.orderId = CheckoutService.generateOrderId(now)
    CheckoutService.pickupCode = CheckoutService.generatePickupCode()
  }

  static getAddress(): Address | null {
    return CheckoutService.address
  }

  static getItems(): CheckoutItemData[] {
    return CheckoutService.items
  }

  static getTotalAmount(): number {
    return CheckoutService.totalAmount
  }

  static getOrderId(): string {
    return CheckoutService.orderId
  }

  static getPickupCode(): string {
    return CheckoutService.pickupCode
  }

  static getCreatedAt(): number {
    return CheckoutService.createdAt
  }

  private static generateOrderId(ts: number): string {
    // 例: yyyyMMddHHmmss + 随机4位
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
    // 4位数字取餐码
    return String(Math.floor(1000 + Math.random() * 9000))
  }
}



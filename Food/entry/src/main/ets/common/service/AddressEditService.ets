import { Address } from './RcpUtilsService'

export class AddressEditService {
  private static editAddress: Address | null = null
  private static isEditMode: boolean = false
  private static needRefresh: boolean = false
  private static selectedAddress: Address | null = null // 选中的地址
  private static readonly KEY_SELECTED_ADDRESS = 'selected_address_json'
  private static readonly KEY_ADDRESS_TS = 'selected_address_saved_at'
  // 地址变更监听器
  private static addressChangeListeners: Array<() => void> = []

  /**
   * 设置要编辑的地址
   */
  static setEditAddress(address: Address): void {
    AddressEditService.editAddress = address
    AddressEditService.isEditMode = true
  }

  /**
   * 获取要编辑的地址
   */
  static getEditAddress(): Address | null {
    return AddressEditService.editAddress
  }

  /**
   * 检查是否为编辑模式
   */
  static isInEditMode(): boolean {
    return AddressEditService.isEditMode
  }

  /**
   * 设置需要刷新标志
   */
  static setNeedRefresh(): void {
    AddressEditService.needRefresh = true
  }

  /**
   * 检查是否需要刷新
   */
  static needRefreshList(): boolean {
    return AddressEditService.needRefresh
  }

  /**
   * 清除刷新标志
   */
  static clearRefreshFlag(): void {
    AddressEditService.needRefresh = false
  }

  /**
   * 清除编辑状态
   */
  static clearEditState(): void {
    AddressEditService.editAddress = null
    AddressEditService.isEditMode = false
    AddressEditService.needRefresh = true // 编辑完成后需要刷新
  }

  /**
   * 监听地址变更事件（新增/编辑成功时触发）
   */
  static addAddressChangeListener(listener: () => void): void {
    AddressEditService.addressChangeListeners.push(listener)
  }

  /**
   * 取消监听地址变更事件
   */
  static removeAddressChangeListener(listener: () => void): void {
    AddressEditService.addressChangeListeners = AddressEditService.addressChangeListeners.filter(l => l !== listener)
  }

  /**
   * 触发地址变更事件
   */
  static emitAddressChanged(): void {
    AddressEditService.addressChangeListeners.forEach(listener => {
      try {
        listener()
      } catch (e) {
        console.error('地址变更回调异常', e)
      }
    })
  }

  /**
   * 设置选中的地址
   */
  static setSelectedAddress(address: Address): void {
    AddressEditService.selectedAddress = address
    // 持久化保存
    try {
      const json: string = JSON.stringify(address)
      AppStorage.setOrCreate(AddressEditService.KEY_SELECTED_ADDRESS, json)
      PersistentStorage.persistProp(AddressEditService.KEY_SELECTED_ADDRESS, json)
      const ts: number = Date.now()
      AppStorage.setOrCreate(AddressEditService.KEY_ADDRESS_TS, ts)
      PersistentStorage.persistProp(AddressEditService.KEY_ADDRESS_TS, ts)
    } catch (_e) {

    }
  }

  /**
   * 获取选中的地址
   */
  static getSelectedAddress(): Address | null {
    if (AddressEditService.selectedAddress) {
      return AddressEditService.selectedAddress
    }
    // 从持久化恢复
    try {
      PersistentStorage.persistProp(AddressEditService.KEY_SELECTED_ADDRESS, '')
    } catch (_e) {

    }
    try {
      PersistentStorage.persistProp(AddressEditService.KEY_ADDRESS_TS, 0)
    } catch (_e) {

    }
    const json = AppStorage.get<string>(AddressEditService.KEY_SELECTED_ADDRESS)
    const savedAt = AppStorage.get<number>(AddressEditService.KEY_ADDRESS_TS) || 0
    const now = Date.now()
    const sevenDays = 7 * 24 * 60 * 60 * 1000
    if (savedAt > 0 && now - savedAt > sevenDays) {
      // 超过7天，清除地址缓存
      AppStorage.setOrCreate(AddressEditService.KEY_SELECTED_ADDRESS, '')
      AppStorage.setOrCreate(AddressEditService.KEY_ADDRESS_TS, 0)
      PersistentStorage.persistProp(AddressEditService.KEY_SELECTED_ADDRESS, '')
      PersistentStorage.persistProp(AddressEditService.KEY_ADDRESS_TS, 0)
      return null
    }
    if (json && json.length > 0) {
      try {
        AddressEditService.selectedAddress = JSON.parse(json) as Address
      } catch (_e) {
        
      }
    }
    return AddressEditService.selectedAddress
  }

  /**
   * 清除选中的地址
   */
  static clearSelectedAddress(): void {
    AddressEditService.selectedAddress = null
    AppStorage.setOrCreate(AddressEditService.KEY_SELECTED_ADDRESS, '')
    PersistentStorage.persistProp(AddressEditService.KEY_SELECTED_ADDRESS, '')
  }
}

export { Address }

import { Address } from './RcpUtilsService'

export class AddressEditService {
  private static editAddress: Address | null = null
  private static isEditMode: boolean = false
  private static needRefresh: boolean = false
  private static selectedAddress: Address | null = null
  private static readonly KEY_SELECTED_ADDRESS = 'selected_address_json'
  private static readonly KEY_ADDRESS_TS = 'selected_address_saved_at'
  private static addressChangeListeners: Array<() => void> = []

  static setEditAddress(address: Address): void {
    AddressEditService.editAddress = address
    AddressEditService.isEditMode = true
  }

  static getEditAddress(): Address | null {
    return AddressEditService.editAddress
  }

  static isInEditMode(): boolean {
    return AddressEditService.isEditMode
  }

  static setNeedRefresh(): void {
    AddressEditService.needRefresh = true
  }

  static needRefreshList(): boolean {
    return AddressEditService.needRefresh
  }

  static clearRefreshFlag(): void {
    AddressEditService.needRefresh = false
  }

  static clearEditState(): void {
    AddressEditService.editAddress = null
    AddressEditService.isEditMode = false
    AddressEditService.needRefresh = true // 编辑完成后需要刷新
  }

  static addAddressChangeListener(listener: () => void): void {
    AddressEditService.addressChangeListeners.push(listener)
  }

  static removeAddressChangeListener(listener: () => void): void {
    AddressEditService.addressChangeListeners = AddressEditService.addressChangeListeners.filter(l => l !== listener)
  }

  static emitAddressChanged(): void {
    AddressEditService.addressChangeListeners.forEach(listener => {
      try {
        listener()
      } catch (e) {
        console.error('地址变更回调异常', e)
      }
    })
  }

  static setSelectedAddress(address: Address): void {
    AddressEditService.selectedAddress = address
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

  static getSelectedAddress(): Address | null {
    if (AddressEditService.selectedAddress) {
      return AddressEditService.selectedAddress
    }
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

  static clearSelectedAddress(): void {
    AddressEditService.selectedAddress = null
    AppStorage.setOrCreate(AddressEditService.KEY_SELECTED_ADDRESS, '')
    PersistentStorage.persistProp(AddressEditService.KEY_SELECTED_ADDRESS, '')
  }
}

export { Address }

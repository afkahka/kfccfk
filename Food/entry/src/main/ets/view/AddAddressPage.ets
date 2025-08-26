import { RcpUtilsService, NewAddressData, Address } from '../common/service/RcpUtilsService'
import { AddressEditService } from '../common/service/AddressEditService'
import { LoginStateService } from '../common/service/LoginStateService'
import { VerificationCodeService, ValidationResult } from '../common/service/VerificationCodeService'

@Builder
export function AddAddressPageBuilder() {
  AddAddressPage()
}

@Preview
@Component
export struct AddAddressPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State isEditMode: boolean = false
  @State editAddressId: number = 0
  @State editAddress: Address | null = null
  @State contactPerson: string = ''
  @State gender: string = '先生'
  @State phoneNumber: string = ''
  @State address: string = ''
  @State houseNumber: string = ''
  @State phoneValidation: ValidationResult = { isValid: true, message: '' }
  @State showPhoneError: boolean = false

  aboutToAppear() {
    const editAddress = AddressEditService.getEditAddress()
    const isEditMode = AddressEditService.isInEditMode()

    if (isEditMode && editAddress && editAddress.id) {
      this.isEditMode = true
      this.editAddressId = editAddress.id
      this.contactPerson = editAddress.contact_person || ''
      this.gender = editAddress.gender === '男' ? '先生' : '女士'
      this.phoneNumber = editAddress.phone_number || ''
      this.address = editAddress.address || ''
      this.houseNumber = editAddress.house_number || ''
      this.validatePhoneNumber(this.phoneNumber)
    } else {
      this.isEditMode = false
      this.editAddressId = 0
      this.contactPerson = ''
      this.gender = '先生'
      this.phoneNumber = ''
      this.address = ''
      this.houseNumber = ''
    }
  }

  onPageShow() {
    const editAddress = AddressEditService.getEditAddress()
    const isEditMode = AddressEditService.isInEditMode()
    if (isEditMode && editAddress && editAddress.id) {
      this.isEditMode = true
      this.editAddressId = editAddress.id
      this.contactPerson = editAddress.contact_person || ''
      this.gender = editAddress.gender === '男' ? '先生' : '女士'
      this.phoneNumber = editAddress.phone_number || ''
      this.address = editAddress.address || ''
      this.houseNumber = editAddress.house_number || ''
      this.validatePhoneNumber(this.phoneNumber)
    } else if (!this.isEditMode) {
      this.isEditMode = false
      this.editAddressId = 0
      this.contactPerson = ''
      this.gender = '先生'
      this.phoneNumber = ''
      this.address = ''
      this.houseNumber = ''
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.back'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.pathStack.pop()
            })
          Text(this.isEditMode ? '编辑地址' : '创建地址')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#222222')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .border({ width: { bottom: 1 }, color: '#F0F0F0' })

        Scroll() {
          Column() {
            this.buildFormRow('联系人', '请填写收货人姓名', this.contactPerson, (value: string) => {
              this.contactPerson = value
            })

            this.buildGenderRow()

            this.buildPhoneRow()

            this.buildFormRow('地址', '请填写收货人地址', this.address, (value: string) => {
              this.address = value
            })

            this.buildFormRow('门牌号', '例如: B座15楼1206室', this.houseNumber, (value: string) => {
              this.houseNumber = value
            })
          }
          .padding({
            top: 0,
            left: 16,
            right: 16,
            bottom: 16
          })
        }
        .align(Alignment.TopStart)
        .layoutWeight(1)
        .backgroundColor(Color.White)

        this.buildSaveButton()
      }
      .width('100%')
    }
    .padding({
      top: this.getUIContext().px2vp(this.topSafeHeight),
      bottom: this.getUIContext().px2vp(this.bottomSafeHeight)
    })
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  @Builder
  buildFormRow(label: string, placeholder: string, value: string, onValueChange: (value: string) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width(80)

        TextInput({
          placeholder: placeholder,
          text: value
        })
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('#222222')
          .backgroundColor(Color.Transparent)
          .onChange(onValueChange)
      }
      .width('100%')
      .padding({ top: 8, bottom: 12 })

      Divider()
        .width('100%')
        .color('#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
  }

  validatePhoneNumber(phone: string): void {
    this.phoneValidation = VerificationCodeService.validateAccountFormat(phone)
    this.showPhoneError = !this.phoneValidation.isValid && phone.length > 0
  }

  @Builder
  buildPhoneRow() {
    Column() {
      Row() {
        Text('手机号')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width(80)
        TextInput({
          placeholder: '请填写收货人手机号',
          text: this.phoneNumber
        })
          .layoutWeight(1)
          .fontSize(16)
          .fontColor(this.showPhoneError ? '#FF3B30' : '#222222')
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.phoneNumber = value
            this.validatePhoneNumber(value)
          })
          .onBlur(() => {
            if (this.phoneNumber.length > 0) {
              this.showPhoneError = !this.phoneValidation.isValid
            }
          })
      }
      .width('100%')
      .padding({ top: 8, bottom: 12 })

      if (this.showPhoneError) {
        Text(this.phoneValidation.message)
          .fontSize(12)
          .fontColor('#FF3B30')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 4, left: 80 })
      }
      Divider()
        .width('100%')
        .color(this.showPhoneError ? '#FF3B30' : '#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
  }

  @Builder
  buildGenderRow() {
    Column() {
      Row() {
        Text('性别')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width(80)

        Row() {
          this.buildGenderOption('先生')
          this.buildGenderOption('女士')
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding({ top: 8, bottom: 12 })

      Divider()
        .width('100%')
        .color('#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
  }

  @Builder
  buildGenderOption(option: string) {
    Row() {
      if (this.gender === option) {
        Row() {
        }
        .width(16)
        .height(16)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .margin({ right: 8 })
      } else {
        Row() {
        }
        .width(16)
        .height(16)
        .border({ width: 2, color: '#CCCCCC' })
        .borderRadius(8)
        .margin({ right: 8 })
      }

      Text(option)
        .fontSize(16)
        .fontColor(this.gender === option ? '#007AFF' : '#666666')
    }
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .onClick(() => {
      this.gender = option
    })
  }

  @Builder
  buildSaveButton() {
    Column() {
      Button('保存')
        .width('90%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor(this.canSubmit() ? '#007AFF' : '#CCCCCC')
        .borderRadius(24)
        .onClick(() => {
          if (this.canSubmit()) {
            this.submitAddress()
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  canSubmit(): boolean {
    return this.contactPerson.trim() !== '' &&
      this.phoneNumber.trim() !== '' &&
    this.phoneValidation.isValid &&
      this.address.trim() !== ''
  }

  async submitAddress() {
    this.validatePhoneNumber(this.phoneNumber)
    if (!this.phoneValidation.isValid) {
      this.showPhoneError = true
      return
    }

    if (!this.canSubmit()) {
      return
    }

    try {
      const addressData: NewAddressData = {
        user_id: LoginStateService.getUserId() || 1,
        contact_person: this.contactPerson,
        gender: this.gender === '先生' ? '男' : '女',
        phone_number: this.phoneNumber,
        address: this.address,
        house_number: this.houseNumber
      }

      if (this.isEditMode) {
        await RcpUtilsService.updateAddress(this.editAddressId, addressData)
        AlertDialog.show({
          title: '更新成功',
          message: '地址已更新',
          confirm: {
            value: '确定',
            action: () => {
              AddressEditService.setNeedRefresh()
              AddressEditService.emitAddressChanged()
              AddressEditService.clearEditState()
              this.pathStack.pop()
            }
          }
        })
      } else {
        await RcpUtilsService.saveAddress(addressData)
        AlertDialog.show({
          title: '保存成功',
          message: '地址已保存',
          confirm: {
            value: '确定',
            action: () => {
              AddressEditService.setNeedRefresh()
              AddressEditService.emitAddressChanged()
              this.pathStack.pop()
            }
          }
        })
      }
    } catch (error) {
      console.error('保存地址失败:', error)
      AlertDialog.show({
        title: '保存失败',
        message: '请稍后重试',
        confirm: {
          value: '确定',
          action: () => {
          }
        }
      })
    }
  }
}

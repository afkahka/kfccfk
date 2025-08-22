import { RcpUtilsService, NewAddressData, Address } from '../common/service/RcpUtilsService'
import { AddressEditService } from '../common/service/AddressEditService'
import { LoginStateService } from '../common/service/LoginStateService'

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
  // 编辑模式相关参数
  @State isEditMode: boolean = false
  @State editAddressId: number = 0
  @State editAddress: Address | null = null
  @State contactPerson: string = ''
  @State gender: string = '先生'
  @State phoneNumber: string = ''
  @State address: string = ''
  @State houseNumber: string = ''

  aboutToAppear() {
    console.info('AddAddressPage aboutToAppear - 检查编辑状态')
    // 从全局服务获取编辑数据
    const editAddress = AddressEditService.getEditAddress()
    const isEditMode = AddressEditService.isInEditMode()

    if (isEditMode && editAddress && editAddress.id) {
      console.info('AddAddressPage: 进入编辑模式，地址ID:', editAddress.id)
      this.isEditMode = true
      this.editAddressId = editAddress.id
      this.contactPerson = editAddress.contact_person || ''
      this.gender = editAddress.gender === '男' ? '先生' : '女士'
      this.phoneNumber = editAddress.phone_number || ''
      this.address = editAddress.address || ''
      this.houseNumber = editAddress.house_number || ''
      console.info('AddAddressPage: 数据填充完成:', {
        contactPerson: this.contactPerson,
        phoneNumber: this.phoneNumber,
        address: this.address
      })
    } else {
      console.info('AddAddressPage: 新增模式')
      // 确保新增模式下所有字段都是空的
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
    console.info('AddAddressPage onPageShow - 检查编辑状态')
    // 页面显示时再次检查编辑数据，确保数据能正确加载
    const editAddress = AddressEditService.getEditAddress()
    const isEditMode = AddressEditService.isInEditMode()

    if (isEditMode && editAddress && editAddress.id) {
      console.info('AddAddressPage onPageShow: 进入编辑模式')
      this.isEditMode = true
      this.editAddressId = editAddress.id
      this.contactPerson = editAddress.contact_person || ''
      this.gender = editAddress.gender === '男' ? '先生' : '女士'
      this.phoneNumber = editAddress.phone_number || ''
      this.address = editAddress.address || ''
      this.houseNumber = editAddress.house_number || ''
    } else if (!this.isEditMode) {
      console.info('AddAddressPage onPageShow: 确保新增模式')
      // 确保新增模式下所有字段都是空的
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

        // 表单内容区域
        Scroll() {
          Column() {
            this.buildFormRow('联系人', '请填写收货人姓名', this.contactPerson, (value: string) => {
              this.contactPerson = value
            })

            this.buildGenderRow()

            this.buildFormRow('手机号', '请填写收货人手机号', this.phoneNumber, (value: string) => {
              this.phoneNumber = value
            })

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

        // 底部保存按钮区域
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

  // 构建表单项行（扁平化设计）
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

      // 分割线
      Divider()
        .width('100%')
        .color('#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
  }

  // 构建性别选择行
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

      // 分割线
      Divider()
        .width('100%')
        .color('#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
  }

  // 构建性别选项
  @Builder
  buildGenderOption(option: string) {
    Row() {
      if (this.gender === option) {
        // 选中状态：蓝色圆圈
        Row() {
        }
        .width(16)
        .height(16)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .margin({ right: 8 })
      } else {
        // 未选中状态：空心圆圈
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

  // 构建保存按钮
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
    .backgroundColor('#F5F5F5')
  }

  // 检查是否可以提交
  canSubmit(): boolean {
    return this.contactPerson.trim() !== '' &&
      this.phoneNumber.trim() !== '' &&
      this.address.trim() !== ''
    // 门牌号可以为空，所以不在这里验证
  }

  // 提交地址
  async submitAddress() {
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
        // 编辑模式：更新地址
        await RcpUtilsService.updateAddress(this.editAddressId, addressData)
        AlertDialog.show({
          title: '更新成功',
          message: '地址已更新',
          confirm: {
            value: '确定',
            action: () => {
              console.info('地址更新成功')
              // 设置需要刷新标志
              AddressEditService.setNeedRefresh()
              // 触发地址变更事件
              AddressEditService.emitAddressChanged()
              // 清除编辑状态
              AddressEditService.clearEditState()
              // 返回上一页
              this.pathStack.pop()
            }
          }
        })
      } else {
        // 新增模式：保存地址
        await RcpUtilsService.saveAddress(addressData)
        AlertDialog.show({
          title: '保存成功',
          message: '地址已保存',
          confirm: {
            value: '确定',
            action: () => {
              console.info('地址保存成功')
              // 设置需要刷新标志
              AddressEditService.setNeedRefresh()
              // 触发地址变更事件
              AddressEditService.emitAddressChanged()
              // 返回上一页
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

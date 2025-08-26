import { LoginStateService } from '../common/service/LoginStateService'
import { RcpUtilsService, UserProfileUpdateData } from '../common/service/RcpUtilsService'
import picker from '@ohos.file.picker'

@Builder
export function ProfileEditPageBuilder() {
  ProfileEditPage()
}

@Preview
@Component
export struct ProfileEditPage {
  @StorageProp('topSafeHeight') topSafeHeight: number = 0
  @StorageProp('bottomSafeHeight') bottomSafeHeight: number = 0
  @Consume('pathStack') pathStack: NavPathStack
  @State userName: string = ''
  @State userPhone: string = ''
  @State userAvatar: string = ''
  @State isAvatarLoading: boolean = false

  aboutToAppear() {
    this.userName = LoginStateService.getUserName() || ''
    this.userPhone = LoginStateService.getUserPhone() || ''
    this.userAvatar = LoginStateService.getUserAvatar() || ''
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

          Text('个人资料')
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
            this.buildAvatarRow()

            Column() {
              this.buildFormRow('昵称', '请输入昵称', this.userName, (value: string) => {
                this.userName = value
              })

              this.buildPhoneRow()
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .backgroundColor('#FFF')
            .borderRadius(12)
            .shadow({
              radius: 8,
              color: '#00000008',
              offsetX: 0,
              offsetY: 2
            })
          }
          .padding({
            top: 16,
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
          .textAlign(TextAlign.Start)

        TextInput({
          placeholder: placeholder,
          text: value
        })
          .layoutWeight(1)
          .fontSize(16)
          .fontColor('#222222')
          .backgroundColor(Color.Transparent)
          .placeholderColor('#ADB5BD')
          .textAlign(TextAlign.Start)
          .onChange(onValueChange)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .justifyContent(FlexAlign.Start)

      if (label !== '手机号') {
        Divider()
          .width('100%')
          .color('#F0F0F0')
          .margin({ top: 0 })
      }
    }
    .width('100%')
  }

  @Builder
  buildAvatarRow() {
    Column() {
      Column() {
        Text('头像')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 16 })

        Column() {
          Stack() {
            Circle()
              .width(80)
              .height(80)
              .fill('#F8F9FA')
              .stroke('#E9ECEF')
              .strokeWidth(2)

            if (this.userAvatar) {
              Image(this.userAvatar)
                .width(76)
                .height(76)
                .borderRadius(38)
                .objectFit(ImageFit.Cover)
            } else {
              Column() {
                Image($r('app.media.logo'))
                  .width(40)
                  .height(40)
                  .objectFit(ImageFit.Contain)
                Text('头像')
                  .fontSize(12)
                  .fontColor('#6C757D')
                  .margin({ top: 4 })
              }
              .width(76)
              .height(76)
              .borderRadius(38)
              .justifyContent(FlexAlign.Center)
            }

            if (this.isAvatarLoading) {
              Circle()
                .width(80)
                .height(80)
                .fill('#00000040')
              LoadingProgress()
                .width(40)
                .height(40)
                .color('#FFF')
            }

            if (!this.isAvatarLoading) {
              Circle()
                .width(24)
                .height(24)
                .fill('#007AFF')
                .position({ x: 56, y: 56 })
                .shadow({
                  radius: 4,
                  color: '#00000020',
                  offsetX: 0,
                  offsetY: 2
                })

              Image($r('app.media.edit'))
                .width(12)
                .height(12)
                .fillColor(Color.White)
                .position({ x: 62, y: 62 })
            }
          }
          .onClick(() => {
            this.selectAvatar()
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 8, bottom: 16 })
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .backgroundColor('#FFF')
      .borderRadius(12)
      .shadow({
        radius: 8,
        color: '#00000008',
        offsetX: 0,
        offsetY: 2
      })
      .margin({ bottom: 16 })

      Divider()
        .width('100%')
        .color('#F0F0F0')
        .margin({ top: 0 })
    }
    .width('100%')
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
          .textAlign(TextAlign.Start)

        Text(this.userPhone)
          .fontSize(16)
          .fontColor('#6C757D')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
  }

  @Builder
  buildSaveButton() {
    Column() {
      Button('保存')
        .width('100%')
        .height(52)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor(this.canSubmit() ? '#007AFF' : '#E9ECEF')
        .borderRadius(26)
        .shadow({
          radius: this.canSubmit() ? 8 : 0,
          color: this.canSubmit() ? '#007AFF40' : 'transparent',
          offsetX: 0,
          offsetY: 4
        })
        .onClick(() => {
          if (this.canSubmit()) {
            this.submitProfile()
          }
        })
    }
    .width('100%')
    .padding({
      top: 24,
      left: 16,
      right: 16,
      bottom: 16
    })
    .backgroundColor(Color.White)
  }

  async selectAvatar() {
    try {
      const photoPicker = new picker.PhotoViewPicker()
      const photoSelectOptions: picker.PhotoSelectOptions = {
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      }
      const photoViewPickerResult = await photoPicker.select(photoSelectOptions)
      if (photoViewPickerResult && photoViewPickerResult.photoUris && photoViewPickerResult.photoUris.length > 0) {
        const selectedPhotoUri = photoViewPickerResult.photoUris[0]
        await this.processSelectedAvatar(selectedPhotoUri)
      }
    } catch (error) {
      console.error('选择头像失败:', error)
      AlertDialog.show({
        title: '选择失败',
        message: '无法选择头像，请重试',
        confirm: {
          value: '确定',
          action: () => {
          }
        }
      })
    }
  }

  async processSelectedAvatar(photoUri: string) {
    this.isAvatarLoading = true

    try {
      this.userAvatar = photoUri
      LoginStateService.setUserAvatar(photoUri)

      AlertDialog.show({
        title: '头像设置成功',
        message: '头像已成功设置',
        confirm: {
          value: '确定',
          action: () => {
          }
        }
      })

    } catch (error) {
      console.error('处理头像失败:', error)
      AlertDialog.show({
        title: '设置失败',
        message: '无法设置头像，请重试',
        confirm: {
          value: '确定',
          action: () => {
          }
        }
      })
    } finally {
      this.isAvatarLoading = false
    }
  }

  canSubmit(): boolean {
    return this.userName.trim() !== ''
  }

  async submitProfile() {
    if (!this.canSubmit()) {
      return
    }

    try {
      const userId = LoginStateService.getUserId()
      if (!userId) {
        AlertDialog.show({
          title: '保存失败',
          message: '用户未登录，请重新登录',
          confirm: {
            value: '确定',
            action: () => {
            }
          }
        })
        return
      }

      const userData: UserProfileUpdateData = {}
      if (this.userName && this.userName.trim() !== '') {
        userData.name = this.userName.trim()
      }

      if (this.userPhone && this.userPhone.trim() !== '') {
        userData.telephone = this.userPhone.trim()
      }

      if (this.userAvatar && this.userAvatar.trim() !== '') {
        userData.avatar = this.userAvatar.trim()
      }

      if (Object.keys(userData).length === 0) {
        AlertDialog.show({
          title: '提示',
          message: '没有需要更新的数据',
          confirm: {
            value: '确定',
            action: () => {
            }
          }
        })
        return
      }

      const updatedUser = await RcpUtilsService.updateUserProfile(userId, userData)

      if (userData.name) {
        LoginStateService.setUserName(userData.name)
      }

      if (userData.telephone) {
        LoginStateService.setUserPhone(userData.telephone)
      }

      if (userData.avatar) {
        LoginStateService.setUserAvatar(userData.avatar)
      }

      AlertDialog.show({
        title: '保存成功',
        message: '个人资料已更新并同步到服务器',
        confirm: {
          value: '确定',
          action: () => {
            setTimeout(() => {
              this.pathStack.pop()
            }, 100)
          }
        }
      })
    } catch (error) {
      let errorMessage = '网络错误，请稍后重试'
      if (error instanceof Error) {
        if (error.message.includes('无效的用户ID')) {
          errorMessage = '用户ID无效，请重新登录'
        } else if (error.message.includes('无效的用户数据')) {
          errorMessage = '用户数据格式错误'
        } else if (error.message.includes('没有有效的数据需要更新')) {
          errorMessage = '没有需要更新的数据'
        } else if (error.message.includes('HTTP错误: 500')) {
          errorMessage = '服务器内部错误，请联系管理员'
        } else if (error.message.includes('HTTP错误: 404')) {
          errorMessage = '用户不存在，请重新登录'
        } else if (error.message.includes('HTTP错误: 400')) {
          errorMessage = '请求参数错误，请检查输入。后端期望接收name和telephone字段。'
        } else if (error.message.includes('网络错误')) {
          errorMessage = '网络连接失败，请检查网络设置'
        } else {
          errorMessage = `保存失败: ${error.message}`
        }
      }

      AlertDialog.show({
        title: '保存失败',
        message: errorMessage,
        confirm: {
          value: '确定',
          action: () => {
          }
        }
      })
    }
  }
}
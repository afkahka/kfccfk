import { LoginStateService } from '../common/service/LoginStateService'
import { RcpUtilsService, UserProfileUpdateData } from '../common/service/RcpUtilsService'

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

  aboutToAppear() {
    // 从登录状态服务获取当前用户信息
    this.userName = LoginStateService.getUserName() || ''
    this.userPhone = LoginStateService.getUserPhone() || ''
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部导航栏
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

        // 表单内容区域
        Scroll() {
                     Column() {
             // 昵称编辑
             this.buildFormRow('昵称', '请输入昵称', this.userName, (value: string) => {
               this.userName = value
             })
             
             // 手机号显示（只读）
             this.buildPhoneRow()
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





  // 构建表单项行
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

  // 构建手机号显示行（只读）
  @Builder
  buildPhoneRow() {
    Column() {
      Row() {
        Text('手机号')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
          .width(80)

        Text(this.userPhone)
          .fontSize(16)
          .fontColor('#999999')
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
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
            this.submitProfile()
          }
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
  }

  // 检查是否可以提交
  canSubmit(): boolean {
    return this.userName.trim() !== ''
  }

  // 提交个人资料
  async submitProfile() {
    if (!this.canSubmit()) {
      return
    }

    try {
      // 获取当前用户ID
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

      // 准备要更新的用户数据
      const userData: UserProfileUpdateData = {}
      if (this.userName && this.userName.trim() !== '') {
        userData.name = this.userName.trim()
      }
      // 根据后端API要求，需要包含telephone字段
      if (this.userPhone && this.userPhone.trim() !== '') {
        userData.telephone = this.userPhone.trim()
      }

      // 检查是否有数据需要更新
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

             // 调用API更新用户信息到数据库
       const updatedUser = await RcpUtilsService.updateUserProfile(userId, userData)

             // 更新本地登录状态服务中的用户信息
       if (userData.name) {
         LoginStateService.setUserName(userData.name)
       }
       if (userData.telephone) {
         LoginStateService.setUserPhone(userData.telephone)
       }

      AlertDialog.show({
        title: '保存成功',
        message: '个人资料已更新并同步到服务器',
                 confirm: {
           value: '确定',
           action: () => {
             // 延迟一下确保数据同步完成，然后返回上一页
             setTimeout(() => {
               this.pathStack.pop()
             }, 100)
           }
         }
      })
         } catch (error) {
       // 根据错误类型显示不同的错误信息
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

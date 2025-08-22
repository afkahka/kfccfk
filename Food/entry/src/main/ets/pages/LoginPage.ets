import { UserConstants } from "../common/constants/UserConstants"
import { VerificationCodeService, SendResult, VerifyResult } from "../common/service/VerificationCodeService"
import { RcpUtilsService, User } from "../common/service/RcpUtilsService"
import { LoginStateService } from "../common/service/LoginStateService"

@Builder
export function LoginPageBuilder(){
  LoginPage()
}

@Component
export struct LoginPage{
  @State account: string = ''
  @State isLoggedIn: boolean = false
  @State verificationCode: string = ''
  @State isLoading: boolean = false
  @State showPassword: boolean = false
  @State countdown: number = 0
  @State canSendCode: boolean = true
  @State errorMessage: string = ''
  @State successMessage: string = ''
  @State userName: string = '' // 新增：存储用户名
  @Consume('pathStack') pathStack:NavPathStack

  build() {
    NavDestination(){
      Column() {
        Image($r('app.media.logo'))
          .width('100vp')
          .aspectRatio(1)
          .margin({top:'50vp'})
        Text('遇见好时光')

        Column() {
          // 错误提示
          if(this.errorMessage){
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#FF3B30')
              .backgroundColor('#FFE5E5')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(6)
              .margin({ bottom: 16 })
              .width('100%')
          }

          // 成功提示
          if(this.successMessage){
            Text(this.successMessage)
              .fontSize(14)
              .fontColor('#34C759')
              .backgroundColor('#E5F7E5')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(6)
              .margin({ bottom: 16 })
              .width('100%')
          }

          Column() {
            Text('账号')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 6 })

            TextInput({
              placeholder: "请输入手机号或邮箱",
              text: this.account
            })
              .width('100%')
              .height(44)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .onChange((value: string) => {
                this.account = value
                this.clearMessages()
              })
              .placeholderColor('#999999')

            // 格式提示
            Text('支持手机号（11位数字）或邮箱地址')
              .fontSize(12)
              .fontColor('#999999')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
          .width('100%')
          .margin({ bottom: 20 })

          Column() {
            Text('验证码')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 6 })

            Row() {
              TextInput({
                placeholder: "请输入验证码",
                text: this.verificationCode
              })
                .width('60%')
                .height(44)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .fontSize(16)
                .onChange((value: string) => {
                  this.verificationCode = value
                  this.clearMessages()
                })
                .placeholderColor('#999999')

              Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                .width('35%')
                .height(44)
                .backgroundColor(this.canSendCode ? '#007AFF' : '#CCCCCC')
                .borderRadius(8)
                .fontSize(14)
                .fontColor(Color.White)
                .enabled(this.canSendCode)
                .onClick(()=>{
                  this.sendVerificationCode()
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .margin({ bottom: 28 })

          Button('登录')
            .width('100%')
            .height(44)
            .backgroundColor(this.canLogin() ? '#007AFF' : '#CCCCCC')
            .borderRadius(8)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .enabled(this.canLogin())
            .onClick(()=>{
              this.handleLogin()
            })
        }
        .width('100%')
        .padding({ left: 32, right: 32 })
        .margin({ top: 24 })

        Blank()
          .layoutWeight(1)

        Column() {
          Divider()
            .color('#E5E5E5')
            .margin({ bottom: 20 })

          Text('其他登录方式')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ bottom: 12 })

          Row({space:30}) {
            Button() {
              Image($r('app.media.wechat'))
                .width(24)
                .height(24)
            }
            .width(44)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(()=>{
              this.wechatLogin()
            })

            Button() {
              Image($r('app.media.qq'))
                .width(24)
                .height(24)
            }
            .width(44)
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(22)
            .onClick(()=>{
              this.qqLogin()
            })
          }
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: 32, right: 32 })
        .margin({ bottom: 40 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }
    .hideTitleBar(true)
    .hideToolBar(true)
  }

  // 检查是否可以登录
  canLogin(): boolean {
    return this.account.length > 0 && this.verificationCode.length > 0
  }

  // 验证手机号是否存在于用户列表中
  async validatePhoneNumber(phoneNumber: string): Promise<boolean> {
    try {
      const users: User[] = await RcpUtilsService.fetchUsers()
      
      // 额外的安全检查
      if (!users || !Array.isArray(users)) {
        return false
      }
      
      // 检查输入的手机号是否在用户列表中存在
      const userExists = users.some(user => user.telephone === phoneNumber)
      
      return userExists
    } catch (error) {
      // 如果无法获取用户列表，为了安全起见，拒绝登录
      return false
    }
  }

  // 验证手机号格式
  isValidPhoneNumber(phoneNumber: string): boolean {
    // 中国手机号格式：11位数字，以1开头
    const phoneRegex = /^1[3-9]\d{9}$/
    return phoneRegex.test(phoneNumber)
  }

  // 清除消息提示
  clearMessages() {
    this.errorMessage = ''
    this.successMessage = ''
  }

  // 发送验证码
  async sendVerificationCode() {
    if (this.account.length === 0) {
      this.errorMessage = '请先输入账号'
      return
    }

    // 检查是否为手机号格式
    if (!this.isValidPhoneNumber(this.account)) {
      this.errorMessage = '请输入正确的手机号格式'
      return
    }

    this.isLoading = true
    this.canSendCode = false

    try {
      // 先验证手机号是否存在于用户列表中
      const isValidPhone = await this.validatePhoneNumber(this.account)
      if (!isValidPhone) {
        this.errorMessage = '该手机号未注册，请先注册或联系管理员'
        this.canSendCode = true
        return
      }

      const result: SendResult = await VerificationCodeService.sendVerificationCode(this.account)

      if(result.success){
        // 尝试获取用户信息以显示用户名
        try {
          const user = await RcpUtilsService.getUserByPhone(this.account)
          
          if (user && user.name) {
            this.userName = user.name
            this.successMessage = `${result.message}，${user.name}`
          } else {
            this.successMessage = result.message
          }
        } catch (error) {
          this.successMessage = result.message
        }
        
        if(result.code){
          this.successMessage += `，验证码：${result.code}`
        }
        this.startCountdown()
      } else {
        this.errorMessage = result.message
        this.canSendCode = true
      }
    }catch(error){
      this.errorMessage = '发送失败，请稍后重试'
      this.canSendCode = true
    }finally{
      this.isLoading = false
    }
  }

  // 开始倒计时
  startCountdown() {
    this.countdown = 60
    const timer = setInterval(()=>{
      this.countdown--
      if(this.countdown <= 0){
        clearInterval(timer)
        this.canSendCode = true
      }
    }, 1000)
  }

  // 处理登录
  async handleLogin() {
    if (!this.canLogin()) {
      return
    }

    this.isLoading = true
    this.clearMessages()

    try {
      // 再次验证手机号是否存在于用户列表中（双重保险）
      if (!this.isValidPhoneNumber(this.account)) {
        this.errorMessage = '请输入正确的手机号格式'
        return
      }

      const isValidPhone = await this.validatePhoneNumber(this.account)
      if (!isValidPhone) {
        this.errorMessage = '该手机号未注册，请先注册或联系管理员'
        return
      }

      const result: VerifyResult = await VerificationCodeService.verifyCode(this.account, this.verificationCode)

      if (result.success) {
        // 获取用户信息以显示用户名
        let user: User | null = null
        try {
          user = await RcpUtilsService.getUserByPhone(this.account)
          
          if (user && user.name) {
            this.userName = user.name
            this.successMessage = `登录成功！欢迎 ${user.name}`
          } else {
            this.successMessage = '登录成功！'
          }
        } catch (error) {
          this.successMessage = '登录成功！'
        }
        
        // 使用LoginStateService记录登录状态
        if (user && user.id) {
          LoginStateService.setUserLoginInfo(
            user.id,
            user.name,
            user.telephone,
            this.account,
            user.avatar || '',
            user.level_type ?? 0
          )
        } else {
          // 如果没有用户ID，至少记录账号和登录状态
          LoginStateService.setLastLoginAccount(this.account)
          LoginStateService.setIsLoggedIn(true)
        }
        this.isLoggedIn = true
        // 登录成功后替换当前路由，避免回退再进入登录/启动页
        this.pathStack.replacePathByName(UserConstants.ROUTER[1], null)
      } else {
        this.errorMessage = result.message
      }
    } catch (error) {
      this.errorMessage = '登录失败，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  // 微信登录
  wechatLogin() {
    // TODO: 实现微信登录
  }

  // QQ登录
  qqLogin() {
    // TODO: 实现QQ登录
  }
}
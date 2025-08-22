export class LoginStateService {
  private static readonly KEY_IS_LOGGED_IN = 'isLoggedIn'
  private static readonly KEY_LAST_ACCOUNT = 'lastLoginAccount'
  private static readonly KEY_USER_ID = 'userId'
  private static readonly KEY_USER_NAME = 'userName'
  private static readonly KEY_USER_PHONE = 'userPhone'
  private static readonly KEY_USER_AVATAR = 'userAvatar'
  private static readonly KEY_USER_LEVEL = 'userLevelType'

  // 初始化持久化存储
  static {
    // 使用PersistentStorage来持久化关键数据
    PersistentStorage.persistProp(LoginStateService.KEY_IS_LOGGED_IN, false)
    PersistentStorage.persistProp(LoginStateService.KEY_LAST_ACCOUNT, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_ID, 0)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_NAME, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_PHONE, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_LEVEL, 0)
  }

  // 静态变量来存储当前值
  private static currentIsLoggedIn: boolean = false
  private static currentLastAccount: string = ''
  private static currentUserId: number = 0
  private static currentUserName: string = ''
  private static currentUserPhone: string = ''
  private static currentUserAvatar: string = ''
  private static currentUserLevelType: number = 0

  /**
   * 设置登录状态
   */
  static setIsLoggedIn(value: boolean): void {
    LoginStateService.currentIsLoggedIn = value
    AppStorage.setOrCreate(LoginStateService.KEY_IS_LOGGED_IN, value)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_IS_LOGGED_IN, value)
  }

  /**
   * 获取登录状态
   */
  static getIsLoggedIn(): boolean {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<boolean>(LoginStateService.KEY_IS_LOGGED_IN)
    if (appStorageValue !== undefined) {
      LoginStateService.currentIsLoggedIn = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentIsLoggedIn
  }

  /**
   * 设置最后登录账号
   */
  static setLastLoginAccount(account: string): void {
    LoginStateService.currentLastAccount = account
    AppStorage.setOrCreate(LoginStateService.KEY_LAST_ACCOUNT, account)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_LAST_ACCOUNT, account)
  }

  /**
   * 获取最后登录账号
   */
  static getLastLoginAccount(): string {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_LAST_ACCOUNT)
    if (appStorageValue !== undefined) {
      LoginStateService.currentLastAccount = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentLastAccount
  }

  /**
   * 设置用户ID
   */
  static setUserId(userId: number): void {
    LoginStateService.currentUserId = userId
    AppStorage.setOrCreate(LoginStateService.KEY_USER_ID, userId)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_USER_ID, userId)
  }

  /**
   * 获取用户ID
   */
  static getUserId(): number {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<number>(LoginStateService.KEY_USER_ID)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserId = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserId
  }

  /**
   * 设置用户姓名
   */
  static setUserName(userName: string): void {
    LoginStateService.currentUserName = userName
    AppStorage.setOrCreate(LoginStateService.KEY_USER_NAME, userName)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_USER_NAME, userName)
  }

  /**
   * 获取用户姓名
   */
  static getUserName(): string {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_NAME)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserName = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserName
  }

  /**
   * 设置用户手机号
   */
  static setUserPhone(userPhone: string): void {
    LoginStateService.currentUserPhone = userPhone
    AppStorage.setOrCreate(LoginStateService.KEY_USER_PHONE, userPhone)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_USER_PHONE, userPhone)
  }

  /**
   * 获取用户手机号
   */
  static getUserPhone(): string {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_PHONE)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserPhone = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserPhone
  }

  /**
   * 设置用户头像
   */
  static setUserAvatar(userAvatar: string): void {
    LoginStateService.currentUserAvatar = userAvatar
    AppStorage.setOrCreate(LoginStateService.KEY_USER_AVATAR, userAvatar)
    // 同时保存到持久化存储
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR, userAvatar)
  }

  /**
   * 设置用户会员等级
   */
  static setUserLevelType(levelType: number): void {
    LoginStateService.currentUserLevelType = levelType
    AppStorage.setOrCreate(LoginStateService.KEY_USER_LEVEL, levelType)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_LEVEL, levelType)
  }

  /**
   * 获取用户会员等级
   */
  static getUserLevelType(): number {
    const appStorageValue = AppStorage.get<number>(LoginStateService.KEY_USER_LEVEL)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserLevelType = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserLevelType
  }

  /**
   * 获取用户头像
   */
  static getUserAvatar(): string {
    // 优先从AppStorage获取，如果没有则使用静态变量
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_AVATAR)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserAvatar = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserAvatar
  }

  /**
   * 设置用户登录信息
   */
  static setUserLoginInfo(userId: number, userName: string, userPhone: string, account: string, userAvatar: string = '', userLevelType: number = 0): void {
    LoginStateService.setUserId(userId)
    LoginStateService.setUserName(userName)
    LoginStateService.setUserPhone(userPhone)
    LoginStateService.setLastLoginAccount(account)
    LoginStateService.setUserAvatar(userAvatar)
    LoginStateService.setUserLevelType(userLevelType)
    LoginStateService.setIsLoggedIn(true)
  }

  /**
   * 清除用户登录信息
   */
  static clearUserLoginInfo(): void {
    LoginStateService.setUserId(0)
    LoginStateService.setUserName('')
    LoginStateService.setUserPhone('')
    LoginStateService.setLastLoginAccount('')
    LoginStateService.setUserAvatar('')
    LoginStateService.setIsLoggedIn(false)
  }

  /**
   * 检查用户是否已登录
   */
  static isUserLoggedIn(): boolean {
    return LoginStateService.getIsLoggedIn() && LoginStateService.getUserId() > 0
  }

  /**
   * 同步AppStorage和PersistentStorage的数据
   */
  static syncStorageData(): void {
    // 从AppStorage读取数据并同步到静态变量
    const isLoggedIn = AppStorage.get<boolean>(LoginStateService.KEY_IS_LOGGED_IN)
    const lastAccount = AppStorage.get<string>(LoginStateService.KEY_LAST_ACCOUNT)
    const userId = AppStorage.get<number>(LoginStateService.KEY_USER_ID)
    const userName = AppStorage.get<string>(LoginStateService.KEY_USER_NAME)
    const userPhone = AppStorage.get<string>(LoginStateService.KEY_USER_PHONE)
    const userAvatar = AppStorage.get<string>(LoginStateService.KEY_USER_AVATAR)
    const userLevelType = AppStorage.get<number>(LoginStateService.KEY_USER_LEVEL)

    // 更新静态变量
    if (isLoggedIn !== undefined) LoginStateService.currentIsLoggedIn = isLoggedIn
    if (lastAccount !== undefined) LoginStateService.currentLastAccount = lastAccount
    if (userId !== undefined) LoginStateService.currentUserId = userId
    if (userName !== undefined) LoginStateService.currentUserName = userName
    if (userPhone !== undefined) LoginStateService.currentUserPhone = userPhone
    if (userAvatar !== undefined) LoginStateService.currentUserAvatar = userAvatar
    if (userLevelType !== undefined) LoginStateService.currentUserLevelType = userLevelType
  }
}

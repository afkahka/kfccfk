export class LoginStateService {
  private static readonly KEY_IS_LOGGED_IN = 'isLoggedIn'
  private static readonly KEY_LAST_ACCOUNT = 'lastLoginAccount'
  private static readonly KEY_USER_ID = 'userId'
  private static readonly KEY_USER_NAME = 'userName'
  private static readonly KEY_USER_PHONE = 'userPhone'
  private static readonly KEY_USER_AVATAR = 'userAvatar'
  private static readonly KEY_USER_AVATAR_BASE64 = 'userAvatarBase64'
  private static readonly KEY_USER_LEVEL = 'userLevelType'

  static {
    PersistentStorage.persistProp(LoginStateService.KEY_IS_LOGGED_IN, false)
    PersistentStorage.persistProp(LoginStateService.KEY_LAST_ACCOUNT, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_ID, 0)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_NAME, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_PHONE, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR_BASE64, '')
    PersistentStorage.persistProp(LoginStateService.KEY_USER_LEVEL, 0)
  }

  private static currentIsLoggedIn: boolean = false
  private static currentLastAccount: string = ''
  private static currentUserId: number = 0
  private static currentUserName: string = ''
  private static currentUserPhone: string = ''
  private static currentUserAvatar: string = ''
  private static currentUserAvatarBase64: string = ''
  private static currentUserLevelType: number = 0

  static setIsLoggedIn(value: boolean): void {
    LoginStateService.currentIsLoggedIn = value
    AppStorage.setOrCreate(LoginStateService.KEY_IS_LOGGED_IN, value)
    PersistentStorage.persistProp(LoginStateService.KEY_IS_LOGGED_IN, value)
  }

  static getIsLoggedIn(): boolean {
    const appStorageValue = AppStorage.get<boolean>(LoginStateService.KEY_IS_LOGGED_IN)
    if (appStorageValue !== undefined) {
      LoginStateService.currentIsLoggedIn = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentIsLoggedIn
  }

  static setLastLoginAccount(account: string): void {
    LoginStateService.currentLastAccount = account
    AppStorage.setOrCreate(LoginStateService.KEY_LAST_ACCOUNT, account)
    PersistentStorage.persistProp(LoginStateService.KEY_LAST_ACCOUNT, account)
  }

  static getLastLoginAccount(): string {
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_LAST_ACCOUNT)
    if (appStorageValue !== undefined) {
      LoginStateService.currentLastAccount = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentLastAccount
  }

  static setUserId(userId: number): void {
    LoginStateService.currentUserId = userId
    AppStorage.setOrCreate(LoginStateService.KEY_USER_ID, userId)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_ID, userId)
  }

  static getUserId(): number {
    const appStorageValue = AppStorage.get<number>(LoginStateService.KEY_USER_ID)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserId = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserId
  }

  static setUserName(userName: string): void {
    LoginStateService.currentUserName = userName
    AppStorage.setOrCreate(LoginStateService.KEY_USER_NAME, userName)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_NAME, userName)
  }

  static getUserName(): string {
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_NAME)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserName = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserName
  }

  static setUserPhone(userPhone: string): void {
    LoginStateService.currentUserPhone = userPhone
    AppStorage.setOrCreate(LoginStateService.KEY_USER_PHONE, userPhone)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_PHONE, userPhone)
  }

  static getUserPhone(): string {
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_PHONE)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserPhone = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserPhone
  }

  static setUserAvatar(userAvatar: string): void {
    LoginStateService.currentUserAvatar = userAvatar
    AppStorage.setOrCreate(LoginStateService.KEY_USER_AVATAR, userAvatar)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR, userAvatar)
  }

  static setUserLevelType(levelType: number): void {
    LoginStateService.currentUserLevelType = levelType
    AppStorage.setOrCreate(LoginStateService.KEY_USER_LEVEL, levelType)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_LEVEL, levelType)
  }

  static getUserLevelType(): number {
    const appStorageValue = AppStorage.get<number>(LoginStateService.KEY_USER_LEVEL)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserLevelType = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserLevelType
  }

  static getUserAvatar(): string {
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_AVATAR)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserAvatar = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserAvatar
  }

  static setUserAvatarBase64(userAvatarBase64: string): void {
    LoginStateService.currentUserAvatarBase64 = userAvatarBase64
    AppStorage.setOrCreate(LoginStateService.KEY_USER_AVATAR_BASE64, userAvatarBase64)
    PersistentStorage.persistProp(LoginStateService.KEY_USER_AVATAR_BASE64, userAvatarBase64)
  }

  static getUserAvatarBase64(): string {
    const appStorageValue = AppStorage.get<string>(LoginStateService.KEY_USER_AVATAR_BASE64)
    if (appStorageValue !== undefined) {
      LoginStateService.currentUserAvatarBase64 = appStorageValue
      return appStorageValue
    }
    return LoginStateService.currentUserAvatarBase64
  }

  static setUserLoginInfo(userId: number, userName: string, userPhone: string, account: string, userAvatar: string = '', userLevelType: number = 0): void {
    LoginStateService.setUserId(userId)
    LoginStateService.setUserName(userName)
    LoginStateService.setUserPhone(userPhone)
    LoginStateService.setLastLoginAccount(account)
    LoginStateService.setUserAvatar(userAvatar)
    LoginStateService.setUserLevelType(userLevelType)
    LoginStateService.setIsLoggedIn(true)
  }

  static clearUserLoginInfo(): void {
    LoginStateService.setUserId(0)
    LoginStateService.setUserName('')
    LoginStateService.setUserPhone('')
    LoginStateService.setLastLoginAccount('')
    LoginStateService.setUserAvatar('')
    LoginStateService.setIsLoggedIn(false)
  }

  static isUserLoggedIn(): boolean {
    return LoginStateService.getIsLoggedIn() && LoginStateService.getUserId() > 0
  }

  static syncStorageData(): void {
    const isLoggedIn = AppStorage.get<boolean>(LoginStateService.KEY_IS_LOGGED_IN)
    const lastAccount = AppStorage.get<string>(LoginStateService.KEY_LAST_ACCOUNT)
    const userId = AppStorage.get<number>(LoginStateService.KEY_USER_ID)
    const userName = AppStorage.get<string>(LoginStateService.KEY_USER_NAME)
    const userPhone = AppStorage.get<string>(LoginStateService.KEY_USER_PHONE)
    const userAvatar = AppStorage.get<string>(LoginStateService.KEY_USER_AVATAR)
    const userLevelType = AppStorage.get<number>(LoginStateService.KEY_USER_LEVEL)

    if (isLoggedIn !== undefined) LoginStateService.currentIsLoggedIn = isLoggedIn
    if (lastAccount !== undefined) LoginStateService.currentLastAccount = lastAccount
    if (userId !== undefined) LoginStateService.currentUserId = userId
    if (userName !== undefined) LoginStateService.currentUserName = userName
    if (userPhone !== undefined) LoginStateService.currentUserPhone = userPhone
    if (userAvatar !== undefined) LoginStateService.currentUserAvatar = userAvatar
    if (userLevelType !== undefined) LoginStateService.currentUserLevelType = userLevelType
  }
}

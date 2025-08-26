import { http } from '@kit.NetworkKit'
import { LoginStateService } from './LoginStateService'

export interface ApiResponse<T> {
  success: boolean
  data: T
}

export interface CoffeeCategory {
  id: number
  title: string
  desc: string
  indexImg: string | null
}

export interface CoffeeItem {
  id: number
  title: string
  price: number
  oldprice: number
  image: string
  parentId: number
}

export interface Address {
  id: number
  user_id: number
  contact_person: string
  gender: string
  phone_number: string
  address: string
  house_number: string
  created_at: string
  updated_at: string
}

export interface NewAddressData {
  user_id: number
  contact_person: string
  gender: string
  phone_number: string
  address: string
  house_number: string
}

export interface UserProfileUpdateData {
  name?: string
  telephone?: string
  avatar?: string
  coins?: number
  growth_value?: number
  level_type?: number
  // 新增：后端支持的增量更新字段
  coins_delta?: number
  growth_delta?: number
}

export interface AvatarUploadData {
  userId: number
  avatarBase64: string
  timestamp: number
}

export interface AvatarUploadResponse {
  success: boolean
  message: string
  avatarUrl?: string
}

export type RequestData = NewAddressData | UserProfileUpdateData | AvatarUploadData
  | Record<string, string | number | boolean>

export interface User {
  id: number
  name: string
  telephone: string
  avatar: string
  level_type?: number
  coins?: number
  growth_value?: number
  coupons?: number
}

export interface UserListResponse {
  success: boolean
  data: User[]
  message: string
}

export interface UserStatsUpdateResponse {
  coins?: number
  growth?: number
  level_type?: number
}

export interface MemberLevel {
  level_type: number
  name: string
  color?: string
  growth_value_min?: number
  growth_value_max?: number
  current_level_txt?: string | null
  next_level_txt?: string | null
}

export interface MemberEndpoints {
  levels: string
  levelDetail: string
  rightCategories: string
  rights: string
  levelRights: string
  levelMainRights: string
}

export interface RawMemberLevel {
  id?: number
  level_type?: number
  levelType?: number
  level_name?: string
  levelName?: string
  name?: string
  color?: string
  growth_value_min?: number
  growth_value_max?: number
  current_level_txt?: string | null
  next_level_txt?: string | null
}

export interface RightCategory {
  id: number
  category: number
  category_name: string
}

export interface RawRightItem {
  id: number
  external_id?: string
  category: number
  right_name: string
  assist_desc?: string
  imgs?: string
  right_desc?: string
  day_of_week?: number
  show_in_main_page?: number
  main_page_show_setting?: string
}

export interface RightItem {
  id: number
  category: number
  name: string
  assistDesc?: string
  image?: string
  desc?: string
  dayOfWeek?: number
  showInMainPage?: boolean
}

export class RcpUtilsService {
  private static readonly BASE_URL: string = 'http://192.168.0.6:3000/api'

  private static async getRequest<T>(path: string): Promise<T> {
    const client: http.HttpRequest = http.createHttp()
    try {
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        header: new Map<string, string>([['Accept', 'application/json']]),
        connectTimeout: 6000,
        readTimeout: 6000
      }

      const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)

      if (response.responseCode !== 200 && response.responseCode !== 201) {
        console.error(`getRequest: HTTP错误 ${response.responseCode}`)
        throw new Error(`HTTP错误: ${response.responseCode}`)
      }

      let resultString: string = ''
      if (typeof response.result === 'string') {
        resultString = response.result as string
      } else if (response.result !== undefined && response.result !== null) {
        resultString = String(response.result)
      }

      if (!resultString) {
        console.warn('getRequest: 响应为空')
        throw new Error('响应为空')
      }

      let parsed: ApiResponse<T>
      try {
        parsed = JSON.parse(resultString) as ApiResponse<T>

      } catch (parseError) {
        console.error(`getRequest: JSON解析失败:`, parseError)
        console.error(`getRequest: 原始响应:`, resultString)
        throw new Error(`JSON解析失败: ${parseError}`)
      }

      if (!parsed || !parsed.success) {
        console.warn('getRequest: 响应不成功:', parsed)
        throw new Error('响应不成功')
      }

      return parsed.data
    } catch (error) {
      console.error(`getRequest: 请求失败 ${path}:`, error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(`请求失败: ${String(error)}`)
      }
    } finally {
      client.destroy()
    }
  }

  static async fetchMemberEndpoints(): Promise<MemberEndpoints> {
    return await RcpUtilsService.getRequest<MemberEndpoints>('/member')
  }

  static async fetchMemberLevels(): Promise<MemberLevel[]> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      const levelsPath = endpoints?.levels ?? '/api/member/levels'
      const raw = await RcpUtilsService.getRequest<RawMemberLevel[]>(levelsPath.replace('/api', ''))
      return raw.map(RcpUtilsService.normalizeMemberLevel)
    } catch (_e) {
      const raw = await RcpUtilsService.getRequest<RawMemberLevel[]>('/member/levels')
      return raw.map(RcpUtilsService.normalizeMemberLevel)
    }
  }

  static async fetchRightCategories(): Promise<RightCategory[]> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      let path = endpoints?.rightCategories || '/api/member/right-categories'
      path = path.replace('/api', '')
      return await RcpUtilsService.getRequest<RightCategory[]>(path)
    } catch (_e) {
      return await RcpUtilsService.getRequest<RightCategory[]>('/member/right-categories')
    }
  }

  private static normalizeRightItem(input: RawRightItem): RightItem {
    return {
      id: input.id,
      category: input.category,
      name: input.right_name,
      assistDesc: input.assist_desc,
      image: input.imgs,
      desc: input.right_desc,
      dayOfWeek: input.day_of_week,
      showInMainPage: input.show_in_main_page === 1
    }
  }

  static async fetchRightsByCategory(category: number): Promise<RightItem[]> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      let path = endpoints?.rights || '/api/member/rights?category='
      if (path.includes('?category=')) {
        path = `${path}${category}`
      } else {
        path = `${path}?category=${category}`
      }
      path = path.replace('/api', '')
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(path)
      return raw.map(RcpUtilsService.normalizeRightItem)
    } catch (_e) {
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(`/member/rights?category=${category}`)
      return raw.map(RcpUtilsService.normalizeRightItem)
    }
  }

  static async fetchRightsByLevel(levelType: number): Promise<RightItem[]> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      let path = endpoints?.levelRights || '/api/member/levels/:levelType/rights'
      path = path.replace(':levelType', String(levelType)).replace('/api', '')
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(path)
      return raw.map(RcpUtilsService.normalizeRightItem)
    } catch (_e) {
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(`/member/levels/${levelType}/rights`)
      return raw.map(RcpUtilsService.normalizeRightItem)
    }
  }

  static async fetchMainRightsByLevel(levelType: number): Promise<RightItem[]> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      let path = endpoints?.levelMainRights || '/api/member/levels/:levelType/main-rights'
      path = path.replace(':levelType', String(levelType)).replace('/api', '')
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(path)
      return raw.map(RcpUtilsService.normalizeRightItem)
    } catch (_e) {
      const raw = await RcpUtilsService.getRequest<RawRightItem[]>(`/member/levels/${levelType}/main-rights`)
      return raw.map(RcpUtilsService.normalizeRightItem)
    }
  }

  private static normalizeMemberLevel(input: RawMemberLevel): MemberLevel {
    const levelType: number = input?.level_type ?? input?.levelType ?? 0
    const name: string = input?.name ?? input?.level_name ?? input?.levelName ?? ''
    const color: string | undefined = input?.color
    return {
      level_type: levelType,
      name,
      color,
      growth_value_min: input?.growth_value_min,
      growth_value_max: input?.growth_value_max,
      current_level_txt: input?.current_level_txt ?? null,
      next_level_txt: input?.next_level_txt ?? null
    }
  }

  static async fetchMemberLevelDetail(levelType: number): Promise<MemberLevel> {
    try {
      const endpoints = await RcpUtilsService.fetchMemberEndpoints()
      let detailPath = endpoints?.levelDetail || '/api/member/levels/:levelType'
      detailPath = detailPath.replace(':levelType', String(levelType))
      if (detailPath.startsWith('/api/')) {
        detailPath = detailPath.replace('/api', '')
      }
      const raw = await RcpUtilsService.getRequest<RawMemberLevel>(detailPath)
      return RcpUtilsService.normalizeMemberLevel(raw)
    } catch (_e) {
      const raw = await RcpUtilsService.getRequest<RawMemberLevel>(`/member/levels/${levelType}`)
      return RcpUtilsService.normalizeMemberLevel(raw)
    }
  }

  private static async postRequest<T, D extends RequestData = RequestData>(path: string, data: D): Promise<T> {
    const client: http.HttpRequest = http.createHttp()
    try {
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        header: new Map<string, string>([
          ['Accept', 'application/json'],
          ['Content-Type', 'application/json']
        ]),
        connectTimeout: 6000,
        readTimeout: 6000,
        extraData: JSON.stringify(data)
      }

      const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)

      if (response.responseCode !== 200 && response.responseCode !== 201) {
        console.error(`postRequest: HTTP错误 ${response.responseCode}`)
        throw new Error(`HTTP错误: ${response.responseCode}`)
      }

      let resultString: string = ''
      if (typeof response.result === 'string') {
        resultString = response.result as string
      } else if (response.result !== undefined && response.result !== null) {
        resultString = String(response.result)
      }

      if (!resultString) {
        console.warn('postRequest: 响应为空')
        throw new Error('响应为空')
      }

      let parsed: ApiResponse<T>
      try {
        parsed = JSON.parse(resultString) as ApiResponse<T>

      } catch (parseError) {
        console.error(`postRequest: JSON解析失败:`, parseError)
        console.error(`postRequest: 原始响应:`, resultString)
        throw new Error(`JSON解析失败: ${parseError}`)
      }

      if (!parsed || !parsed.success) {
        console.warn('postRequest: 响应不成功:', parsed)
        throw new Error('响应不成功')
      }

      return parsed.data
    } catch (error) {
      console.error(`postRequest: 请求失败 ${path}:`, error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(`请求失败: ${String(error)}`)
      }
    } finally {
      client.destroy()
    }
  }

  private static async putRequest<T, D extends RequestData = RequestData>(path: string, data: D): Promise<T> {
    const client: http.HttpRequest = http.createHttp()
    try {
      const requestOptions: http.HttpRequestOptions = {
        method: http.RequestMethod.PUT,
        header: new Map<string, string>([
          ['Accept', 'application/json'],
          ['Content-Type', 'application/json']
        ]),
        connectTimeout: 6000,
        readTimeout: 6000,
        extraData: JSON.stringify(data)
      }
      const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)

      if (response.responseCode !== 200 && response.responseCode !== 201) {
        console.error(`putRequest: HTTP错误 ${response.responseCode}`)
        throw new Error(`HTTP错误: ${response.responseCode}`)
      }

      let resultString: string = ''
      if (typeof response.result === 'string') {
        resultString = response.result as string
      } else if (response.result !== undefined && response.result !== null) {
        resultString = String(response.result)
      }

      if (!resultString) {
        console.warn('putRequest: 响应为空')
        throw new Error('响应为空')
      }

      let parsed: ApiResponse<T>
      try {
        parsed = JSON.parse(resultString) as ApiResponse<T>
      } catch (parseError) {
        console.error(`putRequest: JSON解析失败:`, parseError)
        console.error(`putRequest: 原始响应:`, resultString)
        throw new Error(`JSON解析失败: ${parseError}`)
      }

      if (!parsed || !parsed.success) {
        console.warn('putRequest: 响应不成功:', parsed)
        throw new Error('响应不成功')
      }

      return parsed.data
    } catch (error) {
      console.error(`putRequest: 请求失败 ${path}:`, error)
      if (error instanceof Error) {
        throw error
      } else {
        throw new Error(`请求失败: ${String(error)}`)
      }
    } finally {
      client.destroy()
    }
  }

  static async fetchCoffeeCategories(): Promise<CoffeeCategory[]> {
    return await RcpUtilsService.getRequest<CoffeeCategory[]>('/category')
  }

  static async fetchCoffees(parentId?: number): Promise<CoffeeItem[]> {
    const query: string = parentId !== undefined ? `?parentId=${parentId}` : ''
    return await RcpUtilsService.getRequest<CoffeeItem[]>(`/coffee${query}`)
  }

  static async fetchAddresses(): Promise<Address[]> {
    return await RcpUtilsService.getRequest<Address[]>('/address')
  }

  static async saveAddress(addressData: NewAddressData): Promise<Address> {
    try {
      const response = await RcpUtilsService.postRequest<Address, NewAddressData>('/address', addressData)
      return response
    } catch (error) {
      console.error('保存地址失败:', error)
      throw new Error('保存地址失败')
    }
  }

  static async updateAddress(addressId: number, addressData: NewAddressData): Promise<Address> {
    try {
      const response = await RcpUtilsService.putRequest<Address, NewAddressData>(`/address/${addressId}`, addressData)
      return response
    } catch (error) {
      console.error('更新地址失败:', error)
      throw new Error('更新地址失败')
    }
  }

  static async fetchUsers(): Promise<User[]> {
    try {
      const users = await RcpUtilsService.getRequest<User[]>('/user')
      if (!Array.isArray(users)) {
        return []
      }

      const validUsers = users.filter(user => {
        if (!user || typeof user !== 'object') {
          return false
        }
        if (!user.id || !user.name || !user.telephone) {
          return false
        }
        return true
      })
      return validUsers
    } catch (error) {
      return []
    }
  }

  static async getUserByPhone(phoneNumber: string): Promise<User | null> {
    try {
      const users = await RcpUtilsService.fetchUsers()
      if (users.length === 0) {
        return null
      }
      const user = users.find(user => user.telephone === phoneNumber)
      return user || null
    } catch (error) {
      return null
    }
  }

  static async getUserById(userId: number): Promise<User | null> {
    try {
      const users = await RcpUtilsService.fetchUsers()
      if (users.length === 0) {
        return null
      }
      const user = users.find(u => u.id === userId)
      return user || null
    } catch (_e) {
      return null
    }
  }

  static async updateUserProfile(userId: number, userData: UserProfileUpdateData): Promise<User> {
    try {
      const response = await RcpUtilsService.putRequest<User, UserProfileUpdateData>(`/user/${userId}`, userData)
      return response
    } catch (error) {
      throw new Error('更新用户信息失败')
    }
  }

  static async updateUserStatsDelta(userId: number, coinsDelta: number, growthDelta: number)
    : Promise<UserStatsUpdateResponse> {
    const payload: UserProfileUpdateData = {
      coins_delta: Number(coinsDelta || 0),
      growth_delta: Number(growthDelta || 0)
    }
    const resp = await RcpUtilsService.putRequest<UserStatsUpdateResponse, UserProfileUpdateData>(`/user/${userId}`, payload)
    return resp
  }

  static async updateUserLevel(userId: number, levelType: number): Promise<User | null> {
    try {
      const current = await RcpUtilsService.getUserById(userId)
      if (!current) return null
      const updated = await RcpUtilsService.updateUserProfile(userId, {
        name: current.name,
        telephone: current.telephone,
        avatar: current.avatar,
        level_type: levelType
      })
      return updated
    } catch (_e) {
      return null
    }
  }

  static async resetUserCoinsToZero(userId: number): Promise<User | null> {
    try {
      const current = await RcpUtilsService.getUserById(userId)
      if (!current) return null
      const updated = await RcpUtilsService.updateUserProfile(userId, {
        name: current.name,
        telephone: current.telephone,
        avatar: current.avatar,
        coins: 0
      })
      return updated
    } catch (_e) {
      return null
    }
  }

  static async incrementUserStats(userId: number, coinsDelta: number, growthDelta: number): Promise<User | null> {
    try {
      const data = await RcpUtilsService.updateUserStatsDelta(userId, coinsDelta, growthDelta)
      if (data && typeof data.level_type === 'number') {
        LoginStateService.setUserLevelType(data.level_type as number)
      }
      const user = await RcpUtilsService.getUserById(userId)
      return user
    } catch (_e) {
      return null
    }
  }

  static async uploadUserAvatar(uploadData: AvatarUploadData): Promise<ApiResponse<AvatarUploadResponse>> {
    try {
      const response =
        await RcpUtilsService.postRequest<ApiResponse<AvatarUploadResponse>, AvatarUploadData>('/user/avatar',
          uploadData)
      return response
    } catch (error) {
      console.error('上传头像失败:', error)
      throw new Error('上传头像失败')
    }
  }
}
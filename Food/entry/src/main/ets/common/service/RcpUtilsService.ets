import { http } from '@kit.NetworkKit'

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

// 地址相关接口
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

// 新增地址数据接口（不包含自动生成的字段）
export interface NewAddressData {
	user_id: number
	contact_person: string
	gender: string
	phone_number: string
	address: string
	house_number: string
}

// 用户信息接口
export interface User {
  id: number
  name: string
  telephone: string
  avatar: string
  level_type?: number
}

// 用户列表响应接口
export interface UserListResponse {
  success: boolean
  data: User[]
  message: string
}

// 会员等级
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

// 原始会员等级（服务端可能返回多种字段命名）
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

export class RcpUtilsService{
	private static readonly BASE_URL: string = 'http://192.168.0.7:3000/api'

	private static async getRequest<T>(path: string): Promise<T> {
		const client: http.HttpRequest = http.createHttp()
		try {
			const requestOptions: http.HttpRequestOptions = {
				method: http.RequestMethod.GET,
				header: new Map<string, string>([['Accept', 'application/json']]),
				connectTimeout: 6000,
				readTimeout: 6000
			}
			
			console.info(`getRequest: 开始请求 ${RcpUtilsService.BASE_URL}${path}`)
			
			const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)
			
			console.info(`getRequest: 请求路径 ${path}, 响应状态码: ${response.responseCode}`)
			
			// 检查HTTP状态码 - GET请求可以接受200(成功)或201(创建成功)
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
			
			console.info(`getRequest: 响应内容: ${resultString}`)
			
			if (!resultString) {
				console.warn('getRequest: 响应为空')
				throw new Error('响应为空')
			}
			
			let parsed: ApiResponse<T>
			try {
				parsed = JSON.parse(resultString) as ApiResponse<T>
				console.info(`getRequest: 解析后的数据:`, parsed)
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
			// 确保抛出的是Error对象
			if (error instanceof Error) {
				throw error
			} else {
				throw new Error(`请求失败: ${String(error)}`)
			}
		} finally {
			client.destroy()
		}
	}

	// 会员模块：获取服务端暴露的会员端点
	static async fetchMemberEndpoints(): Promise<MemberEndpoints> {
		return await RcpUtilsService.getRequest<MemberEndpoints>('/member')
	}

	// 会员模块：获取会员等级列表
	static async fetchMemberLevels(): Promise<MemberLevel[]> {
		// 若服务端 `/member` 返回端点，再次请求 levels；否则允许直接 `/member/levels`
		try {
			const endpoints = await RcpUtilsService.fetchMemberEndpoints()
			const levelsPath = endpoints?.levels ?? '/api/member/levels'
			const raw = await RcpUtilsService.getRequest<RawMemberLevel[]>(levelsPath.replace('/api', ''))
			return raw.map(RcpUtilsService.normalizeMemberLevel)
		} catch (_e) {
			// 兜底：直接按既定路径请求
			const raw = await RcpUtilsService.getRequest<RawMemberLevel[]>('/member/levels')
			return raw.map(RcpUtilsService.normalizeMemberLevel)
		}
	}

	// 权益：分类列表
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

	// 权益：按分类获取权益列表
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

	// 权益：指定等级全部权益
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

	// 权益：指定等级主权益（用于“首页展示”）
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

	// 会员模块：获取指定 levelType 的等级详情
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

	private static async postRequest<T>(path: string, data: NewAddressData): Promise<T> {
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
			
			console.info(`postRequest: 开始请求 ${RcpUtilsService.BASE_URL}${path}`)
			
			const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)
			
			console.info(`postRequest: 请求路径 ${path}, 响应状态码: ${response.responseCode}`)
			
			// 检查HTTP状态码 - POST请求可以接受200(成功)或201(创建成功)
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
			
			console.info(`postRequest: 响应内容: ${resultString}`)
			
			if (!resultString) {
				console.warn('postRequest: 响应为空')
				throw new Error('响应为空')
			}
			
			let parsed: ApiResponse<T>
			try {
				parsed = JSON.parse(resultString) as ApiResponse<T>
				console.info(`postRequest: 解析后的数据:`, parsed)
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
			// 确保抛出的是Error对象
			if (error instanceof Error) {
				throw error
			} else {
				throw new Error(`请求失败: ${String(error)}`)
			}
		} finally {
			client.destroy()
		}
	}

	private static async putRequest<T>(path: string, data: NewAddressData): Promise<T> {
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
			
			console.info(`putRequest: 开始请求 ${RcpUtilsService.BASE_URL}${path}`)
			
			const response: http.HttpResponse = await client.request(`${RcpUtilsService.BASE_URL}${path}`, requestOptions)
			
			console.info(`putRequest: 请求路径 ${path}, 响应状态码: ${response.responseCode}`)
			
			// 检查HTTP状态码 - PUT请求可以接受200(成功)或201(创建成功)
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
			
			console.info(`putRequest: 响应内容: ${resultString}`)
			
			if (!resultString) {
				console.warn('putRequest: 响应为空')
				throw new Error('响应为空')
			}
			
			let parsed: ApiResponse<T>
			try {
				parsed = JSON.parse(resultString) as ApiResponse<T>
				console.info(`putRequest: 解析后的数据:`, parsed)
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
			// 确保抛出的是Error对象
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
		return await RcpUtilsService.getRequest<CoffeeCategory[] >('/category')
	}

	static async fetchCoffees(parentId?: number): Promise<CoffeeItem[]> {
		const query: string = parentId !== undefined ? `?parentId=${parentId}` : ''
		return await RcpUtilsService.getRequest<CoffeeItem[]>(`/coffee${query}`)
	}

	// 获取地址列表
	static async fetchAddresses(): Promise<Address[]> {
		return await RcpUtilsService.getRequest<Address[]>('/address')
	}

	// 保存地址
	static async saveAddress(addressData: NewAddressData): Promise<Address> {
		try {
			const response = await RcpUtilsService.postRequest<Address>('/address', addressData)
			return response
		} catch (error) {
			console.error('保存地址失败:', error)
			throw new Error('保存地址失败')
		}
	}

	// 更新地址
		// 更新地址
	static async updateAddress(addressId: number, addressData: NewAddressData): Promise<Address> {
		try {
			const response = await RcpUtilsService.putRequest<Address>(`/address/${addressId}`, addressData)
			return response
		} catch (error) {
			console.error('更新地址失败:', error)
			throw new Error('更新地址失败')
		}
	}

	// 获取用户列表
	static async fetchUsers(): Promise<User[]> {
		try {
			console.info('fetchUsers: 开始获取用户列表')
			const users = await RcpUtilsService.getRequest<User[]>('/user')
			console.info(`fetchUsers: 成功获取 ${users.length} 个用户`)
			
			// 验证返回的数据
			if (!Array.isArray(users)) {
				console.warn('fetchUsers: 返回的数据不是数组:', users)
				return []
			}
			
			// 验证每个用户对象
			const validUsers = users.filter(user => {
				if (!user || typeof user !== 'object') {
					console.warn('fetchUsers: 无效的用户对象:', user)
					return false
				}
				if (!user.id || !user.name || !user.telephone) {
					console.warn('fetchUsers: 用户对象缺少必要字段:', user)
					return false
				}
				return true
			})
			
			console.info(`fetchUsers: 有效用户数量: ${validUsers.length}`)
			return validUsers
		} catch (error) {
			console.error('fetchUsers: 获取用户列表失败:', error)
			// 返回空数组而不是抛出错误，避免登录功能完全失效
			return []
		}
	}

	// 根据手机号获取用户信息
	static async getUserByPhone(phoneNumber: string): Promise<User | null> {
		try {
			console.info('getUserByPhone: 开始查找手机号:', phoneNumber)
			const users = await RcpUtilsService.fetchUsers()
			console.info('getUserByPhone: 获取到用户列表，数量:', users.length)

			if (users.length === 0) {
				console.warn('getUserByPhone: 用户列表为空')
				return null
			}

			const user = users.find(user => user.telephone === phoneNumber)
			console.info('getUserByPhone: 找到的用户:', user)

			if (user) {
				console.info('getUserByPhone: 成功找到用户，姓名:', user.name, '手机号:', user.telephone, '头像:', user.avatar)
			} else {
				console.warn('getUserByPhone: 未找到匹配的用户，手机号:', phoneNumber)
				console.info('getUserByPhone: 所有用户的手机号:', users.map(u => u.telephone))
			}

			return user || null
		} catch (error) {
			console.error('getUserByPhone: 根据手机号获取用户信息失败:', error)
			return null
		}
	}
}
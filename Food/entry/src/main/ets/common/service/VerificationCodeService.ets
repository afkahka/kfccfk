/**
 * 验证码服务类
 * 模拟真实的验证码发送和验证功能
 */
export class VerificationCodeService {
  // 存储验证码的Map，key为手机号/邮箱，value为验证码信息
  private static verificationCodes: Map<string, VerificationCodeInfo> = new Map()
  // 验证码有效期（毫秒）
  private static readonly VALID_DURATION: number = 5 * 60 * 1000 // 5分钟

  // 验证码长度
  private static readonly CODE_LENGTH: number = 6

  // 发送验证码
  static sendVerificationCode(account: string): Promise<SendResult> {
    return new Promise((resolve) => {
      // 模拟网络延迟
      setTimeout(() => {
        try {
          // 验证账号格式
          const validationResult = VerificationCodeService.validateAccountFormat(account)
          if (!validationResult.isValid) {
            resolve({
              success: false,
              message: validationResult.message
            })
            return
          }

          // 检查发送频率限制（防止频繁发送）
          const existingCode = VerificationCodeService.verificationCodes.get(account)
          if (existingCode && Date.now() - existingCode.sendTime < 60 * 1000) {
            resolve({
              success: false,
              message: '发送过于频繁，请1分钟后再试'
            })
            return
          }

          // 生成验证码
          const code = VerificationCodeService.generateVerificationCode()
          const sendTime = Date.now()

          // 存储验证码信息
          VerificationCodeService.verificationCodes.set(account, {
            code: code,
            sendTime: sendTime,
            attempts: 0
          })

          // 模拟发送成功
          console.info(`模拟发送验证码到 ${account}: ${code}`)

          resolve({
            success: true,
            message: '验证码发送成功',
            code: code // 开发阶段显示验证码，生产环境应该删除
          })

        } catch (error) {
          resolve({
            success: false,
            message: '发送失败，请稍后重试'
          })
        }
      }, 1000) // 模拟1秒网络延迟
    })
  }

  // 验证验证码
  static verifyCode(account: string, code: string): Promise<VerifyResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        try {
          const codeInfo = VerificationCodeService.verificationCodes.get(account)

          if (!codeInfo) {
            resolve({
              success: false,
              message: '验证码不存在或已过期，请重新获取'
            })
            return
          }

          // 检查验证码是否过期
          if (Date.now() - codeInfo.sendTime > VerificationCodeService.VALID_DURATION) {
            VerificationCodeService.verificationCodes.delete(account)
            resolve({
              success: false,
              message: '验证码已过期，请重新获取'
            })
            return
          }

          // 检查尝试次数
          if (codeInfo.attempts >= 5) {
            VerificationCodeService.verificationCodes.delete(account)
            resolve({
              success: false,
              message: '验证码尝试次数过多，请重新获取'
            })
            return
          }

          // 增加尝试次数
          codeInfo.attempts++

          // 验证验证码
          if (codeInfo.code === code) {
            // 验证成功，删除验证码
            VerificationCodeService.verificationCodes.delete(account)
            resolve({
              success: true,
              message: '验证码验证成功'
            })
          } else {
            resolve({
              success: false,
              message: `验证码错误，还剩${5 - codeInfo.attempts}次尝试机会`
            })
          }

        } catch (error) {
          resolve({
            success: false,
            message: '验证失败，请稍后重试'
          })
        }
      }, 500) // 模拟500ms验证延迟
    })
  }

  // 生成随机验证码
  private static generateVerificationCode(): string {
    let code = ''
    for (let i = 0; i < VerificationCodeService.CODE_LENGTH; i++) {
      code += Math.floor(Math.random() * 10).toString()
    }
    return code
  }

  // 验证账号格式并返回详细结果
  static validateAccountFormat(account: string): ValidationResult {
    // 手机号格式：1开头的11位数字
    const phoneRegex = /^1[3-9]\d{9}$/

    if (phoneRegex.test(account)) {
      return {
        isValid: true,
        message: '手机号格式正确'
      }
    }

    // 邮箱格式验证
    if (account.includes('@')) {
      // 基本格式检查
      const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

      if (!emailRegex.test(account)) {
        return {
          isValid: false,
          message: '邮箱格式不正确，请检查@符号和域名格式'
        }
      }

      // 进一步验证邮箱的合理性
      const parts = account.split('@')
      const localPart = parts[0]
      const domainPart = parts[1]

      // 本地部分检查
      if (localPart.length === 0) {
        return {
          isValid: false,
          message: '邮箱@符号前不能为空'
        }
      }

      if (localPart.length > 64) {
        return {
          isValid: false,
          message: '邮箱@符号前部分过长，不能超过64个字符'
        }
      }

      // 域名部分检查
      if (domainPart.length === 0) {
        return {
          isValid: false,
          message: '邮箱@符号后不能为空'
        }
      }

      if (domainPart.length > 253) {
        return {
          isValid: false,
          message: '邮箱域名部分过长，不能超过253个字符'
        }
      }

      // 域名不能以点开头或结尾
      if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
        return {
          isValid: false,
          message: '邮箱域名不能以点开头或结尾'
        }
      }

      // 域名不能包含连续的点
      if (domainPart.includes('..')) {
        return {
          isValid: false,
          message: '邮箱域名不能包含连续的点'
        }
      }

      // 顶级域名至少2个字符
      const topLevelDomain = domainPart.split('.').pop()
      if (!topLevelDomain || topLevelDomain.length < 2) {
        return {
          isValid: false,
          message: '邮箱顶级域名至少需要2个字符（如.com、.cn）'
        }
      }

      // 检查是否为常见无效域名
      const invalidDomains = ['1.2', '0.0', '127.0.0.1', 'localhost']
      if (invalidDomains.includes(domainPart)) {
        return {
          isValid: false,
          message: '请输入有效的邮箱域名，不能使用测试域名'
        }
      }

      return {
        isValid: true,
        message: '邮箱格式正确'
      }
    }

    // 既不是手机号也不是邮箱
    return {
      isValid: false,
      message: '请输入有效的手机号（11位数字）或邮箱地址'
    }
  }

  // 验证账号格式（保持向后兼容）
  private static isValidAccount(account: string): boolean {
    return VerificationCodeService.validateAccountFormat(account).isValid
  }

  // 获取剩余时间（秒）
  static getRemainingTime(account: string): number {
    const codeInfo = VerificationCodeService.verificationCodes.get(account)
    if (!codeInfo) {
      return 0
    }

    const remaining = VerificationCodeService.VALID_DURATION - (Date.now() - codeInfo.sendTime)
    return Math.max(0, Math.ceil(remaining / 1000))
  }

  // 清理过期的验证码
  static cleanupExpiredCodes(): void {
    const now = Date.now()
    const entries = VerificationCodeService.verificationCodes.entries()
    for (const entry of entries) {
      const account = entry[0]
      const codeInfo = entry[1]
      if (now - codeInfo.sendTime > VerificationCodeService.VALID_DURATION) {
        VerificationCodeService.verificationCodes.delete(account)
      }
    }
  }
}

// 验证码信息接口
interface VerificationCodeInfo {
  code: string
  sendTime: number
  attempts: number
}

// 发送结果接口
export interface SendResult {
  success: boolean
  message: string
  code?: string // 开发阶段显示验证码
}

// 验证结果接口
export interface VerifyResult {
  success: boolean
  message: string
}

// 验证账号格式结果接口
export interface ValidationResult {
  isValid: boolean
  message: string
}

interface VerificationCodeInfo {
  code: string
  sendTime: number
  attempts: number
}

export interface SendResult {
  success: boolean
  message: string
  code?: string
}

export interface VerifyResult {
  success: boolean
  message: string
}

export interface ValidationResult {
  isValid: boolean
  message: string
}

/**
 * 验证码服务类
 * 模拟真实的验证码发送和验证功能
 */

export class VerificationCodeService {
  private static verificationCodes: Map<string, VerificationCodeInfo> = new Map()
  private static readonly VALID_DURATION: number = 5 * 60 * 1000 // 5分钟
  private static readonly CODE_LENGTH: number = 6
  static sendVerificationCode(account: string): Promise<SendResult> {
    return new Promise((resolve) => {
      setTimeout(() => {
        try {
          const validationResult = VerificationCodeService.validateAccountFormat(account)
          if (!validationResult.isValid) {
            resolve({
              success: false,
              message: validationResult.message
            })
            return
          }
          const existingCode = VerificationCodeService.verificationCodes.get(account)
          if (existingCode && Date.now() - existingCode.sendTime < 60 * 1000) {
            resolve({
              success: false,
              message: '发送过于频繁，请1分钟后再试'
            })
            return
          }
          const code = VerificationCodeService.generateVerificationCode()
          const sendTime = Date.now()

          VerificationCodeService.verificationCodes.set(account, {
            code: code,
            sendTime: sendTime,
            attempts: 0
          })

          console.info(`模拟发送验证码到 ${account}: ${code}`)
          resolve({
            success: true,
            message: '验证码发送成功',
            code: code
          })

        } catch (error) {
          resolve({
            success: false,
            message: '发送失败，请稍后重试'
          })
        }
      }, 1000)
    })
  }

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
          if (Date.now() - codeInfo.sendTime > VerificationCodeService.VALID_DURATION) {
            VerificationCodeService.verificationCodes.delete(account)
            resolve({
              success: false,
              message: '验证码已过期，请重新获取'
            })
            return
          }

          if (codeInfo.attempts >= 5) {
            VerificationCodeService.verificationCodes.delete(account)
            resolve({
              success: false,
              message: '验证码尝试次数过多，请重新获取'
            })
            return
          }

          codeInfo.attempts++

          if (codeInfo.code === code) {
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
      }, 500)
    })
  }

  private static generateVerificationCode(): string {
    let code = ''
    for (let i = 0; i < VerificationCodeService.CODE_LENGTH; i++) {
      code += Math.floor(Math.random() * 10).toString()
    }
    return code
  }

  static validateAccountFormat(account: string): ValidationResult {
    const phoneRegex = /^1[3-9]\d{9}$/
    if (phoneRegex.test(account)) {
      return {
        isValid: true,
        message: '手机号格式正确'
      }
    }

    if (account.includes('@')) {
      const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
      if (!emailRegex.test(account)) {
        return {
          isValid: false,
          message: '邮箱格式不正确，请检查@符号和域名格式'
        }
      }

      const parts = account.split('@')
      const localPart = parts[0]
      const domainPart = parts[1]

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

      if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
        return {
          isValid: false,
          message: '邮箱域名不能以点开头或结尾'
        }
      }

      if (domainPart.includes('..')) {
        return {
          isValid: false,
          message: '邮箱域名不能包含连续的点'
        }
      }

      const topLevelDomain = domainPart.split('.').pop()
      if (!topLevelDomain || topLevelDomain.length < 2) {
        return {
          isValid: false,
          message: '邮箱顶级域名至少需要2个字符（如.com、.cn）'
        }
      }

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

    return {
      isValid: false,
      message: '请输入有效的手机号（11位数字）或邮箱地址'
    }
  }

  private static isValidAccount(account: string): boolean {
    return VerificationCodeService.validateAccountFormat(account).isValid
  }

  static getRemainingTime(account: string): number {
    const codeInfo = VerificationCodeService.verificationCodes.get(account)
    if (!codeInfo) {
      return 0
    }

    const remaining = VerificationCodeService.VALID_DURATION - (Date.now() - codeInfo.sendTime)
    return Math.max(0, Math.ceil(remaining / 1000))
  }

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


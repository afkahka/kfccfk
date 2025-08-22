export class Images {
  id: number
  image: Resource | string

  constructor(id: number, image: Resource | string) {
    this.id = id
    this.image = image
  }
}

export class MenberIcon {
  id: number
  image: Resource | string
  title: string
  text: string

  constructor(id: number, image: Resource | string, title: string, text: string) {
    this.id = id
    this.image = image
    this.title = title
    this.text = text
  }
}

export class MainPageViewModel {
  private bannerImage: Images[] = [
    new Images(1, $r('app.media.banner_1')),
    new Images(2, $r('app.media.banner_2')),
    new Images(3, $r('app.media.banner_3'))
  ]
  private menberIcon: MenberIcon[] = [
    new MenberIcon(1, $r('app.media.ic_store'), '充值赠券', '35元首充福利'),
    new MenberIcon(2, $r('app.media.ic_gift'), '进群有礼', '周四抽免单'),
    new MenberIcon(3, $r('app.media.ic_store'), '雪王魔法铺', '0元兑周边'),
    new MenberIcon(4, $r('app.media.ic_cc'), '礼品卡', '送TA心意'),
  ]

  getBannerImage() {
    return this.bannerImage
  }

  getMenberIcon() {
    return this.menberIcon
  }
}

export default new MainPageViewModel()
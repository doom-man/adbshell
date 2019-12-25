CfgType = {
    -- 建筑列表 以国家分类
    BUILDING_COUNTRY_LIST = - 3,
    -- 城镇中心建筑列表 以国家为key
    BUILDING_CENTER_DEF = - 2,
    -- 商店列表分类 以商店类型为key
    BUILDING_SHOP_TYPE = - 1,
    -- 道具
    ETC = 3,
    -- 装备
    EQUIP = 4,

    --领主等级
    LEVEL = 6,

    --vip等级
    VIP = 7,
    -- 国家
    COUNTRY = 11,
    -- 建筑
    BUILDING = 12,
    -- 建筑商城
    BUILDING_SHOP = 13,

    -- 城市随机资源
    CITY_RAND_RESOURCE = 14,
    -- 科技配置表
    TECH_UPDATE = 15,
    --联盟科技表
    TECH_FAMILY = 22,

    -- 士兵配置表
    CFG_SOLDIER = 16,

    --士兵技能
    CFG_SOLDIER_SKILL = 17,

    --地图事件
    MAP_EVENT_DATA = 18,

    --地图随机事件
    MAP_RAND_EVENT_DATA = 19,

    -- 任务配置信息
    TASK_LIST = 21,

    --活动列表
    ACTIVITY_LIST = 24,

    -- 考古出征距离
    BOOK_SPEED = 25,

    -- 图鉴册
    BOOKMENU = 30,

    -- 图鉴
    BOOK = 31,

    --要塞数据
    FORTDATA = 32,

    --要塞守军
    FORT_NPCDATA = 33,

    BUILDING_INFO_CFG = 100,

    CFG_BUILDING_INFO_TITLE = 101,

    --常量表
    CFG_CONST  = 102,

    --领主信息
    LORD_INFO  = 103,

     --建筑物的分配工人提示
    BUILDING_TIPS = 104,

    -- 事件详情
    NOTICE_INFO = 105,

    -- 系统公告
    SYS_NOTICE = 106,

    --联盟日志
    UNION_LOG = 107,

    --VIP表
    VIP_INFO = 108,

    --VIP等级表
    VIP_LEVEL = 109,

    --VIP升级经验
    VIP_DF = 110,
    VIP_SHOP = 111,
    --据点配置
    BASTION_DATA = 112,
    --限时活动
    LIMIT_ACTIVITY = 113,
    --世界BOSS配置
    BOSS_DATA = 114,
    --每日狂欢配置
    DAILY_HAPPY_ACTIVITY=115,
    --新手引导文本
    GUIDE_TEXT = 120,



    --按钮开启IDs
    BUTTONSTATUS = 208,

    -- 名将
    HERO = 209,

    -- 名将图鉴总表
    HERO_BOOK = 210,

    -- 名将图鉴表
    HERO_BOOK_TYPE = 211,

    -- 名将技能
    HERO_SKILL = 212,

    -- 图鉴材料兑换表
    HERO_MATERIAL = 213,

    -- 招募配置表
    MIRACLE_RECTUIT_DEF = 214,

    -- 王座策略表
    THRONE_STRATEGY = 215,

    --王座配置
    THRONE_DEF = 216,

    -- 王国官职
    KINGDOM_OFFICER = 217,

    -- 王国政策
    KINGDOM_POLICY = 218,

    -- 官职buff
    KINGDOM_BUFF = 219,

    -- 捐赠配置

    KINGDOM_DONATE = 220,
    --跨服战要塞数据
    NETBATTLE_FORTDATA = 221,

    --跨服战活动数据
    CROSS_ACTIVEITY_DEF = 222,

    -- 端午节配置
    DRAGON_BOAT = 223,
    -- rune.json
    RUNE_DATA = 224,
    RUNE_PROPERTY = 225,
    RUNE_STRENGTH = 226,
    RUNE_MAP = 227,
    RUNE_INTRODUCE = 228,
    -- rune_property
    -- rune_streng_then.json

    -- 许愿池配置
    WISH_LUCK = 229,

    -- 战舰
    SHIP_DATA = 230,

    -- 战舰技能
    SHIP_SKILL = 231,

    -- 战舰buff
    SHIP_SKILL_BUFF = 232,

    -- 战舰科技
    SHIP_TECH = 233,

    --成就系统
    ACHIEVEMENT = 234,

    -- 航海
    SHIP_EXPEDITION = 235,
    -- 道具获取途径表
    ITEM_FROM = 236,
    --稱號表
    ROLE_TITLE = 237,
    --bUFF
    CITY_BUFF = 238,
    --城市皮肤
    CITY_SKIN = 239,
    --联盟基础表
    FAMILY_BASE = 240,
    --符文特性表
    RUNE_FEATURE = 241,
    --英雄试炼
    HEROLEVEL_BASE = 242,
    --守军科技
    ARMYTECH = 243,
    --荣誉
    HORNOR_TECH = 244,
    HORNOR_LEVEL = 245,
    --圣物科技
    RUNE_TECH = 246,
    --皮肤强化
    SKIN_STRENGTHEN = 247,
    --联盟政策
    FAMILY_POLICY = 248,
    --
    BOOK_TECH = 249,
    BOOK_TECH_MENU = 250,
    --限时兑换
    LIMIT_EXCHANGE = 251,

    --挖矿资源表
    ORE_RES = 252,

    --挖矿组
    ORE_GROUP = 253,

    --圣物技能
    RUNE_SKILL = 254,

    --圣物技能觉醒需求
    RUNE_AWAKEN_NEED = 255,
    --功能解锁提示
    UNLOCK_FUNC_PROMPT = 256,
    SHIP_REFIX_SKILL = 257,
    --战舰改装订单
    SHIP_REFIT_SKILL_ORDER = 258,
     -- 头像
     ROLE_HEAD = 259,
     -- BUFF名字
     BUFF_NAME = 260,
     -- 形象
     ROLE_IMAGE = 261,

    --跨服据点配置
    CROSS_STRONG_HOLD = 266,
    --章节
    CAPHTER_TITLE = 267,
    CAPHTER_TASK = 268,
    -- 领地扩张
    LAND_EXPAND = 269,
}
-- 路径表
cfg_path = nil
-- 建筑信息标题表
cfg_buildingInfoTitle = nil

CfgFileList = {
    [CfgType.ACHIEVEMENT] = "av.json",
    [CfgType.BUILDING] = "building.json",
    [CfgType.BUILDING_SHOP] = "building_shop.json",
    [CfgType.COUNTRY] = "country.json",
    [CfgType.CITY_RAND_RESOURCE] = "city_rand_resource.json",
    [CfgType.TECH_UPDATE] = "tech.json",
    [CfgType.TECH_FAMILY] = "family_tech.json",
    [CfgType.CFG_SOLDIER] = "soldier.json",
    [CfgType.CFG_SOLDIER_SKILL] = "soldier_skill.json",
    [CfgType.CFG_CONST] = "const.json",
    [CfgType.ETC] = "etc.json",
    [CfgType.LEVEL] = "level.json",
    [CfgType.MAP_EVENT_DATA] = "world_point_data.json",
    [CfgType.MAP_RAND_EVENT_DATA] = "point_event.json",
    [CfgType.TASK_LIST] = "task.json",
    [CfgType.BOOKMENU] = "book_menu.json",
    [CfgType.BOOK] = "book.json",
    [CfgType.FORTDATA] = "fortress_data.json",
    [CfgType.FORT_NPCDATA] = "fortress_data_npc.json",
    [CfgType.ACTIVITY_LIST] = "activity.json",
    [CfgType.BOOK_SPEED] = "book_speed.json",
    [CfgType.BUTTONSTATUS] = "button_status.json",
    [CfgType.VIP_INFO] = "vip_info.json",
    [CfgType.VIP_DF] = "vip.json",
    [CfgType.GUIDE_TEXT] = "guideText.json",
    [CfgType.BASTION_DATA] = "strong_hold.json",
    [CfgType.LIMIT_ACTIVITY] = "limit_activity.json",
    [CfgType.DAILY_HAPPY_ACTIVITY] = "daily_happy_activity.json",
    [CfgType.BOSS_DATA] = "boss_data.json",
    [CfgType.HERO] = "hero.json",
    [CfgType.HERO_BOOK] = "hero_book.json",
    [CfgType.HERO_BOOK_TYPE] = "hero_book_type.json",
    [CfgType.HERO_SKILL] = "skill_data.json",
    [CfgType.HERO_MATERIAL] = "soure_change.json",
    [CfgType.MIRACLE_RECTUIT_DEF] = "miracle_recruit_def.json",
    [CfgType.THRONE_STRATEGY] = "strategy.json",
    [CfgType.KINGDOM_OFFICER] = "throne_official.json",
    [CfgType.KINGDOM_POLICY] = "throne_policy.json",
    [CfgType.KINGDOM_BUFF] = "throne_buff.json",
    [CfgType.KINGDOM_DONATE] = "throne_donate.json",
    [CfgType.THRONE_DEF] = "throne_def.json",
    [CfgType.NETBATTLE_FORTDATA] = "cross_fortress_data.json",
    [CfgType.CROSS_ACTIVEITY_DEF] = "cross_activity_def.json",
    [CfgType.DRAGON_BOAT] = "dwj.json",
    [CfgType.RUNE_DATA] = "rune.json",
    [CfgType.RUNE_PROPERTY] = "rune_property.json",
    [CfgType.RUNE_STRENGTH] = "rune_streng_then.json",
    [CfgType.RUNE_MAP] = "synthetic.json",
    [CfgType.RUNE_INTRODUCE] = "runeIntroduceCfg.json",
    [CfgType.WISH_LUCK] = "wish_luck_draw.json",
    [CfgType.SHIP_DATA] = "ship.json",
    [CfgType.SHIP_SKILL] = "ship_skill.json",
    [CfgType.SHIP_SKILL_BUFF] = "ship_skill_buff.json",
    [CfgType.SHIP_TECH] = "ship_tech.json",
    [CfgType.SHIP_EXPEDITION] = "expedition.json",
    [CfgType.ROLE_TITLE] = "title_def.json",
    [CfgType.ITEM_FROM] = "df_gaintype.json",
    [CfgType.CITY_BUFF] = "buff.json",
    [CfgType.CITY_SKIN] = "adornment.json",
    [CfgType.FAMILY_BASE] = "family.json",
    [CfgType.RUNE_FEATURE] = "rune_feature.json",
    [CfgType.HEROLEVEL_BASE] = "upgrade.json",
    [CfgType.ARMYTECH] = "guard_army_tech.json",
    [CfgType.RUNE_TECH] = "rune_title_tech.json",    
    [CfgType.HORNOR_TECH] = "honour_tech.json",
    [CfgType.HORNOR_LEVEL] = "honour_tech_lv.json",
    [CfgType.SKIN_STRENGTHEN] = "adornment_strengthen.json",
    [CfgType.FAMILY_POLICY] = "family_policy.json",
    [CfgType.BOOK_TECH] = "book_tech.json",
    [CfgType.BOOK_TECH_MENU] = "book_tech_menu.json",
    [CfgType.LIMIT_EXCHANGE] = "limited_redemption.json",
    [CfgType.ORE_RES] = "mining_resource.json",
    [CfgType.ORE_GROUP] = "mining_group.json",
    [CfgType.RUNE_SKILL] = "rune_skill.json",
    [CfgType.RUNE_AWAKEN_NEED] = "rune_need.json",
    [CfgType.UNLOCK_FUNC_PROMPT] = "new_function_unlock.json",
    [CfgType.SHIP_REFIX_SKILL] = "ship_combo_skill.json",
    [CfgType.SHIP_REFIT_SKILL_ORDER] = "ship_armour_order.json",
    [CfgType.ROLE_HEAD] = "role_head.json",
    [CfgType.BUFF_NAME] = "ship_combo_buff_enum.json",
    [CfgType.ROLE_IMAGE] = "role_image.json",
    [CfgType.CROSS_STRONG_HOLD]= "cross_strong_hold.json",
    [CfgType.CAPHTER_TITLE] = "chapter.json",  
    [CfgType.CAPHTER_TASK] = "chapter_task.json",
    [CfgType.LAND_EXPAND] = "land_occupation.json",
}
-- 配置表
cfg = {
    [CfgType.BUTTONSTATUS]  = {},
    [CfgType.BOOK_SPEED] = {},
    [CfgType.BUILDING_COUNTRY_LIST] = { },
    [CfgType.BUILDING_CENTER_DEF] = { },
    [CfgType.BUILDING_SHOP_TYPE] = { },
    [CfgType.COUNTRY] = { },
    [CfgType.BUILDING] = { },
    [CfgType.ACHIEVEMENT] = { },
    [CfgType.BUILDING_SHOP] = { },
    [CfgType.CITY_RAND_RESOURCE] = { },
    [CfgType.ETC] = { },
    [CfgType.TECH_UPDATE] = { },
    [CfgType.TECH_FAMILY] = { },
    [CfgType.CFG_SOLDIER] = { },
    [CfgType.CFG_SOLDIER_SKILL] = { },
    [CfgType.BUILDING_INFO_CFG] = { },
    [CfgType.CFG_BUILDING_INFO_TITLE] = {},
    [CfgType.CFG_CONST]  = {},
    [CfgType.LEVEL] = {},
    [CfgType.MAP_EVENT_DATA] = {},
    [CfgType.MAP_RAND_EVENT_DATA] = {},
    [CfgType.TASK_LIST] = {},
    [CfgType.BOOKMENU] ={},
    [CfgType.BOOK] ={},
    [CfgType.FORTDATA] = {},
    [CfgType.FORT_NPCDATA] = {},
    [CfgType.ACTIVITY_LIST] = {},
    [CfgType.VIP_INFO] = {},
    [CfgType.VIP_LEVEL] = {},
    [CfgType.VIP_DF] = {},
    [CfgType.BASTION_DATA] = {},
    [CfgType.GUIDE_TEXT]  = {},
    [CfgType.LIMIT_ACTIVITY] = {},
    [CfgType.BOSS_DATA] = {},
    [CfgType.DAILY_HAPPY_ACTIVITY] = {},
    [CfgType.HERO] = {},
    [CfgType.HERO_BOOK] = {},
    [CfgType.HERO_BOOK_TYPE] = {},
    [CfgType.HERO_SKILL] = {},
    [CfgType.HERO_MATERIAL] = {},
    [CfgType.MIRACLE_RECTUIT_DEF] = {},
    [CfgType.THRONE_STRATEGY] = {},
    [CfgType.KINGDOM_OFFICER] = {},
    [CfgType.KINGDOM_POLICY] = {},
    [CfgType.KINGDOM_BUFF] = {},
    [CfgType.KINGDOM_DONATE] = {},
    [CfgType.THRONE_DEF] = {},
    [CfgType.NETBATTLE_FORTDATA] = {},
    [CfgType.CROSS_ACTIVEITY_DEF] = {},
    [CfgType.DRAGON_BOAT] = {},
    [CfgType.RUNE_DATA] = {},
    [CfgType.RUNE_PROPERTY] = {},
    [CfgType.RUNE_STRENGTH] = {},
    [CfgType.RUNE_MAP] = {},
    [CfgType.RUNE_INTRODUCE] = {},
    [CfgType.WISH_LUCK] = {},
    [CfgType.SHIP_DATA] = {},
    [CfgType.SHIP_SKILL] = {},
    [CfgType.SHIP_SKILL_BUFF] = {},
    [CfgType.SHIP_TECH] = {},
    [CfgType.SHIP_EXPEDITION] = {},
    [CfgType.ROLE_TITLE] = {},
    [CfgType.ITEM_FROM] = {},
    [CfgType.CITY_BUFF] = {},
    [CfgType.CITY_SKIN] = {},
    [CfgType.FAMILY_BASE] = {},
    [CfgType.RUNE_FEATURE] = {},
    [CfgType.HEROLEVEL_BASE] = {},
    [CfgType.ARMYTECH] = {},
    [CfgType.RUNE_TECH] = {},
    [CfgType.HORNOR_TECH] = {},
    [CfgType.HORNOR_LEVEL] = {},
    [CfgType.SKIN_STRENGTHEN] = {},
    [CfgType.FAMILY_POLICY] = {},
    [CfgType.BOOK_TECH] = {},
    [CfgType.BOOK_TECH_MENU] = {},
    [CfgType.LIMIT_EXCHANGE] = {},
    [CfgType.ORE_RES] = {},
    [CfgType.ORE_GROUP] = {},
    [CfgType.RUNE_SKILL] = {},
    [CfgType.RUNE_AWAKEN_NEED] = {},
    [CfgType.UNLOCK_FUNC_PROMPT] = {},
    [CfgType.SHIP_REFIX_SKILL] = {},
    [CfgType.SHIP_REFIT_SKILL_ORDER] =  {},
    [CfgType.ROLE_HEAD] = {},
    [CfgType.BUFF_NAME] = {},
    [CfgType.ROLE_IMAGE] = {},
    [CfgType.CROSS_STRONG_HOLD]={},
    [CfgType.CAPHTER_TITLE] = {},  
    [CfgType.CAPHTER_TASK] = {},
    [CfgType.LAND_EXPAND] = {},
}

server = {
    -- 服务器系统linux时间
    systime = 0,
    sysoffset = 0,
    -- 跨服服务器
    Cross_systime = 0,
    Cross_sysoffset = 0,
}

-- 玩家信息表
function initUserData()
user = {
    uid = 0,
    -- 名字
    name = "",
    -- 头像
    faceIcon = "",
    --演武次数
    drillCount = 0,
    -- 驿站坐标
    stageX = -1,

    stageY = -1,

    -- 联盟官职 是否是盟主 跨服用
    officeDegree = false,

    x=0,

    y=0,
    -- 迁城免费
    movecity = 0,
    --等级
    lv=1,
    --经验
    exp=0,
    --帮派名字
    familyName="",
    --帮派id
    familyUid=0,
    maxPower = 0,
    --单位每小时产出资源量
    foodPer = 0,
    stonePer = 0,
    woodPer = 0,

    -- 战斗力
    grade = 110,
    --元宝
    paygem = 0,

    -- 食物
    food = 1000,
    -- 木材
    wood = 220,
    -- 黄金
    gold = 440,
    -- 石头
    stone = 5530,

    -- 食物
    maxFood = 1000,
    -- 木材
    maxWood = 220,
    -- 黄金
    maxGold = 440,
    -- 石头
    maxStone = 5530,

    -- 食物产量
    foodPer = 0,
    -- 木材产量
    woodPer = 0,
    -- 石头产量
    stonePer = 0,
    --守军
    
    -- 农民总上限
    maxfarmer = 0,

    -- 当前拥有农民
    curfarmer = 0,

    -- 工作中农民
    workfarmer = 0,
    --空闲工人 = curfarmer - workfarmer
    idlefarmer = 0,
    -- 钻石
    diamond = 110,
    --大地图坐标
    curMapCrood = cc.p(100,100),
    --主城坐标
    majorCityCrood = cc.p(0,0),
    --战舰改装数据
    shipRefixData = {},
    --战舰改装仓库
    shipRefixBagData = {},
    -- VIP
    vip = 0,
    -- vipExp
    vipExp = 0,
    --今日获得VIP经验
    todayExp = 0,
    --VIP剩余时间
    vipTime = 0,
    --VIP信息上次更新时间
    vipLastUpdateTime = 0,
    -- 国家ID
    countryId = 1,
    -- 推广渠道的用户
    source = "",
    -- 背包
    pkg = { },
    -- 符文材料背包
    materBackpack = {},
    -- 战舰数据
    warshipData = {},
    --战舰改装材料
    metaRefitBackpack = {},
    --rune
    runeEquiped = {},
    --装备特性红点
    runeEquipedRedpoint = {},
    --rune
    runeEquipIndex = 0,
    -- rune backpack
    runeBackpack = {},
    -- rune material
    -- runeMaterial = {},
    --商城道具列表
    shopList = { },
    -- 建筑
    building = { },
    -- 主建筑
    centerBuild = { },

    -- 正在建或者正在升级的建筑
    buildingDateLine = { },
     -- 已经建造的建筑数量
    buildingTypeNum = { },
    -- 生产农民的数据
    produceframerdata = nil,
--    -- 已经学习的科技
--    techData = { },
--    -- 正在学习的科技
--    techingData = { },
    --士兵/陷阱
    soldierData={},
    -- 正在生产士兵/陷阱
    produceSoldierData={},
    --训练界面数据
    produceSoldierLockData = {},
    -- 内城随机资源采集点
    cityRandResource = { },

    -- 服务器下发已使用的全类型科技数据集合
    techServerDatas = { },
    -- 根据建筑类型得到的所有科技集合
    techTypeDatas = { },
    -- 服务器下发的已使用的联盟科技
    familyTechServerDatas = {},
    -- 当前联盟科技列表
    familyTechDatas = {},
    --服务器下发的已使用的军旗科技
    flagTechServerDatas = {},

    --邮件列表
    mailList={},
    --英雄试炼邮件列表
    mailHeroLevelList={},
    --遗迹挖矿邮件列表
    mailDigoreList={},
	--抵御蛮族邮件列表
    mailResistList={},
    --战舰竞技邮件列表
    mailShipPvpList = {},
    --新邮件数量
    newMail={},

    --角色属性
    propertyValue={},

    --跨服角色属性
    propertyValue_Server={},

	--创建联盟数据
	family = nil,

	--所有的联盟列表
	familyList = {},

	--联盟初始化数据
	familyInit = nil,

	--联盟成员列表
	familyMemberList = {},

	--申请联盟
	familyApply = nil,

	--联盟申请列表
	familyApplyList = {},

	--同意申请
	familyAgree = nil,

	--联盟设置加入联盟的最低等级和战力
	familySetMinData = nil,

	--玩家接收联盟邀请的列表
	familyRequestList = {},

	--联盟邀请发出邀请
	familyRequest = nil,

	--联盟邀请玩家的初始列表
	familyRequestMemberInit = {},

	--联盟申请玩家的初始列表
	familyInviteMemberInit = {},

	--踢出联盟
	familyBeKick = nil,

	--修改在联盟的职位
	familySetDegree = nil,

    -- 盟主禅让时间
    familyabdicatetime = 0,

	--退出联盟
	familyESC = nil,

	--请求联盟帮助
	familyHelp = nil,

	--联盟贡献
	familyContribution = nil,

	--请求过帮助的建筑ID列表
	bulidId = {},

	--联盟公告
	familyNotice = nil,

	--别人请求帮助列表
	familyHelpList = {},

	--自己请求的帮助列表
	familyBeHelpList = {},

    --帮助过的建筑列表
    familyHelpedBid = {},

	--单个联盟成员信息
	familyMember = nil,

    --最大带军队数量
    maxTroopsNum = 1000,

    --伤兵总数
    desableSoldiers={},

    --伤兵恢复队列
    revertingSoldiers={},

    --跨服伤兵总数
    desableSoldiers_c={},

    --跨服伤兵恢复队列
    revertingSoldiers_c={},
    --伤兵上限
    treatNumAdd = 0,


    --警示队列
    warningList = {},

    --队列数量
	warningListNum = 0,

    --任务列表
    taskList = {},

    --任务更新
    taskUpdate = {},

	--完成任务ID
	taskId = nil,

    --礼包信息
    packageData = nil,

	--考古背包
	bookPkg={},

    --考古身上的装备
    bookEquip = {},

    -- 图册开启信息
    bookAtlas = {},

    -- 图鉴册开启
    bookHand = {},

    --守军科技
    guard_tech = {},
    --守军
    guardSoldier = {},
    -- 当前图鉴册
    bookHandId = 0,

	--礼包信息
	packageInfo = nil,

	--月卡是否存在状态
	monthType = 0,

	--月卡信息
	monthInfo = nil,

	--可购买的物品信息
	recharge = {},

    --活动列表数据
    activityList = {},

    --活动详情数据
    activityDetail = nil,

    --充值相关活动数据 包括 每日充值，累计充值等
    activityPayData = {},
    --月卡
    activityMonthCardData = {},

    --活动积分抽奖数据
    activityDetail_trunplate = nil,

    --活动ID
    activityId = 0,

    --活动状态
    activityStatus = 0,

    --首充礼包信息
    firstAward = nil,

    --签到
    signAward = {},

    --充值返利
    rechargeRebate = {},

    --积分兑换
    exchange = {},

    --已开启的按钮id
    newBtnIDs = {},

    --出征携带的宠物
    dressPetId = nil,

    --家族聊天信息
    msgFamilyInfo = {},

    --喇叭广播消息
    msgTrumpetInfo = {},

    --世界聊天信息
    msgWorldInfo = {},

    --自己发出去的邮件
    sendMail = {},

    -- 自己地块数据
    plotData = {},

    -- 盟友主城主城数据
    allianceplot = {},
    -- 个人排行榜
    rankdata = {},

    -- 联盟排行榜
    rankAlliancedata = {},
    --
    rankAlliancedatashow = 1, --1：显示 0 ：不显示
    -- 战损排行
    plunderData = {},

    -- 积分排行榜
    scoreData = {},

    -- 成就排行榜
    AScoreData = {},

    --限时排行榜
    promotin_LimitList = {},

    --体力回复倒计时
    recover = {},

    -- 世界地图要塞数据
    fortWorldData = {},

    --免费改名特权
    updateName = nil,

    --联盟贡献数据
    allianceGivenData = {},
    -- Buff
     Role_Buff ={},

    -- 集火队列
    teamArmyData = {},

    --集火军队详情
    teamArmyInfoData = {},

    --内城军队详情
    teamCityArmyInfoData = {},

    -- 集火历史记录
    teamHistoryList = {},

    -- 援助记录
    defensHistoryList= {},

     -- 月卡周卡信息
    monthWeekInfos = {},

    -- 盟战提示
    allianceConvergeHint = {attack = 0,defener = 0,},

    -- 要塞试炼 名将
    fortheroData = {},
    -- 要塞试炼排名
    fortheroRankList = nil,

    -- 要塞试炼历史排名
    fortheroHistoryRankList = {},

    -- 服务器下发的可激活/已激活的图鉴列表
    worldIdentifyList = {},

    -- 主动技能列表
    heroSkillList = {},

    -- 已经使用技能的buff
    heroBuffList = {},

    -- 名将招募
    fortHeroSoldierList = {},

    -- 奇迹兵招募
    fortRecuritSoldierList = {},

    -- 名将奇迹招募
    fortRecuritSoldierData = {},

    -- 名将技能是否开启
    heroSkillStatus = false,

    --双十一活动数据
    elevenShopInfos= {},

    --双十一开始倒计时
    elevenLeftTime = nil,

    -- 推广数据
    popularizeData = {},

    -- 红包数据
    hongBao_Anim_Timer = nil,    -- 红包动画计时器

    hongBao_State = 1,           -- 红包状态

    hongBao_ID = nil, -- 红包ID


    hongBao_openState = 0, -- 切换内外城的红包状态

    hongBao_name = nil, --发红包的玩家

    hongBao_union = nil, --发红包的联盟

    throne_create = nil, -- 王座初始化

    throne_morleRank = nil, -- 王座排行

    kingdom_OfficerData = nil, -- 官职

    throne_InitData = {}, -- 王座事件

    throne_Strategy = nil, -- 王座策略

    ThroneStrAnimation = {}, -- 王座特效

    CrossSeverRank = {}, -- 本期期跨服去排行榜

    CrossScoreRank = {}, -- 跨服个人积分排行榜

    Cross_PolicyData_Military = {}, -- 军政

    Cross_Sever_Status = 0, -- 跨服状态 0不在跨服 ，1跨服

    msgCampInfo = {}, -- 阵营聊天

    msgCrossInfo = {}, --跨服聊天

    OpenCrossThroneTime = {} ,-- 开启跨服活动倒计时

    throne_plot = {}, -- 世界地图王座

    Maxlansize = 0, -- 最大地块数

    markKingPos = {}, --国王目标

    Cross_Throne_Occupy = nil, -- 沦陷王座

    Cross_Throne_End = {}, -- 跨服王座结束

    Cross_Sever_User = {}, -- 跨服保存游戏服数据
    Rune_Create_info = {},-- 查找初始化界面

    Rune_Create_info_level = 1,-- 符文初始boss等级


    Warship_Tech = {},-- 战舰科技

    AchievementData = {},--成就数据

    curSelectShipType = 1, -- 当前选中的战舰类型

    AchievementData = {},--成就数据

    UI_REDPOINT = {promotionBtn={},payBtn={},relicBtn={},serverTaskBtn={}}, --UI红点显示

    Achievenment_Redpoint={}, --成就红点显示

    taxInfo = {},--征税信息

    runeNormalSearch = {},--圣物普通搜索

    zhaohuanItemNums = 0, --大地图召唤车队所需道具数量

    herolevelCfg = nil, --英雄试炼配置解析

    guard_patrol_status = 0, --禁卫军巡逻状态

    guard_resist_status = 0, --禁卫军 抵御蛮族攻城状态

    rune_handbook_new = 0, --圣物图鉴有新增

    commendTaskId=nil, --推荐任务数据

    activity_buttons_show={}, --活动按钮主界面显示
    activity_buttons_down_show = {}, -- 活动按钮下排显示
    activity_mail_new={},  --活动是否有新邮件
    unlock_func_id=0,  --解锁功能ID
}
end
initUserData()

gameMap={
    mapCellDatas={},
    troopData = {}, --行军队列
    fortDatas = {},--要塞数据
    fortDesc = {}, --要塞加成描述
    sortFortDatas = {},
    lineSegmentDatas = {},--路段数据
    postFortData = nil,--驿站连接要塞
    bastionData = {},--据点数据
    overLordDatas={},  --领主信息
    throneDatas = {}, -- 跨服王座信息
    bossDatas = {} --世界BOSS数据
}
local function buildindLimitparser(ext)
    if ext then
        ext = string.gsub(ext, ":", "=")
        ext = "{" .. ext .. "}"
        return me.unserialize(ext)
    end
    return nil
end
-- 根据类型返回该建建筑
function cfg.getShopDef(type)
    local shopList = cfg.buildind_shop[user.countryId]
    for key, var in pairs(shopList) do
        for typeKey, typeVar in pairs(shopList) do
            if (typeVar.def.type == type) then
                return typeVar
            end
        end
    end
    return nil
end

-- 主城建筑
function cfg.initCenter(var)
    if var.type == cfg.BUILDING_TYPE_CENTER then
        local ext = var.ext
        var.extValue = buildindLimitparser(ext)
    end

end

-- 主城国家建筑
function cfg.initBuildCountryList(var)
    local ext = var.ext
    var.extValue = buildindLimitparser(ext)
    if (cfg[CfgType.BUILDING_COUNTRY_LIST][var.countryId] == nil) then
        cfg[CfgType.BUILDING_COUNTRY_LIST][var.countryId] = { }
    end
    cfg[CfgType.BUILDING_COUNTRY_LIST][var.countryId][var.level] = var
end

function cfg.initBuildingShop(var)
    if cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId] == nil then
        cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId] = { }
    end
    if cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId][var.shopType] == nil then
        cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId][var.shopType] = { }
    end
    var.def = cfg[CfgType.BUILDING][var.buildingId]

    cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId][var.shopType][var.buildingId] = var

end

function cfg.initVipInfoByLevel(var)
    if cfg[CfgType.VIP_LEVEL][var.viplevel] == nil then
       cfg[CfgType.VIP_LEVEL][var.viplevel] = {}
    end
    table.insert(cfg[CfgType.VIP_LEVEL][var.viplevel],var)
end

function getUserMaxPower()
    return user.maxPower + tonumber( user.propertyValue["EnergyAdd"] ) or 0 
end
function cfg.getSortShop(country)

    --   cfg[CfgType.BUILDING_SHOP_TYPE][var.countryId][var.shopType]

end
-- 建筑商店表
cfg.buildind_shop = { }
-- 建筑可建造数量
cfg.buildLimit = { }
-- 城镇中心
cfg.BUILDING_TYPE_CENTER = "center"
-- 房屋
cfg.BUILDING_TYPE_HOUSE = "house"
-- 城门
cfg.BUILDING_TYPE_DOOR = "door"
-- 瞭望塔
cfg.BUILDING_TYPE_TOWER = "tower"
--- 军营
cfg.BUILDING_TYPE_BARRACK = "barrack"
-- 靶场
cfg.BUILDING_TYPE_RANGE = "range"
-- 马厩
cfg.BUILDING_TYPE_HORSE = "horse"
-- 铁匠铺
cfg.BUILDING_TYPE_BLACKSMITH = "blacksmith"
-- 武器场
cfg.BUILDING_TYPE_SIEGE = "siege"
-- 修道院
cfg.BUILDING_TYPE_ABBEY = "abbey"
-- 城堡
cfg.BUILDING_TYPE_CASTLE = "castle"
-- 大学
cfg.BUILDING_TYPE_COLLEGE = "college"
-- 磨房
cfg.BUILDING_TYPE_FOOD = "food"
-- 伐木场
cfg.BUILDING_TYPE_LUMBER = "lumber"
-- 市场
cfg.BUILDING_TYPE_MARKET = "market"
-- 奇迹
cfg.BUILDING_TYPE_WONDER = "wonder"
-- 采石场
cfg.BUILDING_TYPE_STONE = "stone"
-- 码头
cfg.BUILDING_TYPE_BOAT = "boat"
-- 祭坛
cfg.BUILDING_TYPE_ALTAR = "altar"
--僧侣
cfg.BUILDING_TYPE_MONK = "monk"

cfg.BUILDING_TYPE_HALL = "hall"
function cfg.initBuildind_shop(json)
    local temp = me.parserJson(json)
    for key, var in pairs(temp) do
        if cfg.buildind_shop[me.toStr(var.countryId)] == nil then
            cfg.buildind_shop[me.toStr(var.countryId)] = { }
        end
        if cfg.buildind_shop[me.toStr(var.countryId)][me.toStr(var.shopType)] == nil then
            cfg.buildind_shop[me.toStr(var.countryId)][me.toStr(var.shopType)] = { }
        end
        var.def = cfg[CfgType.BUILDING][var.buildingId]
        -- 将def构造在配置上
        table.insert(cfg.buildind_shop[me.toStr(var.countryId)][me.toStr(var.shopType)], var)
        -- print(var.countryId.."---"..var.shopType)
    end
    me.LogTable(cfg.buildind_shop)
    -- me.LogTable(cfg.buildind_shop["1"]["3"])
end

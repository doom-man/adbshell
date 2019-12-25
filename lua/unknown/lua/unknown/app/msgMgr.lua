MSGVER = 1
-- 跨服消息
--[[
1557
1562
11
]]
MsgCode = {
    -- 心跳
    PING = 1,
    -- 心跳
    PONG = 2,
    -- 重新连接
    AUTH_RELOGIN = 1200,
    -- 登录注册相关
    AUTH_LOGIN = 257,
    -- 注册
    AUTH_ROLE_REG = 258,
    -- 验证登录
    AUTH_SIGN_LOGIN = 259,
    -- 重连
    AUTH_SIGN_RELOGIN = 266,
    -- 验证成功进入游戏
    AUTH_ENTRY_GAME = 260,
    -- 选择国家
    AUTH_SELECT_COUNTRY = 265,
    --  --注册成功 266
    -- AUTH_ROLE_REG_SUCESS=266,
    -- 获得聊天记录
    GET_CHAT_RECORD = 1580,

    -- 错误提示
    ERROR_ALERT = 3585,
    -- 据点改名
    BASTION_CHANGE_NAME = 1593,
    -- 获取据点改名价格
    BASTION_GET_PRICE = 1594,
    -- 角色信息
    ROLE_INFO = 3586,
    -- VIP直接升级
    VIP_LEVEL_UP = 3702,
    --是否显示VIP
    SHOW_VIP_MSG = 3718,

    CROSS_RANK = 3077,

    UPDATE_ROLE_TITLE = 3699,
    -- 更新出生点坐标
    ROLE_ORIGIN_UPDATE = 3665,
    -- 快速充
    MSG_SHIP_BL = 2578,
    -- 重新获取正在建筑中的数据
    ROLE_DATELINE_DATA = 3587,
    -- 通知消息
    ROLE_NOTICE = 3588,
    -- 名将技能使用广播
    HERO_SKILL_NOTICE = 3689,
    -- 钻石更新
    ROLE_GEM_UPDATE = 3589,
    ROLE_PAYGEM_UPDATE = 3602,
    -- VIP信息更新
    ROLE_VIP_UPDATE = 3592,
    -- 食物更新
    ROLE_FOOD_UPDATE = 3593,
    -- 木材币更新
    ROLE_WOOD_UPDATE = 3594,
    -- 石头更新
    ROLE_STONE_UPDATE = 3595,
    -- 黄金更新
    ROLE_GOLD_UPDATE = 3596,
    -- 资源更新
    ROLE_RESOURCE_UPDATE = 3597,
    -- 属性更新
    ROLE_PROPERTY_UPDATE = 3598,
    -- 跨服属性更新
    ROLE_PROPERTY_UPDATE_SERVER = 3106,
    -- 跨服国王标记
    MAP_MARK_KING = 3107,
    -- 背包物品使用
    ROLE_BACKPACK_USE = 3604,
    -- 背包物品
    ROLE_BACKPACK_ITEM = 3609,
    -- 增加背包物品
    ROLE_BACKPACK_ITEM_ADD = 3610,
    -- 背包数量移除
    ROLE_BACKPACK_ITEM_REMOVE = 3611,
    -- 背包数量改变
    ROLE_BACKPACK_ITEM_CHANGE = 3612,

    -- 一健使用资源
    ROLE_BACKPACK_QUICK_ITEM_USE = 3613,

    -- 背包道具分解
    ROLE_BACKPACK_ITEM_BREAK = 3706,

    -- 答题活动
    ACTIVITY_QUESTION = 3873,

    -- 活动挖矿 报名
    ACTIVITY_DIGORE_JOIN = 10502,

    -- 活动挖矿 进入挖矿界面
    ACTIVITY_DIGORE_SHOW = 10503,

    -- 活动挖矿 挖矿详情界面
    ACTIVITY_DIGORE_DETAIL = 10506,

    -- 活动挖矿 挖矿入驻出征
    ACTIVITY_DIGORE_EXPED = 10505,

    -- 活动挖矿 挖矿军队列表
    ACTIVITY_DIGORE_ARMY_LIST = 10511,

    -- 活动挖矿 挖矿军队更新
    ACTIVITY_DIGORE_ARMY_UPDATE = 10512,

    -- 活动挖矿 挖矿军队召回
    ACTIVITY_DIGORE_ARMY_CALLBACK = 10510,

    -- 活动挖矿 挖矿军队立即召回
    ACTIVITY_DIGORE_ARMY_CALLBACK_QUICK = 10516,

    -- 活动挖矿 转让队长
    ACTIVITY_DIGORE_TURNOVER_CAPTAIN = 10507,

    -- 活动挖矿 积分排行
    ACTIVITY_DIGORE_RANK = 10515,

    -- 活动新邮件
    ACTIVITY_MAIL_NEW = 3639,
    MSG_STATISTICS = 3709,
    -- 跨服消息
    -- 请求跨服连接数据（游戏服）
    ACTIVITY_CROSS_APPLY_AUTH = 3122,
    -- 跨服连接验证（跨服）
    MSG_CROSS_PLAYER_AUTH = 3081,
    -- 跨服服务器初始化完成（游戏服）
    MSG_CROSS_PLAYER_INIT_RE = 3075,
    -- 跨服玩家进入（跨服）
    MSG_CROSS_PLAYER_ENTRY = 3082,
    -- 遣散士兵
    MSG_CITY_SOLIDER_DEL = 564,
    -- 新邮件数量
    ROLE_MAIL_NEW = 3614,
    -- 邮件信息
    ROLE_MAIL_INFO = 3615,
    -- 邮件增加
    ROLE_MAIL_ADD = 3616,
    -- 获取邮件
    ROLE_MAIL_GET = 3617,
    -- 删除邮件
    ROLE_MAIL_DELETE = 3623,
    -- 邮件道具获取
    ROLE_MAIL_GET_ITEM = 3618,
    -- 邮件批量道具获取
    ROLE_MAIL_ALL_GET_ITEM = 3690,

    -- 获取战报
    ROLE_MAIL_BATTTLE_REPORT = 3631,

    -- 获取侦查
    ROLE_MAIL_SPY_REPORT = 3632,
    -- 充值检测
    RECHARGE_CHECK = 3703,
    -- 充值取消
    RECHARGE_CANCEL = 3704,
    -- 被攻击提示
    ROLE_BE_ATTACK_ALERT = 3634,

    -- 被攻击提示移除
    ROLE_BE_ATTACK_ALERT_REMOVE = 3635,
    -- 刷新限時活動
    ROLE_REFRESH_LIMIT_PACKAGE = 3698,
    -- 是否隐藏图腾
    MSG_SHOW_TOTEM = 10205,
    -- 考古物品
    ROLE_BOOK_ITEM = 3640,
    -- 增加考古物品
    ROLE_BOOK_ITEM_ADD = 3641,
    -- 考古数量移除
    ROLE_BOOK_ITEM_REMOVE = 3642,
    -- 考古数量改变
    ROLE_BOOK_ITEM_CHANGE = 3643,

    MSG_CITY_FIRE = 3711,
    -- 功能解锁
    MSG_UNLOCK_FUNC = 3712,
    -- 更换头像
    CHANGE_HEAD = 3713,
    -- 更换形象
    CHANGE_LORD_IMAGE = 3714,
    -- 头像列表
    GET_HEAD_LIST = 3715,
    -- 形象列表
    GET_LORD_IMAGE_LIST = 3716,

    -- 文字弹出提示
    GLOBAL_TIPS_POPITEM = 3674,
    -- 使用城市状态道具
    USE_CITY_BUFF_ITEM = 3700,
    MSG_SOLDIER_ADDS = 567,
    -- 充值结果
    RECHAGE_RESULT = 3701,

    -- 内城信息
    -- //初始化建筑
    CITY_BUILDING_INIT = 513,
    -- //建筑建造队列
    CITY_BUILDING_DATE_LINE = 514,
    -- //建筑建造
    CITY_BUILDING_STRUCT = 515,
    -- //建筑建造完成
    CITY_BUILDING_STRUCT_FINISH = 516,
    -- //建筑升级
    CITY_BUILDING_UPLEVEL = 517,
    -- //建筑升级完成
    CITY_BUILDING_UPLEVEL_FINISH = 518,
    -- //农民效率分配
    CITY_BUILDING_FARMERCHANGE = 519,
    -- //资源收集
    CITY_GET_RESOURCE = 520,

    -- //取消建设
    CITY_BUILDING_CANCEL = 521,

    -- //城市基本信息刷新
    CITY_UPDATE = 522,

    -- //采集资源点刷新
    CITY_RAND_RESOURCE_UPDATE = 523,

    -- //采集资源点
    CITY_RAND_RESOURCE = 524,

    -- //收获采集资源点
    CITY_RAND_RESOURCE_GET = 525,

    -- // 资源点信息
    CITY_RESOURCE_INFO = 526,

    -- //初始化农民
    CITY_P_FARMER_INIT = 532,
    -- //生产农民
    CITY_P_FARMER = 533,

    -- //生产完成农民
    CITY_P_FARMER_FINISH = 534,

    -- 初始化科技界面数据
    CITY_TECH_VIEW = 536,
    -- 初始化科技
    CITY_TECH_INIT = 537,
    -- 科技升级
    CITY_TECH_UPLEVEL = 538,
    -- 科技升级完成
    CITY_TECH_FINISH = 539,

    -- 士兵生更新
    CITY_SOLDIER_UPDATE = 540,

    -- 初始化士兵生产界面数据
    CITY_P_SOLDIER_VIEW = 541,
    -- 初始化士兵生产
    CITY_P_SOLDIER_INIT = 542,
    -- 生产士兵
    CITY_P_SOLDIER = 543,
    -- 生产完成士兵
    CITY_P_SOLDIER_FINISH = 544,

    -- 快速完成钻石
    CITY_QUICK_GEM = 545,
    -- 支付类型
    PAYMODE = 369,
    -- 5分钟免费
    CITY_QUICK_FREE = 557,

    -- 快速完成道具
    CITY_QUICK_ITEM = 546,

    MSG_SHENJIANG_DUIHUAN = 3708,
    MSG_GUARD_TECH_INIT = 10301,
    -- 禁卫军科技初始化
    MSG_GUARD_TECH_UP_LEVLE = 10302,
    -- 禁卫军科技升级
    MSG_GUARD_ARMY_INIT = 10303,
    -- 禁卫军初始化
    MSG_GUARD_ARMY_DP = 10304,
    -- 禁卫军配置士兵
    MSG_GUARD_PATROL_INIT = 10307,
    -- 禁卫军巡逻初始化
    MSG_GUARD_PATROL_START = 10305,
    -- 禁卫军巡逻开始
    MSG_GUARD_PATROL_STOP = 10308,
    -- 禁卫军巡逻停止
    MSG_GUARD_PATROL_GET = 10306,
    -- 禁卫军巡逻奖励领取
    MSG_GUARD_STATUS_CHANGE = 10309,
    -- 禁卫军状态更新
    MSG_GUARD_AUTOFILL_RECORD = 10310,
    -- 禁卫军自动补兵记录


    -- 禁卫军 抵御蛮族攻城状态
    MSG_GUARD_RESIST_STATUS = 10311,


    -- 伤兵恢复初始化
    CITY_P_REVERT_SOLDIER_VIEW = 547,

    -- 死兵恢复初始化
    CITY_P_RELIVE_SOLDIER_VIEW = 562,

    -- 伤兵恢复
    CITY_P_REVERT_SOLDIER = 548,

    -- 死兵恢复
    CITY_P_RELIVE_SOLDIER = 563,

    -- 伤兵恢复生产线
    CITY_P_REVERT_SOLDIER_LINE = 549,

    -- 伤兵恢复完成
    CITY_P_REVERT_SOLDIER_FINISH = 550,

    -- 称号列表
    MSG_TITLE_LIST = 10101,
    -- 军队信息
    CITY_ARMY_INFO = 551,

    -- 征税信息
    CITY_TAX_INFO = 554,
    -- 征税
    CITY_TAX_GET = 555,
    -- 征收积分详情
    CITY_TAX_DETAIL = 559,
    -- 初始化升级士兵
    CITY_UP_SOLDIER_INIT = 560,
    -- 升级士兵
    CITY_UP_SOLDIER = 561,

    -- 初始化
    BOOK_INIT = 1409,

    -- 合成
    BOOK_COMPOUND = 1410,
    --晋升
    BOOK_COMPOUND_LEVEL = 1417,
    -- 装备
    BOOK_EQUIP = 1411,

    -- 卸下
    BOOK_UN_EQUIP = 1412,


    -- 图鉴册增加
    BOOK_MENU_ADD = 1413,

    -- 图鉴增加
    BOOK_ADD = 1414,

    -- 集火组队创建 联盟广播
    WORLD_TEAM_CREATE = 1597,

    -- 集火组队信息
    WORLD_TEAM_INFO = 1598,

    -- 加入集火军队
    WORLD_TEAM_ADD = 1599,

    -- 集火军队详情
    WORLD_TEAM_DETAIL = 1600,

    -- 组队遣返军队
    WORLD_TEAM_REJECT_ARMY = 1601,

    -- 解散军队
    WORLD_TEAM_RELEASE = 1602,

    -- 内城防御部队
    WORLD_TEAM_CITY_ARMY = 1603,

    -- 集火到达
    WORLD_TEAM_ARMY_WAIT = 1604,

    -- 集火防御到达
    WORLD_TEAM_CITY_ARMY_WAIT = 1605,

    -- 集火历史记录
    WORLD_TEAM_HISTORY = 1872,

    -- 高级行军召回 队长
    WORLD_TEAM_CALL_BACK = 1606,

    -- 军队详细信息 集火防御
    WORLD_ARMY_DETAIL = 1607,

    -- 立即返回
    WORLD_ARMY_CALL_BACK = 1616,

    -- 援兵上限
    WORLD_CITY_TEAM_VIEW = 1617,

    -- 联盟集火提示
    ALLIANCE_CONVERGE_HINT = 1618,

    -- 移除集火提示
    ALLIANCE_CONVERGE_RENIVE_HINT = 1619,

    -- 联盟政策发布
    ALLIANCE_POLICY_PUBLISH = 1874,

    -- 联盟政策列表
    ALLIANCE_POLICY_LIST = 1875,

    -- 联盟科技研究加速
    ALLIANCE_TECH_SPEED_UP = 1876,

    -- 联盟科技加速剩余次数
    ALLIANCE_TECH_SPEED_UP_TIMES_LEFT = 1877,
    -- 开启要塞试炼
    WORLD_FORT_HERO_OPEN = 1620,

    -- 要塞试炼详情
    WORLD_FORT_HERO_GENERAL = 1621,

    -- 要塞试炼历史排名
    WORLD_FORT_HERO_HOSTORY_GENERAL = 1622,

    -- 要塞试炼排名
    WORLD_FORT_HERO_RANK = 1623,

    -- 清除要塞冷却时间
    WORLD_FORT_CLEAR_TIME = 1625,

    -- 王座策略指令
    WORLD_THRONE_STRATEGY = 1627,

    -- 王座策略指令发动
    WORLD_THRONE_STRATEGY_START = 1628,

    -- 王座buffer
    WORLD_THRONE_BUFFER = 1629,

    -- 王座初始化
    WORLD_THRONE_CREATE = 1636,

    -- 王座事件
    WORLD_THRONE_INIT = 1637,

    -- 王座民心排行榜
    WORLD_THRONE_MORALE = 1638,

    -- 王座策略准备
    WORLD_THRONE_STARTEGY_READY = 1640,

    -- 援兵记录
    ROLE_DEFENS_HISTORY = 3675,

    -- 世界聊天
    WORLD_CHAT_INFO = 1548,

    -- 家族聊天
    FAMLIY_CHAT_INFO = 1546,

    -- 地图查看
    WORLD_MAP_VIEW = 1556,

    -- 地图布署军队
    WORLD_ARMY_DP = 1557,

    -- 地图块更新
    WORLD_POINT = 1558,

    -- 地图战斗
    WORLD_BATTLE_INFO = 1559,

    WORLD_FIRST_BATTLE = 3710,
    -- 地图侦察
    WORLD_MAP_SPY = 1560,

    -- 地图建立贸易站
    WORLD_MAP_DP_TRADINGPOST = 1561,

    -- 地图获取进攻路径
    WORLD_MAP_PATH = 1562,

    -- 地图进攻路径路线移除
    WORLD_MAP_ARMY_REMOVE = 1563,

    -- 地图进攻路径路线移除
    WORLD_MAP_ARMY_REMOVE_TABLE = 1641,

    -- 军队详情
    WORLD_ARMY_INFO = 1645,

    -- 召回军队
    WORLD_MAP_ARMY_CALL_BACK = 1564,


    -- 放弃土地
    WORLD_MAP_DROP_POINT = 1565,


    -- 取消放弃土地
    WORLD_MAP_DROP_POINT_CANCEL = 1566,

    -- 移动城市
    WORLD_MAP_MOVE_CITY = 1567,

    -- 地块状态移除
    MSG_WORLD_REMOVE = 1568,

    -- 征服世界个人初始化
    WORLD_FORTRESS_INIT = 1576,

    -- 征服世界帮会初始化
    WORLD_FORTRESS_FAMILY_INIT = 1577,

    -- 个人征服世界数据更新
    WORLD_FORTRESS_UPDATE = 1578,

    -- 征服世界帮会更新
    WORLD_FORTRESS_FAMILY_UPDATE = 1579,

    -- 建造据点
    WORLD_STRONG_HOLD_STRUCT = 1586,
    -- 升级据点
    WORLD_STRONG_HOLD_UPlEVEL = 1587,

    -- 据点列表
    WORLD_STRONG_HOLD_LIST = 1588,

    -- 据点刷新
    WORLD_STRONG_HOLD_UPDATE = 1589,

    -- 据点移除
    WORLD_STRONG_HOLD_REMOVE = 1590,

    -- 加速升级
    WORLD_STRONG_HOLD_SPEEDUP = 1591,

    -- 取消升级
    WORLD_STRONG_HOLD_CANCELUP = 1592,

    -- 商店初始化
    SHOP_INIT = 3921,

    -- 双十一商店初始化
    ELEVEN_SHOP = 3852,

    -- 双十一商店倒计时
    ELEVEN_SHOP_CD = 3853,
    -- 活动按纽主界面显示
    ACTIVITY_BUTTON_SHOW = 3876,
    -- 兑换活动
    EXCHANGE_ACTIVITY = 3854,
    -- 迁城
    MOVE_CITY_INFO = 1655,
    -- 商店购买
    SHOP_BUY = 3922,
    -- 购买次数（数量)
    SHOP_BUY_AMOUNT = 3924,

    -- 没有联盟信息，提示
    FAMILY_NOT_INFOR_HINT = 1837,

    -- 加入家族，更新角色的联盟信息
    FAMILY_UPDATA_INFO = 3655,
    -- VIP 礼包购买
    VIP_DAY_BUY = 3697,
    -- 家族创建
    FAMILY_CREATE = 1794,

    -- 创建失败消息
    FAMILY_CREATE_ERROR = 1823,

    -- 所有家族的列表
    FAMILY_LIST = 1793,

    -- 家族信息初始化界面
    FAMILY_INIT = 1796,

    -- 家族成员列表
    MSG_FAMILY_INIT_MEMBER_LIST = 1811,

    -- 更新家族成员列表
    MSG_FAMILY_UPDATA_MEMBER_LIST = 1799,

    -- 申请加入家族
    FAMILY_APPLY = 1795,
    FAMILY_APPLY_NAME = 1801,

    -- 申请加入家族的列表
    FAMILY_APPLY_LIST = 1797,

    -- 玩家同意申请
    FAMILY_AGREE = 1800,

    -- 被同意申请
    FAMILY_BE_AGREE = 1813,

    -- 同意或拒绝申请
    FAMILY_APPLY_INVITE = 1840,

    -- 设置公开招募状态
    FAMILY_RECRUIT_OPEN = 1841,

    -- 联盟申请列表
    FAMILY_INVITE_LIST = 1842,

    -- 按名字直接邀请
    FAMILY_INVITE_NAME = 1843,

    -- 一键邀请所有玩家
    FAMILY_INVITE_ALL = 1844,

    -- 获取联盟要塞列表
    FAMILY_FORT_LIST = 1845,

    -- 玩家收到家族邀请的列表
    FAMILY_REQUEST_LIST = 1805,

    -- 家族发出邀请
    FAMILY_REQUEST = 1810,

    -- 家族邀请成员的初始界面
    FAMILY_REQUEST_INIT = 1809,

    -- 踢出联盟
    FAMILY_KICK = 1799,

    -- 被踢出联盟
    FAMILY_BE_KICK = 1814,

    -- 设置联盟职位
    FAMILY_SET_DEGREE = 1806,

    -- 取消禅让
    FAMILY_SET_CANCELL = 1870,

    -- 被设置联盟职位
    FAMILY_BE_DEGREE = 1815,

    -- 请求联盟帮助
    FAMILY_HELP = 1807,

    -- 初始化城镇的帮助按钮
    FAMILY_HELP_CREATE = 1839,
    -- 联盟请求帮助列表
    FAMILY_HELP_LIST = 1808,

    -- 联盟被帮助提示
    FAMILY_HELP_HINT = 1816,

    -- 联盟单个成员信息
    FAMILY_MEMBER = 1812,

    -- 联盟设置
    FAMILY_SET_RESTRI = 1832,

    -- 申请失败
    FAMILY_APPLY_ERROR = 1827,

    -- 修改公告
    FAMILY_NOTICE_EDIT = 1798,

    -- 退出联盟
    FAMILY_MEMBER_ESC = 1833,

    -- 一键帮助
    FAMILY_HELP_ALL = 1835,

    -- 请求过帮助的建筑ID
    BULID_ID_LIST = 1828,

    -- 刷新联盟贡献
    FAMILY_MEMBER_UPDATE = 1831,

    -- 成员给予联盟帮助
    FAMILY_SET_HELP = 1834,

    -- 移除请求过帮助的ID
    BULID_HELP_REMOVE = 1830,

    -- 联盟科技
    FAMILY_TECH = 1862,
    -- 更新联盟科技
    UPDATE_FAMILY_TECH = 1863,
    -- 正在升级的联盟科技
    FAMILY_TECH_UPDATING = 1864,
    -- 升级结束
    FAMILY_FINISH_UPDATING = 1869,
    -- 钻石加速正在升级的联盟科技
    FAMILY_TECH_UPDATING_SPEED = 1868,
    -- 联盟徽章
    FAMILY_TECH_GIVEN = 1865,
    -- 联盟徽章捐赠获得(暴击)
    FAMILY_TECH_GIVEN_BET = 1866,
    -- 联盟贡献捐赠清除时间
    FAMILY_TECH_CLEAR_TIME = 1867,

    -- 领主经验更新
    ROLE_EXP_UPDATE = 3590,

    -- 领主战力更新
    ROLE_FIGHT_UPDATE = 3599,

    -- 资源产出更新
    ROLE_OUT_INFO = 3603,

    -- 体力更新
    ROLE_POWER_UPDATE = 3600,

    -- 地块数量更新
    ROLE_LANDSIZE_UPDATE = 3601,

    -- 任务列表
    TASK_LIST = 3647,

    -- 更新任务
    TASK_UPDATE = 3644,

    -- 完成任务
    TASK_COMPLETE = 3645,

    -- 接取任务
    TASK_ACCEPT = 3646,
    --章节任务
    TASK_CAPHTER_TITLE = 10701,
    TASK_CAPHTER_DATA = 10702,
    TASK_CAPHTER_GET_TITLE = 10705,
    TASK_CAPHTER_GET_TASK = 10704,
    TASK_CAPHTER_DATA_UPDATA = 10703,
    TASK_CAPHTER_OPEN = 10706,
    -- 礼包更新
    PACKAGE_UPDATE = 3637,

    -- 领取礼包
    GET_PACKAGE = 3638,

    -- 查看月卡（新）
    CHECK_MONTH = 3671,

    -- 更新月卡（新）
    UPDATE_MONTH = 3672,

    -- 月卡奖励下发
    REWARD_MONTH = 3673,

    -- 领取月卡
    --        GET_MONTH = 3651,

    -- 月卡是否存在信息
    -- 	MONTH_CARD = 3648,

    -- 月卡信息
    -- 	MONTH_INFO = 3649,

    -- 商店物品信息
    RECHARGE = 3650,

    -- 地块数据详情
    ROLE_MAP_LAND_INFO = 3653,

    -- 开启的活动列表
    ACTIVITY_LIST = 3841,

    -- 充值返利充值成功更新充值返利界面详情
    ACTIVITY_UPDATE_RECHARGEREBATE = 3844,

    -- 初始界面活动信息
    ACTIVITY_INIT_VIEW = 3845,

    -- 更新活动详情里的数据
    ACTIVITY_UPDATE_DETAIL = 3847,


    -- 抵御蛮族更新
    ACTIVITY_RESIST_UPDATE = 10312,

    -- 抵御蛮族 敌军详情
    ACTIVITY_RESIST_ENEMY_DETAIL = 1649,

    -- 抽奖获得优质奖励记录
    ACTIVITY_DARW_RECORD = 3848,

    -- 积分帮助信息
    ACTIVITY_VIGOUR_INFO = 3849,

    -- 积分领取奖励完成
    ACTIVITY_FINISH_REWARD = 3850,
    -- 抽将通知记录
    TIME_TURNPLARE_RECODE = 3875,

    -- 奇迹转换
    WONDER_CHANGE = 552,

    -- 奇迹转换完成
    WONDER_CHANGE_FINISH = 553,

    -- 按钮开启状态
    TASK_BUTTON_STATUS = 3652,
    --功能开启
    OPEN_FUNTION =  3719,
    MSG_CITY_HONOUR_TECH = 565,
    -- 荣誉科技565
    MSG_CITY_HONOUR_TECH_UP_LEVEL = 566,
    -- 荣誉科技升级566

    -- 联盟日志
    ALLIANCE_LOG = 1836,

    -- 收发邮件
    CHAT_MAIL = 1569,

    -- 发送联盟邮件
    UNION_MAIL = 1873,

    -- 领主改名
    LORD_RENAME = 3654,

    --        --月卡活动开关
    --        SWITCH_PROMOTION_MONTH = 556,

    -- 加入/创建联盟冷却时间
    ALLIANCE_CD = 3656,

    -- 排行榜
    WORLD_RANK_LIST = 1539,

    -- 个人信息
    ROLE_VIEW_PLAYER_INFO = 3629,

    -- 联盟信息
    RANK_FAMILY_INFO = 1838,


    -- 新手引导上传
    UPLOAD_GUIDE_INDEX = 558,

    -- 沦陷信息
    FAMILY_CAPTIVE = 1853,
    -- 沦陷反叛捐资源
    FAMILY_CAPTIVE_REVERT = 1854,
    -- 沦陷反叛成功
    FAMILY_CAPTIVE_REVERT_SUCCESS = 1855,
    -- 沦陷列表
    FAMILY_CAPTIVE_LIST = 1852,
    -- //进入保护 3666
    ROLE_PROTECTED = 3666,
    -- //清除保护冷却 3667
    ROLE_CLEAN_PROTECTED_COUNTDONW = 3667,
    -- //取消保护 3668
    ROLE_CANCEL_PROTECTED = 3668,

    ROLE_PROTECTED_INFO = 3669,
    -- buff
    ROLE_BUFF_UPDATE = 3670,

    -- 兑换
    EXPCHAGE_GEM = 3696,


    ACTIVITY_LIMIT_REWARDS = 3851,

    ACTIVITY_RESISTINVASION_REWARDS = 3874,

    WORLD_FORT_HERO_ACTIVITION = 3676,
    -- 激活名将

    WORLD_FORT_HERO_UPGRADE = 3677,
    -- 进阶名将,改变进度

    WORLD_FORT_HERO_UPGRADE_FINISH = 3682,
    -- 进阶名将完成

    WORLD_FORT_HERO_IDENTIFY_LIST = 3678,
    -- 名将图鉴列表

    WORLD_FORT_HERO_UPGRADE_DETIAL = 3681,
    -- 图鉴进度详情

    WORLD_FORT_HERO_EXCHANGE = 3683,
    -- 图鉴材料兑换

    WORLF_FORT_HERO_SOLDIER = 3687,
    -- 名将招募列表

    WORLD_FORT_RECURIT_SOLDIER = 3684,
    -- 名将奇迹兵招募

    WORLD_FORT_SOLDIER_UPDATA = 3686,
    -- 刷新奇迹兵招募

    WORLD_FORT_SOLDIER_BUY = 3685,
    -- 招募奇迹兵

    WORLD_FORT_HERO_SKILL_LIST = 3679,
    -- 已经激活的主动技能列表

    WORLD_FORT_HERO_USE_SKILL = 1624,
    -- 使用主动技能

    WORLD_FORT_HERO_BUFF = 3680,
    -- 地图块的buff刷新

    -- 天下大势
    WORLD_TASK_NAME_LIST = 1655,
    WORLD_TASK_LIST = 1652,
    WORLD_TASK_NAME_VIEW = 1653,
    WORLD_TASK_GET = 1654,
    WORLD_TASK_COMPLETE = 1656,
    -- 成长之路
    GROW_WAY_GET = 1657,
    WORLD_FORT_HERO_OPEN_SKILL = 3688,
    -- 首次开启主动技能,出现技能按钮引导
    -- 推广详情
    POPULARIZE_ONFO_DATA = 3855,

    -- 推广跳转时间
    POPULARIZE_SKIP_TIME = 3856,

    -- 推广领取奖励
    POPULARIZE_DRAW_REWARDS = 3857,
    -- 标记boss
    BOSS_MARK = 1626,

    -- 大地图召唤商队
    MAP_ZHAOHUAN_SHANGDUI = 1648,

    -- 红包开启
    REDBAO_OPEN = 3858,

    -- 红包关闭
    REDBAO_CLODE = 3859,

    -- 点击领取红包
    REDBAO_CLICK = 3860,

    -- 周签到
    WEEKY_SIGN = 3861,

    -- 周签到领取奖励
    WEEKY_SIGN_REWARD = 3862,

    -- 武勋兑换
    ACTIVITY_MEDAL_EXCHANGE = 3863,

    -- 点击王座按钮
    KINGDOM_TYPE_DETAIL = 1633,

    -- 任命与解任
    KINGDOM_ADMIN_OFFICER = 1631,

    -- 任命官员名字检测
    KINGDOM_NAME_CHECK = 1650,

    -- 修改宣言
    KINGDOM_CHANGE_MOTTO = 1635,

    -- 国库捐赠
    KINGDOM_FOUNDATION_DONATE = 1651,

    -- 捐赠物品
    KINGDOM_DONATE_ITEM = 1634,

    -- 赏赐资源
    KINGDOM_GIVEN_ITEM = 1632,

    -- 领取俸禄
    KINGDOM_GIVEN_SALARY = 1639,

    -- 发布国家政策
    KINGDOM_NATIONAL_POLICY_PUBLISH = 1630,
    -- 跨服关闭
    CROSS_SEVER_SHUT_DOWN = 3083,
    -- 本期跨服对战
    CROSS_SEVER_FIGHT_RECORD = 3123,

    -- 军政/跨服活动列表
    CROSS_SEVER_PROMOTION_LIST = 3124,

    -- 跨服状态
    CROSS_SEVER_STATUS = 3691,

    -- 退出跨服状态
    CROSS_SEVER_ONEXIT = 3099,

    -- 王座积分排行榜
    CROSS_SEVER_SCORE_RANK = 3100,

    -- 跨服活动奖励
    CROSS_SEVER_REWARD = 3851,

    -- 阵营聊天
    CAMOP_CHAT_INFO = 3101,

    -- 跨服聊天
    CROSS_CHAT_INFO = 3104,

    -- 跨服聊天记录
    CROSS_CHAT_RECORD = 3105,

    -- 全服喇叭广播
    CROSS_CHAT_TRUMPET = 1642,

    -- 沦陷王座
    CROSS_THRONE_OCCUPY = 3109,

    -- 跨服结束
    CROSS_THRONE_END = 3110,
    -- 符文
    RUNE_INFO = 10001,
    -- 符文初始化
    RUNE_BACKPACK = 10002,
    -- 符文背包
    RUNE_UPDATE = 10003,
    -- 更新背包里的一组符文(下行)
    RUNE_REMOVE = 10004,
    -- 移除背包里的一组符文(下行)
    RUNE_EQUIP = 10005,
    -- 装备/卸载符文
    RUNE_STRENGTH = 10006,
    -- 符文强化
    RUNE_COMPOUND = 10007,
    -- 符文合成
    RUNE_RESOLVE = 10008,
    -- 符文方案激活
    RUNE_CASE_ACTIVE = 10020,
    -- 符文方案特性
    RUNE_CASE_FEATURE = 10021,
    -- 神器锁定
    RUNE_LOCK = 10012,
    -- 星级合成概率查看
    RUNE_PROBABILITY = 10013,
    -- 圣器搜寻左则列表
    RUNE_SEARCH_LEFT_LIST = 10016,
    -- 圣器搜寻右侧数据
    RUNE_SEARCH_RIGHT_INIT = 10014,
    -- 圣器搜寻请求
    RUNE_SEARCH_REQUEST = 10015,

    -- 圣器觉醒请求
    RUNE_AWAKEN_REQUEST = 10026,

    -- 圣器技能重置
    RUNE_SKILL_RESET = 10028,
    -- 圣器技能替换
    RUNE_SKILL_REPLACE = 10029,
    -- 符文分解
    -- 查找符文守卫
    MSG_RUNE_FIND_GUARD = 10009,

    -- 查找初始化
    MSG_RUNE_FIND_GUARD_INIT = 10010,

    -- 更新当前已挑战的怪物等级
    MSG_RUNE_UPDATE_GUARD_LEVEL = 10011,

    -- 圣物洗练
    MSG_RUNE_XL = 10017,

    -- 圣物洗练-替换
    MSG_RUNE_XL_EXPECT = 10018,

    -- 圣物洗练-结果
    MSG_RUNE_XL_EXPECT_RESULT = 10019,

    -- 圣物材料 指定合成
    RUNE_COMPOUND_STYLE = 3705,

    -- 圣物图鉴激活列表
    RUNE_HANDBOOK_ACTIVE = 10022,

    -- 圣物图鉴有新增
    RUNE_HANDBOOK_NEW = 10023,

    -- 圣物特性红点取消
    RUNE_TEXIN_REDPOINT_REMOVE = 10025,

    -- 占卜
    ACTIVITY_AURGURY = 3125,

    -- 许愿
    ACTIVITY_WISH = 3126,

    -- 宝箱/符文道具合成
    BOX_REMAKE = 3692,

    -- 放弃要塞
    WORLD_FORTRESS_GIVEUP = 1643,
    -- 取消放弃要塞
    WORLD_FORTRESS_GIVEUP_CALCLE = 1644,

    -- 初始化战舰数据
    MSG_WARSHIP_INIT = 2561,
    -- 打造战舰
    MSG_WARSHIP_BUILD = 2562,
    -- 战舰升级
    MSG_WARSHIP_UPGRADE = 2563,
    -- 填充弹药
    MSG_WARSHIP_FILL_FIRE = 2564,
    -- 战舰更新
    MSG_WARSHIP_UPDATE = 2565,

    -- 战舰科技升级
    MSG_SHIP_TECH_UP = 2566,

    -- 设置战舰状态
    MSG_WARSHIP_STATUS = 2567,
    -- 战舰技能升级
    MSG_SHIP_SKILL_UPGRADE = 2568,


    -- 成就系统数据
    MSG_ACHIEVENMENT_INIT = 3694,
    -- 领取成就
    MSG_ACHIEVENMENT_GET = 3693,
    -- 成就达成 主动通知
    MSG_ACHIEVENMENT_NOTICE = 3695,
    -- 战舰经验购买并使用
    MSG_SHIP_EXP_BUY = 2569,
    -- 远征初始化
    MSG_SHIP_EXPEDITION_INIT = 2570,
    -- 更新远征任务
    MSG_SHIP_EXPEDITION_UPDATE = 2571,
    -- 领取远征任务
    NSG_SHIP_EXPEDITION_REWARD = 2572,
    -- 远征
    MSG_SHIP_EXPEDITION = 2573,
    -- 远征任务全部刷新
    MSG_SHIP_EXPEDITION_REFRESH = 2574,
    -- 远征召回
    MSG_SHIP_EXPEDITION_CANCEL = 2575,
    -- 远征加速
    MSG_SHIP_EXPEDITION_SPEED = 2576,

    -- 红点状态更新
    MSG_RED_POINT_UPDATE = 3870,

    -- 红点移除
    MSG_RED_POINT_REMOVE = 3872,

    -- 放逐轮陷的领地
    MSG_EXILE = 1646,

    -- 被放逐领地的玩家收到消息
    MSG_BE_EXILE = 1647,

    -- 战舰突破
    MSG_SHIP_OVERFULL = 2577,
    -- 装扮列表
    MSG_ADORNMENT_LIST = 10201,
    -- 装备装扮
    MSG_ADORNMENT_EQUIPT = 10203,
    -- 装扮更新
    MSG_ADORNMENT_UPDATE = 10202,

    -- 英雄试炼 首页排行数据
    MSG_HEROLEVEL_INDEXDATA = 10403,

    -- 英雄试炼 征服数据
    MSG_HEROLEVEL_CONQUER = 10404,

    -- 英雄试炼 征服结果
    MSG_HEROLEVEL_CONQUER_RESULT = 10405,

    -- 英雄试炼 扫荡结果
    MSG_HEROLEVEL_SAODANG_RESULT = 10406,

    -- 英雄试炼 重置
    MSG_HEROLEVEL_RESET = 10409,
    -- 城市皮肤升级
    MSG_SKIN_LEVEL_STAR = 10204,
    MSG_BOOK_TECH_MENU = 1415,
    -- 图鉴科技1415
    MSG_BOOK_TECH_UP_LEVL = 1416,-- 图鉴科技升级1416
    -- 战舰改装
    MSG_SHIP_REFIT = 2592,
    -- 战舰改装背包
    MSG_SHIP_REFIT_BAG = 2593,
    -- 战舰改装-装备
    MSG_SHIP_REFIT_EQUIP = 2579,
    -- 战舰改装-卸下
    MSG_SHIP_REFIT_UNEQUIP = 2583,
    -- 战舰改装分解
    MSG_SHIP_REFIT_BREAK = 2582,
    -- 战舰改装升级
    MSG_SHIP_REFIT_LEVELUP = 2580,
    -- 工厂订单
    MSG_SHIP_REFIT_FACTORY_ORDER = 2594,
    -- 开始订单
    MSG_SHIP_REFIT_FACTORY_ORDER_START = 2588,
    -- 收获订单
    MSG_SHIP_REFIT_FACTORY_ORDER_COMPLETE = 2589,
    -- 加速订单
    MSG_SHIP_REFIT_FACTORY_ORDER_QUICK = 2595,
    -- 进入竞技场
    MSG_SHIP_REFIT_ENTER_PVP = 2585,
    --获取可用战舰
    MSG_SHIP_REFIT_GET_SHIP = 2596,
    --设置进攻战舰
    MSG_SHIP_REFIT_SET_ATT = 2598,
    --设置防守战舰
    MSG_SHIP_REFIT_SET_DEF = 2597,
    --战舰战斗
    MSG_SHIP_REFIT_PVP_BATTLE = 2584,
    MSG_SHIP_REFIT_PVP_MAILINFO = 2600,
    ----------------跨服争霸相关------------------
    -- 跨服争霸活动信息
    PVP_INFO = 10601,
    -- 跨服争霸报名
    PVP_SIGN_UP = 10602,
    -- 跨服争霸阵容配置
    PVP_FORMATION_SET = 10603,
    -- 跨服争霸阵容配置信息
    PVP_FORMATION_INFO = 10604,
    -- 跨服争霸队伍互换
    PVP_FORMATION_EXCHANGE = 10605,
    -- 跨服争霸海选记录
    PVP_PRESELECTION_RECORD = 10606,
    -- 跨服争霸玩家个人战报
    PVP_PERSONAL_WAR_REPORT = 10607,
    --  跨服争霸战报详情
    PVP_WAR_REPORT_DETAIL = 10608,
    -- 跨服争霸下注
    PVP_BET = 10609,
    -- 跨服争霸某一组玩家战报
    PVP_TWO_PLAYER_WAR_REPORT = 10611,
    -- 跨服争霸海选阶段数据更新
    PVP_PRESELECTION_DATA_UPDATE = 10612,
    -- 跨服争霸对战阶段数据更新
    PVP_MATCH_DATA_UPDATE = 10613,
    -- 跨服争霸详细赛程
    PVP_DETAIL_SCHEDULE = 10614,
    ---------------------------------------------
    --设置波次
    MSG_SET_WAVE = 3717,
}
_MSG = {
    -- 战舰改装
    ship_refit = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    ship_refit_bag = function(t, i)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_BAG
        msg.v = MSGVER
        msg.c = { }
        msg.c.t = t
        msg.c.i = i
        return msg
    end,
    msg_ship_refit_equip = function(shipId, comboSkillId, armourIndex)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_EQUIP
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipId = shipId
        msg.c.comboSkillId = comboSkillId
        msg.c.armourIndex = armourIndex
        return msg
    end,
    msg_ship_refit_unequip = function(shipId, armourIndex)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_UNEQUIP
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipId = shipId
        msg.c.armourIndex = armourIndex
        return msg
    end,
    msg_ship_refit_break = function(shipArmourId, qualities, batch)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_BREAK
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipArmourId = shipArmourId
        msg.c.armourType = armourType
        msg.c.qualities = qualities
        msg.c.batch = batch
        return msg
    end,
    msg_ship_refit_levelup = function(shipId, shipComboSkillId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_LEVELUP
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipId = shipId
        msg.c.shipComboSkillId = shipComboSkillId
        return msg
    end,
    -- 工厂订单
    msg_ship_refit_factory_order = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_FACTORY_ORDER
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 开始订单
    msg_ship_refit_factory_order_start = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_FACTORY_ORDER_START
        msg.v = MSGVER
        msg.c = { }
        msg.c.orderType = id
        return msg
    end,
    -- 完成订单
    msg_ship_refit_factory_order_complete = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_FACTORY_ORDER_COMPLETE
        msg.v = MSGVER
        msg.c = { }
        msg.c.orderType = id
        return msg
    end,
    -- 加速订单
    msg_ship_refit_factory_order_quick = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_FACTORY_ORDER_QUICK
        msg.v = MSGVER
        msg.c = { }
        msg.c.orderType = id
        return msg
    end,
    --进入竞技
    msg_ship_refit_enter_pvp = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_ENTER_PVP
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    --获取可装配战舰
    msg_ship_refit_get_ship = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_GET_SHIP
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    --设置进攻战舰
    msg_ship_refit_set_att = function(shipId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_SET_ATT
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipId = shipId
        return msg
    end,
    --设置防守战舰
    msg_ship_refit_set_def = function(shipId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_SET_DEF
        msg.v = MSGVER
        msg.c = { }
        msg.c.shipId = shipId
        return msg
    end,
    
    --PVP战斗
    msg_ship_refit_pvp_battle = function(rank)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_PVP_BATTLE
        msg.v = MSGVER
        msg.c = { }
        msg.c.targetRank = rank
        return msg
    end,
    --竞技场战报详情
    msg_ship_refit_pvp_mailinfo = function (mailUid)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_REFIT_PVP_MAILINFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.mailUid = mailUid
        return msg
    end,
    setwave = function (wv)
        local msg = { }
        msg.t = MsgCode.MSG_SET_WAVE
        msg.v = MSGVER
        msg.c = { }
        msg.c.maxW = wv
        return msg
    end,
    -- ping 消息
    pingMsg = function()
        local msg = { }
        msg.t = MsgCode.PING
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 考古图鉴
    book_tech_menu = function()
        local msg = { }
        msg.t = MsgCode.MSG_BOOK_TECH_MENU
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 是否隐藏图腾
    msg_show_totem = function(show)
        local msg = { }
        msg.t = MsgCode.MSG_SHOW_TOTEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.show = show
        return msg
    end,
    book_tech_levelup = function(techId, blist)
        local msg = { }
        msg.t = MsgCode.MSG_BOOK_TECH_UP_LEVL
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        msg.c.blist = blist
        return msg
    end,
    -- 迁城信息
    moveCityInfo = function()
        local msg = { }
        msg.t = MsgCode.MOVE_CITY_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    citySkinList = function()
        local msg = { }
        msg.t = MsgCode.MSG_ADORNMENT_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    world_task_name_list = function()
        local msg = { }
        msg.t = MsgCode.WORLD_TASK_NAME_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    world_task_name_view = function(id)
        local msg = { }
        msg.t = MsgCode.WORLD_TASK_NAME_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    world_task_get = function(id)
        local msg = { }
        msg.t = MsgCode.WORLD_TASK_GET
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    grow_way_get = function(id)
        local msg = { }
        msg.t = MsgCode.GROW_WAY_GET
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    world_task_list = function(id)
        local msg = { }
        msg.t = MsgCode.WORLD_TASK_LIST
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = id
        return msg
    end,
    citySkinEquip = function(defid)
        local msg = { }
        msg.t = MsgCode.MSG_ADORNMENT_EQUIPT
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = defid
        return msg
    end,
    citySkinLevelStar = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_SKIN_LEVEL_STAR
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    achievenment_get = function(defid)
        local msg = { }
        msg.t = MsgCode.MSG_ACHIEVENMENT_GET
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defid
        return msg
    end,
    -- 荣耀系统初始化
    hornor_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_CITY_HONOUR_TECH
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    hornor_levelup = function(techId, itemId)
        local msg = { }
        msg.t = MsgCode.MSG_CITY_HONOUR_TECH_UP_LEVEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        msg.c.itemId = itemId
        return msg
    end,

    achievenment_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_ACHIEVENMENT_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 称号列表
    roleTitleList = function()
        local msg = { }
        msg.t = MsgCode.MSG_TITLE_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    world_fortress_giveup_cancel = function(x, y)
        local msg = { }
        msg.t = MsgCode.WORLD_FORTRESS_GIVEUP_CALCLE
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,

    world_fortress_giveup = function(x, y)
        local msg = { }
        msg.t = MsgCode.WORLD_FORTRESS_GIVEUP
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,

    box_remake = function(id, num)
        local msg = { }
        msg.t = MsgCode.BOX_REMAKE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.num = num
        return msg
    end,
    -- 元宝兑换
    expchagegem = function(num)
        local msg = { }
        msg.t = MsgCode.EXPCHAGE_GEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.num = num
        return msg
    end,

    activity_wish = function(id)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_WISH
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    activity_aurgury = function()
        local msg = { }
        msg.t = MsgCode.ACTIVITY_AURGURY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    kingdom_policy_publish = function(defId, name, gem)
        local msg = { }
        msg.t = MsgCode.KINGDOM_NATIONAL_POLICY_PUBLISH
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defId
        msg.c.name = name or ""
        msg.c.gem = gem
        return msg
    end,

    kingdom_given_item = function(target, food, wood, stone, gold)
        local msg = { }
        msg.t = MsgCode.KINGDOM_GIVEN_ITEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.target = target
        msg.c.food = food
        msg.c.wood = wood
        msg.c.stone = stone
        msg.c.gold = gold
        return msg
    end,

    kingdom_given_salary = function()
        local msg = { }
        msg.t = MsgCode.KINGDOM_GIVEN_SALARY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    kingdom_donate_item = function(defId, count)
        local msg = { }
        msg.t = MsgCode.KINGDOM_DONATE_ITEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defId
        msg.c.count = count
        return msg
    end,

    kingdom_foundation_donate = function()
        local msg = { }
        msg.t = MsgCode.KINGDOM_FOUNDATION_DONATE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    kingdom_change_motto = function(words)
        local msg = { }
        msg.t = MsgCode.KINGDOM_CHANGE_MOTTO
        msg.v = MSGVER
        msg.c = { }
        msg.c.kingWorlds = words
        return msg
    end,

    kingdom_admin_officer = function(target, degree, type)
        local msg = { }
        msg.t = MsgCode.KINGDOM_ADMIN_OFFICER
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = type
        msg.c.target = target
        msg.c.degree = degree
        return msg
    end,

    kingdom_name_check = function(name, degree)
        local msg = { }
        msg.t = MsgCode.KINGDOM_NAME_CHECK
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        msg.c.degree = degree
        return msg
    end,

    -- 王国按钮请求
    kingdom_detail_type = function(type)
        local msg = { }
        msg.t = MsgCode.KINGDOM_TYPE_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = type
        return msg
    end,

    --- 注册消息
    registMsg = function(acc, pwd, gender, source)
        local msg = { }
        msg.t = MsgCode.AUTH_ROLE_REG
        msg.v = MSGVER
        msg.c = { }
        msg.c.account = acc or ""
        msg.c.pwd = pwd or ""
        msg.c.gender = gender or 1
        msg.c.source = source or ""
        return msg
    end,

    -- 验证登录
    signLogin = function(r)
        local msg = { }
        msg.t = MsgCode.AUTH_SIGN_LOGIN
        msg.v = MSGVER
        msg.c = r
        return msg
    end,
    reSignLogin = function(r)
        local msg = { }
        msg.t = MsgCode.AUTH_SIGN_RELOGIN
        msg.v = MSGVER
        msg.c = r
        return msg
    end,
    -- 登录消息
    loginMsg = function(acc, pwd)
        local msg = { }
        msg.t = MsgCode.AUTH_LOGIN
        msg.v = MSGVER
        msg.c = { }
        msg.c.account = acc or ""
        msg.c.pwd = pwd or ""
        return msg
    end,
    -- 跨服国王标记
    mapMarkKing = function(x, y, c)
        local msg = { }
        msg.t = MsgCode.MAP_MARK_KING
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x;
        msg.c.y = y;
        msg.c.content = c
        return msg
    end,
    -- 标记BOSS
    markBoss = function(x, y)
        local msg = { }
        msg.t = MsgCode.BOSS_MARK
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x;
        msg.c.y = y;
        return msg
    end,

    -- 召唤商队消息
    mapZhaohuan = function(x, y, itemId)
        local msg = { }
        msg.t = MsgCode.MAP_ZHAOHUAN_SHANGDUI
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x;
        msg.c.y = y;
        msg.c.id = itemId;
        return msg
    end,
    -- 选择国家消息
    selectCountryMsg = function(id)
        local msg = { }
        msg.t = MsgCode.AUTH_SELECT_COUNTRY
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id or 1
        return msg
    end,

    -- 跨服连接数据
    getNetBattleDataMsg = function()
        local msg = { }
        msg.t = MsgCode.ACTIVITY_CROSS_APPLY_AUTH
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 跨服玩家验证
    NetBattlePlayerAuthMsg = function(uid, time, sid, token)
        local msg = { }
        msg.t = MsgCode.MSG_CROSS_PLAYER_AUTH
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.time = time
        msg.c.sid = sid
        msg.c.token = token
        return msg
    end,
    -- 跨服连接数据
    NetBattleEnterMsg = function()
        local msg = { }
        msg.t = MsgCode.MSG_CROSS_PLAYER_ENTRY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,


    -- 重新获取正在建造数据消息
    loadDateLineDataMsg = function()
        local msg = { }
        msg.t = MsgCode.ROLE_DATELINE_DATA
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 获取数据消息
    loadDataMsg = function(opt)
        local msg = { }
        msg.t = MsgCode.ROLE_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.opt = opt
        return msg
    end,
    -- 获取邮件侦察日志
    loadMailSpyReport = function(uid)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_SPY_REPORT
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 邮件uid
        return msg
    end,

    -- 建造
    buildingStruct = function(shopId, index, farmer, quick)
        local msg = { }
        msg.t = MsgCode.CITY_BUILDING_STRUCT
        msg.v = MSGVER
        msg.c = { }
        msg.c.shopId = shopId
        msg.c.index = index
        -- 建筑唯一id
        msg.c.farmer = farmer
        -- 建造时的农民数
        msg.c.quick = quick or 0
        -- 1为快速建造 0为普通
        return msg
    end,

    -- 升级
    buildingUpLevel = function(index, farmer, quick)
        local msg = { }
        msg.t = MsgCode.CITY_BUILDING_UPLEVEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.index = index
        msg.c.farmer = farmer
        -- 升级的农民数
        msg.c.quick = quick or 0
        -- 1为快速建造 0为普通
        return msg
    end,

    -- 收集资源
    getResource = function(index)
        local msg = { }
        msg.t = MsgCode.CITY_GET_RESOURCE
        msg.v = MSGVER
        msg.c = { }
        msg.c.index = index
        -- 建筑唯一id
        return msg
    end,

    -- 调节农民
    allotMsg = function(data)
        local msg = { }
        msg.t = MsgCode.CITY_BUILDING_FARMERCHANGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.blist = data
        return msg
    end,
    -- 采集内城随机资源点
    randResource = function(placeIndex)
        local msg = { }
        msg.t = MsgCode.CITY_RAND_RESOURCE
        msg.v = MSGVER
        msg.c = { }
        msg.c.place = placeIndex
        return msg
    end,
    -- 收获采集内城随机资源点
    getRandResource = function(placeIndex)
        local msg = { }
        msg.t = MsgCode.CITY_RAND_RESOURCE_GET
        msg.v = MSGVER
        msg.c = { }
        msg.c.place = placeIndex
        return msg
    end,
    -- //生产农民
    prodFarmer = function()
        local msg = { }
        msg.t = MsgCode.CITY_P_FARMER
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    cross_rank = function()
        local msg = { }
        msg.t = MsgCode.CROSS_RANK
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 升级科技初始数据
    techView = function(tid, lv, bid)
        local msg = { }
        msg.t = MsgCode.CITY_TECH_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.tid = tid
        -- 科技typteid
        msg.c.lv = lv
        -- 科技等级
        msg.c.bid = bid
        -- 建筑id
        return msg
    end,

    -- 升级科技
    techUpLevel = function(tid, lv, bid, quick)
        local msg = { }
        msg.t = MsgCode.CITY_TECH_UPLEVEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.tid = tid
        -- 科技typteid
        msg.c.lv = lv
        -- 科技等级
        msg.c.bid = bid
        -- 建筑id
        msg.c.quick = quick or 0
        -- 1为快速建造 0为普通
        return msg
    end,
    -- 生产士兵
    prodSoldier = function(sid, num, bid, quick)
        local msg = { }
        msg.t = MsgCode.CITY_P_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        msg.c.num = num
        -- 士兵数量
        msg.c.sid = sid
        -- 士兵Id
        msg.c.quick = quick or 0
        -- 1为快速建造 0为普通
        return msg
    end,
    -- 请求训练界面数据
    prodSoldierView = function(bid)
        local msg = { }
        msg.t = MsgCode.CITY_P_SOLDIER_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        return msg
    end,

    -- 快速完成钻石
    buildQuickGem = function(bid)
        local msg = { }
        msg.t = MsgCode.CITY_QUICK_GEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        return msg
    end,
    -- 五分钟免费
    buildQuickFree = function(bid)
        local msg = { }
        msg.t = MsgCode.CITY_QUICK_FREE
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        return msg
    end,
    -- 快速完成道具
    buildQuickItem = function(bid, itemUid, itemNum, items)
        local msg = { }
        msg.t = MsgCode.CITY_QUICK_ITEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        msg.c.itemUid = itemUid
        -- 道具id
        msg.c.itemNum = itemNum
        -- 道具数量

        msg.c.items = items
        return msg
    end,
    -- 一健使用资源
    resQuickItemUse = function(items)
        local msg = { }
        msg.t = MsgCode.ROLE_BACKPACK_QUICK_ITEM_USE
        msg.v = MSGVER
        msg.c = { }

        msg.c.items = items
        return msg
    end,

    -- 取消建设中的任务
    buildingCancel = function(bid)
        local msg = { }
        msg.t = MsgCode.CITY_BUILDING_CANCEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        -- 建筑id
        return msg
    end,

    -- 恢复伤兵初始化
    revertSoldierInit = function(rtype)
        local msg = { }
        msg.t = MsgCode.CITY_P_REVERT_SOLDIER_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = rtype
        return msg
    end,

    -- 恢复死兵初始化
    reliveSoldierInit = function()
        local msg = { }
        msg.t = MsgCode.CITY_P_RELIVE_SOLDIER_VIEW
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 恢复伤兵
    revertSoldier = function(army, quick, rtype)
        local msg = { }
        msg.t = MsgCode.CITY_P_REVERT_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        msg.c.army = army
        -- {id:数量,id:数量}
        msg.c.quick = quick or 0
        -- 加速完成
        msg.c.type = rtype
        return msg
    end,

    -- 恢复死兵
    reliveSoldier = function(army, quick)
        local msg = { }
        msg.t = MsgCode.CITY_P_RELIVE_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        msg.c.army = army
        -- {id:数量,id:数量}
        msg.c.quick = quick or 0
        -- 加速完成
        return msg
    end,
    -- 军队信息
    armyinfo = function()
        local msg = { }
        msg.t = MsgCode.CITY_ARMY_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 资源点信息
    resourceBuildingInfo = function(index)
        local msg = { }
        msg.t = MsgCode.CITY_RESOURCE_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.bindex = index
        -- 建筑唯一id
        return msg
    end,
    -- //世界聊天
    worldChat = function(text)
        local msg = { }
        msg.t = MsgCode.WORLD_CHAT_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.c = text
        return msg
    end,

    -- 集火历史记录
    worldTeamHistory = function()
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_HISTORY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 集火信息
    worldTeamInfo = function()
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 集火军队详情信息
    worldTeamArmyInfo = function(teamId, attackId)
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.teamId = teamId
        -- 集火id
        msg.c.attackId = attackId
        -- 集火id
        return msg
    end,
    -- 军队详情信息
    worldTeamArmyDetail = function(teamId)
        local msg = { }
        msg.t = MsgCode.WORLD_ARMY_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.armyId = teamId
        -- 集火id
        return msg
    end,
    -- 遣返集火军队
    worldTeamArmyReject = function(teamId, armyId)
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_REJECT_ARMY
        msg.v = MSGVER
        msg.c = { }
        msg.c.teamId = teamId
        -- 集火id
        msg.c.armyId = armyId
        -- 军队id
        return msg
    end,
    -- 解散集火军队
    worldTeamArmyRelease = function(teamId)
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_RELEASE
        msg.v = MSGVER
        msg.c = { }
        msg.c.teamId = teamId
        -- 集火id
        return msg
    end,
    -- 获取士兵升级数据
    getSoldierLevelUpData = function(bid, sid)
        local msg = { }
        msg.t = MsgCode.CITY_UP_SOLDIER_INIT
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        msg.c.sid = sid
        print("获取士兵升级数据")
        return msg
    end,
    -- 升级士兵
    soldierLevelUp = function(bid, sid, num, quick)
        local msg = { }
        msg.t = MsgCode.CITY_UP_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        msg.c.bid = bid
        msg.c.sid = sid
        msg.c.num = num
        msg.c.quick = quick
        print("升级士兵")
        return msg
    end,
    -- 内城防御军队
    worldTeamCityArmy = function()
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_CITY_ARMY
        msg.v = MSGVER
        msg.c = { }
        print("内城防御军队")
        return msg
    end,
    -- 立即返回集火军队（队长权限）
    worldArmycallbackArmy = function(auid, useGem)
        local msg = { }
        msg.t = MsgCode.WORLD_ARMY_CALL_BACK
        msg.v = MSGVER
        msg.c = { }
        msg.c.auid = auid
        -- 军队唯一id
        msg.c.useGem = useGem
        -- 是否使用钻石
        return msg
    end,
    -- 联盟集火提示
    allianceConvergeHint = function()
        local msg = { }
        msg.t = MsgCode.ALLIANCE_CONVERGE_HINT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 联盟政策发布
    alliancePolicyPublish = function(id)
        local msg = { }
        msg.t = MsgCode.ALLIANCE_POLICY_PUBLISH
        msg.v = MSGVER
        msg.c = { id = id }
        return msg
    end,

    -- 联盟政策列表
    alliancePolicyLIST = function()
        local msg = { }
        msg.t = MsgCode.ALLIANCE_POLICY_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
     -- 领取章节
    task_caphter_get_title = function()
        local msg = { }
        msg.t = MsgCode.TASK_CAPHTER_GET_TITLE
        msg.v = MSGVER
        msg.c = { }
        
        return msg
    end,
     -- 
    task_caphter_get_task = function(id)
        local msg = { }
        msg.t = MsgCode.TASK_CAPHTER_GET_TASK
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    -- 要塞试炼详情
    worldfortherogeneral = function()
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_GENERAL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 开始要塞试炼
    worldfortheroopengeneral = function(cp)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_OPEN
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = cp.x
        msg.c.y = cp.y
        return msg
    end,
    -- 清除要塞冷却时间
    worldfortcleartime = function(herotype)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_CLEAR_TIME
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = herotype
        return msg
    end,
    -- 要塞试炼排名
    worldfortherorankgeneral = function(cp)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_RANK
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = cp.x
        msg.c.y = cp.y
        return msg
    end,
    -- 要塞试炼历史排名
    worldfortherohoistoryrankgeneral = function(herotype)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_HOSTORY_GENERAL
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = herotype
        return msg
    end,
    -- 王座初始化
    worldthronecreate = function()
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_CREATE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 王座策略
    worldthronestartegy = function()
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_STRATEGY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 王座策略发动
    worldthronestartegystart = function(id)
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_STRATEGY_START
        msg.v = MSGVER
        msg.c = { }
        msg.c.strategyId = id
        return msg
    end,
    -- 王座buffer
    worldthronebuffer = function()
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_BUFFER
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 王座事件
    worldthroneinit = function()
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 王座民心排行
    worldthronemorle = function()
        local msg = { }
        msg.t = MsgCode.WORLD_THRONE_MORALE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- //高级行军召回集火部队
    worldTeamcallbackArmy = function(auid, useGem)
        local msg = { }
        msg.t = MsgCode.WORLD_TEAM_CALL_BACK
        msg.v = MSGVER
        msg.c = { }
        msg.c.auid = auid
        -- 军队唯一id
        msg.c.useGem = useGem or 0
        -- 是否使用钻石
        return msg
    end,
    -- //援兵上限
    worldTeamCityTeam = function(uid)
        local msg = { }
        msg.t = MsgCode.WORLD_CITY_TEAM_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 玩家id
        return msg
    end,
    -- 援兵记录
    worldTeamDefensHistory = function()
        local msg = { }
        msg.t = MsgCode.ROLE_DEFENS_HISTORY
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- //家族聊天
    famliyChat = function(text)
        local msg = { }
        msg.t = MsgCode.FAMLIY_CHAT_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.c = text
        return msg
    end,
    viplevelup = function()
        local msg = { }
        msg.t = MsgCode.VIP_LEVEL_UP
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    show_vip_msg = function (show)
        local msg = { }
        msg.t = MsgCode.SHOW_VIP_MSG
        msg.v = MSGVER
        msg.c = { }
        msg.c.show = show
        return msg
    end,
    -- //地图
    worldMapView = function(x, y, opt, stp)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.opt = opt or 1
        msg.c.stp = stp or 0
        msg.c.x = x
        msg.c.y = y
        return msg
    end,
    -- //地图布署军队
    worldMapArmyDp = function(ox, oy, x, y, status, army, shipType, archtime, petDefId, waitTime, teamId)
        local msg = { }
        msg.t = MsgCode.WORLD_ARMY_DP
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        msg.c.ox = ox
        msg.c.oy = oy
        msg.c.status = status
        -- 41 探索  42出征 43驻扎 40回城  46考古 47演武  73 调动
        msg.c.army = army
        -- {id:数量,id:数量}
        msg.c.archtime = archtime or 0
        -- 当考古时的考古次数
        msg.c.petDefId = petDefId or 0
        msg.c.waitTime = waitTime or 0
        -- 集火 集结时间
        msg.c.teamId = teamId or 0
        -- 队员加入集火需要传

        msg.c.shipType = shipType or 0
        -- 加入战舰
        return msg
    end,
    -- //地图侦察
    worldMapSpy = function(x, y, army)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_SPY
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        msg.c.army = army or { }
        -- {id:数量,id:数量}
        return msg
    end,

    -- //地图建立贸易站
    worldMapTradingPost = function(x, y)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_DP_TRADINGPOST
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,
    -- //地图获取进攻路径
    worldMapPath = function(ox, oy, x, y, state)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_PATH
        msg.v = MSGVER
        msg.c = { }
        msg.c.status = state
        msg.c.ox = ox
        msg.c.oy = oy
        msg.c.x = x
        msg.c.y = y
        return msg
    end,

    -- //召回军队
    callbackArmy = function(auid)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_ARMY_CALL_BACK
        msg.v = MSGVER
        msg.c = { }
        msg.c.auid = auid
        -- 军队唯一id
        return msg
    end,

    -- //军队详情
    worldArmyInfo = function(Armyid)
        local msg = { }
        msg.t = MsgCode.WORLD_ARMY_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = Armyid
        -- 军队唯一id
        return msg
    end,
    -- //放弃土地
    dropPoint = function(x, y, t)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_DROP_POINT
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        msg.c.t = t
        return msg
    end,


    -- //取消放弃土地
    cancelDropPoint = function(x, y)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_DROP_POINT_CANCEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,


    -- //移动城市
    moveCity = function(x, y)
        local msg = { }
        msg.t = MsgCode.WORLD_MAP_MOVE_CITY
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,

    -- //征税信息
    taxInfo = function()
        local msg = { }
        msg.t = MsgCode.CITY_TAX_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- //征税详情查看
    taxDetail = function()
        local msg = { }
        msg.t = MsgCode.CITY_TAX_DETAIL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- //征税
    taxGet = function(useGem, quick)
        local msg = { }
        msg.t = MsgCode.CITY_TAX_GET
        msg.v = MSGVER
        msg.c = { }
        -- 1:使用钻石征收
        msg.c.useGem = useGem
        -- 1:一键征收   0:征收一次
        msg.c.quick = quick
        return msg
    end,

    -- //征服世界个人初始化
    fortressInit = function()
        local msg = { }
        msg.t = MsgCode.WORLD_FORTRESS_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    refreshgift = function()
        local msg = { }
        msg.t = MsgCode.ROLE_REFRESH_LIMIT_PACKAGE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 道具使用
    itemUse = function(itemUid, amount, constId)
        local msg = { }
        msg.t = MsgCode.ROLE_BACKPACK_USE
        msg.v = MSGVER
        msg.c = { }
        msg.c.itemUid = itemUid
        -- 道具唯一id
        msg.c.amount = amount
        msg.c.constId = constId or 0
        -- 数量
        return msg
    end,

    -- 道具分解
    itemBreak = function(itemUid, amount)
        local msg = { }
        msg.t = MsgCode.ROLE_BACKPACK_ITEM_BREAK
        msg.v = MSGVER
        msg.c = { }
        msg.c.itemUid = itemUid
        -- 道具唯一id
        msg.c.amount = amount
        -- 数量
        print("道具分解  itemid = "..itemUid)
        return msg
    end,

    bastion_changeName = function(x, y, name)
        local msg = { }
        msg.t = MsgCode.BASTION_CHANGE_NAME
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        msg.c.name = name
        return msg
    end,
    bastion_getPrice = function(x, y)
        local msg = { }
        msg.t = MsgCode.BASTION_GET_PRICE
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = x
        msg.c.y = y
        return msg
    end,
    -- 获取邮件
    mailList = function(mailType, isNew)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = mailType
        -- 1 普通 2系统消息 3 战斗战报和侦查战报
        msg.c.isNew = isNew or 0
        -- 1 时获取所有的新邮件
        return msg
    end,

    -- 读取邮件
    readMail = function(uid, t)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_GET
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.type = t
        -- 邮件uid
        return msg
    end,

    --
    -- 守军巡逻初始化
    guard_patrol_init = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_PATROL_INIT
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,

    --
    -- 守军巡逻开始
    guard_patrol_start = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_PATROL_START
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,

    --
    -- 守军巡逻停止
    guard_patrol_stop = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_PATROL_STOP
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,

    --
    -- 守军巡逻领取奖励
    guard_patrol_get = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_PATROL_GET
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,

    --
    -- 禁卫军自动补兵记录
    guard_patrol_autofill_record = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_AUTOFILL_RECORD
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,
    ship_bl = function(t)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_BL
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = t
        -- 邮件uid
        return msg
    end,    
    -- 守军科技初始化
    guard_tech_init = function(args)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_TECH_INIT
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,

    -- 守军科技强化
    guard_tech_up = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_TECH_UP_LEVLE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        -- 邮件uid
        return msg
    end,
    -- 守军初始化
    guard_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_ARMY_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 守军配置
    guard_set = function(auto, army)
        local msg = { }
        msg.t = MsgCode.MSG_GUARD_ARMY_DP
        msg.v = MSGVER
        msg.c = { }
        msg.c.army = army
        msg.c.auto = auto
        return msg
    end,

    -- 删除邮件
    deleteMail = function(uid)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_DELETE
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 邮件uid
        return msg
    end,

    -- 获取邮件道具
    getMailItem = function(uid)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_GET_ITEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 邮件uid
        return msg
    end,
    -- 获取邮件道具
    getAllMailItem = function()
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_ALL_GET_ITEM
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,
    -- 获取邮件战报 1 为战报 2为详细
    getMailBattleReport = function(uid, index, rtype)
        local msg = { }
        msg.t = MsgCode.ROLE_MAIL_BATTTLE_REPORT
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 邮件uid
        msg.c.index = index

        msg.c.type = rtype or 0
        -- 1 为战报 2为详细
        return msg
    end,

    rechargeCheck = function(rid)
        local msg = { }
        msg.t = MsgCode.RECHARGE_CHECK
        msg.v = MSGVER
        msg.c = { }
        msg.c.rid = rid
        -- 邮件uid
        return msg
    end,
    rechargeCancel = function()
        local msg = { }
        msg.t = MsgCode.RECHARGE_CANCEL
        msg.v = MSGVER
        msg.c = { }
        -- 邮件uid
        return msg
    end,
    -- 地块详细列表
    roleLandInfo = function()
        local msg = { }
        msg.t = MsgCode.ROLE_MAP_LAND_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 创建家族
    createFamily = function(name, notice)
        local msg = { }
        msg.t = MsgCode.FAMILY_CREATE
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        -- 联盟名字
        msg.c.notice = notice
        -- 联盟公告
        return msg
    end,
    -- 建造据点
    buildBastion = function(p, name)
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_STRUCT
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = p.x
        msg.c.y = p.y
        msg.c.name = name
        return msg
    end,
    -- 升级据点
    levelUpBastion = function(p, quick)
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_UPlEVEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.quick = quick
        msg.c.x = p.x
        msg.c.y = p.y
        return msg
    end,

    -- 加速升级据点
    levelUpSpeedUp = function(p)
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_SPEEDUP
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = p.x
        msg.c.y = p.y
        return msg
    end,

    -- 取消升级据点
    cancelUpSpeedUp = function(p)
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_CANCELUP
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = p.x
        msg.c.y = p.y
        return msg
    end,

    -- 据点列表
    strongHoldlist = function()
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 据点列表
    strongHoldDelete = function(p)
        local msg = { }
        msg.t = MsgCode.WORLD_STRONG_HOLD_REMOVE
        msg.v = MSGVER
        msg.c = { }
        msg.c.x = p.x
        msg.c.y = p.y
        return msg
    end,
    -- 获取家族列表
    getListFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族初始化
    getFamilyInfor = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族成员列表
    getListMember = function()
        local msg = { }
        msg.t = MsgCode.MSG_FAMILY_INIT_MEMBER_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族申请
    applyFamily = function(uid)
        local msg = { }
        msg.t = MsgCode.FAMILY_APPLY
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,
    -- 家族申请
    applyFamilyByName = function(name)
        local msg = { }
        msg.t = MsgCode.FAMILY_APPLY_NAME
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        return msg
    end,

    -- 家族申请列表
    getapplyFamilyList = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_APPLY_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 同意申请家族
    agreeFamily = function(uid, agree)
        local msg = { }
        msg.t = MsgCode.FAMILY_AGREE
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.agree = agree
        return msg
    end,


    -- 玩家收到家族的邀请的列表
    requestListFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_REQUEST_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族邀请玩家的列表
    requestMemberFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_REQUEST_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族邀请玩家
    requestFamily = function(uid)
        local msg = { }
        msg.t = MsgCode.FAMILY_REQUEST
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,
    -- 同意或拒绝申请
    applyinviteFamily = function(uid, RefuseAggree)
        local msg = { }
        msg.t = MsgCode.FAMILY_APPLY_INVITE
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.RefuseAggree = RefuseAggree
        -- 1同意 2 拒绝
        return msg
    end,
    -- 设置联盟招募状态
    recruitOpenFamily = function(recruit)
        local msg = { }
        msg.t = MsgCode.FAMILY_RECRUIT_OPEN
        msg.v = MSGVER
        msg.c = { }
        msg.c.recruit = recruit
        -- 1开 2 关
        return msg
    end,
    -- 联盟申请的列表
    inviteMemberFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_INVITE_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 联盟按名字直接邀请玩家
    inviteNameFamily = function(name)
        local msg = { }
        msg.t = MsgCode.FAMILY_INVITE_NAME
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        return msg
    end,
    -- 联盟一键邀请所有玩家
    inviteAllFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_INVITE_ALL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    question = function(qid, aid)

        local msg = { }
        msg.t = MsgCode.ACTIVITY_QUESTION
        msg.v = MSGVER
        msg.c = { }
        msg.c.qid = qid
        msg.c.aid = aid
        return msg
    end,
    -- 踢出家族
    kickFamily = function(uid)
        local msg = { }
        msg.t = MsgCode.FAMILY_KICK
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,
    --
    -- 玩家请求家族帮助
    requestHelpFamily = function(index)
        local msg = { }
        msg.t = MsgCode.FAMILY_HELP
        msg.v = MSGVER
        msg.c = { }
        msg.c.index = index
        -- 建筑的uid
        return msg
    end,

    -- 家族帮助的列表
    helpListFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_HELP_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 修改在联盟的职位
    updateDegreeFamily = function(uid, degree)
        local msg = { }
        msg.t = MsgCode.FAMILY_SET_DEGREE
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.degree = degree
        return msg
    end,
    -- 修改在联盟的职位
    cancelDegreeFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_SET_CANCELL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 联盟设置加入的最小等级和战力
    setFamily = function(minLevel, minPower)
        local msg = { }
        msg.t = MsgCode.FAMILY_SET_RESTRI
        msg.v = MSGVER
        msg.c = { }
        msg.c.minLevel = minLevel
        msg.c.minPower = minPower
        return msg
    end,

    -- 修改联盟公告
    updateNoticeFamily = function(contentType, content)
        local msg = { }
        msg.t = MsgCode.FAMILY_NOTICE_EDIT
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = contentType
        msg.c.content = content
        return msg
    end,


    -- 退出联盟
    escFamily = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_MEMBER_ESC
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 家族成员给予联盟帮助
    setHelp = function(uid, roleUid)
        local msg = { }
        msg.t = MsgCode.FAMILY_SET_HELP
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.roleUid = roleUid
        return msg
    end,

    -- 一键帮助
    allHelp = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_HELP_ALL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 初始化双十一商店
    initElevenShop = function()
        local msg = { }
        msg.t = MsgCode.ELEVEN_SHOP
        msg.v = MSGVER
        return msg
    end,

    -- 兑换码协议
    sendExchangeCode = function(code)
        local msg = { }
        msg.t = MsgCode.EXCHANGE_ACTIVITY
        msg.v = MSGVER
        msg.c = { }
        msg.c.giftCode = code
        return msg
    end,

    -- 初始化商店
    initShop = function(shopId)
        local msg = { }
        msg.t = MsgCode.SHOP_INIT
        msg.v = MSGVER
        msg.c = { }
        msg.c.shopId = shopId
        return msg
    end,

    -- 购买物品
    shopBuy = function(shopId, defId, buyAmount, nowUse)
        local msg = { }
        msg.t = MsgCode.SHOP_BUY
        msg.v = MSGVER
        msg.c = { }
        msg.c.shopId = shopId
        -- 商店
        msg.c.defId = defId
        -- 物品defd
        msg.c.buyAmount = buyAmount 
        -- 物品数量
        msg.c.use = nowUse
        -- 购买并马上使用
        print("购买物品id".. defId .."商店id"..shopId .. "购买数量"..buyAmount)
        return msg
    end,

    -- 通用消息结构 用于只发一个消息ID text 可以没有
    commonMsg = function(mid, text)
        local msg = { }
        msg.t = mid
        msg.v = MSGVER
        msg.c = text or { }
        return msg
    end,


    -- 需要接收任务
    updateTask = function(taskId)
        local msg = { }
        msg.t = TASK_ACCEPT
        msg.v = MSGVER
        msg.c.taskId = taskId
        -- 任务配置id
        return msg
    end,

    -- 完成任务
    completedTask = function(taskDefId, quick)
        local msg = { }
        msg.t = MsgCode.TASK_COMPLETE
        msg.v = MSGVER
        msg.c = { }
        msg.c.taskDefId = taskDefId
        msg.c.quick = quick
        -- 任务配置id
        return msg
    end,
    delSoldier = function(defid, num)
        local msg = { }
        msg.t = MsgCode.MSG_CITY_SOLIDER_DEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.sid = defid
        msg.c.num = num
        return msg
    end,
    -- 领取礼包
    getPackage = function(packageId)
        local msg = { }
        msg.t = MsgCode.GET_PACKAGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.packageId = packageId
        -- 礼包id
        return msg
    end,
    -- 初始界面
    testBattleNet = function()
        local msg = { }
        msg.t = 6010
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = 1
        return msg
    end,

    -- 初始界面
    initBook = function(bookMenuId)
        local msg = { }
        msg.t = MsgCode.BOOK_INIT
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = bookMenuId or 1
        return msg
    end,
    -- 合成
    bookCompound = function(bookId, num)
        local msg = { }
        msg.t = MsgCode.BOOK_COMPOUND
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = bookId
        -- 合成图鉴id
        msg.c.num = num or 1
        -- 合成数量
        return msg
    end,
    bookCompoundLevel = function(uid)
        local msg = { }
        msg.t = MsgCode.BOOK_COMPOUND_LEVEL
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,
    
    -- 装备
    bookEquip = function(uid, index)
        local msg = { }
        msg.t = MsgCode.BOOK_EQUIP
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        msg.c.index = index
        -- 图鉴背包道具uid
        return msg
    end,
    -- 卸下
    bookUnEquip = function(uid)
        local msg = { }
        msg.t = MsgCode.BOOK_UN_EQUIP
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        -- 图鉴背包道具uid
        return msg
    end,

    -- 月卡信息
    monthInfo = function()
        local msg = { }
        msg.t = MsgCode.CHECK_MONTH
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 领取月卡/周卡礼包
    getMonth = function(id)
        local msg = { }
        msg.t = MsgCode.UPDATE_MONTH
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 购买钻石（充值）
    recharge = function(id)
        local msg = { }
        msg.t = MsgCode.RECHARGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 活动列表请求
    activityList = function(gp)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_LIST
        msg.v = MSGVER
        msg.c = { }
        msg.c.gp = gp
        -- 1为普通活动，2为充值活动
        return msg
    end,

    -- 活动详情界面请求
    activityDetail = function(id)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_INIT_VIEW
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 活动敌军详情界面请求
    activityResistEnemyDetail = function()
        local msg = { }
        msg.t = MsgCode.ACTIVITY_RESIST_ENEMY_DETAIL
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 更新活动详情里的数据
    updateActivityDetail = function(activityId, defid, typeid, count)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_UPDATE_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.activityId = activityId
        msg.c.defid = defid or 0
        msg.c.typeid = typeid or 0
        msg.c.num = count or 0
        return msg
    end,

    -- 充值返利充值成功更新充值返利界面详情
    updateRechargeRebate = function(defId)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_UPDATE_RECHARGEREBATE
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defId
        return msg
    end,

    -- 积分详情
    getVigourInfo = function()
        local msg = { }
        msg.t = MsgCode.ACTIVITY_VIGOUR_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    changeWonder = function(farmer, quick, index, defid)
        local msg = { }
        msg.t = MsgCode.WONDER_CHANGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.farmer = farmer
        msg.c.quick = quick
        msg.c.index = index
        msg.c.defid = defid
        return msg
    end,

    allianceLog = function()
        local msg = { }
        msg.t = MsgCode.ALLIANCE_LOG
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    chatMail = function(name, title, content)
        local msg = { }
        msg.t = MsgCode.CHAT_MAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        msg.c.title = title
        msg.c.content = content
        return msg
    end,

    unionMail = function(title, content)
        local msg = { }
        msg.t = MsgCode.UNION_MAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.title = title
        msg.c.content = content
        return msg
    end,

    lordRename = function(name)
        local msg = { }
        msg.t = MsgCode.LORD_RENAME
        msg.v = MSGVER
        msg.c = { }
        msg.c.name = name
        return msg
    end,

    getAllianceCd = function()
        local msg = { }
        msg.t = MsgCode.ALLIANCE_CD
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 排行榜
    rankList = function(RankType)
        local msg = { }
        msg.t = MsgCode.WORLD_RANK_LIST
        msg.v = MSGVER
        msg.c = { }
        msg.c.typeId = RankType
        -- 1 个人 2 联盟
        return msg
    end,
    -- 个人信息
    roleInfor = function(uid)
        local msg = { }
        msg.t = MsgCode.ROLE_VIEW_PLAYER_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,
    -- 个人信息
    rankallianceInfor = function(uid)
        local msg = { }
        msg.t = MsgCode.RANK_FAMILY_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,

    -- 新手引导上传
    uploadGuideIndex = function(index_,save)
        local msg = { }
        msg.t = MsgCode.UPLOAD_GUIDE_INDEX
        msg.v = MSGVER
        msg.c = { }
        msg.c.guideIndex = index_
        msg.c.nosave = save
        return msg
    end,

    -- 获取最近聊天记录
    getChatRecord = function()
        local msg = { }
        msg.t = MsgCode.GET_CHAT_RECORD
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 沦陷反叛捐资源
    revertCaptive = function(c)
        local msg = { }
        msg.t = MsgCode.FAMILY_CAPTIVE_REVERT
        msg.v = MSGVER
        msg.c = c
        return msg
    end,

    -- 沦陷信息
    getCaptiveInfo = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_CAPTIVE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 沦陷列表
    getCaptiveList = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_CAPTIVE_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    giveTech_Alliance = function(techId, resourceId, num)
        local msg = { }
        msg.t = MsgCode.FAMILY_TECH_GIVEN
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        msg.c.resourceId = resourceId
        msg.c.num = num
        return msg
    end,

    getFamily_Alliance = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_TECH
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    clearCoolDownTime = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_TECH_CLEAR_TIME
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    upgradeAllianceTech = function(techId, quick)
        local msg = { }
        msg.t = MsgCode.FAMILY_TECH_UPDATING
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        msg.c.quick = quick
        return msg
    end,

    speedUpAllianceTech = function(techId)
        local msg = { }
        msg.t = MsgCode.FAMILY_TECH_UPDATING_SPEED
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        return msg
    end,

    -- 请求联盟要塞列表
    getFortList = function()
        local msg = { }
        msg.t = MsgCode.FAMILY_FORT_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- //进入保护 3666
    RoleProtected = function()
        local msg = { }
        msg.t = MsgCode.ROLE_PROTECTED
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- //清除保护冷却 3667
    RoleCleanProtectedCountdonw = function()
        local msg = { }
        msg.t = MsgCode.ROLE_CLEAN_PROTECTED_COUNTDONW
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 取消保护 3668
    RoleCancelProtected = function()
        local msg = { }
        msg.t = MsgCode.ROLE_CANCEL_PROTECTED
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    RoleProtectedInfo = function()
        local msg = { }
        msg.t = MsgCode.ROLE_PROTECTED_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    CheckActivity_Limit_Reward = function(typeid)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_LIMIT_REWARDS
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = typeid
        return msg
    end,
    CheckActivity_ResistInvasion_Reward = function(typeid)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_RESISTINVASION_REWARDS
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = typeid
        return msg
    end,

    digoreJoin = function(id, isJoin)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_JOIN
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.reg = isJoin
        return msg
    end,
    digoreRank = function(groupId, typeId)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_RANK
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = groupId
        msg.c.typeId = typeId
        return msg
    end,
    digoreShow = function(id, page)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_SHOW
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.page = page
        return msg
    end,

    digoreDetail = function(id, index)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.page = 0
        msg.c.index = index
        return msg
    end,

    digoreExped = function(groupId, index, army, shipType)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_EXPED
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = groupId
        msg.c.army = army
        msg.c.shipType = shipType
        msg.c.index = index
        return msg
    end,

    digoreCallback = function(id)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_ARMY_CALLBACK
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    digoreCallbackQuick = function(id)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_ARMY_CALLBACK_QUICK
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    digoreTurnoverCaptain = function(groupId, oreIndex, posIndex)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_DIGORE_TURNOVER_CAPTAIN
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = groupId
        msg.c.index = oreIndex
        msg.c.leaderIndex = posIndex
        return msg
    end,

    worldHeroActivition = function(heroBookId, defId)
        -- heroBookId：图鉴id， defId:图鉴类型id
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_ACTIVITION
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defId
        msg.c.heroBookId = heroBookId
        return msg
    end,

    worldHeroUpgrade = function(heroId, autoUpgrade, autoBuy)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_UPGRADE
        msg.v = MSGVER
        msg.c = { }
        msg.c.heroBookId = heroId
        msg.c.voluntarily = autoUpgrade
        -- 是否自动进阶
        msg.c.autoBuy = autoBuy
        -- 是否自动购买材料
        return msg
    end,

    worldHeroIdentifyList = function()
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_IDENTIFY_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    worldHeroDetail = function(heroBookId)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_UPGRADE_DETIAL
        msg.v = MSGVER
        msg.c = { }
        msg.c.heroBookId = heroBookId
        return msg
    end,

    worldHeroExchange = function(buyId, sellId, number)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_EXCHANGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.buyId = buyId
        msg.c.sellId = sellId
        msg.c.number = number
        return msg
    end,

    worldUseSkill = function(skillId)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_USE_SKILL
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = skillId
        return msg
    end,

    hero_exchange = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_SHENJIANG_DUIHUAN
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,
    worldSkillList = function()
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_HERO_SKILL_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    --  名将招募列表
    worldHeroSoldier = function()
        local msg = { }
        msg.t = MsgCode.WORLF_FORT_HERO_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    --  招募奇迹兵列表
    worldSoldierRecurit = function(ptype)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_RECURIT_SOLDIER
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = ptype
        return msg
    end,
    --  刷新招募奇迹兵
    worldSoldierUpdata = function(ptype)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_SOLDIER_UPDATA
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = ptype
        return msg
    end,
    -- 更新称号
    updateUserTitle = function(tid)
        local msg = { }
        msg.t = MsgCode.UPDATE_ROLE_TITLE
        msg.v = MSGVER
        msg.c = { }
        msg.c.title = tid
        return msg
    end,
    --  招募奇迹兵
    worldSoldierBuy = function(ptype, index)
        local msg = { }
        msg.t = MsgCode.WORLD_FORT_SOLDIER_BUY
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = ptype
        msg.c.index = index
        return msg
    end,

    -- 推广详情
    Popularize_Info_Data = function()
        local msg = { }
        msg.t = MsgCode.POPULARIZE_ONFO_DATA
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 推广跳转时间
    Popularize_Skip_Time = function(id, aspect)
        local msg = { }
        msg.t = MsgCode.POPULARIZE_SKIP_TIME
        msg.v = MSGVER
        msg.c = { }
        msg.c.promotionId = id
        msg.c.aspect = aspect
        -- 0:跳出 1:进入
        return msg
    end,

    -- 推广领取奖励
    Popularize_Draw_Rewards = function(id)
        local msg = { }
        msg.t = MsgCode.POPULARIZE_DRAW_REWARDS
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 领取红包
    Hongbao_Clicked = function(clickGift)
        local msg = { }
        msg.t = MsgCode.REDBAO_CLICK
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = user.hongBao_ID
        msg.c.gift = clickGift or 0
        return msg
    end,
    -- 本期跨服对战
    Cross_Fight_Record = function()
        local msg = { }
        msg.t = MsgCode.CROSS_SEVER_FIGHT_RECORD
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 本期跨服对战
    Cross_Promotion_List = function()
        local msg = { }
        msg.t = MsgCode.CROSS_SEVER_PROMOTION_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 退出跨服对战
    Cross_Sever_onExit = function()
        local msg = { }
        msg.t = MsgCode.CROSS_SEVER_ONEXIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 退出跨服对战
    Cross_Sever_Score_Rank = function(RankType)
        local msg = { }
        msg.t = MsgCode.CROSS_SEVER_SCORE_RANK
        msg.v = MSGVER
        msg.c = { }
        msg.c.typeId = RankType
        return msg
    end,
    -- 跨服奖励
    Cross_Sever_Reward = function(typeid, stp)
        local msg = { }
        msg.t = MsgCode.CROSS_SEVER_REWARD
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = typeid
        msg.c.stp = stp
        return msg
    end,
    -- 阵营聊天
    Camp_Chat_Info = function(text)
        local msg = { }
        msg.t = MsgCode.CAMOP_CHAT_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.c = text
        return msg
    end,
    -- 跨服聊天
    Cross_Chat_Info = function(text)
        local msg = { }
        msg.t = MsgCode.CROSS_CHAT_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.c = text
        return msg
    end,
    -- 跨服聊天记录
    Cross_Chat_Record = function()
        local msg = { }
        msg.t = MsgCode.CROSS_CHAT_RECORD
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 全服喇叭聊天
    Cross_Chat_Trumpet = function(type_, content)
        local msg = { }
        msg.t = MsgCode.CROSS_CHAT_TRUMPET
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = type_
        msg.c.content = content
        return msg
    end,

    -- 周签到活动签到
    Weeky_Sign = function()
        local msg = { }
        msg.t = MsgCode.WEEKY_SIGN
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 周签到活动奖励领取
    Weeky_Sign_Reward = function(weekId, extra)
        local msg = { }
        msg.t = MsgCode.WEEKY_SIGN_REWARD
        msg.v = MSGVER
        msg.c = { }
        msg.c.weekId = weekId
        msg.c.extra = extra
        return msg
    end,
    getVipDayGift = function()
        local msg = { }
        msg.t = MsgCode.VIP_DAY_GIFT
        msg.v = MSGVER
        msg.c = { }

        return msg
    end,
    buyVipDayGift = function(level, t)
        local msg = { }
        msg.t = MsgCode.VIP_DAY_BUY
        msg.v = MSGVER
        msg.c = { }
        msg.c.vip = level
        msg.c.daily = t
        return msg
    end,

    -- 武勋积分兑换
    Medal_Exchange = function(defId)
        local msg = { }
        msg.t = MsgCode.ACTIVITY_MEDAL_EXCHANGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.defId = defId
        return msg
    end,
    -- 符文守卫查找
    Rune_find_guard = function(level, type, x, y)
        local msg = { }
        msg.t = MsgCode.MSG_RUNE_FIND_GUARD
        msg.v = MSGVER
        msg.c = { }
        msg.c.level = level
        msg.c.type = type
        msg.c.x = x
        msg.c.y = y
        return msg
    end,
    -- 符文守卫查查找初始化
    Rune_find_guard_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_RUNE_FIND_GUARD_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 符文初始化
    Rune_info = function()
        local msg = { }
        msg.t = MsgCode.RUNE_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 符文背包
    Rune_backpack = function()
        local msg = { }
        msg.t = MsgCode.RUNE_BACKPACK
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 装备/卸载符文
    -- @param index(int): 要装备的符文框下标id
    -- @param nid(int): 装备的符文id  nid为0 表示卸下, 其他表示装备的符文id
    Rune_equip = function(index, nid, plan)
        local msg = { }
        msg.t = MsgCode.RUNE_EQUIP
        msg.v = MSGVER
        msg.c = { index = index, nid = nid, plan = plan }
        return msg
    end,

    Rune_awaken = function(runeId, target)
        local msg = { }
        msg.t = MsgCode.RUNE_AWAKEN_REQUEST
        msg.v = MSGVER
        msg.c = { runeId = runeId, target = target }
        return msg
    end,

    Rune_skill_reset = function(runeId, usePayGem)
        local msg = { }
        msg.t = MsgCode.RUNE_SKILL_RESET
        msg.v = MSGVER
        msg.c = { runeId = runeId, usePayGem = usePayGem }
        return msg
    end,
    Rune_skill_replace = function(runeId)
        local msg = { }
        msg.t = MsgCode.RUNE_SKILL_REPLACE
        msg.v = MSGVER
        msg.c = { runeId = runeId }
        return msg
    end,

    -- 符文方案激活
    Rune_case_active = function(plan)
        local msg = { }
        msg.t = MsgCode.RUNE_CASE_ACTIVE
        msg.v = MSGVER
        msg.c = { plan = plan }
        return msg
    end,

    -- 符文方案特性
    Rune_case_feature = function(plan)
        local msg = { }
        msg.t = MsgCode.RUNE_CASE_FEATURE
        msg.v = MSGVER
        msg.c = { plan = plan }
        return msg
    end,
    msg_statistics = function()
        local msg = { }
        msg.t = MsgCode.MSG_STATISTICS
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 符文强化
    -- @param soleId(int): 要强化的符文唯一id
    Rune_strength = function(soleId)
        local msg = { }
        msg.t = MsgCode.RUNE_STRENGTH
        msg.v = MSGVER
        msg.c = { id = soleId }
        return msg
    end,

    -- 圣物洗练
    -- @param soleId(int): 要强化的符文唯一id
    Rune_xl = function(soleId, batch, want, lock)
        local msg = { }
        msg.t = MsgCode.MSG_RUNE_XL
        msg.v = MSGVER
        msg.c = { id = soleId, batch = batch, want = want, lock = lock }
        return msg
    end,

    -- 圣物洗练-替换
    -- @param soleId(int): 要强化的符文唯一id
    Rune_xl_expect = function(soleId, index)
        local msg = { }
        msg.t = MsgCode.MSG_RUNE_XL_EXPECT
        msg.v = MSGVER
        msg.c = { id = soleId, index = index }
        return msg
    end,

    -- 获取圣物洗练结果
    -- @param soleId(int): 要强化的符文唯一id
    Rune_xl_expect_result = function(soleId)
        local msg = { }
        msg.t = MsgCode.MSG_RUNE_XL_EXPECT_RESULT
        msg.v = MSGVER
        msg.c = { id = soleId }
        return msg
    end,

    -- 圣器解锁或锁定
    -- @param soleId(int): 要强化的符文唯一id
    Rune_lock = function(soleId)
        local msg = { }
        msg.t = MsgCode.RUNE_LOCK
        msg.v = MSGVER
        msg.c = { id = soleId }
        return msg
    end,
    -- 符文合成
    -- @param target(int): 合成的符文配置id
    -- @param ids(int []): 选择的符文唯一id列表
    Rune_compound = function(target, ids)
        local msg = { }
        msg.t = MsgCode.RUNE_COMPOUND
        msg.v = MSGVER
        local idsStr = table.concat(ids, ":")
        msg.c = { target = target, ids = idsStr }
        return msg
    end,
    -- 符文合成概率
    -- @param target(int): 合成的符文配置id
    -- @param ids(int []): 选择的符文唯一id列表
    Rune_probability = function(target, ids)
        local msg = { }
        msg.t = MsgCode.RUNE_PROBABILITY
        msg.v = MSGVER
        local idsStr = table.concat(ids, ":")
        msg.c = { target = target, ids = idsStr }
        return msg
    end,
    -- 符文分解
    -- @param soleId(int): 要分解的符文id
    Rune_resolve = function(soleId, star)
        local msg = { }
        msg.t = MsgCode.RUNE_RESOLVE
        msg.v = MSGVER
        msg.c = { id = soleId, star = star }
        return msg
    end,
    --
    -- @param soleId(int):
    Rune_search_left_list = function()
        local msg = { }
        msg.t = MsgCode.RUNE_SEARCH_LEFT_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    --
    -- @param soleId(int):
    Rune_search_request = function(type, id, single)
        local msg = { }
        msg.t = MsgCode.RUNE_SEARCH_REQUEST
        msg.v = MSGVER
        msg.c = { type = type, id = id, single = single }
        return msg
    end,

    --
    -- @param soleId(int):
    Rune_search_right_data = function(id)
        local msg = { }
        msg.t = MsgCode.RUNE_SEARCH_RIGHT_INIT
        msg.v = MSGVER
        msg.c = { id = id }
        return msg
    end,
    --
    -- @param soleId(int):
    Rune_handbook_active = function()
        local msg = { }
        msg.t = MsgCode.RUNE_HANDBOOK_ACTIVE
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    --
    -- @param soleId(int):
    Rune_texin_redpoint_remove = function(plan)
        local msg = { }
        msg.t = MsgCode.RUNE_TEXIN_REDPOINT_REMOVE
        msg.v = MSGVER
        msg.c = { plan = plan }
        return msg
    end,

    -- 道具合成
    -- @param id(int): 要合成的道具配置id
    -- @param num(int): 合成的数量
    Prop_compound = function(id, num)
        local msg = { }
        msg.t = MsgCode.BOX_REMAKE
        msg.v = MSGVER
        msg.c = { id = id, num = num }
        return msg
    end,

    -- 道具合成
    -- @param id(int): 要合成的道具配置id
    -- @param num(int): 合成的数量
    Prop_compound_style = function(srcId, num, destId)
        local msg = { }
        msg.t = MsgCode.RUNE_COMPOUND_STYLE
        msg.v = MSGVER
        msg.c = { id = srcId, num = num, tid = destId }
        return msg
    end,

    -- 科技升级
    Ship_Tech_up = function(type, order, itemType, itemNum)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_TECH_UP
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = type
        msg.c.order = order
        msg.c.itemType = itemType
        msg.c.itemNum = itemNum
        return msg
    end,
    -- 初始化战舰
    warShip_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_WARSHIP_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 打造战舰
    -- @param shipType 战舰类型
    Ship_create = function(shipType)
        local msg = { }
        msg.t = MsgCode.MSG_WARSHIP_BUILD
        msg.v = MSGVER
        msg.c = { type = shipType }
        return msg
    end,
    -- 恢复耐久
    Ship_restore = function(shipType, restoreNum, bRes)
        local msg = { }
        msg.t = MsgCode.MSG_WARSHIP_FILL_FIRE
        msg.v = MSGVER
        msg.c = {
            type = shipType,
            num = restoreNum,
            resource = bRes
        }
        return msg
    end,
    -- 战舰升级
    Ship_upgrade = function(shipType)
        local msg = { }
        msg.t = MsgCode.MSG_WARSHIP_UPGRADE
        msg.v = MSGVER
        msg.c = {
            type = shipType
        }
        return msg
    end,
    -- 设置守城和取消守城
    Ship_status = function(shipType, shipStatus)
        local msg = { }
        msg.t = MsgCode.MSG_WARSHIP_STATUS
        msg.v = MSGVER
        msg.c = {
            type = shipType,
            status = shipStatus
        }
        return msg
    end,
    -- 战舰技能升级
    Ship_skill_update = function(shipType, skillId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_SKILL_UPGRADE
        msg.v = MSGVER
        msg.c = {
            type = shipType,
            skillId = skillId
        }
        return msg
    end,
    Ship_exp_buy = function(shipType, itemId, itemNum)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXP_BUY
        msg.v = MSGVER
        msg.c = {
            type = shipType,
            defId = itemId,
            num = itemNum,
        }
        return msg
    end,
    userCityBuffItem = function(defid)
        local msg = { }
        msg.t = MsgCode.USE_CITY_BUFF_ITEM
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = defid
        return msg
    end,

    -- 远征任务初始化
    ship_expedition_init = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXPEDITION_INIT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,
    -- 刷新远征任务
    ship_expedition_refresh = function()
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXPEDITION_REFRESH
        msg.v = MSGVER
        msg.c = {
        }
        return msg
    end,
    -- 远征
    ship_expedition = function(taskId, shipType)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXPEDITION
        msg.v = MSGVER
        msg.c = {
            id = taskId,
            type = shipType
        }
        return msg
    end,
    -- 远征召回
    ship_expedition_cancel = function(taskId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXPEDITION_CANCEL
        msg.v = MSGVER
        msg.c = {
            id = taskId,
        }
        return msg
    end,
    -- 远征任务奖励领取
    ship_expedition_reward = function(taskId)
        local msg = { }
        msg.t = MsgCode.NSG_SHIP_EXPEDITION_REWARD
        msg.v = MSGVER
        msg.c = {
            id = taskId,
        }
        return msg
    end,
    -- 远征加速
    ship_expedition_speed = function(taskId)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_EXPEDITION_SPEED
        msg.v = MSGVER
        msg.c = {
            id = taskId,
        }
        return msg
    end,

    -- 红点移除
    remove_red_point = function(id)
        local msg = { }
        msg.t = MsgCode.MSG_RED_POINT_REMOVE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 放逐轮陷的领地
    Lord_exile = function(uid)
        local msg = { }
        msg.t = MsgCode.MSG_EXILE
        msg.v = MSGVER
        msg.c = { }
        msg.c.uid = uid
        return msg
    end,

    -- 放逐轮陷的领地
    Ship_overfull = function(shipType)
        local msg = { }
        msg.t = MsgCode.MSG_SHIP_OVERFULL
        msg.v = MSGVER
        msg.c = { }
        msg.c.type = shipType
        return msg
    end,

    -- 英雄试炼 首页排行数据
    HeroLevel_indexdata = function()
        local msg = { }
        msg.t = MsgCode.MSG_HEROLEVEL_INDEXDATA
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 英雄试炼 征服数据
    HeroLevel_conquer = function()
        local msg = { }
        msg.t = MsgCode.MSG_HEROLEVEL_CONQUER
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 英雄试炼 扫荡数据
    HeroLevel_saodang = function()
        local msg = { }
        msg.t = MsgCode.MSG_HEROLEVEL_SAODANG_RESULT
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 联盟科技研究加速
    alliance_tech_speed_up = function(techId, resourceId, num)
        local msg = { }
        msg.t = MsgCode.ALLIANCE_TECH_SPEED_UP
        msg.v = MSGVER
        msg.c = { }
        msg.c.techId = techId
        msg.c.rid = resourceId
        msg.c.rAmount = num
        return msg
    end,

    -- 更换头像
    change_head = function(id)
        local msg = { }
        msg.t = MsgCode.CHANGE_HEAD
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 更换形象
    change_lord_head = function(id)
        local msg = { }
        msg.t = MsgCode.CHANGE_LORD_IMAGE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 获取头像列表
    get_head_list = function()
        local msg = { }
        msg.t = MsgCode.GET_HEAD_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 获取领主形象列表
    get_lord_image_list = function()
        local msg = { }
        msg.t = MsgCode.GET_LORD_IMAGE_LIST
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 获取跨服争霸活动信息
    get_pvp_info = function(id)
        local msg = { }
        msg.t = MsgCode.PVP_INFO
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.history = PvpMainView.isHistory
        return msg
    end,

    -- 跨服争霸报名
    sign_up_pvp = function(id)
        local msg = { }
        msg.t = MsgCode.PVP_SIGN_UP
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 跨服争霸军队部署
    set_pvp_formation = function(c)
        local msg = { }
        msg.t = MsgCode.PVP_FORMATION_SET
        msg.v = MSGVER
        msg.c = c
        return msg
    end,

    -- 获取跨服争霸军队部署信息
    get_pvp_formation_info = function()
        local msg = { }
        msg.t = MsgCode.PVP_FORMATION_INFO
        msg.v = MSGVER
        msg.c = { }
        return msg
    end,

    -- 跨服争霸队伍互换
    exchange_pvp_formation = function(a, b)
        local msg = { }
        msg.t = MsgCode.PVP_FORMATION_EXCHANGE
        msg.v = MSGVER
        msg.c = {ida = a, idb = b}
        return msg
    end,

    -- 跨服争霸海选记录
    get_pvp_preselection_record = function()
        local msg = { }
        msg.t = MsgCode.PVP_PRESELECTION_RECORD
        msg.v = MSGVER
        msg.c = {}
        msg.c.history = PvpMainView.isHistory
        return msg
    end,

    -- 跨服争霸玩家个人战报
    get_pvp_personal_war_report = function()
        local msg = { }
        msg.t = MsgCode.PVP_PERSONAL_WAR_REPORT
        msg.v = MSGVER
        msg.c = { }
        msg.c.history = PvpMainView.isHistory
        return msg
    end,

    -- 跨服争霸战报详情
    get_pvp_war_report_detail = function(id, index)
        local msg = { }
        msg.t = MsgCode.PVP_WAR_REPORT_DETAIL
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.index = index
        return msg
    end,

    -- 跨服争霸下注
    pvp_bet = function(group, id, index, num)
        local msg = { }
        msg.t = MsgCode.PVP_BET
        msg.v = MSGVER
        msg.c = { }
        msg.c.group = group
        msg.c.id = id
        msg.c.index = index
        msg.c.num = num
        return msg
    end,

    -- 跨服争霸一组玩家战报
    get_pvp_two_player_war_report = function(id)
        local msg = { }
        msg.t = MsgCode.PVP_TWO_PLAYER_WAR_REPORT
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        return msg
    end,

    -- 跨服争霸详细赛程
    get_pvp_detial_schedule = function(id)
        local msg = { }
        msg.t = MsgCode.PVP_DETAIL_SCHEDULE
        msg.v = MSGVER
        msg.c = { }
        msg.c.id = id
        msg.c.history = PvpMainView.isHistory
        return msg
    end,
}

-- 判断是否是需要的MSG
function checkMsg(t, id)
    if t and t == id then
        return true
    end
    return false
end
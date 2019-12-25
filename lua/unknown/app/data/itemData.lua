BaseDefData = class("BaseDefData")
BaseDefData.__index = BaseDefData
function BaseDefData:ctor(defid, type)
    --    print("BaseDefData:ctor()")
    -- 配置id
    self.defid = defid
    self.type = type

    --    print("BaseDefData:ctor ====   self.type = "..self.type.."  self.dedid = "..self.defid)
end
function BaseDefData:getDef()
    if (self.def == nil) then
        self.def = cfg[self.type][self.defid]
    end
    return self.def
end
function BaseDefData:setDefId(defid)
    self.defid = defid
    self.def = nil
end
function BaseDefData:getNextLevelDef()
    return cfg[CfgType.BUILDING][self:getDef().nextlvid]
end
-- 建筑
BuildIngData = class("BuildIngData", BaseDefData)
function BuildIngData:ctor(index, defid, data, farmer)
    super(self, defid, CfgType.BUILDING)
    -- 位置ID range*1000+id
    self.index = index
    self.data = data
    self.worker = farmer or 0
    return self
end
-- 获取下级DEF

-- 建筑建造&升级
BuildIngStructData = class("BuildIngStructData", BaseDefData)
function BuildIngStructData:ctor(index, defid, countdown, upLevel, farmer)
    super(self, defid, CfgType.BUILDING)
    self.index = index
    self.countdown = countdown
    self.upLevel = upLevel
    self.builder = farmer or 0
    -- 接收数据时间
    self.recvTime = me.sysTime()
    return self
end

-- 道具
EtcItemData = class("EtcItemData", BaseDefData)
function EtcItemData:ctor(uid, defid, count, locValue, locData, remateTime, savePrev)
    super(self, defid, CfgType.ETC)
    self.uid = uid
    if savePrev == true then
        for key, var in pairs(user.pkg) do
            if var:getDef().id == defid then
                self.prevCount = var.count
            end
        end
    end
    self.count = count
    self.locValue = locValue
    self.locData = locData
    self.remateTime = remateTime
    return self
end
ShopItemData = class("ShopItemData", BaseDefData)
function ShopItemData:ctor(pro)
    super(self, pro.itemDefId, CfgType.ETC)   
    -- 道具类型
    --self.sellType = sellType
    -- 出售类型 1钻石 2礼券 3兑换 4贡献 5 元宝
    --self.price = price
    for key, var in pairs(pro) do
        self[key] = var
    end    
    self.uid = pro.id
    return self
end
function ShopItemData:getCurrencyNum()
    if self.sellType == 1 then        
        return user.diamond       
    elseif self.sellType == 2 then
        return (user.allianceGivenData.gongxian or 0)
    elseif self.sellType == 3 then
    elseif self.sellType == 4 then
    elseif self.sellType == 5 then  
         return  user.paygem         
    end
end
function ShopItemData:checkHaveEnough()
    local ret = false
    if self.sellType == 1 then        
        ret =  tonumber( self.price ) <= user.diamond
        if ret == false then
             askToRechage(0)
        end
        return ret
    elseif self.sellType == 2 then
        return tonumber( self.price ) <= (user.allianceGivenData.gongxian or 0)
    elseif self.sellType == 3 then
    elseif self.sellType == 4 then
        return self.price[2] <= getItemNum(self.price[1])
    elseif self.sellType == 5 then  
         ret = tonumber( self.price ) <= user.paygem
         if ret == false then
            askToRechage(1)
         end
        return ret
    elseif self.sellType == 6 then  
        ret = tonumber( self.price ) <= user.turnplateScore
        return ret
    end
end
function ShopItemData:getCurrencyIcon()
    if self.sellType == 1 then
        return "gongyong_tubiao_zuanshi.png"
    elseif self.sellType == 2 then
        return "ziyuan_anniu_gongxianzhi.png"
    elseif self.sellType == 3 then
    elseif self.sellType == 4 then
        return getItemIcon(self.price[1])
    elseif self.sellType == 5 then  
        return "yuanbao.png"
    elseif self.sellType == 6 then 
        return "turnplateScore.png"
    end
end
--[Comment]
--城市皮肤
skinData = class("skinData")
skinData.__index = skinData
m_skinData = nil
function skinData:ctor(id,defid)
    print("skinData:ctor()")      
    self.id = id
    self.defid  = defid
    self.status = -1
end
function skinData:getDef()
    return cfg[CfgType.SKIN_STRENGTHEN][self.defid]
end
--随机资源点
CityRandResource=class("CityRandResource",BaseDefData)
function CityRandResource:ctor(defid,place,value,work,outValue)
    super(self,defid,CfgType.CITY_RAND_RESOURCE)
    self.place = place
    -- 所在地
    self.value = value
    -- 已经采集数量
    self.work = work
    -- 是否在采集1,2采集,3采空
    self.outValue = outValue
    -- 可收获的

    self.def=cfg[CfgType.CITY_RAND_RESOURCE][defid]
    self.leftTime =(self.def.out - self.value) /(self.def.out / self.def.time)
    -- 单位时间产出
    self.startTime = me.sysTime()
    --print(self.leftTime.."======================="..self.place)
    return self
end
--生产农民数据
produceframerData = class("produceframerData")
produceframerData.__index = produceframerData
function produceframerData:ctor(num_,time_,ptime_)
    print("produceframerData:ctor()")
    self.num = num_
    self.time = time_
    self.ptime = ptime_
end

--伤兵数据
revertSoilderData = class("revertSoilderData")
revertSoilderData.__index = revertSoilderData
function revertSoilderData:ctor(sId_,num_,cur_)
    self.defId = sId_
    self.num=num_
    self.curNum = cur_ or 0
end

function revertSoilderData:getDef()
    if self.def == nil then
       self.def =  cfg[CfgType.CFG_SOLDIER][self.defId]
    end
    return self.def
end

--恢复伤兵数据
revertingData = class("revertingData")
revertingData.__index = revertingData
function revertingData:ctor(bid_,time_,ptime_,army_,ctype)
    self.bid = bid_
    -- 建筑id
    self.time = time_
    -- 总时间
    self.ptime = ptime_
    -- 已经走过的时间
    self.army = { }

    -- 接收数据时间
    self.recvTime = me.sysTime()

    -- 伤兵队列
    if ctype == 0 then
        for key, var in pairs(army_) do
            local s = user.desableSoldiers[var[1]]
            local totalNum = var[2]
            if s and s.num then
                totalNum = s.num
            end
            local soldierData=revertSoilderData.new(var[1],totalNum,var[2])
            self.army[var[1]] = soldierData
        end
    elseif ctype == 1 then
        for key, var in pairs(army_) do
        local s = user.desableSoldiers_c[var[1]]
        local totalNum = var[2]
        if s and s.num then
            totalNum = s.num
        end
        local soldierData=revertSoilderData.new(var[1],totalNum,var[2])
        self.army[var[1]] = soldierData
    end
    end
end

function revertingData:updateDate(defid_,totalNum_)
    if self.army[defid_] ~= nil then
        self.army[defid_].num = totalNum_
    end
end

--士兵数据
soldierData = class("soldierData")
soldierData.__index = soldierData
function soldierData:ctor(sId_,num_)
    self.defId = sId_
    self.num=num_
end

function soldierData:getDef()
    if self.def == nil then
       self.def =  cfg[CfgType.CFG_SOLDIER][self.defId]
    end
    return self.def
end

--训练数据
trainData = class("trainData")
trainData.__index = trainData
--如果训练的为农民就没有sid
function trainData:ctor(num_,time_,ptime_,bindex_,sid_,t)
    print("trainData:ctor()")
    self.num = num_
    self.time = time_
    -- 训练1个农民需要的总时间
    self.ptime = ptime_
    -- 训练当前农民已经走过的时间
    self.sid = sid_
    self.bindex = bindex_
    --1 士兵升级 0 是普通
    self.stype = t or 0

    self.recvTime = me.sysTime()
end
function trainData:getDef()
    if self.def == nil then
        self.def = cfg[CfgType.CFG_SOLDIER][self.sid]
    end
    return self.def
end
--训练界面数据数据
trainViewData = class("trainViewData")
trainViewData.__index = trainViewData
function trainViewData:ctor(bindex_,tnum_,list_, totalNum_,wonderMax,curWonder)
    print("trainViewData:ctor()")
    self.totalNum = totalNum_
    -- 训练总上限
    self.tnum = tnum_
    -- 最大训练数
    self.list = list_
    -- 已经解锁的
    self.bindex = bindex_
    -- 训练的建筑
    --最大奇迹兵
    self.wonderMax = wonderMax

    self.curWonder = curWonder
end


--邮件数据
mailData = class("mailData")
mailData.__index = mailData
function mailData:ctor(msg)
    print("mailData:ctor()")

    self.uid = msg.uid
    -- id
    self.roleuid = msg.roleUid or 0
    -- 人物id
    self.source = msg.source
    -- 发件人
    self.type = msg.type
    -- 1 消息 2系统消息 3战斗战报 4 侦查
    self.status = msg.status
    -- 状态 -1已经读取 -2 道具已经领取
    self.Property = msg.process
    -- 46 考古 41 探索 42 出征
    self.nvalue = msg.nvalue or 0
    -- 内容id
    self.time = msg.time
    -- 时间
    self.title = msg.title or ""
    -- 标题
    if(msg.type==3 )then
        local content=msg.content
        self.x=content.x
        self.y=content.y
        self.loseArmy = content.loseArmy
        -- 1 有损战斗 0 没有损失 -- 有损战斗下发
        self.win = content.win
        -- 1 为胜利 2为失败
        self.rType = content.rType
        -- 1侦察 2 被侦查 ， 1进攻 2 防御 ，3 集火进攻，4 集火防御
        self.attacker=mailBattleReportData.new(content.attacker,content.alv,content.atkCountry)
        self.defender=mailBattleReportData.new(content.defender,content.dlv,content.defCountry)
        self.name = content.nm
        -- 名字
        self.FighType = content.ft or 0
        -- 战斗类型 0 ：无 1：地块战斗 2：要塞战斗 3：主城战斗 4：据点战斗
        self.durable = content.zm or 0
        -- 耐久
        self.landLv = content.llv or 0
        -- 土地等级
        self.belong = content.tp or 0
        -- 归属变更 0：无 1：归属信息变更
        self.FightType = content.pt or 0
        -- 战斗状态 0：无 1：保护状态，未发生战斗，2：防御部队为0 未发生战斗
        self.atcNum = content.atcNum
        -- 进攻人数
        self.defNum = content.defNum
        -- 防御人数

    elseif (msg.type== 2 ) then
        self.itemList = msg.item
        self.content = msg.content
    else
        self.content = msg.content
        -- 内容
    end
end

mailBattleReportData = class("mailBattleReportData")
mailBattleReportData.__index = mailBattleReportData
function mailBattleReportData:ctor(name,lv, wenming)
    print("mailBattleReportData:ctor()")
    self.name = name
    -- id
    self.lv = lv
    -- 等级
    self.wenming = wenming
    -- 文明
end

--家族数据
familyData = class("familyData")
familyData.__index = familyData
function familyData:ctor(uid,exp,level,ownerName,name,power,memberNumber,maxMember,levelExp,notice,minLevel,minPower,recruit,appalyStatus)
    print("familyData:ctor()")
    self.uid = uid
    -- id
    self.exp = exp
    -- 家族经验
    self.level = level
    -- 家族等级
    self.ownerName = ownerName
    -- 家族族长名字
    self.name = name
    --简称
    self.shortname = nil
    -- 家族名字
    self.power = power
    -- 家族战力
    self.memberNumber = memberNumber
    -- 家族成员人数
    self.maxMember = maxMember
    -- 家族最大成员数
    self.levelExp = levelExp
    -- 下一等级需要经验
	self.notice = notice
	self.minLevel = minLevel
	self.minPower = minPower
    self.recruit = recruit
    -- 招募状态
    self.appalyStatus = appalyStatus
end

--家族成员数据
familyMemberData = class("familyMemberData")
familyMemberData.__index = familyMemberData
function familyMemberData:ctor(uid,level,name,power,helpNumber,maxHelp,degree,lastlogout,x,y,contribution,status)
    print("familyMemberData:ctor()")
    self.uid = uid
    -- id
    self.level = level
    -- 成员等级
    self.name = name
    -- 成员名字
    self.power = power
    -- 成员战斗力
    self.helpNumber = helpNumber
    -- 成员对家族的帮组次数
    self.maxHelp = maxHelp
    -- 每天可以帮助的总次数
    self.degree = degree
    -- 在联盟的身份  1-族长，2-副族长，3-官员，4-平民
	self.x = x
	self.y = y
    self.offlineTime = lastlogout or 0
    -- 离线时间
	self.contribution = contribution
    self.inviteStatus = status
    -- 邀请状态
end
--家族成员数据
familyInviteData = class("familyInviteData")
familyInviteData.__index = familyInviteData
function familyInviteData:ctor(uid,level,name,power,x,y)
    print("familyInviteData:ctor()")
    self.uid = uid
    -- id
    self.level = level
    -- 成员等级
    self.name = name
    -- 成员名字
    self.power = power
    -- 成员战斗力
	self.x = x
	self.y = y

end
--联盟帮助数据
familyHelpData = class("familyHelpData")
familyHelpData.__index = familyHelpData
function familyHelpData:ctor(uid,defId,roleUid,name,helpNumber,countHelpNumber,ptype)
    print("familyHelpData:ctor()")
    self.uid = uid
    -- 建筑ID
    self.defId = defId
    -- 建筑配置ID
    self.roleUid = roleUid
    -- 请求帮助的角色ID
    self.name = name
    -- 请求帮助的领主名字
    self.ptype = ptype
    -- 类型 1升级 2建设 3恢复伤兵
    self.helpNumber = helpNumber
    -- 已帮助次数
    self.countHelpNumber = countHelpNumber
    -- 成员每条帮助需要的总帮助次数
end

--请求过帮助的建筑id和建筑配置id
familyHelpBid = class("familyHelpBid")
familyHelpBid.__index = familyHelpBid
function familyHelpBid:ctor(bid,defId)
    print("familyHelpBid:ctor()")
    self.bid = bid
    -- 建筑ID
    self.defId = defId
    -- 建筑配置ID
end

--[[
    local alertUid=msg.c.uid --警示的uid
    local name=msg.c.name --攻击者名字
    local family=msg.c.family --攻击者帮会 有可能为空
    local time=msg.c.time --发起时间
    local ox=msg.c.ox --源x
    local oy=msg.c.oy --源y
    local x=msg.c.x --目标x
    local y=msg.c.y --目标y
    local status=msg.c.status --状态 50为侦察 88：被联盟集火 其它为进攻  2000挖矿被攻击
    local city=msg.c.city --不是城市时为空
    local countTime=msg.c.countTime --到达时间
]]
warningData = class("warningData")
warningData.__index = warningData
function warningData:ctor(uid_,name_,family_,time_,ox_,oy_,x_,y_,status_,city_,countTime_, osTime_, shorName)
    print("warningData:ctor()")
    self.uid = uid_
    self.name = name_
    self.family = family_
    self.time = time_
    self.ox = ox_
    self.oy = oy_
    self.x = x_
    self.y = y_
    self.status = status_
    self.city = city_
    self.countTime = countTime_
    self.curTimeIndex = osTime_
    self.shorName = shorName
    -- 当前系统时间
end

--任务数据
taskData = class("taskData",BaseDefData)
taskData.acceptAble = 1
taskData.running = 2
taskData.completeAble = 3
taskData.completed = 4
function taskData:ctor(id,defId,progress,item,value,count,awards,quick)
    print("taskData:ctor()")
    super(self,defId,CfgType.TASK_LIST)
    self.id = id
    -- 任务id
    self.progress = progress
    -- 任务状态  display_none--1  display-0  running-1  acceptAble-2  completeAble-3  completed-4
    self.item = item
    -- 需要完成的任务条件
    self.value = value
    -- 完成进度
    self.count = count
    -- 需要完成的数量
    self.awards = awards
    -- 日常任务快速完成
    self.quick = quick
    -- 任务奖励
    self.ptime = me.sysTime()
    -- 时间
    self.sortIndex = 1
    if self.progress == 3 then --已完成
        self.sortIndex = 99999
    else
        self.sortIndex = self:getDef().sortid
    end
    -- 排序索引 (3:已完成的任务，2：日常任务，1：默认值)
    -- return self
end
--礼包数据
packageData = class("packageData")
packageData.__index = packageData
function packageData:ctor(id,status,award,times)
	 print("packageData:ctor()")
    self.id = id
    -- 礼包id
    self.status = status
    -- 礼包状态 3-倒计时中，4-可领取
    self.award = award
    -- 奖励道具
    self.times = times
    -- 等待时间
    self.revtime = me.sysTime()
    -- 收到时间
end

--充值项数据
rechargeData = class("rechargeData")
rechargeData.__index = rechargeData
function rechargeData:ctor(data)
    print("rechargeData:ctor()")
    for key, var in pairs(data) do
        self[key] = var
    end     
end

--月卡/周卡数据
monthWeekData = class("monthWeekData")
monthWeekData.__index = monthWeekData
function monthWeekData:ctor(data)
	 print("monthWeekData:ctor()")
    self.content = data.content
    -- 描述文字
    self.day = data.day
    -- 当前天数
    self.id = data.id
    -- id号
    self.items = data.items
    -- 月卡奖励
    self.limit = data.limit
    -- 限购次数
    self.rnm = data.rnm
    -- 已购买的次数
    self.status = data.status
    -- 领取状态（-1，没有购买，0：可领取，1：已领取）
    self.title = data.title
    -- 标题
    self.total = data.total
    --  总天数
    self.type = data.type
    -- 月卡/周卡类型 1周卡，2月卡
    self.data = data.data
    -- 客户端自定义预留
end


--服务器列表cell数据
servserData = class("servserData")
servserData.__index = servserData
function servserData:ctor(sid,ip,name,status,state,desc)
    self.sid = sid
    -- 服务器uid
    self.ip = ip
    -- 服务器ip
    self.name = name
    -- 服务器名字
    self.status = status
    -- 服务器类型 (1：新服，2：推荐服，3：推荐和新服)
    self.state = state or 0
    -- 服务器状态 （1 正常，2，拥挤，3，爆满。0，维护,4已满,5即将开放）
 
   self.desc = desc or ""
   --服务器描述，包括即将开放时间等
   
end


--图册信息
bookAltasData = class("bookAltasData")
bookAltasData.__index = bookAltasData
function bookAltasData:ctor(id,OpenStaus)
    self.id = id
    -- 图册id
    self.status = OpenStaus
    -- 图册开启状态
end

--新军礼包信息
novicePackData = class("novicePackData")
novicePackData.__index = novicePackData
function novicePackData:ctor(price,items,activityId,time,status)
    self.price = price
    -- 购买礼包需钻石数量
    self.items = items
    -- 礼包奖励道具
    self.activityId = activityId
    -- 活动id号
    self.time = time
    -- 剩余时间
    self.startTime = me.sysTime()
    -- 时间戳
    self.status = status
end

--7日登录信息
seventhPackData = class("seventhPackData")
seventhPackData.__index = seventhPackData
function seventhPackData:ctor(list,activityId)
    self.list = list
    -- 7日登录奖励数据
    self.activityId = activityId
    -- 活动id号
end

--首充奖励
FirstChargeAwardData = class("FirstChargeAwardData")
FirstChargeAwardData.__index = FirstChargeAwardData
function FirstChargeAwardData:ctor(activityId,items,status)
    self.activityId = activityId
    -- 活动ID
    self.items = items
    -- 礼包奖励道具
    self.status = status
    -- 领取状态
end

--签到
SignAwardData = class("SignAwardData")
SignAwardData.__index = SignAwardData
function SignAwardData:ctor(activityId,currentDay,items, openDate, endDate, isShowDate)
    self.activityId = activityId
    -- 活动ID
    self.currentDay = currentDay
    -- 登录第几天
    self.items = items
    -- 奖励道具

    self.openDate=openDate
    self.endDate=endDate
    self.isShowDate=isShowDate
end

--充值返利
RechargeRebateData = class("RechargeRebateData")
RechargeRebateData.__index = RechargeRebateData
function RechargeRebateData:ctor(activityId,startTime,closeTime,list)
    self.activityId = activityId
    -- 活动ID
    self.btnStatus = startTime
    -- 活动开启时间
    self.beginTime = closeTime
    -- 活动关闭时间
    self.endTime = list
    -- 礼包奖励道具
end

-- 盛宴数据
FreshMeatData = class("FreshMeatData")
FreshMeatData.__index = FreshMeatData
function FreshMeatData:ctor(activityId,open,power,list)
    self.activityId = activityId
    -- 活动ID
    self.open = open
    -- 按钮状态
    self.power = power
    -- 体力值
    self.dlist = list
    -- 盛宴时间表
end

--联盟攻城
AttackSHData = class("AttackSHData")
AttackSHData.__index = AttackSHData
function AttackSHData:ctor(activityId,startTime,closeTime,list)
    self.activityId = activityId
    -- 活动ID
    self.startTime = startTime
    -- 活动开启时间
    self.closeTime = closeTime
    -- 关闭时间
    self.list = list
    -- 奖品表
end

--基金奖励
FoundatonData = class("FoundatonData")
FoundatonData.__index = FoundatonData
function FoundatonData:ctor(activityId,chargeNum,chargeLimit,list,multiplying)
    self.activityId = activityId
    -- 活动ID
    self.chargeNum = chargeNum
    -- 充值总计
    self.chargeLimit = chargeLimit
    -- 充值定额
    self.dlist = list
    -- 领取表
    self.addDiamond = multiplying[1]
    self.addPercent = multiplying[2]
end

-- 掠夺天下
PlunderWorldData = class("PlunderWorldData")
PlunderWorldData.__index = PlunderWorldData
--day 活动时间 gls:已经领取过的item num:累计资源 list:奖励列表
function PlunderWorldData:ctor(activityId,day,gls,num,list)
    self.activityId = activityId
    -- 活动ID
    self.cd = day
    self.startTime = me.sysTime()
    self.gls = gls
    self.num = num
    self.list = list
end

-- 限时活动礼包(开启)
timeLimitDetailData = class("timeLimitDetailData")
timeLimitDetailData.__index = timeLimitDetailData
function timeLimitDetailData:ctor(activityId,cd,rewards,number,smallID,stage,singleRanking,totalRanking)
    self.activityId = activityId
    -- 活动ID
    self.rewards = rewards
    -- 物品信息 (status:1未领取，0已领取，2未达到)
    self.stageID = smallID
    -- 阶段id
    self.stage = stage
    -- 处于几段
    self.number = number
    -- 当前积分
    self.singleRanking = singleRanking
    -- 阶段排名
    self.totalRanking = totalRanking
    -- 总排名
    self.startTime = me.sysTime()
    self.countDown = cd

    local function sortFunc(pa, pb)
        if me.toNum(pa["key"]) < me.toNum(pb["key"]) then
            return true
        end
    end
    table.sort(self.rewards,sortFunc)
end

function timeLimitDetailData:update(stage,status)
    for key, var in pairs(self.rewards) do
        if me.toNum(var.key) == me.toNum(stage) then
            var.status = status
        end
    end
end

-- 限时活动礼包(未开启)
timeLimitData = class("timeLimitData")
timeLimitData.__index = timeLimitData
function timeLimitData:ctor(activityId,cd,rewards)
    self.activityId = activityId
    -- 活动ID
    self.rewards = rewards
    -- 奖励物品
    self.startTime = me.sysTime()
    self.countDown = cd
end

-- 新春礼包
NewSpringData = class("NewSpringData")
NewSpringData.__index = NewSpringData
function NewSpringData:ctor(activityId,rewards,time)
    self.activityId = activityId
    if activityId == ACITVITY_ID_NEW_SPRING then
        self.newSpringStartTime = me.sysTime()
        self.time = time/1000
    end
    -- 活动ID
    self.rewards = rewards
    -- 奖励物品
    for key, var in pairs(self.rewards) do
       var["startTime"] = me.sysTime()
    end
end

-- 礼包奖励
GiftData = class("GiftData")
GiftData.__index = GiftData
function GiftData:ctor(data)
    for key, var in pairs(data) do
      self[key] = var
    end 
    self.rewards = self.rewarder
    for key, var in pairs(self.rewarder) do
       var["startTime"] = me.sysTime()
    end
end

--积分兑换
ExchangeData = class("ExchangeData")
ExchangeData.__index = ExchangeData
function ExchangeData:ctor(activityId,defId,integral,icon,price)
    self.activityId = activityId
    -- 活动ID
    self.defId = defId
    -- 奖励ID
    self.integral = integral
    -- 当前拥有积分
    self.icon = icon
    -- 图标
    self.price = price
    -- 价格
end

--国庆特庆
NationalDayData = class("NationalDayData")
NationalDayData.__index = NationalDayData
function NationalDayData:ctor(activityId,items,needs)
    self.activityId = activityId
    -- 活动ID
    self.items = items
    self:sortByNeeds(needs)
end
function NationalDayData:sortByNeeds(tab)
    me.tableClear(self.needs)
    self.needs = {}
    for key, var in pairs(tab) do
        self.needs[#self.needs+1]={}
        self.needs[#self.needs]["id"]= me.toNum(key)
        self.needs[#self.needs]["num"]= me.toNum(var)
    end
    local function sortEx(pa,pb)
          return pa["id"] < pb["id"]
    end
    table.sort(self.needs,sortEx)
end
-- 红包活动
HongBaoData = class("HongBaoData")
HongBaoData.__index = HongBaoData
function HongBaoData:ctor(data)
    for key, var in pairs(data) do
         self[key] = var
    end    
end

-- 每日特惠
EveryDayData = class("EveryDayData")
EveryDayData.__index = EveryDayData
function EveryDayData:ctor(activityId,rid,rwd,tr,ls,buy,nm,tl)
    self.activityId = activityId
    self.RechargeId = rid -- 充值id
    self.RechargRewardId = rwd -- 充值礼包id
    self.TotalRward = tr -- 总奖励列表
    self.ReceiceReward = ls -- 已领取奖励
    self.isbuy = buy -- 当天是否已购买 0:未购买 1：购买
    self.BuyDayNum = nm -- 购买的累积天数
    self.TotalBuyDay = tl -- 总天数
end

-- 许愿珠活动
WishData = class("WishData")
WishData.__index = WishData
function WishData:ctor(activityId, openDate, endDate, needId, haveNum, synId, synHave, x, y)
    self.activityId = activityId
    self.openDate = openDate
    self.endDate = endDate
    self.needId = needId
    self.haveNum = haveNum
    self.synId = synId
    self.synHave = synHave
    self.x = x
    self.y = y
end

-- 战舰活动
ShipData = class("ShipData")
ShipData.__index = ShipData
function WishData:ctor(activityId, openDate, endDate, needId, haveNum, synId, synHave, x, y)
    self.activityId = activityId
    self.openDate = openDate
    self.endDate = endDate
    self.needId = needId
    self.haveNum = haveNum
    self.synId = synId
    self.synHave = synHave
    self.x = x
    self.y = y
end

--武勋兑换活动
MedalData = class("MedalData")
MedalData.__index = MedalData
function MedalData:ctor(activityId, wuXunNm, list, openDate, endDate, integral)
    self.activityId = activityId
    self.wuXunNm = wuXunNm
    self.list = nil
    self.list = list
    if openDate then
        self.openDate = openDate
    else
        self.openDate = user.activityDetail.openDate
    end
    if endDate then
        self.endDate = endDate
    else
        self.endDate = user.activityDetail.endDate
    end
    self.integral = integral
end

--周签到活动数据
WeekySignData = class("WeekySignData")
WeekySignData.__index = WeekySignData
function WeekySignData:ctor(activityId,got,dayNum,weekNum,currentWeek,records,rewards,extras)
    self.activityId = activityId
    self.got = got
    self.dayNum = dayNum
    self.weekNum = weekNum
    self.currentWeek = currentWeek
    self.records = records
    self.rewards = rewards
    self.extras = extras
end

-- 劳动节活动
LadourDayData = class("LadourDayData")
LadourDayData.__index = LadourDayData
function LadourDayData:ctor(activityId,countDown,list)
    self.activityId = activityId
    self.countDown = countDown -- 倒计时
    self.list = list --  物品
end
--新春福卷
NewYearDayData = class("NewYearDayData")
NewYearDayData.__index = NewYearDayData
function NewYearDayData:ctor(activityId,gd,sc,er,tr,gls,openDate,endDate)
    self.activityId = activityId
    -- 活动ID
    self.GoogLuckNum = gd
    self.IntegrNum = sc
    self.GoogLuckTab = self:sortByNeeds(er)
    self.IntegrTab = self:sortByNeedtrs(tr)
    self.IntegrReward = gls
    self.openDate = openDate
    self.endDate = endDate
end
function NewYearDayData:sortByNeeds(tab)
    local needs = {}
    for key, var in pairs(tab) do
        needs[#needs+1] = {}
        needs[#needs]["id"] = var["id"] -- 奖励ID
        needs[#needs]["TypeId"] = var["need"][1] -- 福卷或积分
        needs[#needs]["num"] = var["need"][2] -- 数量
    end
    return needs
end
function NewYearDayData:sortByNeedtrs(tab)
    local needs = {}
    for key, var in pairs(tab) do
        needs[#needs+1] = {}
        needs[#needs]["id"] = var["id"] -- 奖励ID
        needs[#needs]["num"] = var["need"][1] -- 数量
    end
    return needs
end
--VIP特惠
VipTimelData = class("VipTimelData")
VipTimelData.__index = VipTimelData
function VipTimelData:ctor(activityId,gls,list,Diamond,std,cd)
    self.activityId = activityId
    -- 活动ID
    self.gls = gls
    -- 已经完成的下标
    self.list = list
    -- 活动物品
    self.Diamond = Diamond
    -- 钻石.折扣
    self.time = std/1000 or 0 --倒计时
    self.cd = cd
end
-- 中秋节活动
MidAutumnFestivalData = class ("MidAutumnFestivalData")
MidAutumnFestivalData.__index = MidAutumnFestivalData
function MidAutumnFestivalData:ctor(activityId, countDown, list)
    -- 活动ID
    self.activityId = activityId

    self.countDown = countDown

    self.list = list
end

-- 积分兑换活动
RedeemData = class("RedeemData")
RedeemData.__index = RedeemData
function RedeemData:ctor(activityId, wuXunNm, list, openDate, endDate, desc)
    self.activityId = activityId
    self.wuXunNm = wuXunNm
    self.list = list
    if openDate then
        self.openDate = openDate
    else
        self.openDate = user.activityDetail.openDate
    end
    if endDate then
        self.endDate = endDate
    else
        self.endDate = user.activityDetail.endDate
    end
    self.desc = desc
end

--积分道具信息
TurnplateData = class("TurnplateData")
TurnplateData.__index = TurnplateData
function TurnplateData:ctor(activityId,list,activityNum,rewarders)
    self.activityId = activityId
    -- 活动ID
    self.list = list
    -- 抽奖物品
    self.activityNum = activityNum
    -- 积分值
    self.rewardersQueue = nil
    -- 获奖玩家名单
    if rewarders then
        self.rewardersQueue = Queue.new()
        for key, var in pairs(rewarders) do
            Queue.push(self.rewardersQueue,var)
        end
    end
    self.helpData = { }
    -- 帮助信息
end

-- "itemId"     = 1042
-- "itemNumber" = 3
-- "name"       = "lord(370,1170)"
function TurnplateData:setRewardList(rewarders)
    if self.rewardersQueue ==nil then
        self.rewardersQueue = Queue.new()
    end
    Queue.push(self.rewardersQueue,rewarders)
end
function TurnplateData:setHelpData(helpData)
    self.helpData = helpData
end

--喇叭广播数据
--    json.addProperty("uid", msg.getUid());    //用户id
--    json.addProperty("nm", msg.getName());    //用户昵称
--    json.addProperty("fsn", msg.getFamilyShortName());//联盟简称 (流浪为"")
--    json.addProperty("deg", msg.getDegree());  //联盟官职
--    json.addProperty("ct", msg.getContent());  //内容
--    json.addProperty("pst", msg.getPersionTitle());  //个人称号
--    json.addProperty("tp", msg.getType());      //广播类型 0：系统广播,1:黄色,2:绿色,2:紫色
--    json.addProperty("sn", msg.getServerName());  //区服([S1])
--    md.getExecute().sendBroadWorldChat(json);
TrumpetData = class("TrumpetData")
TrumpetData.__index = TrumpetData
function TrumpetData:ctor(uid,nm,fsn,deg,ct,pst,tp,sn,date)
    self.uid = uid
    self.name = nm
    if me.isValidStr(fsn) == true then
        self.familyName = fsn
    else
        self.familyName = "流浪"
    end
    self.degree = deg
    self.content = ct
    self.pst = pst
    self.tp = tp
    self.camp = sn
    self.date = date
end

--聊天数据
MsgData = class("MsgData")
MsgData.__index = MsgData
function MsgData:ctor(uid,name,date,content,familyName,shorName,degree,fightNum,noticeId,camp,title,worldDegree)
    self.uid = uid
    -- userID
    self.name = name
    -- 玩家名字
    self.date = date
    -- 玩家说话时间
    self.content = content
    -- 说话内容
    if me.isValidStr(familyName) == true then
        self.familyName = familyName
    else
        self.familyName = "流浪"
    end

    self.shorName = shorName

    -- 家族名字
    self.degree = degree
    -- 职位
    self.fightNum = fightNum
    -- 战斗力
    self.content = content
    -- 说话内容
    if noticeId then
        self.noticeId = noticeId --自定义类型 包括集火，发红包等
    end
    self.camp = camp or "" -- 区服
    self.title = title
    self.worldDegree=worldDegree
end

--聊天邮件数据
MsgMailData = class("MsgMailData")
MsgMailData.__index = MsgMailData
function MsgMailData:ctor(rname,title,content,date,CrossType)
    self.rname = rname
    -- 收件人名字
    self.date = date
    -- 发出时间
    self.content = content
    -- 内容
    self.title = title
    -- 标题
    self.CrossType = CrossType or 0 -- 0 游戏服，1跨服
end
--个人排行榜数据
RankData = class("RankData")
RankData.__index = RankData
function RankData:ctor(data,pRank)
    self.rank = pRank
    self.uid = me.toNum(data[1])
    -- uid
    self.fight = me.toNum(data[2])
    -- 战斗力
    self.level = me.toNum(data[4])
    -- 等级
    self.rname = data[3]
    -- 名字
    self.defId = me.toNum(data[5])
    -- 城镇中心的ID
    self.landbnum = me.toNum(data[6])
    -- 地块数
end

--限时活动排行榜数据
LimitData = class("LimitData")
LimitData.__index = LimitData
function LimitData:ctor(info,index)
    self.uid = info[1]
    -- uid
    self.name = info[3]
    -- 名字
    self.level = info[4]
    -- 等级
    self.unit = info[5]
    -- 联盟
    self.num = info[2]
    -- 积分
    self.index = index
    -- 名次
end

--成就排行榜数据
AScoreData = class("AScoreData")
AScoreData.__index = AScoreData
function AScoreData:ctor(data,pRank)
    self.rank = pRank
    -- uid
    self.uid = me.toNum(data[1])
    -- 积分
    self.score = me.toNum(data[2])
    -- 玩家名
    self.rname = data[3]
    -- 等级
    self.level = me.toNum(data[4])
    -- 当前时代defid
    self.defId = me.toNum(data[5])
    -- 战力
    self.fight = me.toNum(data[6])
end
--跨服个人积分排行榜数据
NetScoreData = class("NetScoreData")
NetScoreData.__index = NetScoreData
function NetScoreData:ctor(data,pRank)
    self.rank = pRank
    -- uid
    self.uid = me.toNum(data[1])
    -- 积分
    self.score = me.toNum(data[2])
    -- 玩家名
    self.rname = data[3]
    -- 服务器
    self.server = data[4]
  
end
--跨服区服积分排行榜数据
NetServerScoreData = class("NetServerScoreData")
NetServerScoreData.__index = NetServerScoreData
function NetServerScoreData:ctor(data,pRank)
    self.rank = pRank
    -- uid
    self.uid = me.toNum(data[1])
    -- 积分
    self.score = me.toNum(data[2])
    -- 服务器名
    self.server = data[3]

end
--个人排行榜数据
ScoreData = class("ScoreData")
ScoreData.__index = ScoreData
function ScoreData:ctor(data,pRank)
    self.rank = pRank
    self.uid = me.toNum(data[1])
    -- uid
    self.score = me.toNum(data[2])
    -- 积分
    self.level = me.toNum(data[4])
    -- 等级
    self.rname = data[3]
    -- 名字
    self.defId = me.toNum(data[5])
    -- 城镇中心的ID
    self.fighttime = me.toNum(data[6])
    -- 战斗次数
end
-- 联盟排行榜数据
RankAllianceData = class("RankAllianceData")
RankAllianceData.__index = RankAllianceData
function RankAllianceData:ctor(data,pRank)
    self.rank = pRank
    self.uid = me.toNum(data[1])
    -- uid
    self.fight = me.toNum(data[2])
    -- 战斗力
    self.level = me.toNum(data[4])
    -- 等级
    self.rname = data[3]
    -- 联盟名字
    self.member = me.toNum(data[5])
    -- 人数
    self.fortnum = me.toNum(data[6])
    -- 要塞数
    self.maxmember = me.toNum(data[8])
    -- 总人数
end
-- 战损排行榜数据
RankPlunderData = class("RankPlunderData")
RankPlunderData.__index = RankPlunderData
function RankPlunderData:ctor(data,pRank)
    self.rank = pRank
    self.uid = me.toNum(data[1])
    -- uid
    self.rname = data[3]
    -- 玩家名字
    self.level = me.toNum(data[4])
    -- 等级
    self.num = me.toNum(data[5])
    -- 次数
    self.food = me.toNum(data[6])
    -- 粮食
    self.wood = me.toNum(data[7])
    -- 木材
    self.stone = me.toNum(data[8])
    -- 石头
    self.gold = me.toNum(data[9])
    -- 金子
    self.fight = me.toNum(data[10])
    -- 战斗力
    self.x = me.toNum(data[11])
    self.y = me.toNum(data[12])
end
-- 联盟排行榜数据
FortWorldData = class("FortWorldData")
FortWorldData.__index = FortWorldData
function FortWorldData:ctor(defid,x,y,name,mine,giveup)
    self.defid = defid
    -- 配置id
    self.x = x
    self.y = y
    self.name = name
    self.mine = mine
    self.giveup = giveup --是否正在放弃
end
-- BUFF
BuffData = class("BuffData")
BuffData.__index = BuffData
function BuffData:ctor(defid,countDown,stype)
    -- 配置id
    self.defid = defid
    self.stype = stype
    self.countDown = countDown + me.sysTime()
end
-- 联盟集火队列
allianceConverge = class("allianceConverge")
allianceConverge.__index = allianceConverge
function allianceConverge:ctor(warType,teamId,CaptainName,status,countTime,time,centerId,x,y,attacker,defener,tp,camp, isJoin)
    self.warType = warType
    -- 战争状态，1:进攻 0 :防御
    self.teamId = teamId
    -- 加入进攻时需要传入的
    self.CaptainName = CaptainName
    -- 进攻与防御的名字
    self.x = x
    -- 目标位置
    self.y = y
    self.centerId = centerId
    -- 主城id
    self.status = status
    -- 状态
    self.countTime = math.floor(countTime / 1000) or 0
    -- 集结时间
    self.totalTime = time or 0
    -- 总时间
    self.ConergeType = tp or 0-- 0:普通集火，1：王座
    self.attacker = aConvergeBattle.new(attacker.family,attacker.leader,attacker.playerMaxNum,attacker.player,attacker.playerList,attacker.teamId,attacker.camp or "")
    self.defener = nil
    if defener then
       self.defener = aConvergeBattle.new(defener.family,defener.leader,defener.playerMaxNum,defener.player,defener.playerList,0,defener.camp or "")
    end
	self.isJoin = isJoin
end
-- 联盟集火单个队列
ConvergeQueue = class("ConvergeQueue")
ConvergeQueue.__index = ConvergeQueue
function ConvergeQueue:ctor(teamId,CaptainName,status,countTime,time,centerId,x,y,family,leader,maxSoliderNum,soliderNum,playerNum,maxPlayerNum,ox,oy,tp,camp)
    self.teamId = teamId
    -- 加入进攻时需要传入的
    self.CaptainName = CaptainName
    -- 进攻与防御的名字
    self.x = x
    -- 目标位置
    self.y = y
    self.leaderX = ox
    self.leaderY = oy
    self.centerId = centerId
    -- 主城id
    self.status = status
    -- 状态
    self.countTime = math.floor(countTime / 1000) or 0
    -- 集结时间
    self.totalTime = math.floor(time / 1000) or 0
    -- 总时间
    self.family = family
    -- 联盟名字
    self.leader = leader
    -- 队长名字
    self.maxSoliderNum = maxSoliderNum
    -- 最大军队人数
    self.soliderNum = soliderNum
    -- 军队人数
    self.playerNum = playerNum
    -- 组队人数
    self.maxPlayerNum = maxPlayerNum
    -- 最大组队人数
    self.ConergeType = tp or 0-- 0:普通集火，1：王座

    self.camp = camp -- 区服
end
-- 集火队列的进攻与防御的人
aConvergeBattle = class("aConvergeBattle")
aConvergeBattle.__index = aConvergeBattle
function aConvergeBattle:ctor(family,leader,playmaxNum,playernum,playerlist,attackId,camp)
    self.family = family
    -- 联盟名字
    self.leader = leader
    -- 队长名字
    self.playmaxNum = playmaxNum
    -- 队伍最大人数
    self.playernum = playernum
    -- 队伍人数
    self.playerlist = playerlist
    -- 队伍集合的人名
    self.attackId = attackId or 0
    -- 进攻方id
    self.camp = camp
end
-- 集火军队详情
TeamArmyData = class("TeamArmyData")
TeamArmyData.__index = TeamArmyData
function TeamArmyData:ctor(armyId,status,counttime,army,name,shipId,city,fightPower)
    self.armyId = armyId
    -- 个人军队id
    self.status = status
    -- 状态
    self.counttime = math.floor(counttime / 1000)
    -- 时间
    self.army = army
    -- 军队id 数量
    self.name = name
    -- 名字
    self.city = city
    -- 主城 防御
    self.fightPower = fightPower
    -- 战斗力
    self.shipId = shipId or 0
end
-- 集火军队详情
ArmyAidData = class("ArmyAidData")
ArmyAidData.__index = ArmyAidData
function ArmyAidData:ctor(armyId,status,counttime,time,army,name,shipId)
    self.armyId = armyId
    -- 个人军队id
    self.status = status
    -- 状态
    self.counttime = math.floor(counttime / 1000)
    -- 时间
    self.army = army
    -- 军队id 数量
    self.name = name
    -- 名字
    self.time = time
    -- 战舰
    self.shipId = shipId or 0
end
-- 集火历史记录
TeamHistoryData = class("TeamHistoryData")
TeamHistoryData.__index = TeamHistoryData
function TeamHistoryData:ctor(win,rType,time,attacker,defener)
    self.win = win
    -- 1:胜利，2：失败
    self.rType = rType
    -- 状态
    self.time = time
    -- 时间
     self.attacker = attacker
     self.defener = defener
end
-- 援助历史记录
DefensHistoryData = class("DefensHistoryData")
DefensHistoryData.__index = DefensHistoryData
function DefensHistoryData:ctor(name,num,time)
    self.name = name
    -- 名字
    self.num = num
    -- 军队数量
    self.time = time
    -- 时间
end

--boss战数据
ActivityBossData = class("ActivityBossData")
ActivityBossData.__index = ActivityBossData
function ActivityBossData:ctor(activityId,list,countDown,open)
    self.activityId = activityId
    -- 活动ID
    self.open = open
    -- 开启状态
    self.list = list
    -- 活动物品
    self.cd = countDown
    -- 倒计时
end

--每日狂欢数据
DailyHappyData = class("DailyHappyData")
DailyHappyData.__index = DailyHappyData
function DailyHappyData:ctor(activityId,open,list,integralItems,countdown,score)
    self.activityId = activityId
    -- 活动ID
    self.open = open
    -- 是否开启
    self.list = list
    -- 活动进度
    self.integralItems = integralItems
    -- 进度奖励
    self.score = score
    -- 总积分
    self.countdown = countdown
    -- 当前倒计时
end

-- 要塞名将
FortHeroData = class("FortHeroData")
FortHeroData.__index = FortHeroData
function FortHeroData:ctor(st,startid,x,y,id,lv,nm,tm,hp,exp,initNm)
    self.open = st -- 开启状态 0 关 1 开
    self.x = x
    self.y = y
    self.startId = startid
    self.heroDefid = id -- 名将配置id
    self.amityLevel = lv -- 试炼度
    self.amityExp = exp
    self.CurNum = nm -- 名将试炼个数
    self.countdown = tm --试炼结束时间
    self.surplusBlood = hp -- 剩余血量
    self.initNm = initNm
end

-- 要塞排名单个数据
FortHeroRankInfo = class("FortHeroRankInfo")
FortHeroRankInfo.__index = FortHeroRankInfo
function FortHeroRankInfo:ctor(rk,nm,ht)
    self.Ranking = rk --  排名
    self.name = nm -- 昵称
    self.HurtPercent = ht -- 伤害百分比
end

-- 要塞排名
FortHeroRankData = class("FortHeroRankData")
FortHeroRankData.__index = FortHeroRankData
function FortHeroRankData:ctor(id,tm,cnm,hp,list,mrk,cd)
    self.heroid = id --  名字
    self.CountTime = tm -- 时间
    self.SurplusNum = cnm -- 剩余试炼个数
    self.surplusBlood = hp -- 剩余血量
    self.CountExperTime = cd or 0 -- 倒计时
    self.RankList = {}
    for key, var in pairs(list) do
        local pFortHeroRankInfo = FortHeroRankInfo.new(var.rk,var.nm,var.ht)
        table.insert(self.RankList,pFortHeroRankInfo)
    end
    self.meInfo = nil
    if mrk ~= nil  then
       mrk.nm = "我"
       self.meInfo = FortHeroRankInfo.new(mrk.rk,mrk.nm,mrk.ht)
    end
end

-- 要塞历史排名数据单个
FortHeroHistoryRankInfo = class("FortHeroHistoryRankInfo")
FortHeroHistoryRankInfo.__index = FortHeroHistoryRankInfo
function FortHeroHistoryRankInfo:ctor(rk,id,nm,level,ht,integal)
    self.Ranking = rk --  排名
    self.id = id
    self.name = nm -- 昵称
    self.level = level
    self.HurtPercent = ht -- 伤害
    self.Integal = integal -- 积分
end

-- 要塞历史排名数据
FortHeroHistoryRankData = class("FortHeroHistoryRankData")
FortHeroHistoryRankData.__index = FortHeroHistoryRankData
function FortHeroHistoryRankData:ctor(id,nm,tm,list,kn)
    self.heroid = id or 0 --
    self.heroName = nm --昵称
    self.time = tm or 0-- 时间
    self.killNum = kn -- 击杀个数
    self.RankList = {}
    local rk = 1
    if list then
        for key, var in pairs(list) do
            local pList = me.split(var,",")
            local pFortHeroHistoryRankInfo = FortHeroHistoryRankInfo.new(rk,pList[1],pList[2],pList[3],pList[4],pList[5])
            table.insert(self.RankList,pFortHeroHistoryRankInfo)
            rk = rk +1
       end
    end

end

-- 名将图鉴列表
fortIdentifyDataList = class("fortIdentifyDataList")
fortIdentifyDataList.__index = fortIdentifyDataList
function fortIdentifyDataList:ctor(heroList)
    self.heroList = heroList -- 图鉴列表 herobookid：英雄id   herobookStatus：激活状态
end

function fortIdentifyDataList:getBookStarsById(heroId)
    local starNum, bookid = 0, 0
    for key, var in pairs(self.heroList) do
        if me.toNum(heroId) == var:getDef().id then
            bookid  = var:getDef().herobookid
            break
        end
    end
    for key, var in pairs(cfg[CfgType.HERO]) do
        if me.toNum(var.herotype) == me.toNum(bookid) then
            starNum = var.bookstar
            break
        end
    end
    return starNum
end

function fortIdentifyDataList:getAllProperty()
    local data = {}
    data.attack = 0
    data.defense = 0
    data.damage = 0
    for key, var in pairs(self.heroList) do
        if me.toNum(var.herobookStatus) == 2 then
            local tmpdef = var:getDef()
            data.attack = data.attack+tmpdef.atkplus
            data.defense = data.defense+tmpdef.defplus
            data.damage = data.damage+tmpdef.dmgplus
        end
    end
    return data
end

function fortIdentifyDataList:getHeroStatusById(heroId)
    for key, var in pairs(self.heroList) do
        if me.toNum(heroId) == var:getDef().id then
            return var.herobookStatus
        end
    end
    return fortIdentifyView.Hero_NoEnough
end

--名将图鉴数据
fortIdentifyData = class("fortIdentifyData",BaseDefData)
-- 1: 可激活， 2：已经激活
function fortIdentifyData:ctor(defid,herobookStatus,progress,countTime,diamondCost)
    super(self,defid, CfgType.HERO_BOOK_TYPE)
    self.herobookStatus = herobookStatus
    self.progress = progress or 0
    self.countTime = countTime or 0
    self.diamondCost = diamondCost or 0
    return self
end

function fortIdentifyData:getSkills()
    local tmpStr = me.split(self:getDef().showskill,",")
    local skillList = {}
    for key, var in pairs(tmpStr) do
        local str = me.split(var,"/")
        skillList[#skillList+1] = {}
        skillList[#skillList].id = me.toNum(str[1])
        skillList[#skillList].status = me.toNum(str[2])
    end
    return skillList
end
-- 名将招募奇迹列表
fortHeroSoldier = class("fortHeroSoldier")
fortHeroSoldier.__index = fortHeroSoldier
function fortHeroSoldier:ctor(heroid,soldier)
    self.heroid = heroid --  名将id
    self.soldierid = soldier -- 士兵id
end
-- 名将招募奇迹兵列表
fortRecuritSoldier = class("fortRecuritSoldier")
fortRecuritSoldier.__index = fortRecuritSoldier
function fortRecuritSoldier:ctor(index,id,nm,tp,nd,hs)
    self.index = index -- 下标 招募需要
    self.soldierid = id --  名将id
    self.num = nm -- 招募数量
    self.recuritType = tp -- 招募类型 1 资源招募 2 钻石招募
    self.needmak = nd -- 需要的材料
    self.halfrecurit = hs -- 招募与否 0 未招募 1 招募
end
function fortRecuritSoldier:getDef()
    if self.def == nil then
       self.def =  cfg[CfgType.CFG_SOLDIER][self.soldierid]
    end
    return self.def
end

-- 双十一数据
ElevenShopData = class("ElevenShopData")
ElevenShopData.__index = ElevenShopData
function ElevenShopData:ctor(closeTime, list, comsumeAgio, comsume)
    -- 结束时间
    self.closeTime = closeTime/1000
    -- 奖励的物品
    --       "agio"        = 0  --折后的价格
    --       "buyNumber"   = 0  -- 已购买的次数
    --       "id"          = 9
    --       "itemDefId"   = 15 --def
    --       "price" =  0   --原价
    --       "zhelv":0       --折率
    --       "selfBuyTote" = 0  --限购总次数
    --       "sellType"    = 1
    --       "tote"        = 0  --全服购买的剩余次数
    self.list = list

    self.comsumeAgio=comsumeAgio
    self.comsume=comsume
end

-- 推广数据
PopulaiizeData = class("PopulaiizeData")
PopulaiizeData.__index = PopulaiizeData
function PopulaiizeData:ctor(id, link, image,content,hortations,ptype,status)
    self.id = id
    self.link = link -- 推广链接
    self.image = image or nil -- 图片
    self.content = content -- 内容
    self.hortations = hortations  -- 进度奖励
    self.pType = ptype -- 类型
    self.status = status -- 状态
end

-- 王座初始化
Throne_CreateData = class("Throne_CreateData")
Throne_CreateData.__index = Throne_CreateData
function Throne_CreateData:ctor(st, fsn, fnm,sc,msc,list,tm,xy,KingName)
    self.Thronr_type = st -- 0 :普通，1：争夺中 2：占领中 3：被占领中（免战）
    self.FamilyShorName = fsn -- 联盟简称
    self.FamilyName = fnm -- 联盟
    self.PeopleHeart =  sc -- 民心
    self.PeopleHeartM = msc -- 总值民心
    self.ThroneKingTerm =tm -- 任期
    self.ThroneKingdecl = xy --宣言
    self.KingName = KingName or ""
    self.Steategy = {} -- 策略
    for key, var in pairs(list) do
        local pData = {}
        pData.id = var.id -- id
        pData.curs = var.curs -- 进度
        table.insert(self.Steategy,pData)
    end
end
-- 王座民心排行单个
Throne_MorleRankData = class("Throne_MorleRankData")
Throne_MorleRankData.__index = Throne_MorleRankData
function Throne_MorleRankData:ctor(fsn,fnm,sc)
     self.FamilyShorName = fsn -- 联盟简称
    self.FamilyName = fnm -- 联盟
    self.PeopleHeart = sc --民心
end
-- 王座民心排行
Throne_MorleRank = class("Throne_MorleRank")
Throne_MorleRank.__index = Throne_MorleRank
function Throne_MorleRank:ctor(st,msc,list,fnm)
    self.Thronr_type = st -- 0 :普通，1：争夺中 2：占领中 3：被占领中（免战）
    self.PeopleHeartM = msc -- 总值民心
    self.OccupyFamily = fnm -- 占领联盟
    self.MorleRank = {}
    for key, var in pairs(list) do
        local pData = Throne_MorleRankData.new(var.fsn,var.fnm,var.sc)
        table.insert(self.MorleRank,pData)
    end
end

-- 王座政策数据
kingdom_policyData = class("kingdom_policyData")
kingdom_policyData.__index = kingdom_policyData
function kingdom_policyData:ctor(crystal,list,type)
    self.crystal = crystal
    self.list = list
    self.type = type
    self.sysTime = me.sysTime()
end

-- 王座国库数据
kingdom_foundationData = class("kingdom_foundationData")
kingdom_foundationData.__index = kingdom_foundationData
function kingdom_foundationData:ctor(food,wood,stone, gold,crystal,exHistory,type, contribute, salary)
    self.food = food
    self.wood = wood
    self.gold = gold
    self.stone = stone
    self.crystal = crystal
    self.exHistory = exHistory
    self.contribute = contribute
    self.type = type
    self.salary=salary
end

-- 王国官职数据
kingdom_officerData = class("kingdom_officerData")
kingdom_officerData.__index = kingdom_officerData
function kingdom_officerData:ctor(list,countDown,kingWorlds,updateAble,identity,autoCountDown)
    self.countDown = countDown
    self.kingWorlds = kingWorlds
    self.updateAble = updateAble
    self.identity = identity --是否是盟主
    self.autoCountDown = autoCountDown --自动任命国王的倒计时
    me.tableClear(self.list)
    self.list = {}
    for key, var in pairs(list) do
        self.list["degree_"..var.degree] = var
        if var.degree == 1 then
            self.kingId = var.uid --国王ID
        end
        if user.uid == var.uid then
            self.myDegree = var.degree
        end
    end
end

-- 王座策略
Throne_StrategyData = class("Throne_StrategyData")
Throne_StrategyData.__index = Throne_StrategyData
function Throne_StrategyData:ctor(defId,value,strgCD)
    self.defId = defId -- id
    self.value = value -- 数量
    self.strgCD = strgCD/1000 -- 冷却时间
end

-- 王座策略
Throne_Strategy = class("Throne_Strategy")
Throne_Strategy.__index = Throne_Strategy
function Throne_Strategy:ctor(type,list,countdown)
    self.Throne_type = type -- 0 :普通，1：争夺中 2：占领中 3：被占领中（免战）
    self.countdown = countdown/1000 or 0-- 冷却
    self.Strategy = {}
    for key, var in pairs(list) do
        local pData = Throne_StrategyData.new(var.defId,var.value,var.strgCD)
        table.insert(self.Strategy,pData)
    end
end

-- 王座策略
Throne_StrategyAni = class("Throne_StrategyAni")
Throne_StrategyAni.__index = Throne_StrategyAni
function Throne_StrategyAni:ctor(type,id)
    self.Throne_type = type -- 0 :普通，1：争夺中
    self.id = id or 0-- 冷却

end
-- 跨服排行榜
Cross_SeverRank = class("Cross_SeverRank")
Cross_SeverRank.__index = Cross_SeverRank
function Cross_SeverRank:ctor(sever,data,begin,timeend,name)
    self.sever = sever -- 服务器id
    self.data = data --
    self.begin = begin -- 开始时间
    self.timeend = timeend -- 结束时间
    self.name = name
end

--跨服个人积分排行榜数据
CrossScoreRank = class("CrossScoreRank")
CrossScoreRank.__index = CrossScoreRank
function CrossScoreRank:ctor(data,pRank)
    self.rank = pRank
    self.uid = me.toNum(data[1])
    -- uid
    self.score = me.toNum(data[2])
    -- 积分
    self.level = me.toNum(data[6])
    -- 等级
    self.rname = data[3]
    -- 联盟名字
    self.Severid = data[4]
    -- 服务器 ID
    self.SeverName = data[5]
    -- 服务器 名字
end

--跨服军政活动
Cross_PolicyData = class("Cross_PolicyData")
Cross_PolicyData.__index = Cross_PolicyData
function Cross_PolicyData:ctor(id,name,des,status,time,ext)
    self.id = id  -- id
    self.name = name -- 活动名字
    self.des = des -- 活动描述
    self.status = status -- 状态：0未开启，1开启，2结束
    self.ExtOut = ext-- 退出 0：未退出，1退出
    self.Time = time/1000 -- 时间
end

-- 开启跨服活动时间
OpenCrossThronetime = class("OpenCrossThronetime")
OpenCrossThronetime.__index = OpenCrossThronetime
function OpenCrossThronetime:ctor(id,status,time)
    self.id = id  -- id
    self.status = status -- 状态：0未开启，1开启
    self.Time = time/1000 -- 时间
end

-- 沦陷王座
CrossThroneOccpy = class("CrossThroneOccpy")
CrossThroneOccpy.__index = CrossThroneOccpy
function CrossThroneOccpy:ctor(mstShortName,mstName,shortName,name,win)
    self.mstShortName = mstShortName  -- 沦陷者区服
    self.mstName = mstName -- 沦陷者
    self.shortName = shortName  -- 被沦陷者区服
    self.name = name -- 被沦陷者
    self.win = win -- 0:失败 1成功
end

-- 沦陷王座
CrossThroneEnd = class("CrossThroneEnd")
CrossThroneEnd.__index = CrossThroneEnd
function CrossThroneEnd:ctor(id,sn,nm,score,matSn,matNm)
    self.id = id
    self.shortName = sn  -- 简称
    self.name = nm -- 区服
    self.mstShortName = matSn   -- 沦陷者简称
    self.mstName = matNm -- 沦陷者区服
    self.socre = score -- 分数
end

-- 战舰科技
WarshipTechData = class("WarshipTechData")
WarshipTechData.__index = WarshipTechData
function WarshipTechData:ctor(config,exp)
   --  super(self,defId, CfgType.SHIP_TECH)
    self.Config = config
    self.exp = exp --
end

--成就数据
AchievementData = class("AchievementData")
AchievementData.__index = AchievementData
function AchievementData:ctor(list,total,score,com)
    self.list = list -- status:0（已领取） 1（未达成） 2（已达成可领取）
    self.total = total
    self.score = score
    self.com = com
end

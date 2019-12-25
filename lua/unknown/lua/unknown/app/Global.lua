-- 这里是存的是全局的 经常用到的变量

ICON_RES_FOOD = "gongyong_tubiao_liangshi.png"
ICON_RES_LUMBER = "gongyong_tubiao_mucai.png"
ICON_RES_GOLD = "gongyong_tubiao_jingbi.png"
ICON_RES_STONE = "gongyong_tubiao_shitou.png"
ICON_RES_FARMER = "gongyong_tubiao_gongren_2.png"
ICON_RES_DIAMOND = "gongyong_tubiao_zuanshi.png"
COLOR_GRAY = cc.c3b(127, 127, 127)
COLOR_RED = cc.c3b(255, 0, 0)
COLOR_GREEN = cc.c3b(166, 232, 81)
COLOR_GREEN_FLAG = cc.c3b(28, 248, 64)
COLOR_ORANGE = cc.c3b(255, 212, 110)
COLOR_WHITE = cc.c3b(255, 255, 255)
COLOR_D4CDB9 = cc.c3b(212, 205, 185)
COLOR_706d63 = me.convert3Color_("0x706d63")
COLOR_BLACK = cc.c3b(0, 0, 0)
COLOR_YELLOW = cc.c3b(252, 243, 62)
COLOR_SER_YELLOW = cc.c3b(211, 195, 122)
COLOR_CHAT_ME = cc.c3b(232, 220, 84) -- E8DC54
COLOR_CHAT_ME_2 = "fedbc1"
COLOR_CHAT_CONTENT = cc.c3b(220, 220, 230)
COLOR_CHAT_CONTENT_2 = "dcdce6"
COLOR_CHAT_BUSSY = cc.c3b(203, 146, 46)
COLOR_CHAT_TITLE = cc.c3b(174, 172, 117)
COLOR_CHAT_DEFAULT = cc.c3b(78, 82, 91)
COLOR_EXPED_GREEN = cc.c3b(70, 167, 57)
COLOR_EXPED_GRAY = cc.c3b(103, 103, 103)
MAX_SHOW_FARMER = 8
ITEM_ETC_TYPE = "etc" -- 背包里有的道具
ITEM_SHOP_TYPE = "shop" -- 商城里的道具
GETMORESHOP_TYPE = 1 -- 获得更多商城
VIPSHOP_TYPE = 2 -- Vip商城
POWERSHOP_TYPE = 3 -- 体力商城
ALLIANCESHOP_TYPE = 4 -- 联盟商店
ARMY_ADD_TYPE = 5 -- 出兵上限
ELEVENSHOP = 9 -- 限时抢购
SHIPDEBRISSHOP = 11
SHIPEXPERICESHOP = 12
-- VIP商城///
VIPLEVELSHOP = 13
-- 积分商城
PLURNTALESCORESHOP = 14
-- 皮肤商店
SKINSHOP = 15
-- 限时兑换
LIMIT_EXCHANGE_SHOP = 16 
-- 遗迹秘宝 挖矿商店
DIGORE_SHOP = 17 

-- 是否已经登录
bLogon = false
-- 大地图tmx对象
tmxMap = nil
-- 主城对象
mainCity = nil
-- 音乐
mAudioMusic = nil
-- 大地图
pWorldMap = nil
-- 切换云层动画完毕
mCloudAnimDone = false
---- 所有的item对象
-- globalItems = nil
-- globalItems = me.createNode("globalItem.csb")
-- globalItems:retain()
-- 背包指定物品ID
mGoodsId = nil
-- 考古指定物品ID
mAppBookMenuId = 1
mAppBookId = 1
-- 保存的地图地址
mMapTablepoint = { }

-- 保存考古可合成的数量
mBookAltasNum = { }
-- 事件信息
mNoticeInfo = { }

mMailRead = false
-- 建立驿站
mMapPost = false

-- 信息条数
mInforNum = 0

mInforHint = 0 -- 信息提示数

mInforOpen = false  -- 信息是否开启

mSkipTimeBool = false -- 切换计时

mSkipTime = nil -- 切换倒计时

mSkipTimeNum = 0

mSkipTimeId = 0 -- 推广跳转id

mCross_Sever = 1 -- 跨服

mCross_Sever_Out = 0 -- 游戏服

NewnetWork = 1 -- 0 初始化请求，1自己请求

First_City = false -- 首次

FirstInterrupt = true -- 双socket链接重连

mMailCross = 13 --  10 游戏 ,11 跨服 ,13 默认首次进入

mFind_rune_boos = 1 -- 查找等级

mWarshipHint = 0 --  0 提示 1 不提示

mFirstWorld = 0 -- 首次进入 0：首次进入 1：查看地图

sheepPath = { 20, 14, 15, 16, 19, 17, 18, 20, 21, 22, 23, 24, 10, 6, 5, 25, 20, 27 }
soldierPath = { 26, 26, 14, 15, 16, 19, 17, 18, 20, 21, 22, 23, 24, 10, 6, 5, 25, 26 }
soldierPathRight = { 25, 25, 5, 6, 10, 12, 9, 8, 16, 15, 14, 27, 1, 26, 25 }
act_btn_list = {52,53,54,55,56,57,18,58,65}

-- 禁卫军巡逻路径
guardsPath = {41, 1, 38, 39, 38, 1, 40, 44, 32, 45, 32, 44, 40, 43, 6, 29, 42}

function cameraLookAtPoint(p)
    if mainCity and mainCity.maplayer then
        return mainCity.maplayer:lookAtPoint(p)
    else
        error("mainCity or mainCity.maplayer is nil")
    end
    return 0
end
function getWorldMapWidth()
    if user.Cross_Sever_Status == mCross_Sever then
        return 101
    elseif user.Cross_Sever_Status == mCross_Sever_Out then
        return 1201
    end
end
function getWorldMapHeight()
    if user.Cross_Sever_Status == mCross_Sever then
        return 101
    elseif user.Cross_Sever_Status == mCross_Sever_Out then
        return 1201
    end
end
function cameraLookAtNode(node, cb_)
    if mainCity and mainCity.maplayer and node then
        return mainCity.maplayer:lookAtNode(node, cb_)
    else
        error("mainCity or mainCity.maplayer is nil")
    end
    return 0
end
-- 去充值商店
function toRechageShop()
    --          local shop = rechageShopLayer:create("rechageShopLayer.csb")
    --          me.runningScene():addChild(shop, me.MAXZORDER)
    --          me.showLayer(shop, "shopbg")
    local promotionView = promotionView:create("paymentView.csb")
    promotionView:setViewTypeID(2)
    me.runningScene():addChild(promotionView, me.MAXZORDER);
    me.showLayer(promotionView, "bg_frame")
end 
function toExpchageShop()
    local exp = expchageLayer:create("expchageLayer.csb")
    me.popLayer(exp, "bg")
end
--[[
function buildLevelUpLayer:getBuildTime()
     local x1 = 1/self.minFarmerTime/self.needFarmerMin
     local x2 = (self.curSelectFarmer - self.needFarmerMin)/(self.needFarmerMax - self.needFarmerMin)
     local x3 = 1/self.maxFarmerTime/self.needFarmerMax - 1/self.minFarmerTime/self.needFarmerMin
     local x4 = 1/(x1+x2*x3)/self.curSelectFarmer
     print(x4)
     return  x4
end
]]
-- 得到当前升级所需时间
function getTimeCost(args)
    local x1 = 1 / args.minFarmerTime / args.needFarmerMin
    local x2 =(args.curSelectFarmer - args.needFarmerMin) /(args.needFarmerMax - args.needFarmerMin)
    local x3 = 1 / args.maxFarmerTime / args.needFarmerMax - 1 / argsminFarmerTime / args.needFarmerMin
    local x4 = 1 /(x1 + x2 * x3) / args.curSelectFarmer
    print(x4)
    return x4
end

--[[
local xprice = {}
    xprice.food = 需要花费的食物
    xprice.wood = 需要花费的木材
    xprice.stone = 需要花费的石头
    xprice.gold = 需要花费的金币
    xprice.time = 最多工人需要花费的时间
    xprice.index =   为差价索引  1 建筑，2 训练 3 科技 ,10 伤兵，11陷阱
]]
-- 钻石花费
function getGemCost(xprice, tech)
    local xFood = xprice.food - user.food
    local xWood = xprice.wood - user.wood
    local xStone = xprice.stone - user.stone
    local xGold = xprice.gold - user.gold
    local xTime = xprice.time
    if tonumber(xprice.index) == 1 then
        if tech == nil or tech == false then
            local xtech = user.propertyValue["BuildTime"]
            xtech = math.min(xtech, 0.98)
            xTime = xTime/(1 + xtech)
        end
    end
    xFood = math.max(0, xFood)
    xWood = math.max(0, xWood)
    xStone = math.max(0, xStone)
    xGold = math.max(0, xGold)
    --    print("xTime = "..xTime)
    --    print("getXresPrice(xprice.index, xTime) = " .. getXresPrice(xprice.index, xTime))
    local timePrice = getXresPrice(xprice.index, xTime) * xTime
    --    print("timePrice = " .. timePrice)
    --    print(" getXresPrice(4, xFood) * xFood = ".. getXresPrice(4, xFood) )
    local foodPrice = getXresPrice(4, xFood) *(xFood)
    local woodPrice = getXresPrice(5, xWood) * xWood
    local stonePrice = getXresPrice(6, xStone) * xStone
    local goldPrice = getXresPrice(7, xGold) * xGold
    --    print("timePrice = "..timePrice)
    --    print("foodPrice = "..foodPrice)
    --    print("woodPrice = "..woodPrice)
    --    print("stonePrice = "..stonePrice)
    --    print("goldPrice = "..goldPrice)
    local allCost = timePrice + foodPrice + woodPrice + stonePrice + goldPrice
    return allCost
end

function getRevertSoilderTime()

end

function getRevertSoilderGem()

end
MAP_RAND_EVENT_TYPE_NPC = 1
MAP_RAND_EVENT_TYPE_ITEM = 2
MAP_RAND_EVENT_TYPE_RES = 3

function doAnchorPoint(node, midp)
    local lastAnp = node:getAnchorPoint();
    pMid = midp
    -- cc.p(e:getCursorX(),e:getCursorY());
    --   local temp = node:convertToNodeSpace(pMid)
    local temp = midp
    print(lastAnp.x .. "---" .. lastAnp.y)

    curAnp = cc.p(temp.x / node:getBoundingBox().width, temp.y / node:getBoundingBox().height)
    print(curAnp.x .. "--" .. curAnp.y)
    node:setAnchorPoint(curAnp)
    print(node:getPositionX())
    print(node:getPositionY())
    local x = node:getPositionX() + node:getBoundingBox().width *(curAnp.x - lastAnp.x)
    local y = node:getPositionY() + node:getBoundingBox().height *(curAnp.y - lastAnp.y)

    node:setPosition(x, y)
    print(node:getPositionX())
    print(node:getPositionY())
end
function selectBuilding(node, callfunc)
    if mainCity and mainCity.maplayer then
        mainCity.maplayer:selectNode(node, callfunc)
    else
        error("mainCity or mainCity.maplayer is nil")
    end
end
-- 计算花费时间
--[[ fNum 当前农民数
     minFarmer 最小农民数
    maxFarmer 最大农民数
    minFarmerTime 最小农民数时间
    maxFarmerTime 最大农民数时间
    --也可以计算生产每个士兵需要的时间，最大最小时间取士兵表里的
]]
function getCostTime(fNum, minFarmer, maxFarmer, minFarmerTime, maxFarmerTime)
    local x1 =(minFarmerTime - maxFarmerTime) *(fNum - minFarmer) /(maxFarmer - minFarmer)
    return minFarmerTime - x1
end
-- 获取建筑建造或者升级时间
function getCurFarmerBuildCostTime(fnum, def)
    return getCostTime(fnum, def.farmer, def.maxfarmer, def.time, def.time2)
end
-- 获取磨房每小时产量
function getFoodOutPerHour(fnum, def)
    local y =(def.out2 - def.out1) /(def.inmaxfarmer - def.infarmer)
    local out = def.out1 +(fnum - def.infarmer) * y
    local out_hour = math.floor(1.2 * out)
    return out_hour
end
-- 获取当前科技升级时间
-- 根据当前工人入住数量算出当前科技升级所需时间
-- @def_ tech的defID，
-- @tofid: 建筑物的TofID
function getTechTime(def_, curWorkers_, bType)
    if bType == cfg.BUILDING_TYPE_TOWER then
        -- 集火科技特殊处理
        return def_.time1
    end

    local tData = user.techServerDatas[def_.id]
    local tofId = tData:getTofid()
    local function getUpgradeTime()
        local minworkTime, maxworkTime = def_.time1, def_.time2
        local tmpBuildDef = user.building[tofId]:getDef()
        local finalTime = minworkTime -(minworkTime - maxworkTime) /(tmpBuildDef.inmaxfarmer - tmpBuildDef.infarmer) *(curWorkers_ - tmpBuildDef.infarmer)
        return finalTime
    end
    return getUpgradeTime()*getTimePercentByPropertyValue("TechTime")
end
function safeScale(node, p, s)
    local lastAnp = node:getAnchorPoint()
    doAnchorPoint(node, p)
    node:setScale(s)
    doAnchorPoint(node, lastAnp)
end

function getLvStrByPlatform()
    return "Lv"
end

function isAndroidPlatform()
    return cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID
end

function isWindowsPlatform()
    return cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS
end

function isIosPlatform()
    return cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD
end

-- 转换玩家的资源的科学记数法
function Scientific(num)
    local b = 1000000000
    local m = 1000000
    local k = 10000
    if num >= b then
        return string.format("%.1f", num / b) .. "b"
    elseif num >= m then
        return string.format("%.1f", num / m) .. "m"
    elseif num >= k then
        return string.format("%.1f", num * 10 / k) .. "k"
    end

    return num
end
-- 转换玩家战斗力为带逗号的计数方式
function UserGrade()
    return user.grade or "???"
end
-- 获取建筑的ICON 图片名字
function buildIcon(build)
    print("get " .. build.name .. "icon " .. build.icon)
    local time = getCenterBuildingTime() + 1   
    local icons = me.split(build.icon,";")
    if #icons > 1 then
        return (icons[time] or "2032") .. ".png"
    else
        return build.icon .. ".png"
    end
end
function buildSmallIcon(build)
    print("get " .. build.name .. "icon =" .. "icon_" .. build.type .. ".png")
    return "icon_" .. build.type .. ".png"
end
function resSmallIcon(res)
    print("get " .. "icon_res_" .. res.type .. ".png")
    return "icon_res_" .. res.type .. ".png"
end
function heroBgHeadIcon(icon)
    print("get " .. "shengjiang_quansheng_" .. icon .. ".png")
    return "shengjiang_quansheng_" .. icon .. ".png"
end
function heroSmallHeadIcon(icon)
    --    print("get " .. "shengjiang_tou_" .. icon .. ".png")
    return "shengjiang_tou_" .. icon .. ".png"
end
function techIcon(techId)
    return "icon_tech_" .. techId .. ".png"
end
function soldierIcon(sdata)
    print("get " .. sdata.name .. "icon " .. sdata.icon)
    local iconStr = sdata.icon .. ".png"
    return iconStr
end
function getMapRandEventIcon(edata)
    local etpye = edata.type

    return "revent_" .. etpye .. ".png"
end
function getAchievementIcon(Aid)
    return "chengjiu_" .. Aid .. ".png"
end
function getItemIcon(itemid)
    print("get icon by id " .. itemid)
    local etc = cfg[CfgType.ETC][me.toNum(itemid)]
    if etc then
        local icon = "item_" .. etc.icon .. ".png"
        if cc.FileUtils:getInstance():isFileExist(icon) or cc.SpriteFrameCache:getInstance():getSpriteFrameByName(icon) then
            return icon
        end
    end
    return "item_9898.png"
end
function getRefitIcon(itemid)
    print("get icon by id " .. itemid)
    local etc = cfg[CfgType.SHIP_REFIX_SKILL][me.toNum(itemid)]
    if etc then
        local icon = "item_" .. etc.icon .. ".png"
        if cc.FileUtils:getInstance():isFileExist(icon) or cc.SpriteFrameCache:getInstance():getSpriteFrameByName(icon) then
            return icon
        end
    end
    return "item_9898.png"
end
function getRuneIcon(iconId)
    local icon = "relicCard_" .. iconId .. ".png"
    if cc.FileUtils:getInstance():isFileExist(icon) or cc.SpriteFrameCache:getInstance():getSpriteFrameByName(icon) then
        return icon
    end
    return "relicCard_0.png"
end

function getRuneQualityIcon(quality)
    return "fuwen_kuang_quelity1.png"
end

function getShipSailTaskTexure(taskType)
    local sailTaskTexture = "zhanjian_hang_tu_" .. taskType .. ".png"
    if cc.FileUtils:getInstance():isFileExist(sailTaskTexture) or cc.SpriteFrameCache:getInstance():getSpriteFrameByName(sailTaskTexture) then
        return sailTaskTexture
    end
end

function getWarshipImageTexture(shipType)
    local fileName = "zhanjian_tupian_zhanjian_" .. shipType .. ".png"
    -- local texture = cc.Director:getInstance():getTextureCache():addImage(filename)
    return fileName
end
 
function getWarshipRestoreRes(resId)
    local resFile = ""

    if resId == 9001 then
        resFile = "gongyong_tubiao_liangshi.png"
    elseif resId == 9002 then
        resFile = "gongyong_tubiao_mucai.png"
    elseif resId == 9003 then
        resFile = "gongyong_tubiao_shitou.png"
    elseif resId == 9004 then
        resFile = "gongyong_tubiao_jingbi.png"
    end

    return resFile
end

-- 获取指定id的祭坛建筑的unlock:符文解锁限制
function getRuneBuildingCfgInfoByid(id)
    local info = cfg[CfgType.BUILDING][id]
    if info == nil then
        return nil
    end
    local ext = info.ext
    local temp = info.ext:split(",")
    return tonumber(temp[2]:split(":")[2])
end
-- 获取所有祭坛建筑配置信息
function getAllRuneBuildingCfgInfo(args)
    local info = cfg[CfgType.BUILDING]
    local temp = { }
    for key, var in pairs(info) do
        if var.type == "altar" then
            table.insert(temp, var)
        end
    end
    return temp
end

function getRuneStrengthAttr(strengthCfg, apt)
    local attr = { }
    for _, v in ipairs(apt) do
        local cfg = cfg[CfgType.RUNE_PROPERTY][v]
        local tmp = string.split(cfg.property, ':')
        local tmp1 = string.split(tmp[2], '|')

        if cfg.type == 1 then
            local value = string.format("%.2f",(tonumber(tmp1[1]) + tonumber(strengthCfg.level - 1) *(tonumber(tmp1[2]) - tonumber(tmp1[1])) / 29) * 100)
            table.insert(attr, { k = tmp[1], id = v, v = value, unit = "%" })
        elseif cfg.type == 2 then
            local value = math.floor(tonumber(tmp1[1]) + tonumber(strengthCfg.level - 1) *(tonumber(tmp1[2]) - tonumber(tmp1[1])) / 29)
            table.insert(attr, { k = tmp[1], id = v, v = value, unit = "" })
        end
    end
    return attr
end

function getHeroSkillIcon(iconId)
    -- 名将技能
    return "shenjiang_jineng_" .. iconId .. ".png"
end
function PointToSegDist(sp, op, tp)
    local x = sp.x
    local y = sp.y
    local x1 = op.x
    local y1 = op.y
    local x2 = tp.x
    local y2 = tp.y
    local cross =(x2 - x1) *(x - x1) +(y2 - y1) *(y - y1)
    if (cross <= 0) then return math.sqrt((x - x1) *(x - x1) +(y - y1) *(y - y1)), op end
    local d2 =(x2 - x1) *(x2 - x1) +(y2 - y1) *(y2 - y1)
    if (cross >= d2) then return Math.Sqrt((x - x2) *(x - x2) +(y - y2) *(y - y2)), tp end
    local r = cross / d2
    local px = x1 +(x2 - x1) * r
    local py = y1 +(y2 - y1) * r
    return math.sqrt((x - px) *(x - px) +(py - y1) *(py - y1)), cc.p()
end

-- 得到当前时代
function getCenterBuildingTime()
    local def = user.centerBuild:getDef()
    return def.era
end
function getCenterBuildingLevel()
    local def = user.centerBuild:getDef()
    return def.level
end
-- 是否有某建筑
function bHaveBuilding(bid)
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if me.toNum(def.id) == me.toNum(bid) then
            return true
        end
    end
    return false
end
-- 是否有某建筑
function bHaveBuildingType(pBuildingType, state)
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if (def.type == pBuildingType) and var.state ~= state then
            return true
        end
    end
    return false
end
-- 达到建筑某级
function bHaveLevelBuilding(type_, level)
    local lv = -1
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if def.type == type_ then
            if def.level > lv then
                lv = def.level
            end
        end
    end
    return lv >= level
end
-- 达到建筑某级
function bLessLevelBuilding(type_, level)
    local lv = -1
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if def.type == type_ then
            if def.level > lv then
                lv = def.level
            end
        end
    end
    return lv > level
end
function getMainCityScale()
    if mainCity and mainCity.maplayer and mainCity.maplayer.mNode then
        return mainCity.maplayer.mNode:getScale()
    end
    return 1
end
function load_cfg_path()
    local temp = LoadCsv("cfg_path.csv")
    cfg_path = { }
    for key, var in pairs(temp) do
        if cfg_path[var.countryId] == nil then
            cfg_path[var.countryId] = { }
        end
        cfg_path[var.countryId][var.name] = var
    end

end

function load_cfg_buildingInfoTitle()
    local temp = LoadCsv("cfg_buildInfoTitle.csv")
    for key, var in pairs(temp) do
        if cfg[CfgType.CFG_BUILDING_INFO_TITLE][var.countryId] == nil then
            cfg[CfgType.CFG_BUILDING_INFO_TITLE][var.countryId] = { }
        end
        cfg[CfgType.CFG_BUILDING_INFO_TITLE][var.countryId][var.type] = var
    end
end
-- t1   00-FF
-- c1   000000-FFFFFF
-- str1 字符串
function getFormatRichStr(t1, c1, str1, t2, c2, str2)
    return string.format("<txt00%s,%s>%s&<txt00%s,%s> %s#n&", t1, c1, str1, t2, c2, str2)
end
function getFormatLordRichStr(str1, str2)
    return string.format("<txt0014,ff0000>%s&<txt0014,00fff0> %s#n&", str1, str2)
end
function getFormatEventRichStr(str)
    return string.format("<txt0014,ff0000>%s#n&", str)
end
function load_cfg_lordInfo()
    local temp = LoadCsv("lordData.csv")
    --  dump(temp)
    for key, var in pairs(temp) do
        if cfg[CfgType.LORD_INFO] == nil then
            cfg[CfgType.LORD_INFO] = { }
        end
        cfg[CfgType.LORD_INFO][var.key] = var
    end
end
function load_cfg_buildingTips()
    local tmp = LoadCsv("buildingTips.csv")
    for key, var in pairs(tmp) do
        if cfg[CfgType.BUILDING_TIPS] == nil then
            cfg[CfgType.BUILDING_TIPS] = { }
        end
        cfg[CfgType.BUILDING_TIPS][var.type] = var
    end
end
function load_cfg_noticeInfo()
    local temp = LoadCsv("noticeinfo.csv")
    for key, var in pairs(temp) do
        if cfg[CfgType.NOTICE_INFO] == nil then
            cfg[CfgType.NOTICE_INFO] = { }
        end
        cfg[CfgType.NOTICE_INFO][me.toNum(key)] = var
    end
end

function load_cfg_sysNotice()
    local temp = LoadCsv("df_notice.csv")
    for key, var in pairs(temp) do
        if cfg[CfgType.SYS_NOTICE] == nil then
            cfg[CfgType.SYS_NOTICE] = { }
        end
        cfg[CfgType.SYS_NOTICE][me.toNum(key)] = var
    end
end

function load_cfg_unionLog()
    local temp = LoadCsv("unionLog.csv")
    for key, var in pairs(temp) do
        if cfg[CfgType.UNION_LOG] == nil then
            cfg[CfgType.UNION_LOG] = { }
        end
        cfg[CfgType.UNION_LOG][me.toNum(key)] = var
    end
end
function getAllSoldierNum()
    if user.soldierData == nil then
        return 0
    end
    local num = 0
    for key, var in pairs(user.soldierData) do
        num = num + var.num
    end
    for key, var in pairs(gameMap.bastionData) do
        if var.army ~= nil and table.maxn(var.army) ~= 0 then
            num = num + 1
            return num
        end
    end
    return num
end
-- 
function getStrongholdData(x, y)

end
--    print(me.Helper:getMapDataById(me.getIdByCoord(cc.p(14,789))))
function load_cfg_mapEventData()
    me.Helper:parseMapData("mapdata.txt")
end
-- 获取地图配置事件数据
function getMapConfigData(cp)
    local id = me.Helper:getMapDataById(me.getIdByCoord(cp))
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
        id = me.Helper:getMapDataById(me.getIdByCoord(cp))
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        local celltype = pWorldMap:isWater(cp)
        if celltype == 153 then
            id = 309
        elseif celltype == 154 then
            id = 209
        elseif celltype == 155 then
            id = 109
        end
    end
    local data = cfg[CfgType.MAP_EVENT_DATA][id]
    return data
end
function getNetBattleMapDataId(cp)
    local id = netBattleMapData[me.getIdByCoord(cp)]
    return id
end
--[[   kind
1.建筑时间费用 宝石/秒 计算向上取整
2.训练时间费用（包括训练和治疗伤兵）
3.科技时间费用
4.粮食购买价格表
5.木材购买价格表
6.石材购买价格表
7.金子购买价格表
]]
function getXresPrice(kind_, value)
    --   print(value)
    if value <= 0 then
        return 0
    end
    if kind_ == 10 or kind_ == 11 then
        kind_ = 2
    end
    --  me.LogTable(cfg[CfgType.CFG_CONST])
    --  me.LogTable(cfg[CfgType.CFG_CONST][kind_],"xxxxx")
    local data = cfg[CfgType.CFG_CONST][kind_].data
    if cfg[CfgType.CFG_CONST][kind_].param == nil then
        if data then
            local tb = me.split(data, ",")
            cfg[CfgType.CFG_CONST][kind_].param = tb
        end
    end
    local p = cfg[CfgType.CFG_CONST][kind_].param
    for var = 1, #p do
        local temp = me.split(p[var], ":")
        if value <= me.toNum(temp[1]) then
            --[[
              if var > 1 then
                  local res = me.toNum(me.split(p[var-1],":")[2])
               --   print("kind = "..kind_.." "..res)
                  return   res
              else
                  local res = me.toNum(temp[2])
                --  print("kind = "..kind_.." "..res)
                  return res
              end
              ]]
            local res = me.toNum(temp[2])
            --  print("kind = "..kind_.." "..res)
            return res
        end
    end
    local res = me.toNum(me.split(p[#p], ":")[2])
    --   print("kind = "..kind_.." "..res)
    return res
end

function setBackpackId(pUid)
    mGoodsId = pUid
end
function getBackpackId()
    return mGoodsId
end
local restexts = {
[1] = "粮食",
[2] = "木头",
[3] = "石头",
[4] = "金子",
}
function showEventTips(msg)
    if msg.c.id == 2 then
        if CUR_GAME_STATE ~= GAME_STATE_WORLDMAP_NETBATTLE then
            -- 占领土地
            local mid = msg.c.txt[4]
            local mdata = cfg[CfgType.MAP_EVENT_DATA][me.toNum(mid)]
            local s_ = mdata.extdesc
            local list = me.split(mdata.extdesc, "|")
            if list then
                 local msg = {}
                 for key, var in pairs(list) do
                     local spx = me.split(var,":")
                     msg[key] = restexts[tonumber(spx[1])]..spx[2]
                 end
                showMultipleTipWithBg(msg)
            end
        end
    elseif msg.c.id == 12 or msg.c.id == 13 or msg.c.id == 14 or msg.c.id == 15 then
        local str = EventInforCell:getEtc(msg.c.txt[4], msg.c.id)
        local list = me.split(str, ",")
        if list then
            for key, var in pairs(list) do
                showTips(var)
            end
        end

    end
end
function fitAlertMsg(str, tag)
    local restxt = ""
    local cnt = 1
    local s, cnt = string.gsub(str, "{+%d}", "")
    if cnt ~= table.getn(tag) then
        return
    end
    while true and tag do
        local st, ed, txt, c = string.find(str, "(.-){(%d-)}")
        if st and ed and txt and me.toNum(c) <= table.getn(tag) then
            restxt = txt .. restxt .. tag[me.toNum(c)]
            str = string.sub(str, ed + 1, -1)
        else
            restxt = restxt .. str
            break
        end
        if cnt < 10 then
            cnt = cnt + 1
        else
            break
        end
    end
    return restxt
end
function getQualityColor(pQuality)
    local rgb = "ffffff"
    -- 默认
    if pQuality == 1 then
        rgb = "ffffff"
        -- 白色
    elseif pQuality == 2 then
        rgb = "40be40"
        -- 绿色
    elseif pQuality == 3 then
        rgb = "3094ed"
        -- 蓝色
    elseif pQuality == 4 then
        rgb = "b949a7"
        -- 紫色
    elseif pQuality == 5 then
        rgb = "d96730"
        -- 橙色
    elseif pQuality == 6 then
        rgb = "d01f1f"
        -- 红色
    end
    return rgb
end
function getQuality(pQuality)
    local pQualityStr = ""
    if pQuality == 1 then
        pQualityStr = "beibao_kuang_hui.png"
        -- 白色
    elseif pQuality == 2 then
        pQualityStr = "beibao_kuang_lv.png"
        -- 绿色
    elseif pQuality == 3 then
        pQualityStr = "beibao_kuang_lan.png"
        -- 蓝色
    elseif pQuality == 4 then
        pQualityStr = "beibao_kuang_zi.png"
        -- 紫色
    elseif pQuality == 5 then
        pQualityStr = "beibao_kuang_cheng.png"
        -- 橙色
    elseif pQuality == 6 then
        pQualityStr = "beibao_kuang_hong.png"
        -- 红色
    end
    return pQualityStr
end
function getArchQuility(pId)
    local pQuality = cfg[CfgType.ETC][me.toNum(pId)]["quality"]
    local pQualityStr = "beibao_kuang_hui.png"
    if pQuality == 1 then
        pQualityStr = "beibao_kuang_hui.png"
        -- 灰色
    elseif pQuality == 2 then
        pQualityStr = "beibao_kuang_lv.png"
        -- 绿色
    elseif pQuality == 3 then
        pQualityStr = "beibao_kuang_lan.png"
        -- 蓝色
    elseif pQuality == 4 then
        pQualityStr = "beibao_kuang_zi.png"
        -- 紫色
    elseif pQuality == 5 then
        pQualityStr = "beibao_kuang_cheng.png"
        -- 橙色
    elseif pQuality == 6 then
        pQualityStr = "beibao_kuang_hong.png"
        -- 红色
    end
    return pQualityStr
end
function initCfg(type, json)
    print("===========load  " .. json)
    local cfgColl = cfg[type]
    local temp = me.parserJson(json)
    for key, var in pairs(temp) do
        cfgColl[var.id] = var
        if (type == CfgType.BUILDING) then
            cfg.initCenter(var)
        elseif (type == CfgType.BUILDING_SHOP) then
            cfg.initBuildingShop(var)
        elseif (type == CfgType.TECH_UPDATE) then
        elseif (type == CfgType.VIP_INFO) then
            cfg.initVipInfoByLevel(var)
        end

    end
    if type == CfgType.BUILDING_SHOP then
        local function comp(a, b)
            return a.sort > a.sort
        end
        for key, var in pairs(cfg[CfgType.BUILDING_SHOP_TYPE]) do
            for key_, var_ in pairs(var) do
                for k, v in pairs(var_) do
                    table.sort(v, comp)
                end
            end
        end
    end
    if type == CfgType.BUFF_NAME then
        local tmp = { }
        for key, var in pairs(cfg[CfgType.BUFF_NAME]) do
            tmp[var.type] = var
        end
        cfg[CfgType.BUFF_NAME] = tmp
    end
    if type == CfgType.BUILDING then
        for key, var in pairs(cfg[CfgType.BUILDING]) do
            if cfg[CfgType.BUILDING_INFO_CFG][var.countryId] == nil then
                cfg[CfgType.BUILDING_INFO_CFG][var.countryId] = { }
            end
            if cfg[CfgType.BUILDING_INFO_CFG][var.countryId][var.type] == nil then
                cfg[CfgType.BUILDING_INFO_CFG][var.countryId][var.type] = { }
            end
            cfg[CfgType.BUILDING_INFO_CFG][var.countryId][var.type][var.level] = var.info
        end
    end
end
function load_cfg()

    --[[
    for key, var in me.pairs(CfgFileList) do
        initCfg(key, var);
    end
    ]]
    -- 加载跨服战地图数据

    local path = cc.FileUtils:getInstance():fullPathForFilename("netbattlemapdata.txt")
    local str = cc.FileUtils:getInstance():getStringFromFile(path)
    netBattleMapData = string.split(str, ",")
    local temp = { }
    local index = 0
    for key, var in ipairs(netBattleMapData) do
        temp[index] = var
        index = index + 1
    end
    netBattleMapData = temp
end
-- 初始化战舰科技
function Warship_Tech()

    for var = 1, 4 do
        user.Warship_Tech[var] = { }
    end
    local pData = cfg[CfgType.SHIP_TECH]
    local pNum = 0
    for key, var in pairs(pData) do
        if me.toNum(var.level) == 0 then
            local pdata = WarshipTechData.new(var, 0)

            user.Warship_Tech[me.toNum(var.type)][me.toNum(var.order)] = pdata
            pNum = pNum + 1
        end

    end
    print("Warship_Tech" .. pNum)
end
-- 商店指定类型的商品
function getShopResourceDataByType(type_)
    local datas = { }
    for k, v in pairs(user.shopList) do
        if me.toNum(k) == type_ then
            for key, var in pairs(v) do
                datas[#datas + 1] = var
            end
        end
    end
    table.sort(datas, function(a, b)
        return a.defid < b.defid
    end )
    return datas
end
-- 得到指定类型的道具和商品
function getResourceDataByType(type_)
    local datas = { }
    datas[ITEM_ETC_TYPE] = { }
    datas[ITEM_SHOP_TYPE] = { }
    for key, var in pairs(user.pkg) do
        local def = var:getDef()
        if me.toNum(def.useType) == me.toNum(type_) then
            datas[ITEM_ETC_TYPE][#datas[ITEM_ETC_TYPE] + 1] = var
        end
    end
    dump(datas[ITEM_ETC_TYPE])
    table.sort(datas[ITEM_ETC_TYPE], function(a, b)
        return a.defid < b.defid
    end )
    print("#user.shopList = " .. #user.shopList)
    for k, v in pairs(user.shopList) do
        if k ~= VIPLEVELSHOP then
            for key, var in pairs(v) do
                -- if var.sellType == 1 then
                -- 得到花费钻石的商品
                local isHaved = false
                for keyEtc, varEtc in pairs(datas[ITEM_ETC_TYPE]) do
                    if me.toNum(var.defid) == me.toNum(varEtc.defid) then
                        isHaved = true
                        break
                    end
                end
                if isHaved == false then
                    if me.toNum(var.itemtype) == me.toNum(type_) then
                        datas[ITEM_SHOP_TYPE][#datas[ITEM_SHOP_TYPE] + 1] = var
                    end
                end
                -- end
            end
        end
    end
    table.sort(datas[ITEM_SHOP_TYPE], function(a, b)
        return a.defid < b.defid
    end )
    return datas
end
-- 背包里指定类型的物品数据
function getBackpackDatasByType(type_)
    local tmpList = { }
    local tmpList1 = { }
    for key, var in pairs(user.pkg) do
        local def = var:getDef()
        if me.toNum(def.useType) == me.toNum(type_) then
            table.insert(tmpList, var)
        elseif me.toNum(def.useType) == USETYPE_ALL.key then
            table.insert(tmpList1, var)
        end
    end

    local function comp(a, b)
        return tonumber(a:getDef().useEffect) > tonumber(b:getDef().useEffect)
    end
    table.sort(tmpList, comp)
    table.sort(tmpList1, comp)
    for k, v in ipairs(tmpList1) do
        table.insert(tmpList, v)
    end
    return tmpList
end

-- 符文背包里指定类型的物品数据
function getBackpackDatasByCfgId(cfgId)
    local datas = { icon = '', nums = 0, name = '' }
    for key, var in pairs(user.materBackpack) do
        if cfgId == var.defid then
            local cf = var:getDef()
            datas['nums'] = datas['nums'] + var.count
            datas['icon'] = "item_" .. cf["icon"] .. ".png"
            datas['name'] = cf["name"]
        end
    end
    if datas["icon"] == "" then
        local cf = cfg[CfgType.ETC][cfgId]
        datas['icon'] = "item_" .. cf["icon"] .. ".png"
        datas['name'] = cf["name"]
    end
    return datas
end

-- 判断是否接壤 没有算路
function isBorder(c)
    local bCaptured = CaptiveMgr:isCaptured()
    for x = -1, 1 do
        for y = -1, 1 do
            if (x ~= 0 or y ~= 0) then
                local data = gameMap.mapCellDatas[me.getIdByCoord(cc.p(c.x + x, c.y + y))]
                if data then
                    local occ = data:getOccState()
                    if bCaptured then
                        -- 沦陷状态
                        if occ == OCC_STATE_OWN then
                            return true
                        end
                    else
                        if occ == OCC_STATE_OWN or occ == OCC_STATE_ALLIED or occ == OCC_STATE_CAPTIVE then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end
-- 迁城判断
function isGrid(c)
    for x = -1, 1 do
        for y = -1, 1 do
            local data = gameMap.mapCellDatas[me.getIdByCoord(cc.p(c.x + x, c.y + y))]
            if data then
                local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(c.x + x, c.y + y))
                if me.toNum(data:getOccState()) ~= OCC_STATE_OWN or data.pointType ~= POINT_NORMAL then
                    print("1111")
                    return false
                end
                if gid and gid >= 41 and gid <= 75 then
                    -- 判断是否为路
                    return false
                end
            else
                return false
            end
        end
    end
    for x = -4, 4 do
        for y = -4, 4 do
            if (c.x + x) > 0 and(c.x + x) < 1200 and(c.y + y) > 0 and(c.y + y) < 1200 then
                local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(c.x + x, c.y + y))
                print(gid)
                if gid and gid >= 41 and gid <= 75 then
                    return false
                end
            else
                return false
            end

        end
    end
    return true
end
function resetFortState()
    gameMap.fortDatas = { }
end
function getConnectedRoadByGird(g)
    if g >= 41 and g <= 45 then
        return 241
    elseif g >= 46 and g <= 50 then
        return 242
    elseif g >= 51 and g <= 55 then
        return 243
    elseif g >= 56 and g <= 60 then
        return 244
    elseif g >= 61 and g <= 65 then
        return 246
    elseif g >= 66 and g <= 70 then
        return 250
    elseif g >= 71 and g <= 75 then
        return 255
    elseif g >= 241 then
        return g
    end
end
function checkHaveNotice(bclick)
    local nid = SharedDataStorageHelper():getCurNoticeId()
    if nid == nil or nid == "" then
        nid = 0
        SharedDataStorageHelper():setCurNoticeId("0")
    end
    me.getHttpString(nocticUrl, function(res)
        local sampleJson = [[{"id":"167","countx":[{"title":"<txt0019,ffc262>许愿珠活动&","count":"<txt0016,ffffff>活动时间：7月18日-7月23日#n&<txt0016,ffffff>活动区服：全服#n&<txt0016,ffffff>活动内容：回馈玩家买塔罗牌参与占卜活动，消耗一个塔罗牌，并为各位领主随机占卜出一个宝藏坐标，并显示 “宝藏位置 ”, 前去击败守卫宝藏的怪物！击败成功后，会得到不同的许愿珠。玩家可以选择想要消耗的许愿珠类型，许愿珠类型不同，许愿时获得的奖励也不同，选择许愿珠时，右侧的奖励也会变化。当集齐七种许愿珠，可以在活动界面合成神龙秘宝，开启成神龙秘宝，可以获得大量奖励。祝各位愉快玩耍！#n&<txt0016,ffffff>活动规则：#n&"},{"title":"<txt0019,ffc262>跨服战排行榜&","count":"<txt0016,ffffff>14区#n&<txt0016,ffffff>28区#n&<txt0016,ffffff>47区#n&"}]}]]
        local tb = me.cjson.decode(res)
        dump(tb)
        if tb == nil then return end
        local id = me.toNum(tb.id)
        --  if tb.countx == nil  then return end
        --  local str = tb.content
        if bclick then
            if table.nums(tb) ~= 0 then
                local nlayer = noticeLayer:create("noticeLayer.csb")
                me.runningScene():addChild(nlayer, me.POPUPZODER)
                if tb.countx == nil then
                    nlayer:oldInit(tb.content)
                else
                    nlayer:initWithStr(tb)
                end
                me.showLayer(nlayer, "bg")
                SharedDataStorageHelper():setCurNoticeId(me.toStr(id))
            else
                showTips("暂无公告")
            end
        else
            if id and me.toNum(nid) < id and table.nums(tb) ~= 0 then
                local nlayer = noticeLayer:create("noticeLayer.csb")
                me.runningScene():addChild(nlayer, me.POPUPZODER)
                if tb.countx == nil then
                    nlayer:oldInit(tb.content)
                else
                    nlayer:initWithStr(tb)
                end
                me.showLayer(nlayer, "bg")
                SharedDataStorageHelper():setCurNoticeId(me.toStr(id))
            end
        end
    end , function()
        print("暂无公告")
    end )
end
function CrossSeverRank(callFunc)
    local pURL = http_ip .. "/cross/get"
    me.getHttpString(pURL, function(res)
        me.tableClear(user.CrossSeverRank)
        local tb = me.cjson.decode(res)
        if tb == nil then return end
        for key, var in pairs(tb.cn) do
            dump(var)
            local pData = Cross_SeverRank.new(var.server, var.data, var.begin, var.close, var.name)
            table.insert(user.CrossSeverRank, pData)
        end
        callFunc()
    end )
end
-- 判断是否靠近路 如果是 返回路的坐标
function isNearLoad(c)
    local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(c.x, c.y))
    if gid and((gid >= 41 and gid <= 75) or gid >= 241) then
        return false
    end
    for x = -1, 1 do
        for y = -1, 1 do
            if (x ~= 0 or y ~= 0) then
                local gid, _ = pWorldMap.floor:getTileGIDAt(cc.p(c.x + x, c.y + y))
                print("gid = " .. gid)
                if gid and((gid >= 41 and gid <= 75) or gid >= 241) then
                    return cc.p(c.x + x, c.y + y)
                end
            end
        end
    end

    return false
end
-- 判断是否可以修建据点
function isCanBuildBastion(c)
    local cell = pWorldMap:getCellDataByCrood(c)
    if cell and cell.pointType == POINT_NORMAL then
        return true
    end
    return false
end
-- [Comment] 行军距离
-- 路径 paths = { oir,tag,list}
--
function getMarchDis(paths)
    local s_cell = 0
    local s_road = 0
    local dis = cc.pGetDistance(paths.ori, paths.tag)
    s_cell = dis
    s_road = 0
    return s_cell, s_road
end
-- [Comment] 行军时间
-- 起始点，终点，最低行军速度(地图坐标系)
function getMarchTimeTwoPoint(op, tp, v)
    local dis = cc.pGetDistance(op, tp) * 240
    local t = dis /(v * 5)
    print("time = " .. t)
    return t
end
-- 获取自己的领主信息
function getUserLordData()
    local data = gameMap.overLordDatas[user.uid]
    return data
end
-- 跳转至内城采集点（草莓地，矿石堆）
function jumpToRandomRes()
    local tar = nil
    for key, var in pairs(mainCity.resMoudles) do
        if var.optBtn and var.optBtn:isVisible() then
            -- 待采集状态
            tar = var
            break
        end
    end
    if tar then
        cameraLookAtNode(tar)
    else
        showTips("暂无可采集资源点")
    end
end

-- 镜头跳转至可收获的资源点，如果没有一个可收获的，就随机找一个资源点
function jumpToResourceTarget()
    local resMoudle = nil
    local findOut = false
    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        if tmp.type == "food" or tmp.type == "lumber" or tmp.type == "stone" then
            resMoudle = var
            if var.gainBtn and var.gainBtn:isVisible() then
                -- 可收获状态
                findOut = true
                break
            end
        end
    end
    if findOut == false then
        for key, var in pairs(mainCity.resMoudles) do
            if var.gainBtn and var.gainBtn:isVisible() then
                -- 可收获状态
                resMoudle = var
                break
            end
        end
    end
    cameraLookAtNode(resMoudle)
end

-- 根据状态判断是否弹窗建造，还是移动镜头显示加速道具等
function jumpTypeByTarget(tar, tTpye_)
    if tar and tar:getData().state ~= BUILDINGSTATE_NORMAL.key then
        -- 跳转镜头至地图所在位置
        cameraLookAtNode(tar, function()
            tar:showBuildingMenu()
        end )
    elseif tar then
        -- 跳转升级UI
        local nextbuildingDef = tar:getData():getNextLevelDef()
        if nextbuildingDef then
            local function callBack(node)
                local nextbuildingData = BuildIngData.new(tar:getToftId(), nextbuildingDef.id, 0)
                mainCity.bLevelUpLayer = buildLevelUpLayer:create("buildLevelUpLayer.csb")
                mainCity.bLevelUpLayer:initWithData(nextbuildingData, tar.toftid)
                mainCity:addChild(mainCity.bLevelUpLayer, me.MAXZORDER)
                me.showLayer(mainCity.bLevelUpLayer, "bg")
            end
            cameraLookAtNode(tar, callBack)
        end
    else
        -- 跳转建造UI
        mainCity.bshopBox = buildShopView:create("buildShopLayer.csb")
        if tTpye_ then
            mainCity.bshopBox:setGuideTarget(tTpye_)
        end
        mainCity:addChild(mainCity.bshopBox, me.MAXZORDER);
        -- me.showLayer(mainCity.bshopBox, "shopbg")
        buildingOptMenuLayer:getInstance():clearnButton()
    end
end

-- 跳转至联盟界面
function jumpToAlliancecreateView()
    if user.familyUid > 0 then
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.allianceInfor = false
        else
            pWorldMap.allianceInfor = false
        end
        NetMan:send(_MSG.getFamilyInfor())
        -- 获取联盟信息
    else
        local alliancecreateView = alliancecreateView:create("alliance/alliancecreate.csb")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity:addChild(alliancecreateView, me.MAXZORDER)
            buildingOptMenuLayer:getInstance():clearnButton()
        else
            pWorldMap:addChild(alliancecreateView, me.MAXZORDER)
        end
        me.showLayer(alliancecreateView, "bg_frame")
       -- NetMan:send(_MSG.getAllianceCd())
        NetMan:send(_MSG.getListFamily())
--        local tips = me.createNode("MessageBox_AllianceTips.csb")
--        me.registGuiClickEventByName(tips,"btn_ok",function (node)
--              tips:removeFromParentAndCleanup()
--        end)
--        me.popLayer(tips)
    end
end

function jumpToTechBuilding()
    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        local strTab = me.split(tmp.button, ",")
        for key, var in pairs(strTab) do
            if var == "study" then
                local function callBack(node)
                    if TaskHelper.bTarget then
                        local tv = techView:getInstance()
                        tv:initData(TaskHelper.bTarget:getDef().id, TaskHelper.bTarget.toftid)
                        mainCity:addChild(tv, 100)
                        me.showLayer(tv, "bg")
                    end
                end
                TaskHelper.bTarget = jumpToTargetExt(tmp.type, true, callBack)
                break
            end
        end
    end
end

-- 跳转至指定类型兵营
function jumpToAnyArmyBuildingByTypes(types_, cb_)
    local targetB = nil
    -- 空闲的最高等级的兵营
    local targetC = nil
    -- 非空闲的任意兵营
    local targetTypes = types_
    local targetLv = 0
    local function isTargetType(tmpType_)
        for key, var in pairs(targetTypes) do
            if tmpType_ == var then
                return true
            end
        end
        return false
    end

    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        if isTargetType(tmp.type) then
            if var and(var:getData().state == BUILDINGSTATE_NORMAL.key or var:getData().state == BUILDINGSTATE_WORK_TRAIN.key) and tmp.level > targetLv then
                targetB = var
                targetLv = tmp.level
            else
                targetC = var
            end
        end
    end

    if targetB == nil and targetC == nil then
        showTips("没有可用的兵营")
        return
    elseif targetB then
        cameraLookAtNode(targetB, cb_)
        return targetB
    elseif targetC then
        cameraLookAtNode(targetC, function()
            tar:showBuildingMenu()
        end )
        return targetC
    end
end

-- 根据类型查找低于bLv等级的建筑物(任务：修建xx个xx等级的建筑物)
function jumpToTargetExt2(bType_, bLv_, cb_)
    local tar = nil
    for key, var in pairs(mainCity.buildingMoudles) do
        -- 优先查找可以升级的
        local tmp = var:getData():getDef()
        if tmp.type == bType_ then
            if me.toNum(tmp.level) < me.toNum(bLv_) and var:getData().state == BUILDINGSTATE_NORMAL.key then
                tar = var
                break
            end
        end
    end
    if tar == nil then
        for key, var in pairs(mainCity.buildingMoudles) do
            -- 其次查找正在升级可以加速的
            local tmp = var:getData():getDef()
            if tmp.type == bType_ then
                if me.toNum(tmp.level) <= me.toNum(bLv_) and(var:getData().state == BUILDINGSTATE_BUILD.key or var:getData().state == BUILDINGSTATE_LEVEUP.key) then
                    tar = var
                    break
                end
            end
        end
    end
    jumpTypeByTarget(tar, bType_)
end

-- 根据类型查找目前等级最高的建筑物
function jumpToTargetExt(tTpye_, justMove_, cb_)
    local tar = nil
    local curBlv = nil
    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        if tmp.type == tTpye_ and(curBlv == nil or curBlv < tmp.level) then
            curBlv = tmp.level
            tar = var
        end
    end
    if tar and justMove_ then
        if tar:getData().state ~= BUILDINGSTATE_NORMAL.key then
            cameraLookAtNode(tar, function()
                tar:showBuildingMenu()
            end )
        else
            cameraLookAtNode(tar, cb_)
        end
    else
        jumpTypeByTarget(tar, tTpye_)
    end
    return tar
end
-- 根据类型查找目前等级最高的建筑物
function jumpToTargetAndShowMenu(tTpye_)
    local tar = nil
    local curBlv = nil
    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        if tmp.type == tTpye_ and(curBlv == nil or curBlv < tmp.level) then
            curBlv = tmp.level
            tar = var
        end
    end
    if tar then
        cameraLookAtNode(tar, function()
            tar:showBuildingMenu()
        end )
    end
    return tar
end

-- 找到指定的类型和状态的建筑物
function getTargetMoudlesByOpt(type_, status_)
    --    print("type_,status_ = "..type_.."  "..status_)
    local tarIndex = nil
    local arr = nil
    if status_ == BUILDINGSTATE_BUILD.key or status_ == BUILDINGSTATE_BUILD.key then
        arr = user.buildingDateLine
    else
        arr = user.building
    end
    for key, var in pairs(arr) do
        --        print("var.state = "..var.state)
        --        print("var:getDef().type = "..var:getDef().type)
        if var.state == status_ and var:getDef().type == type_ then
            tarIndex = key
            break
        end
    end
    if tarIndex then
        return mainCity.buildingMoudles[tarIndex]
    end
    return nil
end

-- 根据传入的id号来查找当前最高等级的建筑物
function jumpToTarget(ndata_, type_)
    local def = cfg[CfgType.BUILDING][me.toNum(ndata_.id)]
    local tar = nil
    local curBlv = nil
    for key, var in pairs(mainCity.buildingMoudles) do
        local tmp = var:getData():getDef()
        local state = var:getData().state
        if tmp.type == def.type and(curBlv == nil or curBlv < tmp.level) then
            curBlv = tmp.level
            tar = var
        end
    end
    jumpTypeByTarget(tar, type_)
end
-- 获取四周的坐标点
function getNearCrood(c)
    local res = { }
    for x = -1, 1 do
        for y = -1, 1 do
            if (x ~= 0 or y ~= 0) then
                table.insert(res, cc.p(c.x + x, c.y + y))
            end
        end
    end
    return res
end
function getThroneNearCrood(c)
    local res = { }
    for x = -3, 3 do
        for y = -3, 3 do
            if (x ~= 0 or y ~= 0) then
                table.insert(res, cc.p(c.x + x, c.y + y))
            end
        end
    end
    return res
end

-- 根据道具id和shopid找到对应的商城配置表的Id
function convertItemIdToShopId(shopid, itemId)
    for key, var in pairs(cfg[SHOP]) do

    end
end
-- 考古
function setBookAltas()
    local pBookMenu = cfg[CfgType.BOOKMENU]
    local pBook = cfg[CfgType.BOOK]
    me.tableClear(mBookAltasNum)
    for key, Mvar in pairs(pBookMenu) do
        local pTable = { }
        for key, var in pairs(pBook) do
            local pId = Mvar["id"]
            if Mvar["id"] == var["bookId"] then
                local p = { }
                p.id = var["id"]
                print(var.id)
                local pNeedData = me.split(var["recipe"], ",")
                local pNum = getBookNum(pNeedData)
                p.num = pNum
                pTable[var["id"]] = p
            end
        end
        mBookAltasNum[key] = pTable
    end
end
function getBookNum(pNeedData)
    local pMulitNum = 0
    for key, var in pairs(pNeedData) do
        local pGoodsData = me.split(var, ":")
        local pId = pGoodsData[1]
        local pNeedNum = pGoodsData[2]
        local pBool = false
        for key, var in pairs(user.bookPkg) do
            if var["defid"] == me.toNum(pId) then
                pBool = true
                if me.toNum(var["count"]) >= me.toNum(pNeedNum) then
                    local pCurrentNum = math.floor(var["count"] / pNeedNum)
                    if pMulitNum == 0 then
                        pMulitNum = pCurrentNum
                    end
                    pMulitNum = math.min(pCurrentNum, pMulitNum)
                else
                    pMulitNum = 0
                    return pMulitNum
                end
            end
        end
        for key, var in pairs(user.bookEquip) do
            if var["defid"] == me.toNum(pId) then
                pBool = true
                if me.toNum(var["count"]) >= me.toNum(pNeedNum) then
                    local pCurrentNum = math.floor(var["count"] / pNeedNum)
                    if pMulitNum == 0 then
                        pMulitNum = pCurrentNum
                    end
                    pMulitNum = math.min(pCurrentNum, pMulitNum)
                else
                    pMulitNum = 0
                    return pMulitNum
                end
            end
        end
        if pBool == false then
            pMulitNum = 0
            return pMulitNum
        end
    end
    return pMulitNum
end

function setNoticeinfo(pId, pData, pBool, pDTime)
    local pInfo = { }
    pInfo.id = pId
    pInfo.text = pData
    if pBool == true then
        pInfo.time = me.sysTime()
    else
        pInfo.time = pDTime
    end
    table.insert(mNoticeInfo, 1, pInfo)
    -- dump(mNoticeInfo)
    local pPrentTime = me.sysTime()
    -- 当前时间
    for key, var in pairs(mNoticeInfo) do
        local pTime = var["time"]
        if key < 21 then
            if pPrentTime >(pTime +(3600 * 6) * 1000) then
                mNoticeInfo[key] = nil
            end
        else
            mNoticeInfo[key] = nil
        end
    end
    if pBool == true then
        SharedDataStorageHelper():setNoticeInfo(user.uid)
    end
end
function getMailHintRed()
    if user.mailList ~= nil then
        for key, var in pairs(user.mailList) do
            if var.type == 3 then
                if var["status"] ~= -1 then
                    return true
                end
            end
        end
    end
    return false
end
function getMailSpyHintRed()
    if user.mailList ~= nil then
        for key, var in pairs(user.mailList) do
            if var.type == 4 then
                if var["status"] ~= -1 then
                    return true
                end
            end
        end
    end
    return false
end
function getMailSystemHintRed()
    if user.mailList ~= nil then
        for key, var in pairs(user.mailList) do
            if var.type == 2 then
                if var["status"] ~= -2 then
                    if var["itemList"] ~= nil then
                        return true
                    end
                end
            end
        end
    end
    return false
end
-- 获取背包道具数量
function getItemNum(itemid)
    local count = 0
    local def = cfg[CfgType.ETC][itemid]
    if itemid == 9001 then
        return user.food
    elseif itemid == 9002 then
        return user.wood
    elseif itemid == 9003 then
        return user.stone
    elseif itemid == 9004 then
        return user.gold
    elseif itemid == 9017 then
        return user.paygem
    elseif itemid == 9008 then
        return user.diamond
    elseif def.useType == 136 or def.useType == 137 then
        for key, var in pairs(user.metaRefitBackpack) do
            if var.defid == tonumber(itemid) then
                count = count + var.count
            end
        end
    else
        for key, var in pairs(user.pkg) do
            if var.defid == tonumber(itemid) then

                count = count + var.count
            end
        end
    end
    return count
end
-- 用于得到物品的动画展示
-- local i = {}
-- for var = 1, 10 do
--    i[#i+1] = {}
--    i[#i]["defId"] = 25+var
--    i[#i]["itemNum"] = var
--    i[#i]["needColorLayer"] = true -- 是否需要加蒙层
-- end
-- getItemAnim(i)
getItemAnim_itemQueue = nil
getItemAnim_itemLayer = nil
singleItem = nil
function getItemAnim(infoDatas_)
    if table.nums(infoDatas_) == 0 then
        return
    end
    local function pushData(data_)
        if data_ then
            Queue.push(getItemAnim_itemQueue, data_)
        end
    end
    if getItemAnim_itemQueue == nil then
        getItemAnim_itemQueue = Queue.new()
        pushData(infoDatas_)
    elseif infoDatas_ then
        pushData(infoDatas_)
        return
    end
    if getItemAnim_itemLayer == nil then
        getItemAnim_itemLayer = ccui.Layout:create()
        getItemAnim_itemLayer:setContentSize(cc.size(me.winSize.width, me.winSize.height))
        getItemAnim_itemLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        getItemAnim_itemLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        getItemAnim_itemLayer:setBackGroundColorOpacity(110)
        getItemAnim_itemLayer:setAnchorPoint(cc.p(0, 0))
        getItemAnim_itemLayer:setPosition(cc.p(0, 0))
        me.runningScene():addChild(getItemAnim_itemLayer, me.ANIMATION)
    end
    local nums = 0
    local rows = 7
    -- 程序渐变特效
    local function playItemAnim(data, idx)
        itemdata_ = data[idx + 1]
        if itemdata_ == nil then
            return
        end
        local def = cfg[CfgType.ETC][itemdata_.defId]
        ----test-----
        local goodsIcon = ""
        local quality = 1
        if itemdata_.is_rune then
            -- 表示该道具类型为符文
            def = cfg[CfgType.RUNE_DATA][itemdata_.defId]
            quality = def.level
            goodsIcon = getRuneIcon(def.icon)
        else
            goodsIcon = "item_" .. def.icon .. ".png"
            quality = def.quality
        end
        ----end-----
        singleItem = me.createNode("Node_rewardItem.csb"):getChildByName("rewardItem"):clone()
        singleItem:setCascadeOpacityEnabled(true)
        singleItem:setOpacity(0)
        local tempItem = singleItem
        local tempItemData = itemdata_
        me.assignWidget(singleItem, "rewardItem"):setSwallowTouches(false)
        me.assignWidget(singleItem, "Goods_Icon"):loadTexture(goodsIcon, me.localType)
        if itemdata_.is_rune then
            me.assignWidget(singleItem, "Goods_Icon"):ignoreContentAdaptWithSize(false)
        end
        me.assignWidget(singleItem, "Image_quality"):loadTexture(getQuality(quality), me.localType)
        me.assignWidget(singleItem, "label_num"):setString(itemdata_.itemNum or 1)
        me.assignWidget(singleItem, "Text_name"):setString(def.name)
        me.fixFontWidth(me.assignWidget(singleItem, "Text_name"),120)
        singleItem:setAnchorPoint(cc.p(0.5, 0.5))
        local isize = singleItem:getContentSize()
        local spw = math.min(50,(me.winSize.width - isize.width * rows) /(rows + 1))
        local ofx =(me.winSize.width - rows *(isize.width + spw)) / 2
        if getItemAnim_itemLayer then
            getItemAnim_itemLayer:addChild(singleItem)
            singleItem:setPosition(cc.p(ofx + spw +(isize.width + spw) *(idx % rows), me.winSize.height / 2 + isize.height - 50 -(isize.height + 50) * math.floor(idx / rows)))
            idx = idx + 1
        end
        -- 美术光效
        local pAnim = mAnimation.new("item_ani")
        pAnim:fishPaly("idle")
        pAnim:setPosition(cc.p(singleItem:getContentSize().width / 2, singleItem:getContentSize().height / 2))
        if me.assignWidget(singleItem, "Panel_artNight") then
            me.assignWidget(singleItem, "Panel_artNight"):addChild(pAnim)
        end
        local fi = cc.FadeIn:create(0.3)
        local dey = cc.DelayTime:create(0.5)
        local func = cc.CallFunc:create( function()
            -- playItemAnim()
            if tempItemData and tempItemData.cb then
                tempItemData.cb(tempItem, idx)
            end
        end )
        local seq = cc.Sequence:create(fi, dey, func)
        singleItem:runAction(seq)
    end
    local function playani()
        if (not Queue.isEmpty(getItemAnim_itemQueue)) then
            local itemData = Queue.pop(getItemAnim_itemQueue)
            nums = table.nums(itemData)
            if nums < rows then
                rows = nums
            end
            for var = 1, nums do
                playItemAnim(itemData, var - 1)
            end
        else
            if getItemAnim_itemLayer then
                getItemAnim_itemLayer:removeFromParentAndCleanup(true)
                getItemAnim_itemLayer = nil
            end
            getItemAnim_itemQueue = nil
            singleItem = nil
        end
    end
    playani()
    if getItemAnim_itemLayer then
        me.registGuiTouchEvent(getItemAnim_itemLayer, function(node, event)
            print("ddsdsdd", event)
            if event ~= ccui.TouchEventType.ended then
                return
            end
            singleItem:removeFromParentAndCleanup()
            playani()
            if not Queue.isEmpty(UserModel.msgControlQueue) then
                 local msg = Queue.pop(UserModel.msgControlQueue)
                 UserModel:reviceData(msg,mCross_Sever_Out,true)
            end
        end )
    end
end
function getRuneAni(runeDataList, callBackfunc)
    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames("animation/EnlistBg.plist")
    cache:addSpriteFrames("animation/EnlistFront.plist")
    local parentNode = cc.Director:getInstance():getRunningScene()
    local rootLayer = parentNode:getChildByName("rootLayer")
    if rootLayer then
        rootLayer:removeFromParent()
    end

    local b = false

    local item = runeItem:create("rune/runeItem.csb")
    item:setAnchorPoint(cc.p(0.5, 0.5))

    rootLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 180), me.winSize.width, me.winSize.height)
    rootLayer:setName("rootLayer")
    parentNode:addChild(rootLayer, 1000)
    rootLayer:setPosition(cc.p(0, 0))
    rootLayer:addChild(item, 100)
    item:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))

    -- 卡牌延时显示动画
    local callFunc = function()
        item:setVisible(true)
        item:setOpacity(0)
        local fadeTo = cc.FadeTo:create(0.3, 255)

        item:runAction(cc.Sequence:create(fadeTo, cc.CallFunc:create( function()
            b = false
        end )))
    end

    -- 卡牌背景动画
    local bgEffect = cc.Sprite:createWithSpriteFrameName("jianglingkapaibeijing_00000.png")
    bgEffect:setAnchorPoint(cc.p(0.5, 0.5))
    bgEffect:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    bgEffect:setScale(4)
    rootLayer:addChild(bgEffect, 99)
    local cache = cc.SpriteFrameCache:getInstance()
    local animFrames = { }
    for j = 1, 10 do
        local frame = cache:getSpriteFrame("jianglingkapaibeijing_0000" .. j - 1 .. ".png")
        if frame == nil then
            break
        end
        animFrames[j] = frame
    end
    -- 卡牌前景动画
    local froneEffect = cc.Sprite:createWithSpriteFrameName("gaojikapai_00000.png")
    froneEffect:setAnchorPoint(cc.p(0.5, 0.5))
    froneEffect:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 15))
    froneEffect:setScale(2)
    rootLayer:addChild(froneEffect, 101)
    local animFrames2 = { }
    for j = 1, 20 do
        local str
        str = string.format("gaojikapai_000%02d.png", j - 1)
        local frame = cache:getSpriteFrame(str)
        if frame == nil then
            break
        end
        animFrames2[j] = frame
    end

    local function playGetAnimation()
        b = true

        item:setVisible(false)
        item:stopAllActions()
        me.DelayRun(callFunc, 0.25, item)

        bgEffect:stopAllActions()
        local animation = cc.Animation:createWithSpriteFrames(animFrames, 0.13)
        local ani1 = cc.Animate:create(animation)
        bgEffect:runAction(cc.RepeatForever:create(ani1))

        froneEffect:stopAllActions()
        local animation2 = cc.Animation:createWithSpriteFrames(animFrames2, 0.05)
        local ani2 = cc.Animate:create(animation2)
        froneEffect:runAction(ani2)
    end

    local runeData = runeDataList[1]
    if not runeData then
        rootLayer:removeFromParent()
        if callBackfunc then
            callBackfunc()
        end
        return
    end
    item:setData(runeData)
    playGetAnimation()

    local index = 1
    local function onTouchBegin(touch, event)
        if b then
            return false
        else
            return true
        end
    end
    local function onTouchMove(touch, event)
        return true
    end
    local function onTouchEnd(touch, event)
        local nextRuneData = runeDataList[index + 1]
        index = index + 1
        if nextRuneData then
            item:setData(nextRuneData)
            playGetAnimation()
        else
            rootLayer:removeFromParent()
            if callBackfunc then
                callBackfunc()
            end
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED);
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED);
    rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, rootLayer);
end
function getRuneAnim(data)
    local getItemAnim_itemLayer = ccui.Layout:create()
    getItemAnim_itemLayer:setContentSize(cc.size(me.winSize.width, me.winSize.height))
    getItemAnim_itemLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    getItemAnim_itemLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    getItemAnim_itemLayer:setBackGroundColorOpacity(0)
    getItemAnim_itemLayer:setAnchorPoint(cc.p(0, 0))
    getItemAnim_itemLayer:setPosition(cc.p(0, 0))

    me.runningScene():addChild(getItemAnim_itemLayer, me.GUIDEZODER)


    -- 美术光效
    local pAnim = mAnimation.new("item_ani")
    pAnim:fishPaly("idle")
    pAnim:setPosition(cc.p(getItemAnim_itemLayer:getContentSize().width / 2, getItemAnim_itemLayer:getContentSize().height / 2))
    pAnim:setScale(3)
    getItemAnim_itemLayer:addChild(pAnim)

    data.cfgId = data.defId
    local singleItem = runeItem:create("rune/runeItem.csb")
    singleItem:setData(data)
    singleItem:setAnchorPoint(0.5, 0.5)
    getItemAnim_itemLayer:addChild(singleItem)
    singleItem:setPosition(cc.p(getItemAnim_itemLayer:getContentSize().width / 2, getItemAnim_itemLayer:getContentSize().height / 2))

    local function clearAndNextAnim()
        singleItem:stopAllActions()
        singleItem:removeFromParentAndCleanup(true)
        singleItem = nil

        getItemAnim_itemLayer:removeFromParentAndCleanup(true)
    end

    me.registGuiTouchEvent(getItemAnim_itemLayer, function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        clearAndNextAnim()
    end )

    local fi = cc.FadeIn:create(0.25)
    local dey = cc.DelayTime:create(1.7)
    local fo = cc.FadeOut:create(0.25)
    local func = cc.CallFunc:create( function()
        getItemAnim_itemLayer:removeFromParentAndCleanup(true)
    end )
    local seq = cc.Sequence:create(fi, dey, fo, func)
    singleItem:runAction(seq)

end

ThroneAnim_itemQueue = nil
function ThroneAnim(infoDatas_)
    local function pushData(data_)
        if data_ then
            Queue.push(ThroneAnim_itemQueue, data_)
        end
    end

    if ThroneAnim_itemQueue == nil then
        ThroneAnim_itemQueue = Queue.new()
        pushData(infoDatas_)
    elseif infoDatas_ then
        pushData(infoDatas_)
    end
end
function openNewBtnAnim(openId_, parentNode_, btnNode_, callFunc_)
    if mainCity and mainCity.taskview ~= nil then
        -- 关闭任务界面
        mainCity.taskview:close()
    end

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    layout:setBackGroundColor(cc.c3b(0, 0, 0))
    layout:setBackGroundColorOpacity(90)
    layout:setAnchorPoint(cc.p(0, 0))
    layout:setPosition(cc.p(0, 0))
    layout:setSwallowTouches(true)
    layout:setTouchEnabled(true)
    parentNode_:addChild(layout, me.POPUPZODER)

    local def = cfg[CfgType.BUTTONSTATUS][me.toNum(openId_)]
    local fi = cc.FadeIn:create(0.5)
    local del = cc.DelayTime:create(1)
    local cb = cc.CallFunc:create( function()
        layout:removeFromParentAndCleanup(true)
        if btnNode_ then
            btnNode_:setVisible(true)
            me.setButtonDisable(btnNode_, true)
            if openId_ == OpenButtonID_TaskBtn then
                --任务按钮
                btnNode_:getChildByName("ArmatureNode_task"):setVisible(true)
            else
                btnNode_:getChildByName("ArmatureNode_Panel"):setVisible(true)
            end
        end
        callFunc_()
    end )
    local seq = cc.Sequence:create(fi, del, cb)
    if btnNode_ then
        local tmpX, tmpY = btnNode_:getPosition()
        local mt = cc.MoveTo:create(0.5, cc.p(tmpX, tmpY))
        seq = cc.Sequence:create(fi, del, mt, cb)
    end
    tmpImage = ccui.ImageView:create()
    tmpImage:loadTexture(def.icon .. ".png", me.localType)
    tmpImage:setPosition(cc.p(layout:getContentSize().width / 2, layout:getContentSize().height / 2 + 40))
    layout:addChild(tmpImage)
    tmpImage:setOpacity(0)
    tmpImage:runAction(seq)

    tmptitleImage = ccui.ImageView:create()
    tmptitleImage:loadTexture("texiao_zhi_xingongneng.png", me.localType)
    tmptitleImage:setPosition(cc.p(layout:getContentSize().width / 2, layout:getContentSize().height / 2 - 40))
    tmptitleImage:setOpacity(0)
    layout:addChild(tmptitleImage)
    local fi2 = cc.FadeIn:create(0.5)
    local del2 = cc.DelayTime:create(1)
    local fo2 = cc.FadeOut:create(0.2)
    local seq2 = cc.Sequence:create(fi2, del2, fo2)
    tmptitleImage:runAction(seq2)
    -- 屏蔽聊天按钮移动位置
    --    if openId_ == OpenButtonID_Battle and mainCity.Node_chat then
    --        local del = cc.DelayTime:create(1.5)
    --        local mt = cc.MoveTo:create(0.5, cc.p(192, 0))
    --        local seq = cc.Sequence:create(del, mt)
    --        mainCity.Node_chat:runAction(seq)
    --    end
end
-- 开启新按钮
-- type_:2正在进行中 , 4 任务完成
function openNewButtonByOpenBtnId(btnid)   
        -- 完成任务/领取奖励后开启
        me.dispatchCustomEvent("weChatView")
        local btn = getOpenBtnByTaskID(btnid)
        local pView = mainCity
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pView = pWorldMap
        end
        if btnid == OpenButtonID_Battle then
            --出外城引导
            guideHelper.setGuideIndex(guideHelper.guideConquest)
            guideHelper.saveGuideIndex()
            guideHelper.nextTaskStep()
        elseif btnid == OpenButtonID_LookMail then
            guideHelper.setGuideIndex(guideHelper.guideReport)
            guideHelper.saveGuideIndex()
            guideHelper.nextTaskStep()
        elseif btnid == OpenButtonID_Arch then
            guideHelper.setGuideIndex(guideHelper.guideGoToArch)
            guideHelper.saveGuideIndex()
            guideHelper.nextTaskStep()
        elseif OpenButtonID_ALLOTERWORKER == btnid then
            if CUR_GAME_STATE == GAME_STATE_CITY then
                me.dispatchCustomEvent("taskCaphterLayerClose")
                guideHelper.setGuideIndex(guideHelper.guideAllot)
                guideHelper.saveGuideIndex()
                guideHelper.nextTaskStep()
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                guideHelper.setGuideIndex(guideHelper.guideAllot)
                guideHelper.saveGuideIndex()
                pWorldMap:goCityView()
            end        
        elseif OpenButtonID_ComArch == btnid then
            if CUR_GAME_STATE == GAME_STATE_CITY then
                me.dispatchCustomEvent("taskCaphterLayerClose")
                guideHelper.setGuideIndex(guideHelper.guideComArch)
                guideHelper.saveGuideIndex()
                guideHelper.nextTaskStep()
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                guideHelper.setGuideIndex(guideHelper.guideComArch)
                guideHelper.saveGuideIndex()
                pWorldMap:goCityView()
            end      
        end
        if btn then
            openNewBtnAnim(btnid, pView, btn, function()
                user.newBtnIDs[me.toStr(btnid)] = btnid
            end )
        end
end

function getTime(pTime)
    local pCurrentTime = me.sysTime() / 1000
    -- 当前时间
    local pDifferTime =(pCurrentTime - pTime)
    -- 差值
    local pYear = math.floor(pDifferTime /(60 * 60 * 24 * 365))
    -- 几年前
    if pYear > 0 then
        return pYear .. "年前"
    end
    local pMonth = math.floor(pDifferTime /(60 * 60 * 24 * 30))
    -- 几月前
    if pMonth > 0 then
        return pMonth .. "个月前"
    end
    local pDay = math.floor(pDifferTime /(60 * 60 * 24))
    -- 几天前
    if pDay > 0 then
        if pDay == 1 then
            return "昨天"
        else
            return pDay .. "天前"
        end
    end
    local hour = math.floor(pDifferTime /(60 * 60))
    -- 几小时前
    if hour > 0 then
        return hour .. "小时前"
    end
    local min = math.floor(pDifferTime / 60)
    -- 几分钟前
    if min > 0 then
        return min .. "分钟前"
    end
    return "刚刚"
end
-- 考古背包的道具数量
function getArchPropNum(pUid)
    local pNum = 0
    if user.bookPkg ~= nil then
        for key, var in pairs(user.bookPkg) do
            if var["uid"] == pUid then
                pNum = var.count
                return pNum
            end
        end
    end
    return pNum
end
function ThroneInit(list)
    local pThroneTab = { }
    for key, var in pairs(list) do
        local pListStr = string.split(var, ",")
        local pConfig = cfg[CfgType.NOTICE_INFO][me.toNum(pListStr[1])]
        local pConfigStr = me.split(pConfig["data"], "|")
        local pStr = ""
        for key, var in pairs(pConfigStr) do
            if key == 1 then
                pStr = var
            else
                local pListVar = pListStr[key + 1]
                if pListVar == nil then
                    break
                end
                if pListVar == "" then
                    pListVar = "流浪"
                end
                pStr = pStr .. pListVar .. var
            end
        end
        local pTab = { }
        pTab.str = pStr
        pTab.time = pListStr[2]
        table.insert(pThroneTab, pTab)
    end

    return pThroneTab
end
-- 主城信息
function getInforStr(pData)
    local restexts = {
                    [1] = "粮食",
                    [2] = "木头",
                    [3] = "石头",
                    [4] = "金子",
                    }
    local function getLandDec(pData)
        if pData then
            local pDec = me.split(pData["extdesc"], "|")
            local pStr = ""
            for key, var in pairs(pDec) do
                local pPDec = me.split(var, ":")
                local pPName = pPDec[2]
                local pPStr = "<txt0013,e4cb79>" .. restexts[tonumber(pPDec[1])] .. "&" .. "<txt0013,e4cb79>" .. pPDec[2] .. "&"
                if key == 1 then
                    pStr = pPStr
                else
                    pStr = pStr .. "<txt0013,e4cb79>,&" .. pPStr
                end
            end
            return pStr
        end
    end
    function getCofigName(pStrData)
        local pTab = me.split(pStrData, "@")
        local pFind = string.find(pStrData, "@")
        local pStrName = pStrData
        if pFind ~= nil then
            local pCfgNameId = pTab[1]
            -- 配置文件名字
            if pCfgNameId == 3 then
                -- 特殊处理
            else
                local pCfgId = pTab[2]
                -- id
                pStrName = cfg[me.toNum(pCfgNameId)][me.toNum(pCfgId)]["name"]
            end
        end
        return pStrName
    end

    function getEtc(pStr, pId)
        local pTab = me.split(pStr, "@")
        local pEtcNStr = ""
        if pTab ~= nil then
            local pCfgNameId = pTab[1]
            -- 配置文件名字
            print(pCfgNameId)
            if (3 == me.toNum(pCfgNameId) and(pId == 29 or pId == 12 or pId == 13 or pId == 14 or pId == 15 or pId == 40)) or(16 == me.toNum(pCfgNameId) and pId == 39) then
                local pEtcData = me.cjson.decode(pTab[2])
                local i = 1
                for key, var in pairs(pEtcData) do
                    local pName = cfg[me.toNum(pCfgNameId)][me.toNum(var[1])]["name"]
                    if i == 1 then
                        pEtcNStr = pEtcNStr .. pName .. "X" .. var[2]
                    else
                        pEtcNStr = pEtcNStr .. "," .. pName .. "X" .. var[2]
                    end
                    i = i + 1
                end
            else
                pEtcNStr = getCofigName(pStr)
            end
        end
        return pEtcNStr
    end
    local pStr = ""
    if pData ~= nil then
        local pConfig = cfg[CfgType.NOTICE_INFO][me.toNum(pData["id"])]
        if pData["text"] ~= nil then
            local pStrData = me.split(pConfig["data"], "|")
            local pID = pData["id"]
            dump(pID)
            if me.toNum(pData["id"]) == 2 then
                local pLandConfig = cfg[CfgType.MAP_EVENT_DATA][me.toNum(pData["text"][4])]
                local pNameStr = pLandConfig["name"]
                local pLevelStr = pLandConfig["landlv"]
                local pDec = me.split(pLandConfig["extdesc"], ":")
                local pDecStr = getLandDec(pLandConfig)
                local pPoint = me.split(pData["text"][3], ":")
                local pTabLand = { }

                pTabLand[1] = pNameStr
                pTabLand[2] = pLevelStr
                pTabLand[3] = pPoint[1] .. "," .. pPoint[2]
                pTabLand[4] = pDecStr
                for key, var in pairs(pStrData) do
                    if key == 1 then
                        pStr = var
                    else
                        pStr = pStr .. pTabLand[key - 1] .. var
                    end
                end
            elseif me.toNum(pData["id"]) == 3 then
                local pLandConfig = cfg[CfgType.MAP_EVENT_DATA][me.toNum(pData["text"][4])]
                local pNameStr = pLandConfig["name"]
                local pLevelStr = pLandConfig["landlv"]
                local pPoint = me.split(pData["text"][3], ":")
                local pTabLand = { }
                pTabLand[1] = pNameStr
                pTabLand[2] = pLevelStr
                pTabLand[3] = pPoint[1] .. "," .. pPoint[2]
                for key, var in pairs(pStrData) do
                    if key == 1 then
                        pStr = var
                    else
                        pStr = pStr .. pTabLand[key - 1] .. var
                    end
                end
            elseif me.toNum(pData["id"]) == 32 and #pData["text"] == 1 then
                for key, var in pairs(pStrData) do
                    if key == 1 then
                        pStr = var .. "流浪" .. "]"
                    elseif key == 2 then
                        pStr = pStr .. pData["text"][1]
                    else
                        pStr = pStr .. var
                    end
                end
            elseif me.toNum(pData["id"]) == 37 and #pData["text"] == 4 then
                for key, var in pairs(pStrData) do
                    if key == 3 then
                        pStr = pStr .. var .. "流浪"
                    elseif key < 3 then
                        pStr = pStr .. var .. pData["text"][key]
                    elseif key < 6 then
                        pStr = pStr .. var .. pData["text"][key - 1]
                    else
                        pStr = pStr .. var
                    end
                end
            else
                dump(pStrData)
                for key, var in pairs(pStrData) do
                    local pStrName = getCofigName(pData["text"][1])
                    if key == 1 then
                        pStr = var .. pStrName
                    else
                        if (#pStrData) >(key) then
                            local pos = string.find(pData["text"][key], "@")
                            if not pos then
                                local pStr1 = pData["text"][key]
                                local posP = string.find(pStr1, ":")
                                if not posP then
                                    pStr = pStr .. var .. pData["text"][key]
                                else
                                    local pPoint = me.split(pStr1, ":")
                                    pStr = pStr .. var .. pPoint[1] .. "," .. pPoint[2]
                                end
                            else
                                local pStrEtc = getEtc(pData["text"][key], tonumber(pID))
                                pStr = pStr .. var .. pStrEtc

                            end
                        else
                            pStr = pStr .. var
                        end
                    end
                end
            end
        else
            pStr = pConfig["data"]
        end
    end
    return pStr, pData["time"]
end
function showInfor(pNode)
    local pSurNum = mInforHint - 1
    me.assignWidget(pNode, "Infor_node_Panel"):removeAllChildren()
    local pStr, _ = getInforStr(mNoticeInfo[mInforHint])
    local rt_infor_concent = mRichText:create(pStr, 410)
    rt_infor_concent:setAnchorPoint(cc.p(0, 1))
    rt_infor_concent:setPosition(cc.p(0, 60))
    rt_infor_concent:setScale(0.8)
    -- local pSurNum = mInforHint - 1    -- 剩余数
    me.assignWidget(pNode, "Infor_node_Panel"):addChild(rt_infor_concent)
    me.assignWidget(pNode, "Infor_num"):setString(pSurNum)
    me.assignWidget(pNode, "Infor_num"):setVisible(true)
    me.assignWidget(pNode, "Infor_num_bg"):setVisible(true)
    me.assignWidget(pNode, "Infor_next_Btn"):setVisible(true)
    me.assignWidget(pNode, "Infor_hint"):setVisible(false)
    me.assignWidget(pNode, "Infor_close_Btn"):setVisible(false)
    if mInforHint == 1 then
        me.assignWidget(pNode, "Infor_close_Btn"):setVisible(true)
        me.assignWidget(pNode, "Infor_next_Btn"):setVisible(false)
    end
    mInforHint = mInforHint - 1
    mInforNum = 0
    setInfortHint(pNode)
end
function InforHintBtn(pNode)
    me.assignWidget(pNode, "Infor_num"):setString(mInforHint)
    me.assignWidget(pNode, "Infor_close_Btn"):setVisible(false)
    me.assignWidget(pNode, "Infor_next_Btn"):setVisible(true)

end 
function InforBtn(pNode, pType, pBool)
    setInfortHint(pNode)
    local InforOpen = pBool
    local pInforBtn = me.assignWidget(pNode, "Infor_open_Btn")
    pInforBtn:setRotation(0)
    local InforNum = 1
    local pInfor_bg = me.assignWidget(pNode, "Infor_bg")
    pInfor_bg:setVisible(false)

    local function Infor_Not()
        -- 没有消息
        me.assignWidget(pNode, "Infor_node_Panel"):removeAllChildren()
        me.assignWidget(pInfor_bg, "Infor_num"):setVisible(false)
        me.assignWidget(pInfor_bg, "Infor_next_Btn"):setVisible(false)
        me.assignWidget(pInfor_bg, "Infor_hint"):setVisible(true)
        me.assignWidget(pInfor_bg, "Infor_num_bg"):setVisible(false)
        me.assignWidget(pNode, "Infor_close_Btn"):setVisible(false)
        mInforNum = 1
    end
    me.registGuiClickEventByName(pNode, "Infor_open_Btn", function(node)
        if InforOpen then
            InforOpen = false
            pInforBtn:setRotation(0)
            pInfor_bg:setVisible(false)
            mInforOpen = InforOpen
            if pType == 2 then
                me.assignWidget(pNode, "Image_miniMap"):setVisible(true)
            end
        else
            InforOpen = true
            pInforBtn:setRotation(180)
            pInfor_bg:setVisible(true)
            mInforOpen = InforOpen
            if pType == 2 then
                me.assignWidget(pNode, "Image_miniMap"):setVisible(false)
            end
            if mInforHint > 0 then
                showInfor(pNode, InforNum)
            else
                Infor_Not()
            end
        end
    end )
    me.assignWidget(pNode, "Infor_open_Btn"):setSwallowTouches(true)
    me.registGuiClickEventByName(pNode, "Infor_next_Btn", function(node)
        if mInforHint > 0 then
            InforNum = InforNum + 1
            showInfor(pNode, InforNum)
        else
            Infor_Not()
        end
    end )
    me.registGuiClickEventByName(pNode, "Infor_close_Btn", function(node)
        InforOpen = false
        pInforBtn:setRotation(0)
        pInfor_bg:setVisible(false)
        mInforOpen = InforOpen
        InforNum = 1
        if pType == 2 then
            me.assignWidget(pNode, "Image_miniMap"):setVisible(true)
        end
    end )
end
function setInfortHint(pNode)
    local pInfor = me.assignWidget(pNode, "Infor_open_hint_bg")
    pInfor:setVisible(false)
    if mInforHint > 0 then
        pInfor:setVisible(true)
        me.assignWidget(pNode, "Infor_open__Hint_num"):setString(mInforHint)
    else
        pInfor:setVisible(false)
    end
end
function load_empty()

end
tabImageName = {
    ["0"] = "waicheng_tubiao_xin_huang.png",
    ["1"] = "waicheng_tubiao_mianzhan_huang.png",
    -- 反叛后 还在保护
    ["2"] = "waicheng_tubiao_shou_zi.png",
    ["3"] = "waicheng_tubiao_lx.png",
}
function getWindowRect()
    local cur = me.getScreenCenterTileCrood(tmxMap)
    local sp = me.convertToScreenCoord(tmxMap, cur)
    return cc.rect(sp.x - me.winSize.width / 2, sp.y - me.winSize.height / 2, me.winSize.width, me.winSize.height)
end
-- 根据服务器下发数据，判断功能的开启
function switchButtons()
    for key, var in pairs(user.newBtnIDs) do
        local btn = getOpenBtnByTaskID(var)
        if me.toNum(var) == OpenButtonID_Eleven or me.toNum(var) == OpenButtonID_WVERYDAY then
            if btn then
                btn:setVisible(false)
            end
        else
            if btn then
                me.setButtonDisable(btn, true)
                btn:setVisible(true)
            end
        end
        --        local fView = mainCity
        --        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        --            fView = pWorldMap
        --        end
        --        if me.toNum(var) == OpenButtonID_Battle and fView.Node_chat then
        --            fView.Node_chat:setPosition(cc.p(192, 0))
        --        end
    end
end
-- 做完引导中的出征任务，才能跳出外城
function canJumpWorldMap()
    if CUR_GAME_STATE == GAME_STATE_CITY then
        local canJump = mainCity.battleBtn:isVisible()
        if canJump == false then
            showTips("外城功能尚未开启!")
        end
        return canJump
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        return true
    end
end
--获取当前进行章节
function getCurTaskCaphter()
     if  user.taskCaphterData then     
         for key, var in pairs(user.taskCaphterData) do
             if var.status == 2 then
                  return var
             end
         end  
         for key, var in pairs(user.taskCaphterData) do
             if var.status == 1 then
                  return var
             end
         end              
     end
     return nil
end
function getOpenBtnByTaskID(id_)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        if me.toNum(id_) == OpenButtonID_Month then
            return mainCity.monthBtn
        end
        if me.toNum(id_) == OpenButtonID_Activity then
            return mainCity.promotionBtn
        end
        if me.toNum(id_) == OpenButtonID_Battle then
            return mainCity.battleBtn
        end
        if me.toNum(id_) == OpenButtonID_Arch then
            return mainCity.Button_Arch
        end
        if me.toNum(id_) == OpenButtonID_RELIC then
            return mainCity.relicBtn
        end
        if me.toNum(id_) == OpenButtonID_Ranking then
            return mainCity.rank_Btn
        end
        if me.toNum(id_) == OpenButtonID_Eleven then
            return mainCity.elevenBtn
        end
        if me.toNum(id_) == OpenButtonID_Tax then
            -- 税收按钮 特殊处理
            if user.newBtnIDs[me.toStr(OpenButtonID_Tax)] == nil then
                openNewBtnAnim(id_, mainCity, nil, function()
                    local tar = nil
                    for key, var in pairs(mainCity.buildingMoudles) do
                        local tmp = var:getData():getDef()
                        if tmp.type == "center" then
                            tar = var
                            break
                        end
                    end
                    cameraLookAtNode(tar, function()
                        tar:showBuildingMenu(buildingOptMenuLayer.BTN_TAX)
                    end )
                end )
            end
            return false
        end
        if me.toNum(id_) == OpenButtonID_GrowWay then
            return mainCity.serverTaskBtn
        end
        if OpenButtonID_TaskBtn == me.toNum(id_) then
            return mainCity.taskBtn
        end
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        if me.toNum(id_) == OpenButtonID_Arch then
            return pWorldMap.Button_Arch
        end
        if me.toNum(id_) == OpenButtonID_RELIC then
            return pWorldMap.relicBtn
        end
        if me.toNum(id_) == OpenButtonID_WorldTask then
            return pWorldMap.pTaskBtn
        end
        if OpenButtonID_TaskBtn == me.toNum(id_) then
            return pWorldMap.pTaskBtn
        end
    end
end

function showPromotion(defId, num)
    defId = tonumber(defId)
    num = tonumber(num)
    local etcCfg = cfg[CfgType.ETC][defId]
    if etcCfg.showtype == 0 then
        showPromotionMode1(defId, num)
    else
        showPromotionMode2(defId, num)
    end
end
function showPromotionMode2(defId, num)
    local globalItems = me.createNode("Node_promotionItem2.csb")
    me.doLayout(me.assignWidget(globalItems, "Panel_7"), me.winSize)
    local etcCfg = cfg[CfgType.ETC][defId]
    local nameTxt = me.assignWidget(globalItems, "nameTxt")
    nameTxt:setString(etcCfg.name)
    local bg_frame = me.assignWidget(globalItems, "bg_frame")
    local descTxt = me.assignWidget(globalItems, "descTxt")
    local descNode = me.assignWidget(globalItems, "descNode")
    if etcCfg.showtype == -1 then
        descTxt:setString("将获得以下道具")
    elseif etcCfg.showtype == -2 then
        descTxt:setString("将任选以下一种道具")
    else
        descTxt:setString("将随机获得以下" .. etcCfg.showtype .. "项道具")
    end

    me.registGuiClickEventByName(globalItems, "Button_5", function(node)
        globalItems:removeFromParentAndCleanup(true)
    end )
    globalItems:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.runningScene():addChild(globalItems, me.POPUPZODER)

    local list = me.assignWidget(globalItems, "list")
    list:removeAllChildren()

    local listItems = string.split(etcCfg.useEffect, ",")
    local h = 249
    if #listItems > 4 then
        h = math.ceil(#listItems / 4) * 140
        if h < 249 then h = 249 end
    end
    
    for i, v in ipairs(listItems) do
        local itemData = string.split(v, ":")
        local itemCfg = cfg[CfgType.ETC][tonumber(itemData[1])]

        local item = BackpackCell:create("backpack/backpackcell.csb")
        list:addChild(item)
        item:setScale(0.8)
        item:setPosition(((i - 1) % 4) * 150, h - 140 - math.floor((i - 1) / 4) * 140)

        item:setUI( { defid = tonumber(itemData[1]), count = tonumber(itemData[2]) })
        local btnBg = me.assignWidget(item, "Button_bg")
        btnBg:setSwallowTouches(false)
        me.registGuiTouchEvent(btnBg, function(node, event)
            if event == ccui.TouchEventType.began then
                descNode:setVisible(true)
                local p = bg_frame:convertToNodeSpace(cc.p(node:convertToWorldSpace(cc.p(node:getPosition()))))
                descNode:setPosition(p.x - 350, p.y + 120)
                local descs = me.split(itemCfg.describe, "|")
                me.assignWidget(descNode, "descTxt_1"):setString(descs[1])

            elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
                descNode:setVisible(false)
            end
        end )

    end

    list:setInnerContainerSize(cc.size(668, h))
end

function showPromotionMode1(defId, num)
    local globalItems = me.createNode("Node_promotionItem.csb")
    me.doLayout(me.assignWidget(globalItems, "Panel_7"), me.winSize)
    local cfg_ = cfg[CfgType.ETC][defId]
    me.assignWidget(globalItems, "prop_name"):setString(cfg_.name)
    local list = me.assignWidget(globalItems, "list")
    local descs = me.split(cfg_.describe or "", "|")
    local Text_imabue_dmg = cc.Label:createWithTTF(descs[1] or "", "fzlsjt.ttf", 20)
    Text_imabue_dmg:setTextColor(cc.c4b(150,126,97,255))
    Text_imabue_dmg:setDimensions(300, 0)
    local h = Text_imabue_dmg:getContentSize().height
    list:addChild(Text_imabue_dmg)
    local ofy = 0
    if Text_imabue_dmg:getContentSize().height / 2 < 125 then
        ofy = 125 - Text_imabue_dmg:getContentSize().height / 2
    else
        ofy = Text_imabue_dmg:getContentSize().height / 2
    end
    Text_imabue_dmg:setPosition(Text_imabue_dmg:getContentSize().width / 2, ofy)
    list:setInnerContainerSize(cc.size(300, h))

    local def_panel = me.assignWidget(globalItems, "def_panel")
    local rune_panel = me.assignWidget(globalItems, "rune_panel")
    local icon = me.assignWidget(globalItems, "icon")
    local box = me.assignWidget(globalItems, "box")
    local typeBox = me.assignWidget(globalItems, "typeBox")
    local nameBox = me.assignWidget(globalItems, "nameBox")
    local nameTxt = me.assignWidget(globalItems, "nameTxt")
    local starNode = me.assignWidget(globalItems, "starNode")
    local typeIco = me.assignWidget(globalItems, "typeIco")
    local star = me.assignWidget(globalItems, "star")
    if cfg_.useType == 133 then
        def_panel:setVisible(false)
        rune_panel:setVisible(true)
        local useEffect = me.split(cfg_.useEffect, ":")
        local runeData = cfg[CfgType.RUNE_DATA][tonumber(useEffect[1])]
        icon:loadTexture(getRuneIcon(runeData.icon), me.plistType)
        box:loadTexture("levelbox" .. runeData.level .. ".png", me.plistType)
        nameTxt:setString(runeData.name)
        typeIco:loadTexture("rune_type_" .. runeData.type .. ".png", me.plistType)
        typeBox:loadTexture("levelbox" .. runeData.level .. "_c2.png", me.plistType)
        starNode:removeAllChildren()
        if tonumber(useEffect[2]) ~= nil then
            local starNums = tonumber(useEffect[2])
            for i = 1, starNums, 1 do
                local star = star:clone():setVisible(true)
                star:setPositionX((i - 1) * 23)
                starNode:addChild(star)
            end
            starNode:setPositionX((234 - starNums * 23) / 2)
        end
    else
        def_panel:setVisible(true)
        rune_panel:setVisible(false)
        me.assignWidget(globalItems, "promotion_quilty"):loadTexture(getQuality(cfg_.quality), me.localType)
        if num ~= nil then
            me.assignWidget(globalItems, "prop_num"):setVisible(true)
            me.assignWidget(globalItems, "prop_num"):setString("x" .. num)
        else
            me.assignWidget(globalItems, "prop_num"):setVisible(false)
        end
        local promotion_icon = me.assignWidget(globalItems, "promotion_icon")
        promotion_icon:loadTexture("item_" .. cfg_.icon .. ".png", me.localType)
        me.resizeImage(promotion_icon, 115, 115)
    end
    me.registGuiClickEventByName(globalItems, "Button_5", function(node)
        globalItems:removeFromParentAndCleanup(true)
    end )
    globalItems:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.runningScene():addChild(globalItems, me.POPUPZODER)

end
function showPromotionChoose(defId, num)
    local globalItems = me.createNode("Node_promotionItem_Choose.csb")
    me.doLayout(me.assignWidget(globalItems, "Panel_7"), me.winSize)
    local cfg_ = cfg[CfgType.ETC][defId]
    me.assignWidget(globalItems, "prop_name"):setString(cfg_.name)
    local list = me.assignWidget(globalItems, "list")
    local descs = me.split(cfg_.describe, "|")
    local Text_imabue_dmg = cc.Label:createWithTTF(descs[1] or "", "font/fzlsjt.ttf", 20)
    Text_imabue_dmg:setTextColor(cc.c4b(150,126,97,255))
    Text_imabue_dmg:setDimensions(300, 0)
    local h = Text_imabue_dmg:getContentSize().height
    list:addChild(Text_imabue_dmg)
    local ofy = 0
    if Text_imabue_dmg:getContentSize().height / 2 < 125 then
        ofy = 125 - Text_imabue_dmg:getContentSize().height / 2
    else
        ofy = Text_imabue_dmg:getContentSize().height / 2
    end
    Text_imabue_dmg:setPosition(Text_imabue_dmg:getContentSize().width / 2, ofy)
    list:setInnerContainerSize(cc.size(300, h))

    local def_panel = me.assignWidget(globalItems, "def_panel")
    local rune_panel = me.assignWidget(globalItems, "rune_panel")
    local icon = me.assignWidget(globalItems, "icon")
    local box = me.assignWidget(globalItems, "box")
    local typeBox = me.assignWidget(globalItems, "typeBox")
    local nameBox = me.assignWidget(globalItems, "nameBox")
    local nameTxt = me.assignWidget(globalItems, "nameTxt")
    local starNode = me.assignWidget(globalItems, "starNode")
    local typeIco = me.assignWidget(globalItems, "typeIco")
    local star = me.assignWidget(globalItems, "star")
    if cfg_.useType == 133 then
        def_panel:setVisible(false)
        rune_panel:setVisible(true)
        local useEffect = me.split(cfg_.useEffect, ":")
        local runeData = cfg[CfgType.RUNE_DATA][tonumber(useEffect[1])]
        icon:loadTexture(getRuneIcon(runeData.icon), me.plistType)
        box:loadTexture("levelbox" .. runeData.level .. ".png", me.plistType)
        nameTxt:setString(runeData.name)
        typeIco:loadTexture("rune_type_" .. runeData.type .. ".png", me.plistType)
        typeBox:loadTexture("levelbox" .. runeData.level .. "_c2.png", me.plistType)
        starNode:removeAllChildren()
        if tonumber(useEffect[2]) ~= nil then
            local starNums = tonumber(useEffect[2])
            for i = 1, starNums, 1 do
                local star = star:clone():setVisible(true)
                star:setPositionX((i - 1) * 23)
                starNode:addChild(star)
            end
            starNode:setPositionX((234 - starNums * 23) / 2)
        end
    else
        def_panel:setVisible(true)
        rune_panel:setVisible(false)
        me.assignWidget(globalItems, "promotion_quilty"):loadTexture(getQuality(cfg_.quality), me.localType)
        if num ~= nil then
            me.assignWidget(globalItems, "prop_num"):setVisible(true)
            me.assignWidget(globalItems, "prop_num"):setString("x" .. num)
        else
            me.assignWidget(globalItems, "prop_num"):setVisible(false)
        end
        local promotion_icon = me.assignWidget(globalItems, "promotion_icon")
        promotion_icon:loadTexture("item_" .. cfg_.icon .. ".png", me.localType)
        me.resizeImage(promotion_icon, 115, 115)
    end
    me.registGuiClickEventByName(globalItems, "Button_Cancel", function(node)
        globalItems:removeFromParentAndCleanup(true)
    end )
    me.registGuiClickEventByName(globalItems, "Button_Choose", function(node)
        me.dispatchCustomEvent("BackpackUse_Choose_Evt", defId)
        globalItems:removeFromParentAndCleanup(true)
    end )
    globalItems:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    me.runningScene():addChild(globalItems, me.POPUPZODER)
end
function showTrumpetWithCfg(data)
    -- 喇叭类型901:绿色,902:黄色 903:紫色
    local id = 540
    if data.tp then
        id = id + data.tp % 10
    end
    local txt = { }
    local str = ""
    local def = cfg[CfgType.SYS_NOTICE][id]
    txt[#txt + 1] = data.sn
    txt[#txt + 1] = data.nm
    txt[#txt + 1] = data.ct
    local tb = me.split(def.data, "|")
    if tb then
        for i = 1, #tb - 1 do
            tb[i] = tb[i] .. txt[i]
        end
        str = table.concat(tb)
        if str and str ~= "" then
            local quee = { }
            quee.num = 1
            quee.icon = def.icon
            quee.txt = str
            marqueeMgr_trumpet.getInstance():addQuee(quee)
        end
    end
end
function showNoticeWithCfg(msg)
    local id = msg.c.id
    local txt = msg.c.txt
    local str = ""
    local num = 0
    local def = cfg[CfgType.SYS_NOTICE][id]
    if def == nil then
        __G__TRACKBACK__("showNoticeWithCfg : id = " .. id .. " is nil !")
        return
    end
    local tb = me.split(def.data, "|")
    if tb then
        --        if id == 501 or id == 507 or id == 508 or id == 510 or id == 517 or id == 525 or id == 548 or id == 549 then
        --            num = 3
        --        elseif id == 502 or id == 534 or id == 535 or id == 536 or id == 537 or id == 538 or id == 539 then
        --            num = 2
        --        elseif id == 518 or id == 545 or id == 546 then
        --            num = 2
        --        elseif id <= 516  then
        --            num = 1
        --        elseif id == 551 then
        --              num = 1
        --        elseif id == 519 or id == 521 or id == 522 or id == 523 or id == 526 or id == 528 or id == 530 or id == 531 or id == 547 or id == 550 then
        --            num = 4
        --        elseif id == 520 or id == 524 or id == 532 or id == 533 then
        --            num = 6
        --        elseif id == 527 or id == 529 then
        --            num = 5
        --        end
        if #tb == 1 then
            num = 0
        else
            num = #tb - 1
        end
        for i = 1, num do
            if id == 519 then
                if id == 519 then
                    local pnum = #txt
                    if pnum == 3 then
                        if i == 1 then
                            tb[i] = tb[i] .. "流浪"
                        else
                            tb[i] = tb[i] .. txt[i - 1]
                        end
                    else
                        tb[i] = tb[i] .. txt[i]
                    end
                end
            elseif id == 522 then
                if i == 3 then
                    local pAlllianceName = txt[i]
                    if txt[i] == "" then
                        pAlllianceName = "流浪"
                    end
                    tb[i] = tb[i] .. pAlllianceName
                else
                    tb[i] = tb[i] .. txt[i]
                end
            elseif id == 527 then
                if i == 4 and txt[i] == "" then
                    tb[i] = tb[i] .. "流浪"
                else
                    tb[i] = tb[i] .. txt[i]
                end
            elseif id == 508 then
                if i == 1 and txt[i] == "" then
                    tb[i] = tb[i] .. "流浪"
                else
                    tb[i] = tb[i] .. txt[i]
                end
            elseif txt[i] then
                if id == 510 or id == 517 or id == 548 then
                    if i == 2 then
                        tb[i] = tb[i] .. cfg[CfgType.ETC][me.toNum(txt[i])].name
                    else
                        tb[i] = tb[i] .. txt[i]
                    end
                else
                    tb[i] = tb[i] .. txt[i]
                    print("i = " .. i .. "   text[i] = " .. txt[i])
                end
            end
        end
        str = table.concat(tb)
        if str and str ~= "" then
            local quee = { }
            quee.num = 1
            quee.plv = def.pri
            quee.txt = str
            marqueeMgr.getInstance():addQuee(quee)
        end
    end
end

-- 得到内城的军队数量
function getCityArmyNum()
    local armyNum = 0
    for key, var in pairs(user.soldierData) do
        if var:getDef().bigType ~= 99 then
            armyNum = armyNum + var.num
        end
    end
    return armyNum
end

-- 解析坐标_针对富文本的分解(提取文字内容，字号，颜色等信息)
function parseRichtText(xStr)
    local function parseHead(str)
        local fsize = string.sub(str, -2, -1)
        return fsize
    end

    local rtInfo = { }
    local function parseText(str)
        local startPos, endPos, head, color, bodyText = string.find(str, "<(%w-),(%x-)>(.-)&")
        -- 英文逗号
        if startPos == nil then
            startPos, endPos, head, color, bodyText = string.find(str, "<(%w-)，(%x-)>(.-)&")
            -- 中文逗号
        end
        if startPos ~= nil and endPos ~= nil and head ~= nil and color ~= nil and bodyText ~= nil then
            rtInfo[#rtInfo + 1] = { }
            rtInfo[#rtInfo].color = color
            rtInfo[#rtInfo].size = parseHead(head)
            rtInfo[#rtInfo].text = bodyText
            local tmp = string.sub(str, endPos, -1)
            parseText(tmp)
        end
    end
    parseText(xStr)
    local rt = ""
    local isMacth = false
    local rebuildRT = ""
    if table.nums(rtInfo) > 0 then
        -- 是富文本
        for key, var in pairs(rtInfo) do
            if isMacth == false then
                -- 只识别一个坐标
                rebuildRT, isMacth = parsePosition(var.text, var.size, nil, var.size, var.color)
                if me.isValidStr(rebuildRT) == true then
                    rt = rt .. rebuildRT
                end
            else
                rt = rt .. "<txt00" .. var.size .. "," .. var.color .. ">" .. var.text .. "&"
            end
        end
    else
        rt = xStr
    end
    return rt
end

-- 解析坐标(不带富文本符号的纯文字信息)
-- fontSize,fontRGB:坐标字体的大小和颜色（默认18号，绿色）
-- txtSize,txtRGB:原来文字的大小和颜色（默认18号，白色）
-- bracket是否主动给坐标加上括号（主要是针对聊天）
function parsePosition(xStr, fontSize, fontRGB, txtSize, txtRGB, bracket)
    if type(xStr) == "table" then
        xStr = table.concat(xStr)
    end
    txtSize = txtSize or "18"
    txtSize = "<txt00" .. txtSize
    txtRGB = txtRGB or "402b1d"
    txtRGB = "," .. txtRGB .. ">"
    local function findPositionIndex(content)
        local startIndex = nil
        local endIndex = nil
        local startPos = nil
        local endPos = nil
        startIndex, endIndex, startPos, endPos = string.find(content, "(%(%d+),(%d+%))")
        if me.isValidStr(startIndex) == false then
            startIndex, endIndex, startPos, endPos = string.find(content, "(%d+),(%d+)")
        end
        if me.isValidStr(startIndex) == false then
            startIndex, endIndex, startPos, endPos = string.find(content, "(%d+)，(%d+)")
        end
        if me.isValidStr(startIndex) == true and me.isValidStr(endIndex) == true
            and me.isValidStr(startPos) == true and me.isValidStr(endPos) == true then
            return startIndex, endIndex, startPos, endPos
        end
        return nil
    end

    local res = { }
    local addIndex = 0
    local matchPosition = false
    local function findPositionIndexsEX(content)
        local startIndex, endIndex, startPos, endPos = findPositionIndex(content)
        if startIndex and endIndex and startPos and endPos then
            local leftContent = string.sub(content, endIndex + 1, string.len(content))
            startIndex = startIndex + addIndex
            endIndex = endIndex + addIndex
            res[#res + 1] = { }
            res[#res].startIndex, res[#res].endIndex, res[#res].startPos, res[#res].endPos = startIndex, endIndex, startPos, endPos
            addIndex = res[#res].endIndex
            matchPosition = true
            if me.isValidStr(leftContent) == true then
                --      findPositionIndexsEX(leftContent) --可识别多个坐标
            end
        end
    end

    findPositionIndexsEX(xStr)
    local function rebuildText(b)
        local fSize = "<txt0118"
        local fCol = ",3ed137>"
        if b == true then
            fCol = fCol .. "("
        end
        if fontSize ~= nil then
            fSize = "<txt01" .. fontSize
        end
        if fontRGB ~= nil then
            fCol = "," .. fontRGB .. ">"
        end
        local resultStr = ""
        local originStr = xStr
        local tmpIndex_start = 1
        local tmpIndex_end = 1

        for key, var in pairs(res) do
            if me.toNum(key) ~= 1 and res[me.toNum(key - 1)] ~= nil then
                tmpIndex_start = res[me.toNum(key - 1)].endIndex + 1
            end
            tmpIndex_end = var.startIndex - 1
            local strBefore = string.sub(originStr, tmpIndex_start, tmpIndex_end)
            if me.isValidStr(strBefore) == true then
                strBefore = txtSize .. txtRGB .. strBefore .. "&"
            end
            local strRebuild = fSize .. fCol .. var.startPos .. "," .. var.endPos
            if b == true then
                strRebuild = strRebuild .. ")&"
            else
                strRebuild = strRebuild .. "&"
            end
            resultStr = resultStr .. strBefore .. strRebuild
            tmpIndex_start = var.endIndex + 1
        end
        local endStr = string.sub(originStr, tmpIndex_start, string.len(originStr))
        if me.isValidStr(endStr) == true then
            endStr = txtSize .. txtRGB .. endStr .. "&"
        end
        resultStr = resultStr .. endStr
        return resultStr
    end
    local tmpRebuildStr = rebuildText(bracket)
    return tmpRebuildStr, matchPosition
end

function umengInit()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = "" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "umnengInit", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end
ishowExitGameMessage = false
function askExitGame()
    if ishowExitGameMessage == false then
        ishowExitGameMessage = true
        me.showMessageDialog("是否退出游戏？", function(evt)
            ishowExitGameMessage = false
            if evt == "ok" then
                if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                    -- jjGameSdk.logoutSdk()
                    me.Helper:endGame()
                end
            end
        end )
    end
end
function TalkingData_onRegister(acc)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { account = acc }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "onRegister", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end
function TalkingData_onLogin(acc)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { account = acc }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "onLogin", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end
function TalkingData_onCreateRole(uid)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { name = uid }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "onCreateRole", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end
function TalkingData_onPay(acc, order, am, cType, pType)
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { account = acc, orderId = order, amount = am, currencyType = cType, payType = pType }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "onPay", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end
function LookMap(pos, ...)
    local arg = { ...}
    local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
    me.showMessageDialog(pStr, function(args)
        if args == "ok" then
            if pos.x > getWorldMapWidth() or pos.y > getWorldMapHeight() then
                showErrorMsg("此坐标为无效点！", 1)
                return
            end
            for key, var in pairs(arg) do
                me.dispatchCustomEvent(var)
            end
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:RankSkipPoint(pos)
            elseif canJumpWorldMap() then
                mainCity:cloudClose( function(node)
                    print("跳转外城")
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    if user.Cross_Sever_Status == mCross_Sever_Out then
                        loadlayer = loadWorldMap:create("loadScene.csb")
                    elseif user.Cross_Sever_Status == mCross_Sever then
                        loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                    end
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                end )
            end
        end
    end )
end
function askLookMap(pos, str, ...)
    local arg = { ...}
    local pStr = str
    me.showMessageDialog(pStr, function(args)
        if args == "ok" then
            if pos.x > getWorldMapWidth() or pos.y > getWorldMapHeight() then
                showErrorMsg("此坐标为无效点！", 1)
                return
            end
            for key, var in pairs(arg) do
                me.dispatchCustomEvent(var)
            end
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:RankSkipPoint(pos)
            elseif canJumpWorldMap() then
                mainCity:cloudClose( function(node)
                    print("跳转外城")
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    if user.Cross_Sever_Status == mCross_Sever_Out then
                        loadlayer = loadWorldMap:create("loadScene.csb")
                    elseif user.Cross_Sever_Status == mCross_Sever then
                        loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                    end
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                end )
            end
        end
    end )
end
function ConvergeLook(pos)
    mainCity:cloudClose( function(node)
        print("跳转外城")
        local loadlayer = loadWorldMap:create("loadScene.csb")
        if user.Cross_Sever_Status == mCross_Sever_Out then
            loadlayer = loadWorldMap:create("loadScene.csb")
        elseif user.Cross_Sever_Status == mCross_Sever then
            loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
        end
        loadlayer:setWarningPoint(pos)
        me.runScene(loadlayer)
    end )
    me.DelayRun( function()
        if pNode then
            pNode:close()
        end
    end )
end
function ConvergeStrong(cp, pType, MaxArmy, TeamId, surplusTime, conergeType)
    local StongHoldList = strongholdlist:create("strongholdtransfer.csb")
    StongHoldList:setCpData(cp, pType, nil)
    StongHoldList:setConverge(MaxArmy, TeamId, surplusTime, conergeType)
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        pWorldMap:addChild(StongHoldList, me.MAXZORDER)
    else
        mainCity:addChild(StongHoldList, me.MAXZORDER)
    end
end
-- 集火出征界面
function ConvergeExped(ori, tag, pArmy, pMaxArmy, status, waitTime, teamId, surplusTime, conergeType)

    user.needaskBattle = false
    -- 集火暂时不提示修道院伤兵过多

    local path = { }
    path.ori = ori
    path.tag = tag
    local pConverArmy = pMaxArmy
    -- math.min(pMaxArmy,user.maxTroopsNum)
    local exped = expedLayer:create("expeditionLayer.csb")
    exped:setExpedState(status)
    exped:setQueueNum(pWorldMap and(pWorldMap.queueNum or 0) or 0)
    exped:setPaths(path)
    exped:setNpc(nil)
    exped:setConver(waitTime, teamId, surplusTime)
    exped:setConvergeArmy(pConverArmy)
    exped:setStar(pArmy)
    if conergeType == 2 then
        exped:setBoosType("bigdragon")
    end

    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        pWorldMap:addChild(exped, me.MAXZORDER)
    else
        mainCity:addChild(exped, me.MAXZORDER)
    end
end

-- 研究/建造加速后的百分比，没有找到对应的数据则返回100%
function getTimePercentByPropertyValue(type_)
    if cfg[CfgType.LORD_INFO][type_] and me.toNum(cfg[CfgType.LORD_INFO][type_].isPercent) == 1 then
        local per = 1 /(1 + me.toNum(user.propertyValue[type_]))
        return per
    end
    return 1
end

-- 根据国家id，得到援助/集火科技的techID
-- @type_:21000 援助之旗，    22000 集火之旗
function getFlagTechIdByCountryID(type_)
    local techID = type_ + user.countryId
    return me.toNum(techID)
end

-- 得到当前集火科技开启状况
function getFlagActtackTechOpenStatus()
    for key, var in pairs(user.techServerDatas) do
        local def = var:getDef()
        if (me.toNum(def.techid) == 22001 or me.toNum(def.techid) == 22002 or me.toNum(def.techid) == 22003 or me.toNum(def.techid) == 22004 or me.toNum(def.techid) == 22005)
            and var:getLockStatus() ~= techData.lockStatus.TECH_TECHING and var:getLockStatus() ~= techData.lockStatus.TECH_UNUSED then
            return true
        end
    end
    return false
end

-- 重新组装聊天的文本
function rebuildChatString(content, noticeId, uid)
    local function resetStr(str)
        local strTab = str
        if me.isValidStr(strTab[1]) == false then
            strTab[1] = "流浪"
        else
            strTab[1] = strTab[1]
        end
        return strTab
    end

    local function getChatStr(id, resTab)
        local tmpStr = ""
        local def = cfg[CfgType.SYS_NOTICE][id]

        if def == nil then
            __G__TRACKBACK__("showNoticeWithCfg : id = " .. id .. " is nil !")
            return
        end
        local defTab = me.split(def.data, "|")
        local num = table.nums(defTab)
        for i = 1, num do
            if resTab[i] and defTab[i] then
                defTab[i] = defTab[i] .. resTab[i]
            end
        end
        return table.concat(defTab)
    end
    local function contactStr(str)
        local tableStr = nil
        if type(str) == "table" then
            tableStr = table.concat(str)
        elseif type(str) == "string" then
            tableStr = str
        end
        return tableStr
    end

    if noticeId and(noticeId == 1006 or noticeId == 1002 or noticeId == 1003 or noticeId == 1007 or noticeId == 1008 or noticeId == 1009 or noticeId == 1010) then
        tmpStr = resetStr(content)
        tmpStr = getChatStr(noticeId, tmpStr)
    elseif noticeId and(noticeId == 1004 or noticeId == 1005 or noticeId == 1011 or noticeId == 1012) then
        tmpStr = getChatStr(noticeId, content)
    elseif uid and uid == 0 then
        -- 系统消息专属文字颜色
        tmpStr = contactStr(content)
        tmpStr = "<txt0014,402b1d>" .. tmpStr .. "&"
    else
        tmpStr = contactStr(content)
    end
    return tmpStr
end

function showHeroMaterialDetail(itemId)
    local panel_skillDetail = cc.CSLoader:createNode("Layer_HeroSkillDetail.csb")
    me.assignWidget(panel_skillDetail, "arch_Info_bg"):setVisible(true)
    me.assignWidget(panel_skillDetail, "progress_Info"):setVisible(false)
    if itemId ~= nil then
        local tmpDef = cfg[CfgType.ETC][itemId]
        me.assignWidget(panel_skillDetail, "skill_icon"):loadTexture(getItemIcon(tmpDef.icon))
        me.assignWidget(panel_skillDetail, "skill_title"):setString(tmpDef.name)
        local descs = me.split(tmpDef.describe, "|")
        me.assignWidget(panel_skillDetail, "skill_Desc"):setString(descs[1])
    end

    return panel_skillDetail
end

function showHeroSkillDetail(skillId)
    local panel_skillDetail = cc.CSLoader:createNode("Layer_HeroSkillDetail.csb")
    me.assignWidget(panel_skillDetail, "arch_Info_bg"):setVisible(skillId ~= nil)
    me.assignWidget(panel_skillDetail, "progress_Info"):setVisible(skillId == nil)
    if skillId ~= nil then
        local tmpDef = cfg[CfgType.HERO_SKILL][skillId]
        --        if tmpDef.skilltype == 1 then
        --            -- 主动技能
        --            me.assignWidget(panel_skillDetail,"skill_Type"):loadTexture("shengjiang_jineng_kuang_fang.png", me.localType)
        --        else
        --            -- 被动技能
        --            me.assignWidget(panel_skillDetail,"skill_Type"):loadTexture("shengjiang_jineng_kuang_yuan.png", me.localType)
        --        end
        me.assignWidget(panel_skillDetail, "skill_icon"):loadTexture(getHeroSkillIcon(tmpDef.skillicon))
        me.assignWidget(panel_skillDetail, "skill_title"):setString(tmpDef.skillname)
        me.assignWidget(panel_skillDetail, "skill_Desc"):setString(tmpDef.skilldesc)
    end

    return panel_skillDetail
end

function setHeroSkillStars(Panel_star, num)
    num = me.toNum(num)
    Panel_star:removeAllChildren()
    if num <= 0 then
        return
    end
    local offY = 20
    for var = 1, num do
        -- 设置技能星级
        local star_img = ccui.ImageView:create()
        star_img:loadTexture("shengjiang_tubiao_xingxing_huang.png", me.localType)
        Panel_star:addChild(star_img)
        if num == 1 then
            star_img:setAnchorPoint(cc.p(0.5, 1))
            star_img:setPosition(Panel_star:getContentSize().width /(num + 1), Panel_star:getContentSize().height + offY)
        elseif num == 2 then
            star_img:setAnchorPoint(cc.p(0.5, 1))
            star_img:setPosition(Panel_star:getContentSize().width /(num + 1) * var, Panel_star:getContentSize().height + offY)
        elseif num == 3 then
            star_img:setAnchorPoint(cc.p(0.5, 1))
            star_img:setPosition(Panel_star:getContentSize().width /(num + 1) * var, Panel_star:getContentSize().height + offY)
        elseif num == 4 then
            star_img:setAnchorPoint(cc.p(0.5, 1))
            star_img:setPosition(Panel_star:getContentSize().width /(num + 1) * var, Panel_star:getContentSize().height + offY)
        end
        if var >= 4 then
            break
        end
    end
end

function c_loginOut()
    -- UserModel:goLogon()
    local loadtomenu = loadBackMenu:create("loadScene.csb")
    me.runScene(loadtomenu)
end
function c_askExit()
    cc.Director:getInstance():endToLua()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        os.exit();
    end
end
function c_getCheckHttpUrl()
    return http_ip .. "/g-uc/yiJieLogin"
end
function c_dispatchCustomEvent(eName, data)
    -- body
    local event = cc.EventCustom:new(eName)
    event._userData = data
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:dispatchEvent(event)
end
function setSkipTime()
    if mSkipTimeBool then
        mSkipTimeNum = me.sysTime()
    end
end
function GetSkipTime()
    if mSkipTimeBool then
        mSkipTimeBool = false
        mSkipTimeNum = me.sysTime() - mSkipTimeNum
        NetMan:send(_MSG.Popularize_Skip_Time(mSkipTimeId, 1))
    end
    return 0
end
function getIdfa()
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) then
        local args = { url = "1" }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "getIDFA", args)
        if not ok then
            cc.Director:getInstance():resume()
        else
            -- print("The ret is:", ret)
            return ret or "NAN"
        end
    else
        print("仅支持IOS")
    end
    return "NAN"
end
function switchHongBaoAnim(panel, visible, closeAnim)
    if panel == nil then
        __G__TRACKBACK__("红包层不存在 !!!")
        return
    end
    if CUR_GAME_STATE == GAME_STATE_CITY then
        buildingOptMenuLayer:getInstance():clearnButton()
    end
    if visible == false then
        if user.hongBao_Anim_Timer ~= nil then
            me.clearTimer(user.hongBao_Anim_Timer)
            user.hongBao_Anim_Timer = nil
        end
        if closeAnim then
            me.DelayRun( function(node)
                me.assignWidget(panel, "Panel_anim"):removeAllChildren()
                panel:setVisible(false)
            end , 5, me.assignWidget(panel, "Panel_anim"))
        else
            me.assignWidget(panel, "Panel_anim"):removeAllChildren()
            panel:setVisible(false)
        end
        return
    end
    panel:setVisible(true)
    me.assignWidget(panel, "Panel_anim"):stopAllActions()
    user.hongBao_Anim_Timer = me.registTimer(-1, function()
        local hb = ccui.ImageView:create("beibao_hongbao_xinnian.png", me.localType)
        me.assignWidget(panel, "Panel_anim"):addChild(hb)
        hb:setRotation(me.getRandom(360, 1, 3))
        hb:setPosition(me.getRandom((me.winSize.width - 100), 6, 8) + 50, me.winSize.height + 100)
        local moveAnim = cc.MoveTo:create(me.getRandom(3, 3, 5) + 0.5, cc.p(hb:getPositionX(), -200))
        local rotaAnim = cc.RotateBy:create(me.getRandom(3, 5, 9) + 3, 270)
        hb:runAction(moveAnim)
        hb:runAction(rotaAnim)
        hb:setScale((me.getRandom(60) + 40) / 300)
        me.registGuiClickEvent(hb, function(node)
            if node then
                NetMan:send(_MSG.Hongbao_Clicked())
            end
            node:stopAllActions()
            node:removeFromParent()
        end )
        me.DelayRun( function(node)
            if node then
                node:stopAllActions()
                node:removeFromParent()
            end
        end , 4, hb)
    end , 0.5)
end
-- 圆形进度条
function RoundProgress(pStr)
    local Progress = cc.ProgressTimer:create(me.createSprite(pStr))
    Progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    Progress:setMidpoint(cc.p(0.5, 0.5))
    -- left:runAction(cc.RepeatForever:create(cc.ProgressTo:create(2, 100)))
    return left
end
function GFortData()
    if user.Cross_Sever_Status == mCross_Sever_Out then
        return cfg[CfgType.FORTDATA]
    elseif user.Cross_Sever_Status == mCross_Sever then
        return cfg[CfgType.NETBATTLE_FORTDATA]
    end
    return cfg[CfgType.FORTDATA]
end
function initFortData()
    local data = GFortData()
    for key, var in pairs(data) do
        gameMap.fortDatas[var.id] = fortData.new(var.id)
        -- 存储加成描述
        local tb = me.split(var.ext, ",")
        local tbD = me.split(var.desc, "|")
        for key, var in pairs(tb) do
            local tbDe = tbD[key]
            local tbExt = me.split(var, ":")
            local tbDesc = me.split(tbDe, ":")
            if not gameMap.fortDesc[tbExt[1]] then
                gameMap.fortDesc[tbExt[1]] = { }
                gameMap.fortDesc[tbExt[1]].value = 0
                gameMap.fortDesc[tbExt[1]].text = tbDesc[2] .. ":+"
            end
        end
    end
end
function askToRechage(t)
    if t == 1 then
        me.showMessageDialog("领主大人，您当前元宝不足!" .. "\n是否跳转至充值?", function(args)
            if args == "ok" then
                toRechageShop()
            end
        end )
    else
        me.showMessageDialog("领主大人，您当前钻石不足!" .. "\n是否跳转至兑换界面?", function(args)
            if args == "ok" then
                toExpchageShop()
            end
        end )
    end
end

function diamondNotenough(needDiamond, callback)
    local listener = nil
    local function closeConfirm()
        UserModel:removeLisener(listener)
    end
    local function recvMsg()
        listener = UserModel:registerLisener( function(msg)
            if checkMsg(msg.t, MsgCode.ROLE_GEM_UPDATE) then
                if callback then
                    callback()
                end
                closeConfirm()
                disWaitLayer()
            elseif checkMsg(msg.t, MsgCode.ERROR_ALERT) then
                closeConfirm()
                disWaitLayer()
            end
        end )
    end

    local date = os.date("%Y-%m-%d")
    local saveDiamondNotenoughTime = cc.UserDefault:getInstance():getStringForKey("diamondNotenoughTime", "")
    local needMoney = needDiamond - user.diamond
    if saveDiamondNotenoughTime == date then
        if needMoney > user.paygem then
            askToRechage(1)
        else
            showWaitLayer()
            recvMsg()
            NetMan:send(_MSG.expchagegem(needMoney))
        end
        return
    end

    local confirmView = cc.CSLoader:createNode("globalDiamondNotenoughMsgBox.csb")
    me.doLayout(confirmView, me.winSize)


    local costTxt2 = me.assignWidget(confirmView, "costTxt2")
    costTxt2:setString(needMoney)
    me.assignWidget(confirmView, "Text_1"):setPositionX(costTxt2:getPositionX() + costTxt2:getContentSize().width + 3)

    local costTxt1 = me.assignWidget(confirmView, "costTxt1")
    costTxt1:setString(needMoney)

    local checkBox = me.assignWidget(confirmView, "checkBox")

    me.registGuiClickEventByName(confirmView, "btn_ok", function(node)
        if checkBox:isSelected() then
            cc.UserDefault:getInstance():setStringForKey("diamondNotenoughTime", date)
            cc.UserDefault:getInstance():flush()
        end

        if needMoney > user.paygem then
            askToRechage(1)
            confirmView:removeFromParent()
            return
        end
        showWaitLayer()
        recvMsg()
        NetMan:send(_MSG.expchagegem(needMoney))
        confirmView:removeFromParent()
    end )
    me.registGuiClickEventByName(confirmView, "btn_cancel", function(node)
        confirmView:removeFromParent()
    end )

    me.registGuiClickEventByName(confirmView, "tips3", function(node)
        if checkBox:isSelected() then
            checkBox:setSelected(false)
        else
            checkBox:setSelected(true)
        end
    end )

    cc.Director:getInstance():getRunningScene():addChild(confirmView, MESSAGE_ORDER)
    me.showLayer(confirmView, "msgBox")

end

function diamondCostMsgBox(costDiamond, callback)
    local date = os.date("%Y-%m-%d")
    local tempKey = string.format("%s-diamondCostTime", user.uid)
    local saveDiamondCostTime = cc.UserDefault:getInstance():getStringForKey(tempKey, "")
    if saveDiamondCostTime == date then
        if callback then
            callback()
        end
        return
    end

    local confirmView = cc.CSLoader:createNode("globalDiamondMsgBox.csb")
    me.doLayout(confirmView, me.winSize)


    local txt1 = me.assignWidget(confirmView, "txt1")
    txt1:setString("确认消耗" .. costDiamond .. "钻石加速吗?")

    local checkBox = me.assignWidget(confirmView, "checkBox")

    me.registGuiClickEventByName(confirmView, "btn_ok", function(node)
        if checkBox:isSelected() then
            cc.UserDefault:getInstance():setStringForKey(tempKey, date)
            cc.UserDefault:getInstance():flush()
        end

        if callback then
            callback()
        end
        confirmView:removeFromParent()
    end )
    me.registGuiClickEventByName(confirmView, "btn_cancel", function(node)
        confirmView:removeFromParent()
    end )

    me.registGuiClickEventByName(confirmView, "tips3", function(node)
        if checkBox:isSelected() then
            checkBox:setSelected(false)
        else
            checkBox:setSelected(true)
        end
    end )

    cc.Director:getInstance():getRunningScene():addChild(confirmView, MESSAGE_ORDER)
    me.showLayer(confirmView, "msgBox")

end

function showRoleUpgradeBox(data)
    local confirmView = cc.CSLoader:createNode("Layer_RoleUpgrade.csb")
    me.doLayout(confirmView, me.winSize)

    local lvTxt1 = me.assignWidget(confirmView, "lvTxt1")
    lvTxt1:setString(user.lv)
    
    local text_new_lv = me.assignWidget(confirmView, "text_new_lv")
    text_new_lv:setString(data.level)
    local lvTxt2 = me.assignWidget(confirmView, "lvTxt2")
    lvTxt2:setString(data.level)

    local nowExt = string.split(cfg[CfgType.LEVEL][user.lv].ext, ",")
    local nextExt = string.split(cfg[CfgType.LEVEL][data.level].ext, ",")
    local tmp1 = string.split(nowExt[1], ":")
    local landNums1 = me.assignWidget(confirmView, "landNums1")
    landNums1:setString("+" .. tmp1[2])

    local tmp1 = string.split(nextExt[1], ":")
    local landNums2 = me.assignWidget(confirmView, "landNums2")
    landNums2:setString("+" .. tmp1[2])

    local tmp1 = string.split(nowExt[2], ":")
    local soliderNums1 = me.assignWidget(confirmView, "soliderNums1")
    soliderNums1:setString("+" .. tmp1[2])

    local tmp1 = string.split(nextExt[2], ":")
    local soliderNums2 = me.assignWidget(confirmView, "soliderNums2")
    soliderNums2:setString("+" .. tmp1[2])
    local tmp1 = string.split(nowExt[9], ":")
    me.assignWidget(confirmView, "soliderNums4"):setString("+" .. tmp1[2])
    local tmp1 = string.split(nextExt[9], ":")
    me.assignWidget(confirmView, "soliderNums5"):setString("+" .. tmp1[2])
    me.registGuiClickEventByName(confirmView, "okBtn", function(node)
        confirmView:removeFromParent()
    end )
    cc.Director:getInstance():getRunningScene():addChild(confirmView, me.MAXZORDER)
    me.showLayer(confirmView, "bg")

end


function removeRedpoint(id)
    for k, v in pairs(user.UI_REDPOINT) do
        for k1, v1 in pairs(v) do
            if v1 == 1 and tonumber(k1) == tonumber(id) then
                v[k1] = nil
                NetMan:send(_MSG.remove_red_point(tonumber(k1)))
                me.dispatchCustomEvent("UI_RED_POINT")
                break
            end
        end
    end
end

----
-- 获取推荐任务
--
function commendTask()
    if user.building[4001] == nil then return nil end

    local completeTask = { }
    local noCompleteTask = { }
    for _, v in pairs(user.taskList) do
        if v.progress > 2 then
            table.insert(completeTask, v)
        else
            table.insert(noCompleteTask, v)
        end
    end
    if user.building[4001].def.level < 10 then
        if #completeTask > 0 then
            table.sort(completeTask, function(a, b)
                return a:getDef().sortid > b:getDef().sortid
            end )
            return completeTask[1]
        elseif #noCompleteTask > 0 then
            table.sort(noCompleteTask, function(a, b)
                return a:getDef().sortid > b:getDef().sortid
            end )
            return noCompleteTask[1]
        end
        return nil
    else
        math.randomseed(os.time())
        if #completeTask > 0 then
            local index = math.random(#completeTask)
            return completeTask[index]
        elseif #noCompleteTask > 0 then
            local index = math.random(#noCompleteTask)
            return noCompleteTask[index]
        end
        return nil
    end
end
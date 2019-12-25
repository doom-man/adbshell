-- 本地数据储存
LocalDataStorage = class("LocalDataStorage")
LocalDataStorage.__index = LocalDataStorage
local lds = nil
function SharedDataStorageHelper()
    if lds == nil then
        lds = LocalDataStorage.new()
    end
    return lds
end

function LocalDataStorage:ctor()
end

KEYS = { }
KEYS.userAccount = "userAccount"
KEYS.userPassword = "userPassword"
KEYS.userMic = "musicoff" -- 背景音乐
KEYS.userEffect = "effectoff" -- 音效
KEYS.userIPName = "useripname" --当前登录服务器名字
KEYS.userSID = "usersid" --当前登录服务器id
KEYS.userLastIp = "lastloginip" --上次登录的服务器地址
KEYS.userPet = "userpet" --上次宠物出征
KEYS.userMailType = "userMailType" --上次查看的邮件类型
KEYS.userWriteMail = "userWriteMail" --玩家最近发出去的20份邮件
KEYS.userNewBuilding = "userNewBuilding" --开启新建筑物
KEYS.userNewBuildingPage = "userNewBuildingPage" --开启新建筑物分页
KEYS.userNewTask = "KEYS.userNewTask" -- 标记新任务
KEYS.userTaxLog = "KEYS.userTaxLog" -- 征收记录
KEYS.payOrderList = "payOrderList" --进行中的订单
KEYS.buttonStatus = "buttonStatus"  --功能按钮开关
KEYS.noticeId = "noticeId" --公告ID
KEYS.ALLOTGUIDE = "allotGuide" -- 引导工人分配标记
KEYS.achievementRedPoint = "achievementRedPoint" --新成就的红点标识
LocalDataStorage.MAPPOINTTABLE = "mappointtable" -- 选中的地图坐标
LocalDataStorage.MAPCROSSPOINTTABLE = "mapCrosspointtable" -- 跨服选中的地图坐标
LocalDataStorage.NOTICEINFO = "noticeinfo" -- 事件信息
LocalDataStorage.WARSHIPHINT = "warshiphint" -- 战舰提示
LocalDataStorage.LOCALVERSION = "localversion" --本地版本号
function LocalDataStorage:setAchievementRedPoint(str)
   cc.UserDefault:getInstance():setStringForKey(KEYS.achievementRedPoint,str)
end
function LocalDataStorage:getAchievementRedPoint()
   return cc.UserDefault:getInstance():getStringForKey(KEYS.achievementRedPoint)
end
function LocalDataStorage:setSM(str)
   cc.UserDefault:getInstance():setStringForKey("sm",str)
end
function LocalDataStorage:getSM()
   return cc.UserDefault:getInstance():getStringForKey("sm") or "nor"
end

--保存玩家是否引导过工人分配任务了
function LocalDataStorage:setAllotGuide()
   cc.UserDefault:getInstance():setStringForKey(KEYS.ALLOTGUIDE..self:getLastLoginSID()..self:getUserAccount(),1)
end
function LocalDataStorage:getAllotGuide()
   return cc.UserDefault:getInstance():getStringForKey(KEYS.ALLOTGUIDE..self:getLastLoginSID()..self:getUserAccount())
end

function LocalDataStorage:setCurNoticeId(str)
   cc.UserDefault:getInstance():setStringForKey(KEYS.noticeId,str)
end
function LocalDataStorage:getCurNoticeId()
   return cc.UserDefault:getInstance():getStringForKey(KEYS.noticeId)
end

--保存玩家发出去邮件 
LocalDataStorage.sendMaxMail = 20 --最大邮件数量
function LocalDataStorage:setButtonStatus(str)
   cc.UserDefault:getInstance():setStringForKey(KEYS.buttonStatus,str)
end
function LocalDataStorage:getButtonStatus()
   return cc.UserDefault:getInstance():getStringForKey(KEYS.buttonStatus)
end
function LocalDataStorage:setTeset(str)
   cc.UserDefault:getInstance():setStringForKey("date",str)
end
function LocalDataStorage:getTeset()
   return cc.UserDefault:getInstance():getStringForKey("date")
end
--订单
function LocalDataStorage:setPayOrderLog(str)
    cc.UserDefault:getInstance():setStringForKey(KEYS.payOrderList..self:getLastLoginSID()..self:getUserAccount(),str)
end
function LocalDataStorage:getPayOrderLog()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.payOrderList..self:getLastLoginSID()..self:getUserAccount())
end
function LocalDataStorage:setTaxLog(str)
    cc.UserDefault:getInstance():setStringForKey(KEYS.userTaxLog..self:getLastLoginSID()..self:getUserAccount(),str)
end
function LocalDataStorage:getTaxLog()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userTaxLog..self:getLastLoginSID()..self:getUserAccount())
end

function LocalDataStorage:setWroteMail(rname_,title_,content_,date_,pType_)
    local function getValueString(data_)
        return data_.rname.."|"..data_.title.."|"..data_.content.."|"..data_.date.."|"..data_.CrossType
    end

    if #user.sendMail > LocalDataStorage.sendMaxMail then
        table.remove(user.sendMail,1)
    end
    local mailData = MsgMailData.new(rname_,title_,content_,date_,pType_)
    user.sendMail[#user.sendMail+1] = mailData
    for key, var in pairs(user.sendMail) do
        local tmp = getValueString(var)
        cc.UserDefault:getInstance():setStringForKey(KEYS.userWriteMail..self:getLastLoginSID()..self:getUserAccount()..me.toNum(key),tmp)
    end
end

--查看玩家最近邮件
function LocalDataStorage:getWroteMail()
    for index = 1, LocalDataStorage.sendMaxMail do
        local str = cc.UserDefault:getInstance():getStringForKey(KEYS.userWriteMail..self:getLastLoginSID()..self:getUserAccount()..index)
        if str ~= nil and str ~= "" then
            local tmp = me.split(str,"|")
            local mail = MsgMailData.new(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5])
            user.sendMail[#user.sendMail+1] = mail
            dump(mail)
        end
    end
    return user.sendMail
end

--保存新开启的任务
-- index : taskid号
-- status_:1：未点击，2已点击
function LocalDataStorage:setNewTask(index_,status_)
    cc.UserDefault:getInstance():setIntegerForKey(KEYS.userNewTask..self:getLastLoginSID()..self:getUserAccount()..index_,status_)
end

function LocalDataStorage:getNewTask(index_)
    return cc.UserDefault:getInstance():getIntegerForKey(KEYS.userNewTask..self:getLastLoginSID()..self:getUserAccount()..index_)
end

-- 保存新开启的建筑物商店分页/建筑按钮
-- index_： 0 建筑商店按钮，1-4建筑商店里的分页
-- status_:1：未点击，2已点击
function LocalDataStorage:setNewBuildingPage(index_,status_)
--    print("setNewBuildingPage index = "..index_.."  only id =  "..KEYS.userNewBuildingPage.."  "..self:getLastLoginSID().."  "..self:getUserAccount().."  status_ = "..status_)
    cc.UserDefault:getInstance():setIntegerForKey(KEYS.userNewBuildingPage..self:getLastLoginSID()..self:getUserAccount()..index_,status_)
end
-- 获得新开启商店分页/建筑按钮 是否新开启
function LocalDataStorage:getNewBuildingPage(index_)
--    print("getNewBuildingPage index = "..index_.."  only id =  "..KEYS.userNewBuildingPage.."  "..self:getLastLoginSID().."  "..self:getUserAccount())
    return cc.UserDefault:getInstance():getIntegerForKey(KEYS.userNewBuildingPage..self:getLastLoginSID()..self:getUserAccount()..index_)
end
-- 保存新开启建筑物
-- status_:1：新开启未点击，2已点击
function LocalDataStorage:setNewOpenBuildings(bId_,status_)
    cc.UserDefault:getInstance():setIntegerForKey(KEYS.userNewBuilding..self:getLastLoginSID()..self:getUserAccount()..bId_,status_)
end
-- 获取新开启建筑物是否存在
function LocalDataStorage:getNewOpenBuildings(bId_)
    return cc.UserDefault:getInstance():getIntegerForKey(KEYS.userNewBuilding..self:getLastLoginSID()..self:getUserAccount()..bId_)
end
-- 获得上次查看的邮件类型
function LocalDataStorage:getUserMailType()
    return cc.UserDefault:getInstance():getIntegerForKey(KEYS.userMailType..self:getLastLoginSID()..self:getUserAccount())
end
-- 保存当前查看的邮件类型
function LocalDataStorage:setUserMailType(mailType)
    cc.UserDefault:getInstance():setIntegerForKey(KEYS.userMailType..self:getLastLoginSID()..self:getUserAccount(), mailType)
    cc.UserDefault:getInstance():flush()
end
-- 获得上次出征宠物ID
function LocalDataStorage:getUserPet()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userPet..self:getLastLoginSID()..self:getUserAccount())
end
-- 保存当前出征宠物ID
function LocalDataStorage:setUserPet(petStr)
    cc.UserDefault:getInstance():setStringForKey(KEYS.userPet..self:getLastLoginSID()..self:getUserAccount(), petStr)
end
-- 获得战舰提示
function LocalDataStorage:getWarshipHint()
    return cc.UserDefault:getInstance():getIntegerForKey(LocalDataStorage.WARSHIPHINT..self:getLastLoginSID()..self:getUserAccount())
end
-- 保存战舰提示
function LocalDataStorage:setWarshipHint(pType)
    cc.UserDefault:getInstance():setIntegerForKey(LocalDataStorage.WARSHIPHINT..self:getLastLoginSID()..self:getUserAccount(), pType)
end
-- 获得上次登录账户名
function LocalDataStorage:getUserAccount()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userAccount)
end
-- 保存登录成功的帐号
function LocalDataStorage:setUserAccount(account)
    cc.UserDefault:getInstance():setStringForKey(KEYS.userAccount, account)
end
-- 获得上次登录账户名
function LocalDataStorage:getUserAccountNEW()
    return cc.UserDefault:getInstance():getStringForKey("getUserAccountNEW")
end
-- 保存登录成功的帐号
function LocalDataStorage:setUserAccountNEW(account)
    cc.UserDefault:getInstance():setStringForKey("getUserAccountNEW", account)
end
-- 获取上次登录的密码
function LocalDataStorage:getUserPassword()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userPassword)
end
-- 保存登录成功的密码
function LocalDataStorage:setUserPassword(password)
    cc.UserDefault:getInstance():setStringForKey(KEYS.userPassword, password)
end
--得到上次登录的服务器ID
function LocalDataStorage:getLastLoginSID()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userSID)
end
-- 得到上次登录服务器名称
function LocalDataStorage:getLastLoginName()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userIPName)
end
-- 得到上次登录服务器地址
function LocalDataStorage:getLastLoginIp()
    return cc.UserDefault:getInstance():getStringForKey(KEYS.userLastIp)
end
--保存最近登录的
function LocalDataStorage:saveLastServerList(acc,str)
  cc.UserDefault:getInstance():setStringForKey("LastServerList_"..acc,str)
end
function LocalDataStorage:loadLastServerList(acc)
  return cc.UserDefault:getInstance():getStringForKey("LastServerList_"..acc)
end
-- 保存当前登录的服务器信息
function LocalDataStorage:setLoginInfo(ip,name,sid)
    if ip then
        cc.UserDefault:getInstance():setStringForKey(KEYS.userLastIp, ip)
    end
    if name then
        cc.UserDefault:getInstance():setStringForKey(KEYS.userIPName, name)
    end
    if sid then
        cc.UserDefault:getInstance():setStringForKey(KEYS.userSID, sid)
    end
end
-- 保存音乐设置
function LocalDataStorage:setUserMic(mic)
    cc.UserDefault:getInstance():setBoolForKey(KEYS.userMic..self:getLastLoginSID()..self:getUserAccount(), mic)
end        
function LocalDataStorage:getUserMic()
    return cc.UserDefault:getInstance():getBoolForKey(KEYS.userMic..self:getLastLoginSID()..self:getUserAccount(), true)
end

-- 保存音效设置
function LocalDataStorage:setUserEffect(mic)
    cc.UserDefault:getInstance():setBoolForKey(KEYS.userEffect..self:getLastLoginSID()..self:getUserAccount(), mic)
end        
function LocalDataStorage:getUserEffect()
    return cc.UserDefault:getInstance():getBoolForKey(KEYS.userEffect..self:getLastLoginSID()..self:getUserAccount(), true)
end

function LocalDataStorage:setTechOpt(key, b)
    cc.UserDefault:getInstance():setBoolForKey(key, b)
end
function LocalDataStorage:getTechOpt(key)
    print(key)
    print(type(cc.UserDefault:getInstance():getBoolForKey(key)))
    return cc.UserDefault:getInstance():getBoolForKey(key)
end
-- 保存选中地图数据
function LocalDataStorage:setMapPoint()
    local pSeverStr = LocalDataStorage.MAPPOINTTABLE
    if user.Cross_Sever_Status == mCross_Sever_Out then 
       pSeverStr = LocalDataStorage.MAPPOINTTABLE  
    elseif user.Cross_Sever_Status == mCross_Sever then
       pSeverStr = LocalDataStorage.MAPCROSSPOINTTABLE
    end 
    local pStr = ""
    if #mMapTablepoint ~= 0 then
        for key, var in pairs(mMapTablepoint) do
            if var.types == 1 then
                local pX = var["X"]
                local pY = var["Y"]
                local name = var["name"]
                local pPointStr = pX .. "," .. pY..","..name
                if string.len(pStr) == 0 then
                pStr = pPointStr
                else
                pStr = pStr .. ";" .. pPointStr
                end
            end           
        end
        if string.len(pStr) > 0 then
            cc.UserDefault:getInstance():setStringForKey(pSeverStr..self:getLastLoginSID()..self:getUserAccount(), pStr)
            cc.UserDefault:getInstance():flush()
        end
    else
       local pStr = ""
       cc.UserDefault:getInstance():setStringForKey(pSeverStr..self:getLastLoginSID()..self:getUserAccount(), pStr)
       cc.UserDefault:getInstance():flush()
    end
    -- self:getMapPoint()
end

function LocalDataStorage:getMapPoint()
    local pSeverStr = LocalDataStorage.MAPPOINTTABLE
    if user.Cross_Sever_Status == mCross_Sever_Out then 
       pSeverStr = LocalDataStorage.MAPPOINTTABLE  
    elseif user.Cross_Sever_Status == mCross_Sever then
       pSeverStr = LocalDataStorage.MAPCROSSPOINTTABLE
    end 
    local pStr = cc.UserDefault:getInstance():getStringForKey(pSeverStr..self:getLastLoginSID()..self:getUserAccount())
    WorldMapView.SignPoints = { }
    mMapTablepoint = {}
    if string.len(pStr) > 0 then
        local pStr1 = me.split(pStr, ';')
        if pStr1 ~= nil then
            for key, var in pairs(pStr1) do
                local pPointStr = me.split(var, ',')
                if pPointStr ~= nil then
                    local pX = pPointStr[1]
                    local pY = pPointStr[2]
                    local pName = pPointStr[3]
                    local pTabPoint = { }
                    pTabPoint.X = pX
                    pTabPoint.Y = pY
                    pTabPoint.name = pName
                    pTabPoint.types = 1
                    table.insert(mMapTablepoint, 1, pTabPoint)
                    WorldMapView.SignPoints[me.getIdByCoord(cc.p(pX, pY))] = true
                end
            end
        else
            local pPointStr = me.split(pStr, ',')
            if #pPointStr > 1 then
                local pX = pPointStr[1]
                local pY = pPointStr[2]
                local pName = pPointStr[3]
                local pTabPoint = { }
                pTabPoint.X = pX
                pTabPoint.Y = pY
                pTabPoint.name = pName
                pTabPoint.types = 1
                table.insert(mMapTablepoint, 1, pTabPoint)
                WorldMapView.SignPoints[me.getIdByCoord(cc.p(pX, pY))] = true
            end
        end
    end
end
-- 事件信息
function LocalDataStorage:setNoticeInfo()
      local pStr = ""  
      if #mNoticeInfo ~= 0 then                
          for key, var in pairs(mNoticeInfo) do
              local pId = var["id"]
              local pTime = var["time"]
              local pText = var["text"]

              local pTextStr = ""
              if pText ~= nil then                        
                  for key, var in pairs(pText) do
                       if string.len(pTextStr) == 0 then
                          pTextStr = var
                       else
                          pTextStr = pTextStr.."|"..var
                       end
                  end
                  local pParentStr = pId.."|"..pTime.."|"..pTextStr
                  if string.len(pStr) == 0 then
                     pStr = pParentStr
                  else
                     pStr = pStr..";"..pParentStr
                  end
               else
                   local pParentStr = pId.."|"..pTime.."|"..pTextStr
                   if string.len(pStr) == 0 then
                     pStr = pParentStr
                   else
                     pStr = pStr..";"..pParentStr
                   end   
               end
          end
          if string.len(pStr) > 0 then
            cc.UserDefault:getInstance():setStringForKey(LocalDataStorage.NOTICEINFO..self:getLastLoginSID()..self:getUserAccount(), pStr)
            cc.UserDefault:getInstance():flush()
        end 
      end
end
function LocalDataStorage:getNoticeInfo()
      me.tableClear(mNoticeInfo)
      local pStr = cc.UserDefault:getInstance():getStringForKey(LocalDataStorage.NOTICEINFO..self:getLastLoginSID()..self:getUserAccount())     
      if string.len(pStr) > 0 then
         local pNoticeInfo = me.split(pStr,";")         
         for key, var in pairs(pNoticeInfo) do
            local pParent = me.split(var,"|")
            local pId = pParent[1]
            local pTime = pParent[2]
            local pText = {}
            if table.maxn(pParent) > 2 then                               
                for key, var in pairs(pParent) do               
                   if key > 2 then
                       pText[key-2] = var              
                   end
                end
            else
               pText = nil
            end   
            setNoticeinfo(pId,pText,false,pTime)
         end         
      end   
end

--遍历当前的建筑物，看有没有新开启的建筑物并储存 
function LocalDataStorage:flushNewBuildings()
    local function isBuilded(bid_)
        for key, var in pairs(user.building) do
            if var:getDef().id == me.toNum(bid_) then
                return true
            end
        end
        return false
    end

    local function getShopPageIndex(bid_)
        for key, var in pairs(cfg[CfgType.BUILDING_SHOP_TYPE][user.countryId]) do
            for ikey, ivar in pairs(var) do
                if me.toNum(ivar.buildingId) == me.toNum(bid_) then
                    SharedDataStorageHelper():setNewBuildingPage(me.toNum(ivar.shopType),1)
                    SharedDataStorageHelper():setNewBuildingPage(0,1)
                end
            end 
        end
    end

    local function isWonderBuilding(bid_) --奇迹建筑物 特殊处理
        local def = cfg[CfgType.BUILDING][me.toNum(bid_)]
        if def.type == "wonder" then
            --查找其余奇迹建筑物的id
            for key, var in pairs(cfg[CfgType.BUILDING]) do
                if var.type == "wonder" and var.countryId == user.countryId and var.level == 1 then
                    SharedDataStorageHelper():setNewOpenBuildings(var.id,1)
                end
            end
        end
    end

    for key, var in pairs(cfg[CfgType.BUILDING]) do
        if var.countryId == user.countryId and var.openLevel and isBuilded(var.openLevel) then
            if SharedDataStorageHelper():getNewOpenBuildings(var.id) == 0 then
                SharedDataStorageHelper():setNewOpenBuildings(var.id,1)
                getShopPageIndex(var.id)
            end
        end
    end

    --isWonderBuilding(28301)

    if mainCity and mainCity.getPositionX then
        mainCity:setNewBuildingTypeOpen()
    end
end
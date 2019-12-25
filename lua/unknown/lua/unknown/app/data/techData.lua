--科技数据对象
techData = class("techData",BaseDefData)

techData.lockStatus = {
    --未开启的科技
    TECH_UNUSED=1,
    --已开启的科技
    TECH_USED=2,
    --已解锁的科技
    TECH_UNLOCKED=3,
    --正在升级
    TECH_TECHING=4,
    --升级完毕
    TECH_FINISH=5,
}

techData.Img = {
    --未开启科技 / 已解锁科技
    TECH_ENABLE = "keji_tubiankuang_liang_01.png",
    TECH_UNENABLE = "keji_tubiankuang_liang_03.png",
    TECH_TITLE_ENABLE = "ui_tech_text_bg.png",
    TECH_TITLE_UNENABLE = "ui_tech_text_bg.png",
}

--type_：3种状态，1为未开启，2为已开启，3为已解锁
function techData:ctor(defid_)
    super(self, defid_,CfgType.TECH_UPDATE)
    self.lockStatus = 0
    self.buildTime = 0 --升级需要的时间
    self.startTime = 0 --开始升级的系统时间
    return self
end 

function techData:init()

end

--保留服务器下发的升级科技所需时间,和buildIndex,开始时间
function techData:setServerInfo(time_, index_,starTime_)
    self.buildTime = time_
    self.index = index_
    self.startTime = starTime_
end

function techData:getTofid()
    return self.index
end

--根据tofid返回其对应的buildid
function techData:getBuildId()
    local buildTofid = mainCity.buildingMoudles[self.index]
    if buildTofid then
        local def = buildTofid:getDef()
        return def.id
    end
end

function techData:getServerInfo()
    return self.buildTime, self.index, self.startTime
end

function techData:getBuildTime()
    return self.buildTime
end

function techData:getStartTime()
    return self.startTime
end

function techData:setLockStatus(status_)
    self.lockStatus = status_
end

function techData:getLockStatus()
    return self.lockStatus
end
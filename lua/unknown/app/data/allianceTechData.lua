--科技数据对象
allianceTechData = class("allianceTechData",BaseDefData)

allianceTechData.lockStatus = {
    --未开启的科技
    TECH_UNUSED=1,
    --已开启的科技,捐赠中 
    TECH_USED=2,
    --已解锁的科技
    TECH_UNLOCKED=3,
    --正在升级(已开启)
    TECH_TECHING=4,
    --正在升级（未开启0升级1）
    TECH_TECHING_UNSED=6,
    --未开启，捐赠中
    TECH_GIVEN=5,
}

allianceTechData.Img = {
    --未开启科技 / 已解锁科技
    TECH_ENABLE = "keji_tubiankuang_liang.png",
    TECH_UNENABLE = "keji_tubiankuang_hui.png",
    TECH_TITLE_ENABLE = "keji_beijing_shuliang_liang.png",
    TECH_TITLE_UNENABLE = "keji_beijing_shuliang_an.png",
}

--type_：3种状态，1为未开启，2为已开启，3为已解锁
function allianceTechData:ctor(defid_)
    super(self, defid_,CfgType.TECH_FAMILY)
    self.lockStatus = allianceTechData.lockStatus.TECH_UNUSED
    self.updateTime = 0 --升级需要的时间
    self.startTime = 0 --开始升级的系统时间
    self.point = 0 --当前的科技积分
    return self
end 

function allianceTechData:init()

end

--保留服务器下发的已经处于贡献的科技所拥有的数据（活动状态，当前积分值）
function allianceTechData:setGivenInfo(active,point)
    if active == 0 then --处于0级，在捐赠中
        self:setLockStatus(allianceTechData.lockStatus.TECH_GIVEN)
    else --已经升级过了，在捐赠中
        self:setLockStatus(allianceTechData.lockStatus.TECH_USED)
    end
    self.point = point
end

--保留服务器下发的升级科技所需时间,开始时间
function allianceTechData:setUpdateInfo(cd)
    self.updateTime = cd
    self.startTime = me.sysTime()
    if self:getLockStatus()==allianceTechData.lockStatus.TECH_GIVEN then
        self:setLockStatus(allianceTechData.lockStatus.TECH_TECHING)
    else
        self:setLockStatus(allianceTechData.lockStatus.TECH_TECHING_UNSED)
    end
end

function allianceTechData:getUpdateTime()
    return self.updateTime
end

function allianceTechData:getStartTime()
    return self.startTime
end

function allianceTechData:getPoint()
    return self.point
end

function allianceTechData:setLockStatus(status_)
    self.lockStatus = status_
end

function allianceTechData:getLockStatus()
    return self.lockStatus
end
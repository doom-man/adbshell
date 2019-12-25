--继承myclass类
base = class("base",myclass)
base.__index = base
function base:ctor(id)    
    super(self,id)
    print("base:ctor()")    
    print(self.id)
    self:getId() --调用继承的成员函数
end
--

_,DUI=...

_duiGlobal=DUI

DUI.bigS=45
DUI.medS=30
DUI.smallS=20
DUI.bigFS=24
DUI.medFS=15
DUI.smallFS=13

local tempF=CreateFrame("Frame")
tempF:RegisterEvent("PLAYER_ENTERING_WORLD")
tempF:SetScript("OnEvent",function()
  local className=UnitClass("player")
  if className~="Priest" then return
  else
    tempF:UnregisterEvent("PLAYER_ENTERING_WORLD")
    tempF=nil
    local fabn=function(goal,unit,arg1,arg2,arg3)
        for i=1,40 do
          local name,_,_,_,_,_,caster=UnitAura(unit,i,arg1,arg2)
          if not name then return nil end
          if (name==goal) and (caster=="player") then return UnitAura(unit,i,arg1,arg2,arg3) end
        end  
    end
    
    local green={0.3,0.95,0.3}
    local red={0.9,0.3,0.3}
    local yellow={0.95,0.95,0.3}
    
    local manaBD={edgeFile ="Interface\\DialogFrame\\UI-DialogBox-Border",edgeSize = 8, insets ={ left = 0, right = 0, top = 0, bottom = 0 }}
    local bd2={edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 10, insets = { left = 4, right = 4, top = 4, bottom = 4 }}
    local insert=table.insert
    local port={}
    local mf=math.floor
    local afterDo=C_Timer.After
    local pairs=pairs
    local playerName=UnitName("player")
    local nCheck=4 --means echecking 4 times across the duration of the cooldown (to account for haste changes, kinda)
                   --I know it's not clean but it still seems more efficient than any alternative
                   
    function DUI.onCast1(self)
      local t,d=GetSpellCooldown(self.id)
      if d<1.5 then
        self.offCD:Show()
        self.onCD:Hide()
      else
        if self.cast then
          local d2=d/nCheck
          for i=1,nCheck-1 do
            afterDo(i*d2,function() self:onCast() end)
          end
        end
        
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
      end
      self.cast=false
    end

    function DUI.onCastRap(self)
      local t,d=GetSpellCooldown(self.id)
      if d<2 then
        self.offCD:Show()
        self.onCD:Hide()
      else
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
        
        local ext=select(6,fabn("Rapture","player","HELPFUL","PLAYER"))
        if ext then
        self.active:Show()
        self.active.ext=ext
        afterDo(ext-GetTime(),function() self.active:Hide() end)
        end
      end

    end
    
    function DUI.onUpdate1(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      self.text1:SetText(mf(rT))
      if rT<0.01 then self.parent:onCast() end
    end
    
    function DUI.onUpdate2(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      if rT<0.01 then self.parent:onCast() end
    end
    
    function DUI.onUpdateJSSChannelUp(self,et)
      self.et=self.et+et
      if self.et<0.1 then return end

      self.et=0
      local rT=self.t+self.d-GetTime()
      self.text:SetText(mf(rT))    
    end
    
    local function createCDIcon(id,size,hasCDTimer)
      local hasCDTimer=hasCDTimer
      if not hasCDTimer then hasCDTimer=false end --unnecessary, I know
      local iF
      local _,_,icon=GetSpellInfo(id)
      local s,fs
      if size=="big" then s=DUI.bigS; fs=DUI.bigFS end
      if size=="med" then s=DUI.medS; fs=DUI.medFS end
      if size=="small" then s=DUI.smallS; fs=DUI.smallFS end

      iF=CreateFrame("Frame",nil,DUI.f)
      iF:SetSize(s,s)
      iF:SetFrameLevel(5)
      iF.id=id
      
      iF.offCD=CreateFrame("Frame",nil,iF)
      iF.offCD:SetAllPoints(true)

      iF.offCD.texture=iF.offCD:CreateTexture(nil,"BACKGROUND")
      iF.offCD.texture:SetAllPoints(true)
      iF.offCD.texture:SetTexture(icon)

      iF.offCD.cd=CreateFrame("Cooldown",nil,iF.offCD,"CooldownFrameTemplate")
      iF.offCD.cd:SetAllPoints(true)
      iF.offCD.cd:SetFrameLevel(iF.offCD:GetFrameLevel())
      iF.offCD.cd:SetDrawEdge(false)
      iF.offCD.cd:SetDrawBling(false)
      
      iF.offCD.text2=iF.offCD:CreateFontString(nil,"OVERLAY")
      iF.offCD.text2:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.offCD.text2:SetPoint("CENTER")
      
      iF.onCD=CreateFrame("Frame",nil,iF)
      iF.onCD:SetAllPoints(true)
      
      iF.onCD.texture=iF.onCD:CreateTexture(nil,"BACKGROUND")
      iF.onCD.texture:SetAllPoints(true)
      iF.onCD.texture:SetTexture(icon)
      iF.onCD.texture:SetDesaturated(1)

      iF.onCD.cd=CreateFrame("Cooldown",nil,iF.onCD,"CooldownFrameTemplate")
      iF.onCD.cd:SetAllPoints(true)
      iF.onCD.cd:SetFrameLevel(iF.onCD:GetFrameLevel())
      iF.onCD.cd:SetDrawEdge(false)
      iF.onCD.cd:SetDrawBling(false)
      
      iF.onCD.text1=iF.onCD:CreateFontString(nil,"OVERLAY")
      iF.onCD.text1:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.onCD.text1:SetPoint("CENTER")

      if hasCDTimer then iF.onCD:SetScript("OnUpdate",DUI.onUpdate1) 
      else iF.onCD:SetScript("OnUpdate",DUI.onUpdate2) end
      iF.onCD.parent=iF

      iF.onCD:Hide()

      iF.onCD.et=0
      port[id]=iF
      return iF
    end
    
    local function createAuraIcon(id,size)
      local iF
      local _,_,icon=GetSpellInfo(id)
      local s,fs
      if size=="big" then s=DUI.bigS; fs=DUI.bigFS end
      if size=="med" then s=DUI.medS; fs=DUI.medFS end
      if size=="small" then s=DUI.smallS; fs=DUI.smallFS end

      iF=CreateFrame("Frame",nil,DUI.f)
      iF:SetSize(s,s)
      iF:SetFrameLevel(5)
      iF.id=id
      
      iF.grey=CreateFrame("Frame",nil,iF)
      iF.grey:SetAllPoints(true)

      iF.grey.texture=iF.grey:CreateTexture(nil,"BACKGROUND")
      iF.grey.texture:SetAllPoints(true)
      iF.grey.texture:SetTexture(icon)
      iF.grey.texture:SetDesaturated(1)

      iF.grey.text=iF.grey:CreateFontString(nil,"OVERLAY")
      iF.grey.text:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.grey.text:SetPoint("CENTER")
      
      iF.normal=CreateFrame("Frame",nil,iF)
      iF.normal:SetAllPoints(true)
      
      iF.normal.texture=iF.normal:CreateTexture(nil,"BACKGROUND")
      iF.normal.texture:SetAllPoints(true)
      iF.normal.texture:SetTexture(icon)

      iF.normal.cd=CreateFrame("Cooldown",nil,iF.normal,"CooldownFrameTemplate")
      iF.normal.cd:SetAllPoints(true)
      iF.normal.cd:SetFrameLevel(iF.normal:GetFrameLevel())

      iF.normal.text=iF.normal:CreateFontString(nil,"OVERLAY")
      iF.normal.text:SetFont("Fonts\\FRIZQT__.ttf",fs,"OUTLINE")
      iF.normal.text:SetPoint("CENTER")

      iF.normal:Hide()

      iF.normal.et=0
      return iF
    end

    local function checkTalentStuff()
      local _,_,_,sch = GetTalentInfo(1,3,1)
      local _,_,_,sol = GetTalentInfo(3,3,1)
      local _,_,_,mb = GetTalentInfo(3,2,1)
      local _,_,_,halo = GetTalentInfo(6,3,1)
      local _,_,_,ds = GetTalentInfo(6,2,1)
      local _,_,_,evan=GetTalentInfo(7,3,1)
      local _,_,_,lb=GetTalentInfo(7,2,1)
      if sch then DUI.sch:Show(); DUI.sch:onCast() else DUI.sch:Hide() end
      if sol then DUI.sol:Show(); DUI.sol:onCast() else DUI.sol:Hide() end
      if halo then DUI.halo:Show(); DUI.halo:onCast() else DUI.halo:Hide() end 
      if ds then DUI.ds:Show(); DUI.ds:onCast() else DUI.ds:Hide() end 
      if evan then DUI.evan:Show(); DUI.evan:onCast(); else DUI.evan:Hide() end
      if mb then DUI.mb:Show(); DUI.mb:onCast(); else DUI.mb:Hide() end
      if lb then DUI.lb:Show(); DUI.lb:onCast(); DUI.pwb:Hide(); else DUI.pwb:Show(); DUI.pwb:onCast(); DUI.lb:Hide(); end

    end

    local function checkCombat()
        if true then return  end
        if InCombatLockdown() then DUI.f:Show() else DUI.f:Hide() end 
    end
    
    local function checkSpecialization()
      
      if GetSpecialization()==1 then 
        DUI.f:Show() 
        DUI.f.loaded=true
      else 
        DUI.f:Hide() 
        DUI.f.loaded=false
      end
      checkCombat()
    end
    
    local function checkTargetSWP()
      if not UnitExists("target") then return nil end

      local _,_,_,_,d,ext=fabn("Shadow Word: Pain","target","HARMFUL","PLAYER")
      
      if not d then 
        d,ext=select(5,fabn("Purge the Wicked","target","HARMFUL","PLAYER"))  --kind of dirty, should do it with checkTalent() TBA
      end
      
      return d,ext
    end
    
    local function fOnShow()
      for _,v in pairs(port) do  v:onCast() end
      DUI.mana:update()
    end
       
    function DUI.onCastRad(self)
      local s,_,t,d=GetSpellCharges(self.id)

      if s==2 then
        self.onCD:Hide()
        self.offCD:Show()
        self.offCD.et=1
        self.offCD.cd:SetCooldown(0,0)
        self.offCD.t=t
        self.offCD.d=d
        self.offCD.text2:SetText(s)
      elseif s>0 and d>2 then
        self.onCD:Hide()
        self.offCD:Show()
        self.offCD.et=1
        self.offCD.cd:SetCooldown(t,d)
        self.offCD.t=t
        self.offCD.d=d
        self.offCD.text2:SetText(s)
        afterDo(d, function() self:onCast() end)
      elseif s==0 then
        self.offCD:Hide()
        self.onCD:Show()
        self.onCD.et=1
        self.onCD.cd:SetCooldown(t,d)
        self.onCD.t=t
        self.onCD.d=d
      end
      
    end
    
    local currentHaste=0
    local hasteSpells={129250}
    DUI.eventHandler = function(self,event,_,tar,id,id2)
      if not self.loaded then return end
      if event=="UNIT_HEALTH_FREQUENT" then
        DUI.health:update()

      elseif event=="UNIT_POWER_UPDATE" then 
        DUI.mana:update()
                
      elseif event=="UNIT_SPELLCAST_SUCCEEDED" then
       local spell=port[id]
       
       if spell then    
         spell.cast=true         
         afterDo(0,function() spell:onCast();  end)         
       end
       if id==132157 then afterDo(0,function() port[194509]:onCast() end) end --if holy nova then check radiance
      
      elseif event=="UNIT_SPELL_HASTE" then
        local haste=UnitSpellHaste("player")
        if haste==currentHaste then return end
        currentHaste=haste
        for i=1,#hasteSpells do 
          local spell=port[hasteSpells[i]]
          afterDo(0,function() spell:onCast();  end)   
        end
      end
      
    end
    
    DUI.f=CreateFrame("Frame","DUIFrame",UIParent)
    local f=DUI.f

    --main frame + mover + slash command
    do
    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED","player")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE","player")
    f:RegisterUnitEvent("UNIT_HEALTH_FREQUENT","player")
    f:RegisterUnitEvent("UNIT_SPELL_HASTE","player")
    f:SetScript("OnEvent",DUI.eventHandler)
    f:SetScript("OnShow",fOnShow)
    f:SetSize(2*DUI.bigS+1,150)
    f:SetPoint("CENTER")
    f:SetMovable(true)

    f.mover=CreateFrame("Frame",nil,f)
    f.mover:SetAllPoints(true)
    f.mover:SetFrameLevel(20)

    f.mover.texture=f.mover:CreateTexture(nil,"OVERLAY")
    f.mover.texture:SetAllPoints(true)
    f.mover.texture:SetColorTexture(0,0,0.1,0.5)

    f.mover:EnableMouse(true)
    f.mover:SetMovable(true)
    f.mover:RegisterForDrag("LeftButton")
    f.mover:SetScript("OnMouseDown", function() DUI.f:StartMoving();  end)
    f.mover:SetScript("OnMouseUp", function() DUI.f:StopMovingOrSizing();  end)
    f.mover:Hide()

    SLASH_DUI1="/dui"
    SlashCmdList["DUI"]= function(arg)
      if f.mover:IsShown() then f.mover:Hide() else f.mover:Show() end
    end

    end --end of main mover slash

    --helper frame
    do
    DUI.h=CreateFrame("Frame","DUIHFrame",UIParent)
    local h=DUI.h
    h:SetPoint("CENTER")
    h:SetSize(1,1)
    h:RegisterEvent("PLAYER_REGEN_ENABLED")
    h:RegisterEvent("PLAYER_REGEN_DISABLED")
    h:RegisterEvent("PLAYER_ENTERING_WORLD")
    h:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    h:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    
    local function hEventHandler(self,event) 
      if event=="PLAYER_REGEN_ENABLED" then
        afterDo(15,checkCombat)
      elseif event=="PLAYER_REGEN_DISABLED" then
        if self.loaded then DUI.f:Show() end
      elseif event=="ACTIVE_TALENT_GROUP_CHANGED" then
        checkTalentStuff()
      elseif event=="PLAYER_SPECIALIZATION_CHANGED" then
        checkSpecialization()
      end
    end

    h:SetScript("OnEvent",hEventHandler)

    end --end of help frame

    --spells 
    do 

    DUI.pen=createCDIcon(47540,"big",true)
    DUI.pen:SetPoint("TOPLEFT",DUI.f,"TOPLEFT",0,0)
    DUI.pen.onCast=DUI.onCast1
    
    DUI.rad=createCDIcon(194509,"big",true)
    DUI.rad:SetPoint("LEFT",DUI.pen,"RIGHT",1,0)
    DUI.rad.onCast=DUI.onCastRad
    DUI.rad.offCD.text2:SetTextColor(green[1],green[2],green[3])

    DUI.halo=createCDIcon(120517,"med",true)
    DUI.halo:SetPoint("TOPRIGHT",DUI.rad,"BOTTOMRIGHT",0,-2-DUI.bigS)
    DUI.halo.onCast=DUI.onCast1
   
    DUI.ds=createCDIcon(110744,"med")
    DUI.ds:SetPoint("TOPRIGHT",DUI.rad,"BOTTOMRIGHT",0,-2-DUI.bigS)
    DUI.ds.onCast=DUI.onCast1
    
    DUI.sol=createCDIcon(129250,"big",true)
    DUI.sol:SetPoint("TOP",DUI.pen,"BOTTOM",0,-1)
    DUI.sol.onCast=DUI.onCast1
   
    DUI.mb=createCDIcon(123040,"big",true)
    DUI.mb:SetPoint("TOP",DUI.pen,"BOTTOM",0,-1)
    DUI.mb.onCast=DUI.onCast1
   
    DUI.sch=createCDIcon(214621,"big",true)
    DUI.sch:SetPoint("TOP",DUI.rad,"BOTTOM",0,-1)
    DUI.sch.onCast=DUI.onCast1
    
    DUI.evan=createCDIcon(246287,"med",true)
    DUI.evan:SetPoint("TOPRIGHT",DUI.rad,"BOTTOMRIGHT",0,-3-DUI.bigS-DUI.medS)
    DUI.evan.onCast=DUI.onCast1
    
    DUI.sdp=createAuraIcon(589,"med")
    DUI.sdp:SetPoint("TOPLEFT",DUI.pen,"BOTTOMLEFT",0,-2-DUI.bigS)
    DUI.sdp:RegisterUnitEvent("UNIT_AURA","TARGET")
    DUI.sdp:RegisterEvent("PLAYER_TARGET_CHANGED")
    DUI.sdp:SetScript("OnEvent",function(self)
      local d,ext=checkTargetSWP()      
      if d then 
        self.grey:Hide()
        self.normal:Show()
        self.normal.d=d
        self.normal.ext=ext
        self.normal.cd:SetCooldown(ext-d,d)
        self.et=10
      else
        self.grey:Show()
        self.normal:Hide()
      end  
    end)
    DUI.sdp.normal:SetScript("OnUpdate",function(self,elapsed)
      self.et=self.et+elapsed
      if self.et<0.15 then return end
      self.et=0
      self.text:SetText(mf(self.ext-GetTime()))   
    end)
    
    DUI.rap=createCDIcon(47536,"med",true)
    DUI.rap:SetPoint("TOPLEFT",DUI.pen,"BOTTOMLEFT",0,-3-DUI.bigS-DUI.medS)
    DUI.rap.onCast=DUI.onCastRap      
    
    DUI.rapActive=CreateFrame("Frame",nil,DUI.rap)
    DUI.rapActive:SetFrameLevel(DUI.rap:GetFrameLevel()+2)
    DUI.rap.active=DUI.rapActive
    DUI.rapActive:SetAllPoints()
    
    DUI.rapActive.texture=DUI.rapActive:CreateTexture(nil,"BACKGROUND")
    DUI.rapActive.texture:SetAllPoints()
    DUI.rapActive.texture:SetTexture(237548)
    
    DUI.rapActive.text=DUI.rapActive:CreateFontString(nil,"OVERLAY")
    DUI.rapActive.text:SetFont("Fonts\\FRIZQT__.ttf",DUI.medFS,"OUTLINE")
    DUI.rapActive.text:SetTextColor(yellow[1],yellow[2],yellow[3])
    DUI.rapActive.text:SetText("NA")
    DUI.rapActive.text:SetPoint("CENTER")
    DUI.rapActive.et=10
    DUI.rapActive.ext=GetTime()
    DUI.rapActive:SetScript("OnUpdate",function(self,elapsed)
      self.et=self.et+elapsed
      if self.et<0.15 then return end
      self.et=0   
      self.text:SetText(math.floor(self.ext-GetTime()))
    end)
    DUI.rapActive:Hide()

    DUI.sf=createCDIcon(254224,"med",false)
    DUI.sf:SetPoint("TOP",DUI.rap,"BOTTOM",0,-1)
    DUI.sf.onCast=DUI.onCast1   
    
    DUI.pwb=createCDIcon(62618,"med",false)
    DUI.pwb:SetPoint("TOPRIGHT",DUI.rad,"BOTTOMRIGHT",0,-4-DUI.bigS-2*DUI.medS)
    DUI.pwb.onCast=DUI.onCast1   
    DUI.pwb.onCD.texture:SetTexture(253400)
    DUI.pwb.offCD.texture:SetTexture(253400)
    
    DUI.lb=createCDIcon(271466,"med",false)
    DUI.lb:SetPoint("TOPRIGHT",DUI.rad,"BOTTOMRIGHT",0,-4-DUI.bigS-2*DUI.medS)
    DUI.lb.onCast=DUI.onCast1   
    DUI.lb.onCD.texture:SetTexture(537078)
    DUI.lb.offCD.texture:SetTexture(537078)

    
    DUI.lj=createCDIcon(255647,"med",false)
    DUI.lj:SetPoint("TOP",DUI.pwb,"BOTTOM",0,-1)
    DUI.lj.onCast=DUI.onCast1  
    
    DUI.pf=createCDIcon(527,"med",true)
    DUI.pf:SetPoint("TOP",DUI.sf,"BOTTOM",0,-1)
    DUI.pf.onCast=DUI.onCast1  
    
    DUI.fade=createCDIcon(586,"small",false)
    DUI.fade:SetPoint("TOPLEFT",DUI.pf,"BOTTOM",10,-1)
    DUI.fade.onCast=DUI.onCast1
    
    DUI.dp=createCDIcon(19236,"small",false)
    DUI.dp:SetPoint("LEFT",DUI.fade,"RIGHT",1,0)
    DUI.dp.onCast=DUI.onCast1
    
    end

    --mana bar
    do
    local function manaUpdateFunc(self)
      local m=UnitPower("player")
      local mm=UnitPowerMax("player")
      local val=m/mm*100
      self:SetValue(val)
      self.text:SetText(mf(val))
    end


    DUI.mana=CreateFrame("StatusBar","DUImana",DUI.f,"TextStatusBar")
    DUI.mana:SetPoint("TOPLEFT",DUI.rad,"BOTTOMLEFT",1,-2-DUI.bigS)
    DUI.mana:SetHeight(122)
    DUI.mana:SetWidth(12)
    DUI.mana:SetOrientation("VERTICAL")
    DUI.mana:SetReverseFill(false)
    DUI.mana:SetMinMaxValues(0,100)
    DUI.mana:SetStatusBarTexture(0.3,0.3,0.95,1)
    DUI.mana.update=manaUpdateFunc

    local bt=DUI.mana:GetStatusBarTexture()
    bt:SetGradientAlpha("HORIZONTAL",1,1,1,1,0.4,0.4,0.4,1)


    DUI.mana.border=CreateFrame("Frame",nil,DUI.mana)
    DUI.mana.border:SetPoint("TOPRIGHT",DUI.mana,"TOPRIGHT",3,3)
    DUI.mana.border:SetPoint("BOTTOMLEFT",DUI.mana,"BOTTOMLEFT",-6,-3)
    --DUI.mana.border:SetBackdrop(manaBD) 

    DUI.mana.text=DUI.mana.border:CreateFontString(nil,"OVERLAY")
    DUI.mana.text:SetFont("Fonts\\FRIZQT__.ttf",12,"OUTLINE")
    DUI.mana.text:SetPoint("TOP",DUI.mana,"TOP",0,-2)
    DUI.mana.text:Hide() --rmove if want to show obv.

    DUI.mana.bg=DUI.mana:CreateTexture(nil,"BACKGROUND")
    DUI.mana.bg:SetPoint("TOPRIGHT",DUI.mana,"TOPRIGHT",2,2)
    DUI.mana.bg:SetPoint("BOTTOMLEFT",DUI.mana,"BOTTOMLEFT",-2,-2)
    DUI.mana.bg:SetColorTexture(0,0,0,1)

    end

    --health bar
    do
    local function healthUpdateFunc(self)
      local m=UnitHealth("player")
      local mm=UnitHealthMax("player")
      local val=m/mm*100
      self:SetValue(val)
      self.text:SetText(mf(val))
    end


    DUI.health=CreateFrame("StatusBar","DUIhealth",DUI.f,"TextStatusBar")
    DUI.health:SetPoint("TOPRIGHT",DUI.pen,"BOTTOMRIGHT",-1,-2-DUI.bigS)
    DUI.health:SetHeight(122)
    DUI.health:SetWidth(12)
    DUI.health:SetOrientation("VERTICAL")
    DUI.health:SetReverseFill(false)
    DUI.health:SetMinMaxValues(0,100)
    DUI.health:SetStatusBarTexture(0.3,0.85,0.3,1)
    DUI.health.update=healthUpdateFunc

    local bt=DUI.health:GetStatusBarTexture()
    bt:SetGradientAlpha("HORIZONTAL",1,1,1,1,0.4,0.4,0.4,1)

    DUI.health.border=CreateFrame("Frame",nil,DUI.health)
    DUI.health.border:SetPoint("TOPRIGHT",DUI.health,"TOPRIGHT",6,3)
    DUI.health.border:SetPoint("BOTTOMLEFT",DUI.health,"BOTTOMLEFT",-3,-3)
    --DUI.health.border:SetBackdrop(healthBD) 

    DUI.health.text=DUI.health.border:CreateFontString(nil,"OVERLAY")
    DUI.health.text:SetFont("Fonts\\FRIZQT__.ttf",12,"OUTLINE")
    DUI.health.text:SetPoint("TOP",DUI.health,"TOP",0,-2)
    DUI.health.text:Hide() --rmove if want to show obv.

    DUI.health.bg=DUI.health:CreateTexture(nil,"BACKGROUND")
    DUI.health.bg:SetPoint("TOPRIGHT",DUI.health,"TOPRIGHT",2,2)
    DUI.health.bg:SetPoint("BOTTOMLEFT",DUI.health,"BOTTOMLEFT",-2,-2)
    DUI.health.bg:SetColorTexture(0,0,0,1)
    end

    
    --things to do on PLAYER_ENTERING_WORLD
    checkTalentStuff()
    fOnShow()
    checkSpecialization()
    if playerName=="Monogon" then 
        if _eFGlobal then --eF1
            afterDo(0,function() DUI.f:SetPoint("TOPRIGHT",_eFGlobal.units,"TOPLEFT",-2,0) end) 
        elseif elFramoGlobal then --eF2
            afterDo(0,function() DUI.f:SetPoint("TOPRIGHT",UIParent,"BOTTOMLEFT",elFramoGlobal.para.units.xPos-2,elFramoGlobal.para.units.yPos) end) 
        end
    end    
    
    --NON DISC UI RELATED THINGS
    --[[
    afterDo(5,function()
    if BigWigsAnchor then BigWigsAnchor:ClearAllPoints();  BigWigsAnchor:SetPoint("TOPLEFT",_eFGlobal.units,"TOPRIGHT",0,2) end 
    end)
    ]]
    checkCombat()
  end
end)














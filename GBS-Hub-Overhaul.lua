local H=game:GetService("HttpService")
local T=game:GetService("TweenService")
local P=game:GetService("Players")
local U=game:GetService("UserInputService")
local L=game:GetService("Lighting")
local LP=P.LocalPlayer
local GP=(syn and syn.protect_gui and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

local old=GP:FindFirstChild("GBSHub")
if old then old:Destroy() end
local ob=L:FindFirstChild("GBSHubBlur")
if ob then ob:Destroy() end

local D={
 settings={scale=1},
 favorites={},
 recent={},
 scripts={
  {title="Infinite Yield",category="Tools",description="Universal admin command script.",source="https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},
  {title="Cobalt",category="Tools",description="Remote event inspection utility.",source="https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"},
  {title="YARHM",category="Universal",description="Universal utility script.",source="https://rawscripts.net/raw/Universal-Script-YARHM-12403"},
  {title="Deo",category="Universal",description="Demonlogy universal script.",source="https://file.garden/ahkRbB3bekZ7SJ00/LOADER"},
  {title="Universal Emotes",category="Universal",description="Universal emote hub by 7yd7.",source="https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"},
  {title="Distance Checker",category="Universal",description="Checks the live distance between two players.",source="https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/DistanceChecker.lua"},
  {title="GBS Aimlocker",category="Universal",description="Universal aimlocker utility.",source="https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/GBSAIMLOCKER.lua"},
  {title="Held Tool Paster",category="Universal",description="Copies the tool you're holding and allows repeated pasting.",source="https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/heldtoolpaster.lua"},
  {title="Hunters vs Hiders - Landmine Region",category="Hunters vs Hiders",description="Places and fills landmine regions with adjustable spacing and delay.",source="https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/huntersvshiders.lua"},
  {title="Tornado",category="Universal",description="Creates a tornado that attracts loose objects.",source="https://raw.githubusercontent.com/GBSZach/RobloxScripts-/refs/heads/main/tornadoscript.lua"}
 }
}

local G=Instance.new("ScreenGui")
G.Name="GBSHub"
G.IgnoreGuiInset=true
G.ResetOnSpawn=false
G.Parent=GP

local B=Instance.new("BlurEffect")
B.Name="GBSHubBlur"
B.Size=10
B.Parent=L

local M=Instance.new("Frame")
M.Size=UDim2.fromScale(.68,.68)
M.Position=UDim2.fromScale(.5,.5)
M.AnchorPoint=Vector2.new(.5,.5)
M.BackgroundColor3=Color3.fromRGB(20,20,20)
M.BorderSizePixel=0
M.Parent=G
Instance.new("UICorner",M).CornerRadius=UDim.new(0,10)

local SC=Instance.new("UIScale")
SC.Scale=D.settings.scale
SC.Parent=M

local function corner(x,r)
 Instance.new("UICorner",x).CornerRadius=UDim.new(0,r or 6)
end

local function button(parent,text,size,pos,bg)
 local b=Instance.new("TextButton")
 b.Size=size
 b.Position=pos
 b.BackgroundColor3=bg or Color3.fromRGB(35,35,35)
 b.Text=text
 b.TextColor3=Color3.new(1,1,1)
 b.Font=Enum.Font.GothamBold
 b.TextSize=13
 b.Parent=parent
 corner(b)
 return b
end

local function label(parent,text,size,pos,fs,color)
 local x=Instance.new("TextLabel")
 x.Size=size
 x.Position=pos
 x.BackgroundTransparency=1
 x.Text=text
 x.TextColor3=color or Color3.new(1,1,1)
 x.Font=Enum.Font.Gotham
 x.TextSize=fs or 14
 x.TextXAlignment=Enum.TextXAlignment.Left
 x.Parent=parent
 return x
end

local top=Instance.new("Frame")
top.Size=UDim2.new(1,0,0,36)
top.BackgroundTransparency=1
top.Parent=M

label(top,"GBS Hub",UDim2.new(1,-120,1,0),UDim2.new(0,10,0,0),18).Font=Enum.Font.GothamBold

local setBtn=button(top,"⚙",UDim2.fromOffset(28,28),UDim2.new(1,-96,0,4))
local minBtn=button(top,"—",UDim2.fromOffset(28,28),UDim2.new(1,-64,0,4))
local closeBtn=button(top,"✕",UDim2.fromOffset(28,28),UDim2.new(1,-32,0,4))

local drag=false
local ds,dp,di

top.InputBegan:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  drag=true
  ds=i.Position
  dp=M.Position
  i.Changed:Connect(function()
   if i.UserInputState==Enum.UserInputState.End then drag=false end
  end)
 end
end)

top.InputChanged:Connect(function(i)
 if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then di=i end
end)

U.InputChanged:Connect(function(i)
 if drag and i==di then
  local d=i.Position-ds
  M.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
 end
end)

local tabs=Instance.new("ScrollingFrame")
tabs.Size=UDim2.new(1,-20,0,34)
tabs.Position=UDim2.new(0,10,0,40)
tabs.BackgroundTransparency=1
tabs.BorderSizePixel=0
tabs.ScrollBarThickness=0
tabs.ScrollingDirection=Enum.ScrollingDirection.X
tabs.AutomaticCanvasSize=Enum.AutomaticSize.X
tabs.Parent=M

local tl=Instance.new("UIListLayout",tabs)
tl.FillDirection=Enum.FillDirection.Horizontal
tl.Padding=UDim.new(0,4)

local search=Instance.new("TextBox")
search.Size=UDim2.new(1,-20,0,30)
search.Position=UDim2.new(0,10,0,78)
search.BackgroundColor3=Color3.fromRGB(30,30,30)
search.TextColor3=Color3.new(1,1,1)
search.PlaceholderColor3=Color3.fromRGB(130,130,130)
search.PlaceholderText="Search scripts..."
search.Text=""
search.ClearTextOnFocus=false
search.Font=Enum.Font.Gotham
search.TextSize=14
search.Parent=M
corner(search)

local scroll=Instance.new("ScrollingFrame")
scroll.Size=UDim2.new(1,-20,1,-120)
scroll.Position=UDim2.new(0,10,0,114)
scroll.BackgroundTransparency=1
scroll.BorderSizePixel=0
scroll.ScrollBarThickness=4
scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.Parent=M

local sl=Instance.new("UIListLayout",scroll)
sl.Padding=UDim.new(0,4)

local function notify(text)
 local n=Instance.new("TextLabel")
 n.Size=UDim2.fromOffset(240,40)
 n.Position=UDim2.new(1,-250,1,-50)
 n.BackgroundColor3=Color3.fromRGB(30,30,30)
 n.TextColor3=Color3.new(1,1,1)
 n.Text=text
 n.Font=Enum.Font.GothamBold
 n.TextSize=14
 n.Parent=G
 corner(n,8)
 n.BackgroundTransparency=1
 n.TextTransparency=1
 T:Create(n,TweenInfo.new(.2),{BackgroundTransparency=0,TextTransparency=0}):Play()
 task.delay(2,function()
  if not n.Parent then return end
  T:Create(n,TweenInfo.new(.2),{BackgroundTransparency=1,TextTransparency=1}):Play()
  task.wait(.2)
  n:Destroy()
 end)
end

local function fav(name)
 return table.find(D.favorites,name)~=nil
end

local function toggleFav(name)
 local i=table.find(D.favorites,name)
 if i then
  table.remove(D.favorites,i)
  return false
 end
 table.insert(D.favorites,name)
 return true
end

local function recent(name)
 local i=table.find(D.recent,name)
 if i then table.remove(D.recent,i) end
 table.insert(D.recent,1,name)
 while #D.recent>10 do table.remove(D.recent) end
end

local function find(name)
 for _,v in ipairs(D.scripts) do
  if v.title==name then return v end
 end
end

local function sourceCode(s)
 if not s or s=="" then return end
 if s:match("^https?://") then
  return 'loadstring(game:HttpGet("'..s..'"))()'
 end
 return s
end

local current="Universal"
local popup

local function closePopup()
 if popup then popup:Destroy() popup=nil end
end

local function popupBase(name,w,h)
 closePopup()
 popup=Instance.new("Frame")
 popup.Size=UDim2.fromOffset(w,h)
 popup.Position=UDim2.fromScale(.5,.5)
 popup.AnchorPoint=Vector2.new(.5,.5)
 popup.BackgroundColor3=Color3.fromRGB(25,25,25)
 popup.Parent=G
 corner(popup,8)

 label(popup,name,UDim2.new(1,-50,0,30),UDim2.new(0,10,0,5),16).Font=Enum.Font.GothamBold

 local c=button(popup,"✕",UDim2.fromOffset(28,28),UDim2.new(1,-34,0,4))
 c.MouseButton1Click:Connect(closePopup)
 return popup
end

local function box(parent,placeholder,y,h)
 local x=Instance.new("TextBox")
 x.Size=UDim2.new(1,-20,0,h or 34)
 x.Position=UDim2.new(0,10,0,y)
 x.BackgroundColor3=Color3.fromRGB(35,35,35)
 x.TextColor3=Color3.new(1,1,1)
 x.PlaceholderColor3=Color3.fromRGB(130,130,130)
 x.PlaceholderText=placeholder
 x.Text=""
 x.ClearTextOnFocus=false
 x.TextWrapped=true
 x.TextYAlignment=Enum.TextYAlignment.Top
 x.Font=Enum.Font.Gotham
 x.TextSize=14
 x.Parent=parent
 corner(x)
 return x
end

local function refreshTabs() end
local function loadTab() end

local function addPopup()
 local p=popupBase("Add Script",320,330)
 local a=box(p,"Script Title",42)
 local b=box(p,"Script URL or Lua Code",82,65)
 local c=box(p,"Category",152)
 local d=box(p,"Description",192,65)
 local ok=button(p,"ADD SCRIPT",UDim2.new(1,-20,0,36),UDim2.new(0,10,1,-46),Color3.fromRGB(60,120,255))

 ok.MouseButton1Click:Connect(function()
  if a.Text=="" or b.Text=="" then notify("Title and source required") return end
  table.insert(D.scripts,{
   title=a.Text,
   category=c.Text~="" and c.Text or "Universal",
   description=d.Text~="" and d.Text or "No description.",
   source=b.Text
  })
  local n=a.Text
  closePopup()
  refreshTabs()
  loadTab(current)
  notify("Added "..n)
 end)
end

local function editPopup(data)
 local p=popupBase("Edit Script",320,330)
 local a=box(p,"Script Title",42);a.Text=data.title
 local b=box(p,"Script URL or Lua Code",82,65);b.Text=data.source or data.code or ""
 local c=box(p,"Category",152);c.Text=data.category or "Universal"
 local d=box(p,"Description",192,65);d.Text=data.description or ""
 local ok=button(p,"SAVE CHANGES",UDim2.new(1,-20,0,36),UDim2.new(0,10,1,-46),Color3.fromRGB(60,120,255))

 ok.MouseButton1Click:Connect(function()
  if a.Text=="" or b.Text=="" then notify("Title and source required") return end
  local old=data.title
  local fi=table.find(D.favorites,old)
  if fi then D.favorites[fi]=a.Text end
  for i,n in ipairs(D.recent) do
   if n==old then D.recent[i]=a.Text end
  end
  data.title=a.Text
  data.source=b.Text
  data.category=c.Text~="" and c.Text or "Universal"
  data.description=d.Text~="" and d.Text or "No description."
  closePopup()
  refreshTabs()
  loadTab(current)
  notify("Updated "..data.title)
 end)
end

local function managePopup(data)
 local p=popupBase("Manage Script",280,250)

 local function mb(text,y,fn)
  local b=button(p,text,UDim2.new(1,-20,0,36),UDim2.new(0,10,0,y))
  b.MouseButton1Click:Connect(fn)
 end

 mb(fav(data.title) and "★ Remove Favorite" or "☆ Add Favorite",45,function()
  local x=toggleFav(data.title)
  closePopup()
  loadTab(current)
  notify(x and "Added to Favorites" or "Removed from Favorites")
 end)

 mb("Copy Source URL",87,function()
  if setclipboard then
   setclipboard(data.source or "")
   notify("Source copied!")
  else notify("Clipboard unsupported") end
 end)

 mb("Copy Loadstring",129,function()
  if setclipboard then
   setclipboard(sourceCode(data.source or data.code) or "")
   notify("Loadstring copied!")
  else notify("Clipboard unsupported") end
 end)

 mb("Edit Script",171,function() editPopup(data) end)

 mb("Delete Script",213,function()
  for i,v in ipairs(D.scripts) do
   if v==data then table.remove(D.scripts,i) break end
  end
  local f=table.find(D.favorites,data.title)
  if f then table.remove(D.favorites,f) end
  for i=#D.recent,1,-1 do
   if D.recent[i]==data.title then table.remove(D.recent,i) end
  end
  closePopup()
  refreshTabs()
  loadTab(current)
  notify("Deleted "..data.title)
 end)
end

local function card(data)
 local c=Instance.new("Frame")
 c.Size=UDim2.new(1,0,0,72)
 c.BackgroundColor3=Color3.fromRGB(28,28,28)
 c.Parent=scroll
 corner(c,8)

 local n=label(c,(fav(data.title) and "★ " or "")..data.title,UDim2.new(1,-125,0,23),UDim2.new(0,10,0,5),15)
 n.Font=Enum.Font.GothamBold
 n.TextTruncate=Enum.TextTruncate.AtEnd

 local d=label(c,data.description or "No description.",UDim2.new(1,-125,0,18),UDim2.new(0,10,0,27),11,Color3.fromRGB(170,170,170))
 d.TextTruncate=Enum.TextTruncate.AtEnd

 label(c,data.category or "Universal",UDim2.new(1,-125,0,17),UDim2.new(0,10,0,46),10,Color3.fromRGB(120,120,120))

 local run=button(c,"RUN",UDim2.fromOffset(52,26),UDim2.new(1,-112,.5,-13),Color3.fromRGB(60,120,255))
 local more=button(c,"•••",UDim2.fromOffset(40,26),UDim2.new(1,-54,.5,-13))

 run.MouseButton1Click:Connect(function()
  run.Text="..."
  local code=sourceCode(data.source or data.code)
  if not code then notify("No source available") run.Text="RUN" return end

  local ok,err=pcall(function() loadstring(code)() end)

  if ok then
   recent(data.title)
   notify("✓ Executed "..data.title)
  else
   warn("[GBS Hub] "..tostring(err))
   notify("✕ Failed "..data.title)
  end

  task.wait(.8)
  if run.Parent then run.Text="RUN" end
 end)

 more.MouseButton1Click:Connect(function() managePopup(data) end)
end

local function saveBackup()
 local ok,j=pcall(function() return H:JSONEncode(D) end)
 if not ok then notify("Backup failed") return end
 if setclipboard then
  setclipboard("GBSHUB3:"..j)
  notify("Backup copied!")
 else notify("Clipboard unsupported") end
end

local function importBackup()
 local p=popupBase("Import Backup",320,270)
 local b=box(p,"Paste GBS Hub backup here...",42,150)
 local ok=button(p,"IMPORT",UDim2.new(1,-20,0,36),UDim2.new(0,10,1,-46),Color3.fromRGB(60,120,255))

 ok.MouseButton1Click:Connect(function()
  local text=b.Text:gsub("^GBSHUB3:",""):gsub("^GBSHUB:","")
  local success,data=pcall(function() return H:JSONDecode(text) end)

  if not success or type(data)~="table" then
   notify("Invalid backup")
   return
  end

  data.settings=data.settings or {scale=1}
  data.favorites=data.favorites or {}
  data.recent=data.recent or {}
  data.scripts=data.scripts or {}

  for _,v in ipairs(data.scripts) do
   if not v.source and v.code then
    v.source=v.code
    v.code=nil
   end
   v.category=v.category or "Universal"
   v.description=v.description or "No description."
  end

  D=data
  SC.Scale=D.settings.scale or 1
  closePopup()
  refreshTabs()
  loadTab(current)
  notify("✓ Backup imported!")
 end)
end

local function option(text,fn)
 local b=button(scroll,text,UDim2.new(1,0,0,40),UDim2.new(),Color3.fromRGB(30,30,30))
 b.MouseButton1Click:Connect(fn)
end

function loadTab(tab)
 current=tab

 for _,v in ipairs(scroll:GetChildren()) do
  if not v:IsA("UIListLayout") then v:Destroy() end
 end

 if tab=="Options" then
  option("＋ Add Script",addPopup)
  option("★ Manage Favorites",function() loadTab("Favorites") end)
  option("Small UI",function() D.settings.scale=.8 SC.Scale=.8 end)
  option("Normal UI",function() D.settings.scale=1 SC.Scale=1 end)
  option("Large UI",function() D.settings.scale=1.2 SC.Scale=1.2 end)
  option("📋 Export Backup",saveBackup)
  option("📥 Import Backup",importBackup)
  option("Destroy GUI",function()
   B:Destroy()
   G:Destroy()
  end)
  return
 end

 local q=search.Text:lower()

 local function matches(v)
  local s=(v.title.." "..(v.category or "").." "..(v.description or "")):lower()
  return q=="" or s:find(q,1,true)
 end

 if tab=="Favorites" then
  for _,v in ipairs(D.scripts) do
   if fav(v.title) and matches(v) then card(v) end
  end
  return
 end

 if tab=="Recent" then
  for _,n in ipairs(D.recent) do
   local v=find(n)
   if v and matches(v) then card(v) end
  end
  return
 end

 for _,v in ipairs(D.scripts) do
  if (v.category or "Universal")==tab and matches(v) then
   card(v)
  end
 end
end

function refreshTabs()
 for _,v in ipairs(tabs:GetChildren()) do
  if not v:IsA("UIListLayout") then v:Destroy() end
 end

 local cats={}
 for _,v in ipairs(D.scripts) do
  local c=v.category or "Universal"
  if not table.find(cats,c) then table.insert(cats,c) end
 end

 table.insert(cats,"Favorites")
 table.insert(cats,"Recent")
 table.insert(cats,"Options")

 for _,name in ipairs(cats) do
  local b=button(tabs,name,UDim2.fromOffset(95,34),UDim2.new(),Color3.fromRGB(30,30,30))
  b.MouseButton1Click:Connect(function() loadTab(name) end)
 end
end

search:GetPropertyChangedSignal("Text"):Connect(function()
 loadTab(current)
end)

local mini

local function minimize()
 if mini then mini:Destroy() end

 mini=button(G,"+",UDim2.fromOffset(50,50),UDim2.new(0,20,.5,0),Color3.fromRGB(30,30,30))
 mini.TextScaled=true
 mini.TextSize=25
 mini.Font=Enum.Font.GothamBold
 mini.BackgroundColor3=Color3.fromRGB(30,30,30)
 mini.Size=UDim2.fromOffset(50,50)
 mini.Position=UDim2.new(0,20,.5,0)
 mini.Text="+"
 mini.BackgroundTransparency=0
 mini.ClipsDescendants=false

 local uc=mini:FindFirstChildOfClass("UICorner")
 if uc then uc.CornerRadius=UDim.new(1,0) end

 local md=false
 local ms,mp,mi

 mini.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   md=true
   ms=i.Position
   mp=mini.Position
   i.Changed:Connect(function()
    if i.UserInputState==Enum.UserInputState.End then md=false end
   end)
  end
 end)

 mini.InputChanged:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then mi=i end
 end)

 U.InputChanged:Connect(function(i)
  if md and i==mi then
   local d=i.Position-ms
   mini.Position=UDim2.new(mp.X.Scale,mp.X.Offset+d.X,mp.Y.Scale,mp.Y.Offset+d.Y)
  end
 end)

 mini.MouseButton1Click:Connect(function()
  M.Visible=true
  B.Enabled=true
  if mini then mini:Destroy() mini=nil end
 end)
end

minBtn.MouseButton1Click:Connect(function()
 M.Visible=false
 B.Enabled=false
 minimize()
end)

closeBtn.MouseButton1Click:Connect(function()
 if mini then mini:Destroy() end
 if B then B:Destroy() end
 G:Destroy()
end)

setBtn.MouseButton1Click:Connect(function()
 loadTab("Options")
end)

refreshTabs()
loadTab("Universal")

if IY_LOADED and not _G.IY_DEBUG then
	-- error("KizzDev is already running!", 0)
	return
end

pcall(function() getgenv().IY_LOADED = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
gethui = missing("function", gethui or get_hidden_gui)
syn = missing("table", syn)
syn_protect_gui = missing("function", syn and syn.protect_gui)
sethidden =  missing("function", sethiddenproperty or set_hidden_property or set_hidden_prop)
gethidden =  missing("function", gethiddenproperty or get_hidden_property or get_hidden_prop)
queueteleport =  missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
firetouchinterest = missing("function", firetouchinterest)
waxwritefile, waxreadfile = writefile, readfile
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
waxgetcustomasset = missing("function", getcustomasset or getsynasset)
hookfunction = missing("function", hookfunction)
hookmetamethod = missing("function", hookmetamethod)
getnamecallmethod = missing("function", getnamecallmethod or get_namecall_method)
checkcaller = missing("function", checkcaller, function() return false end)
newcclosure = missing("function", newcclosure, function(f, ...) return f(...) end)
getgc = missing("function", getgc or get_gc_objects)
setthreadidentity = missing("function", setthreadidentity or (syn and syn.set_thread_identity) or syn_context_set or setthreadcontext)
replicatesignal = missing("function", replicatesignal)
getconnections = missing("function", getconnections or get_signal_cons)

Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

Players = Services.Players
UserInputService = Services.UserInputService
TweenService = Services.TweenService
HttpService = Services.HttpService
ExperienceService = Services.ExperienceService
MarketplaceService = Services.MarketplaceService
RunService = Services.RunService
TeleportService = Services.TeleportService
StarterGui = Services.StarterGui
GuiService = Services.GuiService
Lighting = Services.Lighting
ContextActionService = Services.ContextActionService
ReplicatedStorage = Services.ReplicatedStorage
GroupService = Services.GroupService
PathService = Services.PathfindingService
SoundService = Services.SoundService
Teams = Services.Teams
StarterPlayer = Services.StarterPlayer
InsertService = Services.InsertService
ChatService = Services.Chat
ProximityPromptService = Services.ProximityPromptService
ContentProvider = Services.ContentProvider
StatsService = Services.Stats
MaterialService = Services.MaterialService
AvatarEditorService = Services.AvatarEditorService
TextService = Services.TextService
TextChatService = Services.TextChatService
CaptureService = Services.CaptureService
VoiceChatService = Services.VoiceChatService
SocialService = Services.SocialService

PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
COREGUI = Services.CoreGui or PlayerGui
IYMouse = cloneref(Players.LocalPlayer:GetMouse())
PlaceId, JobId = game.PlaceId, game.JobId
xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)
isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
--[[rcdEnabled = select(2, pcall(function()
    return gethidden(workspace, "RejectCharacterDeletions") ~= Enum.RejectCharacterDeletions.Disabled
end)) or false]]

-- xylex & europa
local iyassets = {
	["infiniteyield/assets/bindsandplugins.png"] = "rbxassetid://5147695474",
	["infiniteyield/assets/close.png"] = "rbxassetid://5054663650",
	["infiniteyield/assets/editaliases.png"] = "rbxassetid://5147488658",
	["infiniteyield/assets/editkeybinds.png"] = "rbxassetid://129697930",
	["infiniteyield/assets/edittheme.png"] = "rbxassetid://4911962991",
	["infiniteyield/assets/editwaypoints.png"] = "rbxassetid://5147488592",
	["infiniteyield/assets/imgstudiopluginlogo.png"] = "rbxassetid://4113050383",
	["infiniteyield/assets/logo.png"] = "rbxassetid://1352543873",
	["infiniteyield/assets/minimize.png"] = "rbxassetid://2406617031",
	["infiniteyield/assets/pin.png"] = "rbxassetid://6234691350",
	["infiniteyield/assets/reference.png"] = "rbxassetid://3523243755",
	["infiniteyield/assets/settings.png"] = "rbxassetid://1204397029",
	["infiniteyield/assets/scrollbar.png"] = "rbxassetid://75024581433929"
}

local function getcustomasset(asset)
	if waxgetcustomasset then
		local success, result = pcall(function()
			return waxgetcustomasset(asset)
		end)
		if success and result ~= nil and result ~= "" then
			return result
		end
	end
	return iyassets[asset]
end

if makefolder and isfolder and writefile and isfile then
	pcall(function() -- good executor trust
		local assets = "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/"
		for _, folder in {"infiniteyield", "infiniteyield/assets"} do
			if not isfolder(folder) then
				makefolder(folder)
			end
		end
		for path in iyassets do
			if not isfile(path) and path ~= 'infiniteyield/assets/scrollbar.png' then
				writefile(path, game:HttpGet((path:gsub("infiniteyield/", assets))))
			end
		end
		-- honestly just blame your phone if the assets appear in your gallery
		if IsOnMobile then writefile("infiniteyield/assets/.nomedia", "") end
	end)
end

currentVersion = "6.4.2"

ScaledHolder = Instance.new("Frame")
Scale = Instance.new("UIScale")
Holder = Instance.new("Frame")
Title = Instance.new("TextLabel")
Dark = Instance.new("Frame")
Cmdbar = Instance.new("TextBox")
CMDsF = Instance.new("ScrollingFrame")
cmdListLayout = Instance.new("UIListLayout")
SettingsButton = Instance.new("ImageButton")
ColorsButton = Instance.new("ImageButton")
Settings = Instance.new("Frame")
Prefix = Instance.new("TextLabel")
PrefixBox = Instance.new("TextBox")
Keybinds = Instance.new("TextLabel")
StayOpen = Instance.new("TextLabel")
Button = Instance.new("Frame")
On = Instance.new("TextButton")
Positions = Instance.new("TextLabel")
EventBind = Instance.new("TextLabel")
Plugins = Instance.new("TextLabel")
Example = Instance.new("TextButton")
Notification = Instance.new("Frame")
Title_2 = Instance.new("TextLabel")
Text_2 = Instance.new("TextLabel")
CloseButton = Instance.new("TextButton")
CloseImage = Instance.new("ImageLabel")
PinButton = Instance.new("TextButton")
PinImage = Instance.new("ImageLabel")
Tooltip = Instance.new("Frame")
Title_3 = Instance.new("TextLabel")
Description = Instance.new("TextLabel")
IntroBackground = Instance.new("Frame")
Logo = Instance.new("ImageLabel")
Credits = Instance.new("TextBox")
KeybindsFrame = Instance.new("Frame")
Close = Instance.new("TextButton")
Add = Instance.new("TextButton")
Delete = Instance.new("TextButton")
Holder_2 = Instance.new("ScrollingFrame")
Example_2 = Instance.new("Frame")
Text_3 = Instance.new("TextLabel")
Delete_2 = Instance.new("TextButton")
KeybindEditor = Instance.new("Frame")
background_2 = Instance.new("Frame")
Dark_3 = Instance.new("Frame")
Directions = Instance.new("TextLabel")
BindTo = Instance.new("TextButton")
TriggerLabel = Instance.new("TextLabel")
BindTriggerSelect = Instance.new("TextButton")
Add_2 = Instance.new("TextButton")
Toggles = Instance.new("ScrollingFrame")
ClickTP  = Instance.new("TextLabel")
Select = Instance.new("TextButton")
ClickDelete = Instance.new("TextLabel")
Select_2 = Instance.new("TextButton")
Cmdbar_2 = Instance.new("TextBox")
Cmdbar_3 = Instance.new("TextBox")
CreateToggle = Instance.new("TextLabel")
Button_2 = Instance.new("Frame")
On_2 = Instance.new("TextButton")
shadow_2 = Instance.new("Frame")
PopupText_2 = Instance.new("TextLabel")
Exit_2 = Instance.new("TextButton")
ExitImage_2 = Instance.new("ImageLabel")
PositionsFrame = Instance.new("Frame")
Close_3 = Instance.new("TextButton")
Delete_5 = Instance.new("TextButton")
Part = Instance.new("TextButton")
Holder_4 = Instance.new("ScrollingFrame")
Example_4 = Instance.new("Frame")
Text_5 = Instance.new("TextLabel")
Delete_6 = Instance.new("TextButton")
TP = Instance.new("TextButton")
AliasesFrame = Instance.new("Frame")
Close_2 = Instance.new("TextButton")
Delete_3 = Instance.new("TextButton")
Holder_3 = Instance.new("ScrollingFrame")
Example_3 = Instance.new("Frame")
Text_4 = Instance.new("TextLabel")
Delete_4 = Instance.new("TextButton")
Aliases = Instance.new("TextLabel")
PluginsFrame = Instance.new("Frame")
Close_4 = Instance.new("TextButton")
Add_3 = Instance.new("TextButton")
Holder_5 = Instance.new("ScrollingFrame")
Example_5 = Instance.new("Frame")
Text_6 = Instance.new("TextLabel")
Delete_7 = Instance.new("TextButton")
PluginEditor = Instance.new("Frame")
background_3 = Instance.new("Frame")
Dark_2 = Instance.new("Frame")
Img = Instance.new("ImageButton")
AddPlugin = Instance.new("TextButton")
FileName = Instance.new("TextBox")
About = Instance.new("TextLabel")
Directions_2 = Instance.new("TextLabel")
shadow_3 = Instance.new("Frame")
PopupText_3 = Instance.new("TextLabel")
Exit_3 = Instance.new("TextButton")
ExitImage_3 = Instance.new("ImageLabel")
AliasHint = Instance.new("TextLabel")
PluginsHint = Instance.new("TextLabel")
PositionsHint = Instance.new("TextLabel")
ToPartFrame = Instance.new("Frame")
background_4 = Instance.new("Frame")
ChoosePart = Instance.new("TextButton")
CopyPath = Instance.new("TextButton")
Directions_3 = Instance.new("TextLabel")
Path = Instance.new("TextLabel")
shadow_4 = Instance.new("Frame")
PopupText_5 = Instance.new("TextLabel")
Exit_4 = Instance.new("TextButton")
ExitImage_5 = Instance.new("ImageLabel")
logs = Instance.new("Frame")
shadow = Instance.new("Frame")
Hide = Instance.new("TextButton")
ImageLabel = Instance.new("ImageLabel")
PopupText = Instance.new("TextLabel")
Exit = Instance.new("TextButton")
ImageLabel_2 = Instance.new("ImageLabel")
background = Instance.new("Frame")
chat = Instance.new("Frame")
Clear = Instance.new("TextButton")
SaveChatlogs = Instance.new("TextButton")
Toggle = Instance.new("TextButton")
scroll_2 = Instance.new("ScrollingFrame")
join = Instance.new("Frame")
Toggle_2 = Instance.new("TextButton")
Clear_2 = Instance.new("TextButton")
scroll_3 = Instance.new("ScrollingFrame")
listlayout = Instance.new("UIListLayout",scroll_3)
selectChat = Instance.new("TextButton")
selectJoin = Instance.new("TextButton")

function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

PARENT = nil
MAX_DISPLAY_ORDER = 1.7976931348623157e308
if gethui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = gethui()
    PARENT = Main
elseif (not is_sirhurt_closure) and syn_protect_gui then
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    syn_protect_gui(Main)
    Main.Parent = COREGUI
    PARENT = Main
elseif COREGUI:FindFirstChild("RobloxGui") then
    PARENT = COREGUI.RobloxGui
else
    local Main = Instance.new("ScreenGui")
    Main.Name = randomString()
    Main.ResetOnSpawn = false
    Main.DisplayOrder = MAX_DISPLAY_ORDER
    Main.Parent = COREGUI
    PARENT = Main
end

shade1 = {}
shade2 = {}
shade3 = {}
text1 = {}
text2 = {}
scroll = {}

ScaledHolder.Name = randomString()
ScaledHolder.Size = UDim2.fromScale(1, 1)
ScaledHolder.BackgroundTransparency = 1
ScaledHolder.Parent = PARENT
Scale.Name = randomString()

Holder.Name = randomString()
Holder.Parent = ScaledHolder
Holder.Active = true
Holder.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Holder.BorderSizePixel = 0
Holder.Position = UDim2.new(1, -250, 1, -220)
Holder.Size = UDim2.new(0, 250, 0, 220)
Holder.ZIndex = 10
table.insert(shade2,Holder)

Title.Name = "Title"
Title.Parent = Holder
Title.Active = true
Title.BackgroundColor3 = Color3.fromRGB(36,36,37)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(0, 250, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Text = "KizzDev FE v" .. currentVersion

do
	local emoji = ({
		["01 01"] = "🎆",
		["02 14"] = "💝",
		["03 17"] = "☘️",
		[(function(Year)
			local A = math.floor(Year/100)
			local B = math.floor((13+8*A)/25)
			local C = (15-B+A-math.floor(A/4))%30
			local D = (4+A-math.floor(A/4))%7
			local E = (19*(Year%19)+C)%30
			local F = (2*(Year%4)+4*(Year%7)+6*E+D)%7
			local G = (22+E+F)
			if E == 29 and F == 6 then
				return "04 19"
			elseif E == 28 and F == 6 then
				return "04 18"
			elseif 31 < G then
				return ("04 %02d"):format(G-31)
			end
			return ("03 %02d"):format(G)
		end)(tonumber(os.date"%Y"))] = "🥚",
		["10 31"] = "🎃",
		["12 25"] = "🎄"
	})[os.date("%m %d")]
	if emoji then
		Title.Text = ("%s %s %s"):format(emoji, Title.Text, emoji)
	end
end

Title.TextColor3 = Color3.new(1, 1, 1)
Title.ZIndex = 10
table.insert(shade1,Title)
table.insert(text1,Title)

Dark.Name = "Dark"
Dark.Parent = Holder
Dark.Active = true
Dark.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Dark.BorderSizePixel = 0
Dark.Position = UDim2.new(0, 0, 0, 45)
Dark.Size = UDim2.new(0, 250, 0, 175)
Dark.ZIndex = 10
table.insert(shade1,Dark)

Cmdbar.Name = "Cmdbar"
Cmdbar.Parent = Holder
Cmdbar.BackgroundTransparency = 1
Cmdbar.BorderSizePixel = 0
Cmdbar.Position = UDim2.new(0, 5, 0, 20)
Cmdbar.Size = UDim2.new(0, 240, 0, 25)
Cmdbar.Font = Enum.Font.SourceSans
Cmdbar.TextSize = 18
Cmdbar.TextXAlignment = Enum.TextXAlignment.Left
Cmdbar.TextColor3 = Color3.new(1, 1, 1)
Cmdbar.Text = ""
Cmdbar.ZIndex = 10
Cmdbar.PlaceholderText = "Command Bar"

CMDsF.Name = "CMDs"
CMDsF.Parent = Holder
CMDsF.BackgroundTransparency = 1
CMDsF.BorderSizePixel = 0
CMDsF.Position = UDim2.new(0, 5, 0, 45)
CMDsF.Size = UDim2.new(0, 245, 0, 175)
CMDsF.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
CMDsF.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.CanvasSize = UDim2.new(0, 0, 0, 0)
CMDsF.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.ScrollBarThickness = 8
CMDsF.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
CMDsF.VerticalScrollBarInset = 'Always'
CMDsF.ZIndex = 10
table.insert(scroll,CMDsF)

cmdListLayout.Parent = CMDsF

SettingsButton.Name = "SettingsButton"
SettingsButton.Parent = Holder
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(0, 230, 0, 0)
SettingsButton.Size = UDim2.new(0, 20, 0, 20)
SettingsButton.Image = getcustomasset("infiniteyield/assets/settings.png")
SettingsButton.ZIndex = 10

ReferenceButton = Instance.new("ImageButton")
ReferenceButton.Name = "ReferenceButton"
ReferenceButton.Parent = Holder
ReferenceButton.BackgroundTransparency = 1
ReferenceButton.Position = UDim2.new(0, 212, 0, 2)
ReferenceButton.Size = UDim2.new(0, 16, 0, 16)
ReferenceButton.Image = getcustomasset("infiniteyield/assets/reference.png")
ReferenceButton.ZIndex = 10

Settings.Name = "Settings"
Settings.Parent = Holder
Settings.Active = true
Settings.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(0, 0, 0, 220)
Settings.Size = UDim2.new(0, 250, 0, 175)
Settings.ZIndex = 10
table.insert(shade1,Settings)

SettingsHolder = Instance.new("ScrollingFrame")
SettingsHolder.Name = "Holder"
SettingsHolder.Parent = Settings
SettingsHolder.BackgroundTransparency = 1
SettingsHolder.BorderSizePixel = 0
SettingsHolder.Size = UDim2.new(1,0,1,0)
SettingsHolder.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
SettingsHolder.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.CanvasSize = UDim2.new(0, 0, 0, 235)
SettingsHolder.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.ScrollBarThickness = 8
SettingsHolder.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
SettingsHolder.VerticalScrollBarInset = 'Always'
SettingsHolder.ZIndex = 10
table.insert(scroll,SettingsHolder)

Prefix.Name = "Prefix"
Prefix.Parent = SettingsHolder
Prefix.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Prefix.BorderSizePixel = 0
Prefix.BackgroundTransparency = 1
Prefix.Position = UDim2.new(0, 5, 0, 5)
Prefix.Size = UDim2.new(1, -10, 0, 20)
Prefix.Font = Enum.Font.SourceSans
Prefix.TextSize = 14
Prefix.Text = "Prefix"
Prefix.TextColor3 = Color3.new(1, 1, 1)
Prefix.TextXAlignment = Enum.TextXAlignment.Left
Prefix.ZIndex = 10
table.insert(shade2,Prefix)
table.insert(text1,Prefix)

PrefixBox.Name = "PrefixBox"
PrefixBox.Parent = Prefix
PrefixBox.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
PrefixBox.BorderSizePixel = 0
PrefixBox.Position = UDim2.new(1, -20, 0, 0)
PrefixBox.Size = UDim2.new(0, 20, 0, 20)
PrefixBox.Font = Enum.Font.SourceSansBold
PrefixBox.TextSize = 14
PrefixBox.Text = ''
PrefixBox.TextColor3 = Color3.new(0, 0, 0)
PrefixBox.ZIndex = 10
table.insert(shade3,PrefixBox)
table.insert(text2,PrefixBox)

function makeSettingsButton(name,iconID,off)
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	button.BorderSizePixel = 0
	button.Position = UDim2.new(0,0,0,0)
	button.Size = UDim2.new(1,0,0,25)
	button.Text = ""
	button.ZIndex = 10
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Parent = button
	icon.Position = UDim2.new(0,5,0,5)
	icon.Size = UDim2.new(0,16,0,16)
	icon.BackgroundTransparency = 1
	icon.Image = iconID
	icon.ZIndex = 10
	if off then
		icon.ScaleType = Enum.ScaleType.Crop
		icon.ImageRectSize = Vector2.new(16,16)
		icon.ImageRectOffset = Vector2.new(off,0)
	end
	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Parent = button
	label.BackgroundTransparency = 1
	label.Text = name
	label.Position = UDim2.new(0,28,0,0)
	label.Size = UDim2.new(1,-28,1,0)
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.ZIndex = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	table.insert(shade2,button)
	table.insert(text1,label)
	return button
end

ColorsButton = makeSettingsButton("Edit Theme",getcustomasset("infiniteyield/assets/edittheme.png"))
ColorsButton.Position = UDim2.new(0, 5, 0, 55)
ColorsButton.Size = UDim2.new(1, -10, 0, 25)
ColorsButton.Name = "Colors"
ColorsButton.Parent = SettingsHolder

Keybinds = makeSettingsButton("Edit Keybinds",getcustomasset("infiniteyield/assets/editkeybinds.png"))
Keybinds.Position = UDim2.new(0, 5, 0, 85)
Keybinds.Size = UDim2.new(1, -10, 0, 25)
Keybinds.Name = "Keybinds"
Keybinds.Parent = SettingsHolder

Aliases = makeSettingsButton("Edit Aliases",getcustomasset("infiniteyield/assets/editaliases.png"))
Aliases.Position = UDim2.new(0, 5, 0, 115)
Aliases.Size = UDim2.new(1, -10, 0, 25)
Aliases.Name = "Aliases"
Aliases.Parent = SettingsHolder

StayOpen.Name = "StayOpen"
StayOpen.Parent = SettingsHolder
StayOpen.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
StayOpen.BorderSizePixel = 0
StayOpen.BackgroundTransparency = 1
StayOpen.Position = UDim2.new(0, 5, 0, 30)
StayOpen.Size = UDim2.new(1, -10, 0, 20)
StayOpen.Font = Enum.Font.SourceSans
StayOpen.TextSize = 14
StayOpen.Text = "Keep Menu Open"
StayOpen.TextColor3 = Color3.new(1, 1, 1)
StayOpen.TextXAlignment = Enum.TextXAlignment.Left
StayOpen.ZIndex = 10
table.insert(shade2,StayOpen)
table.insert(text1,StayOpen)

Button.Name = "Button"
Button.Parent = StayOpen
Button.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(1, -20, 0, 0)
Button.Size = UDim2.new(0, 20, 0, 20)
Button.ZIndex = 10
table.insert(shade3,Button)

On.Name = "On"
On.Parent = Button
On.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On.BackgroundTransparency = 1
On.BorderSizePixel = 0
On.Position = UDim2.new(0, 2, 0, 2)
On.Size = UDim2.new(0, 16, 0, 16)
On.Font = Enum.Font.SourceSans
On.FontSize = Enum.FontSize.Size14
On.Text = ""
On.TextColor3 = Color3.new(0, 0, 0)
On.ZIndex = 10

Positions = makeSettingsButton("Edit/Goto Waypoints",getcustomasset("infiniteyield/assets/editwaypoints.png"))
Positions.Position = UDim2.new(0, 5, 0, 145)
Positions.Size = UDim2.new(1, -10, 0, 25)
Positions.Name = "Waypoints"
Positions.Parent = SettingsHolder

EventBind = makeSettingsButton("Edit Event Binds",getcustomasset("infiniteyield/assets/bindsandplugins.png"),759)
EventBind.Position = UDim2.new(0, 5, 0, 205)
EventBind.Size = UDim2.new(1, -10, 0, 25)
EventBind.Name = "EventBinds"
EventBind.Parent = SettingsHolder

Plugins = makeSettingsButton("Manage Plugins",getcustomasset("infiniteyield/assets/bindsandplugins.png"),743)
Plugins.Position = UDim2.new(0, 5, 0, 175)
Plugins.Size = UDim2.new(1, -10, 0, 25)
Plugins.Name = "Plugins"
Plugins.Parent = SettingsHolder

Example.Name = "Example"
Example.Parent = Holder
Example.BackgroundTransparency = 1
Example.BorderSizePixel = 0
Example.Size = UDim2.new(0, 190, 0, 20)
Example.Visible = false
Example.Font = Enum.Font.SourceSans
Example.TextSize = 18
Example.Text = "Example"
Example.TextColor3 = Color3.new(1, 1, 1)
Example.TextXAlignment = Enum.TextXAlignment.Left
Example.ZIndex = 10
table.insert(text1,Example)

Notification.Name = randomString()
Notification.Parent = ScaledHolder
Notification.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Notification.BorderSizePixel = 0
Notification.Position = UDim2.new(1, -500, 1, 20)
Notification.Size = UDim2.new(0, 250, 0, 100)
Notification.ZIndex = 10
table.insert(shade1,Notification)

Title_2.Name = "Title"
Title_2.Parent = Notification
Title_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_2.BorderSizePixel = 0
Title_2.Size = UDim2.new(0, 250, 0, 20)
Title_2.Font = Enum.Font.SourceSans
Title_2.TextSize = 14
Title_2.Text = "Notification Title"
Title_2.TextColor3 = Color3.new(1, 1, 1)
Title_2.ZIndex = 10
table.insert(shade2,Title_2)
table.insert(text1,Title_2)

Text_2.Name = "Text"
Text_2.Parent = Notification
Text_2.BackgroundTransparency = 1
Text_2.BorderSizePixel = 0
Text_2.Position = UDim2.new(0, 5, 0, 25)
Text_2.Size = UDim2.new(0, 240, 0, 75)
Text_2.Font = Enum.Font.SourceSans
Text_2.TextSize = 16
Text_2.Text = "Notification Text"
Text_2.TextColor3 = Color3.new(1, 1, 1)
Text_2.TextWrapped = true
Text_2.ZIndex = 10
table.insert(text1,Text_2)

CloseButton.Name = "CloseButton"
CloseButton.Parent = Notification
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = ""
CloseButton.ZIndex = 10

CloseImage.Parent = CloseButton
CloseImage.BackgroundColor3 = Color3.new(1, 1, 1)
CloseImage.BackgroundTransparency = 1
CloseImage.Position = UDim2.new(0, 5, 0, 5)
CloseImage.Size = UDim2.new(0, 10, 0, 10)
CloseImage.Image = getcustomasset("infiniteyield/assets/close.png")
CloseImage.ZIndex = 10

PinButton.Name = "PinButton"
PinButton.Parent = Notification
PinButton.BackgroundTransparency = 1
PinButton.Size = UDim2.new(0, 20, 0, 20)
PinButton.ZIndex = 10
PinButton.Text = ""

PinImage.Parent = PinButton
PinImage.BackgroundColor3 = Color3.new(1, 1, 1)
PinImage.BackgroundTransparency = 1
PinImage.Position = UDim2.new(0, 3, 0, 3)
PinImage.Size = UDim2.new(0, 14, 0, 14)
PinImage.ZIndex = 10
PinImage.Image = getcustomasset("infiniteyield/assets/pin.png")

Tooltip.Name = randomString()
Tooltip.Parent = ScaledHolder
Tooltip.Active = true
Tooltip.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
Tooltip.BackgroundTransparency = 0.1
Tooltip.BorderSizePixel = 0
Tooltip.Size = UDim2.new(0, 200, 0, 96)
Tooltip.Visible = false
Tooltip.ZIndex = 10
table.insert(shade1,Tooltip)

Title_3.Name = "Title"
Title_3.Parent = Tooltip
Title_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Title_3.BackgroundTransparency = 0.1
Title_3.BorderSizePixel = 0
Title_3.Size = UDim2.new(0, 200, 0, 20)
Title_3.Font = Enum.Font.SourceSans
Title_3.TextSize = 14
Title_3.Text = ""
Title_3.TextColor3 = Color3.new(1, 1, 1)
Title_3.TextTransparency = 0.1
Title_3.ZIndex = 10
table.insert(shade2,Title_3)
table.insert(text1,Title_3)

Description.Name = "Description"
Description.Parent = Tooltip
Description.BackgroundTransparency = 1
Description.BorderSizePixel = 0
Description.Size = UDim2.new(0,180,0,72)
Description.Position = UDim2.new(0,10,0,18)
Description.Font = Enum.Font.SourceSans
Description.TextSize = 16
Description.Text = ""
Description.TextColor3 = Color3.new(1, 1, 1)
Description.TextTransparency = 0.1
Description.TextWrapped = true
Description.ZIndex = 10
table.insert(text1,Description)

IntroBackground.Name = "IntroBackground"
IntroBackground.Parent = Holder
IntroBackground.Active = true
IntroBackground.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
IntroBackground.BorderSizePixel = 0
IntroBackground.Position = UDim2.new(0, 0, 0, 45)
IntroBackground.Size = UDim2.new(0, 250, 0, 175)
IntroBackground.ZIndex = 10

Logo.Name = "Logo"
Logo.Parent = Holder
Logo.BackgroundTransparency = 1
Logo.BorderSizePixel = 0
Logo.Position = UDim2.new(0, 125, 0, 127)
Logo.Size = UDim2.new(0, 10, 0, 10)
Logo.Image = getcustomasset("infiniteyield/assets/logo.png")
Logo.ImageTransparency = 0
Logo.ZIndex = 10

Credits.Name = "Credits"
Credits.Parent = Holder
Credits.BackgroundTransparency = 1
Credits.BorderSizePixel = 0
Credits.Position = UDim2.new(0, 0, 0.9, 30)
Credits.Size = UDim2.new(0, 250, 0, 20)
Credits.Font = Enum.Font.SourceSansLight
Credits.FontSize = Enum.FontSize.Size14
Credits.Text = "Edge // Zwolf // Moon // Toon // Peyton // ATP"
Credits.TextColor3 = Color3.new(1, 1, 1)
Credits.ZIndex = 10

KeybindsFrame.Name = "KeybindsFrame"
KeybindsFrame.Parent = Settings
KeybindsFrame.Active = true
KeybindsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
KeybindsFrame.BorderSizePixel = 0
KeybindsFrame.Position = UDim2.new(0, 0, 0, 175)
KeybindsFrame.Size = UDim2.new(0, 250, 0, 175)
KeybindsFrame.ZIndex = 10
table.insert(shade1,KeybindsFrame)

Close.Name = "Close"
Close.Parent = KeybindsFrame
Close.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0, 205, 0, 150)
Close.Size = UDim2.new(0, 40, 0, 20)
Close.Font = Enum.Font.SourceSans
Close.TextSize = 14
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.ZIndex = 10
table.insert(shade2,Close)
table.insert(text1,Close)

Add.Name = "Add"
Add.Parent = KeybindsFrame
Add.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add.BorderSizePixel = 0
Add.Position = UDim2.new(0, 5, 0, 150)
Add.Size = UDim2.new(0, 40, 0, 20)
Add.Font = Enum.Font.SourceSans
Add.TextSize = 14
Add.Text = "Add"
Add.TextColor3 = Color3.new(1, 1, 1)
Add.ZIndex = 10
table.insert(shade2,Add)
table.insert(text1,Add)

Delete.Name = "Delete"
Delete.Parent = KeybindsFrame
Delete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete.BorderSizePixel = 0
Delete.Position = UDim2.new(0, 50, 0, 150)
Delete.Size = UDim2.new(0, 40, 0, 20)
Delete.Font = Enum.Font.SourceSans
Delete.TextSize = 14
Delete.Text = "Clear"
Delete.TextColor3 = Color3.new(1, 1, 1)
Delete.ZIndex = 10
table.insert(shade2,Delete)
table.insert(text1,Delete)

Holder_2.Name = "Holder"
Holder_2.Parent = KeybindsFrame
Holder_2.BackgroundTransparency = 1
Holder_2.BorderSizePixel = 0
Holder_2.Position = UDim2.new(0, 0, 0, 0)
Holder_2.Size = UDim2.new(0, 250, 0, 145)
Holder_2.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_2.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.ScrollBarThickness = 0
Holder_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_2.VerticalScrollBarInset = 'Always'
Holder_2.ZIndex = 10

Example_2.Name = "Example"
Example_2.Parent = KeybindsFrame
Example_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_2.BorderSizePixel = 0
Example_2.Size = UDim2.new(0, 10, 0, 20)
Example_2.Visible = false
Example_2.ZIndex = 10
table.insert(shade2,Example_2)

Text_3.Name = "Text"
Text_3.Parent = Example_2
Text_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_3.BorderSizePixel = 0
Text_3.Position = UDim2.new(0, 10, 0, 0)
Text_3.Size = UDim2.new(0, 240, 0, 20)
Text_3.Font = Enum.Font.SourceSans
Text_3.TextSize = 14
Text_3.Text = "nom"
Text_3.TextColor3 = Color3.new(1, 1, 1)
Text_3.TextXAlignment = Enum.TextXAlignment.Left
Text_3.ZIndex = 10
table.insert(shade2,Text_3)
table.insert(text1,Text_3)

Delete_2.Name = "Delete"
Delete_2.Parent = Text_3
Delete_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_2.BorderSizePixel = 0
Delete_2.Position = UDim2.new(0, 200, 0, 0)
Delete_2.Size = UDim2.new(0, 40, 0, 20)
Delete_2.Font = Enum.Font.SourceSans
Delete_2.TextSize = 14
Delete_2.Text = "Delete"
Delete_2.TextColor3 = Color3.new(0, 0, 0)
Delete_2.ZIndex = 10
table.insert(shade3,Delete_2)
table.insert(text2,Delete_2)

KeybindEditor.Name = randomString()
KeybindEditor.Parent = ScaledHolder
KeybindEditor.Active = true
KeybindEditor.BackgroundTransparency = 1
KeybindEditor.Position = UDim2.new(0.5, -180, 0, -500)
KeybindEditor.Size = UDim2.new(0, 360, 0, 20)
KeybindEditor.ZIndex = 10

background_2.Name = "background"
background_2.Parent = KeybindEditor
background_2.Active = true
background_2.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_2.BorderSizePixel = 0
background_2.Position = UDim2.new(0, 0, 0, 20)
background_2.Size = UDim2.new(0, 360, 0, 185)
background_2.ZIndex = 10
table.insert(shade1,background_2)

Dark_3.Name = "Dark"
Dark_3.Parent = background_2
Dark_3.Active = true
Dark_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_3.BorderSizePixel = 0
Dark_3.Position = UDim2.new(0, 135, 0, 0)
Dark_3.Size = UDim2.new(0, 2, 0, 185)
Dark_3.ZIndex = 10
table.insert(shade2,Dark_3)

Directions.Name = "Directions"
Directions.Parent = background_2
Directions.BackgroundTransparency = 1
Directions.BorderSizePixel = 0
Directions.Position = UDim2.new(0, 10, 0, 15)
Directions.Size = UDim2.new(0, 115, 0, 90)
Directions.ZIndex = 10
Directions.Font = Enum.Font.SourceSans
Directions.Text = "Click the button below and press a key/mouse button. Then select what you want to bind it to."
Directions.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions.TextSize = 14.000
Directions.TextWrapped = true
Directions.TextYAlignment = Enum.TextYAlignment.Top
table.insert(text1,Directions)

BindTo.Name = "BindTo"
BindTo.Parent = background_2
BindTo.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTo.BorderSizePixel = 0
BindTo.Position = UDim2.new(0, 10, 0, 95)
BindTo.Size = UDim2.new(0, 115, 0, 50)
BindTo.ZIndex = 10
BindTo.Font = Enum.Font.SourceSans
BindTo.Text = "Click to bind"
BindTo.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTo.TextSize = 16.000
table.insert(shade2,BindTo)
table.insert(text1,BindTo)

TriggerLabel.Name = "TriggerLabel"
TriggerLabel.Parent = background_2
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Position = UDim2.new(0, 10, 0, 155)
TriggerLabel.Size = UDim2.new(0, 45, 0, 20)
TriggerLabel.ZIndex = 10
TriggerLabel.Font = Enum.Font.SourceSans
TriggerLabel.Text = "Trigger:"
TriggerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TriggerLabel.TextSize = 14.000
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,TriggerLabel)

BindTriggerSelect.Name = "BindTo"
BindTriggerSelect.Parent = background_2
BindTriggerSelect.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
BindTriggerSelect.BorderSizePixel = 0
BindTriggerSelect.Position = UDim2.new(0, 60, 0, 155)
BindTriggerSelect.Size = UDim2.new(0, 65, 0, 20)
BindTriggerSelect.ZIndex = 10
BindTriggerSelect.Font = Enum.Font.SourceSans
BindTriggerSelect.Text = "KeyDown"
BindTriggerSelect.TextColor3 = Color3.fromRGB(255, 255, 255)
BindTriggerSelect.TextSize = 16.000
table.insert(shade2,BindTriggerSelect)
table.insert(text1,BindTriggerSelect)

Add_2.Name = "Add"
Add_2.Parent = background_2
Add_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_2.BorderSizePixel = 0
Add_2.Position = UDim2.new(0, 310, 0, 35)
Add_2.Size = UDim2.new(0, 40, 0, 20)
Add_2.ZIndex = 10
Add_2.Font = Enum.Font.SourceSans
Add_2.Text = "Add"
Add_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Add_2.TextSize = 14.000
table.insert(shade2,Add_2)
table.insert(text1,Add_2)

Toggles.Name = "Toggles"
Toggles.Parent = background_2
Toggles.BackgroundTransparency = 1
Toggles.BorderSizePixel = 0
Toggles.Position = UDim2.new(0, 150, 0, 125)
Toggles.Size = UDim2.new(0, 200, 0, 50)
Toggles.ZIndex = 10
Toggles.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.CanvasSize = UDim2.new(0, 0, 0, 50)
Toggles.ScrollBarThickness = 8
Toggles.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Toggles.VerticalScrollBarInset = Enum.ScrollBarInset.Always
table.insert(scroll,Toggles)

ClickTP.Name = "Click TP (Hold Key & Click)"
ClickTP.Parent = Toggles
ClickTP.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickTP.BorderSizePixel = 0
ClickTP.Size = UDim2.new(0, 200, 0, 20)
ClickTP.ZIndex = 10
ClickTP.Font = Enum.Font.SourceSans
ClickTP.Text = "    Click TP (Hold Key & Click)"
ClickTP.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickTP.TextSize = 14.000
ClickTP.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickTP)
table.insert(text1,ClickTP)

Select.Name = "Select"
Select.Parent = ClickTP
Select.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select.BorderSizePixel = 0
Select.Position = UDim2.new(0, 160, 0, 0)
Select.Size = UDim2.new(0, 40, 0, 20)
Select.ZIndex = 10
Select.Font = Enum.Font.SourceSans
Select.Text = "Add"
Select.TextColor3 = Color3.fromRGB(0, 0, 0)
Select.TextSize = 14.000
table.insert(shade3,Select)
table.insert(text2,Select)

ClickDelete.Name = "Click Delete (Hold Key & Click)"
ClickDelete.Parent = Toggles
ClickDelete.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ClickDelete.BorderSizePixel = 0
ClickDelete.Position = UDim2.new(0, 0, 0, 25)
ClickDelete.Size = UDim2.new(0, 200, 0, 20)
ClickDelete.ZIndex = 10
ClickDelete.Font = Enum.Font.SourceSans
ClickDelete.Text = "    Click Delete (Hold Key & Click)"
ClickDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
ClickDelete.TextSize = 14.000
ClickDelete.TextXAlignment = Enum.TextXAlignment.Left
table.insert(shade2,ClickDelete)
table.insert(text1,ClickDelete)

Select_2.Name = "Select"
Select_2.Parent = ClickDelete
Select_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Select_2.BorderSizePixel = 0
Select_2.Position = UDim2.new(0, 160, 0, 0)
Select_2.Size = UDim2.new(0, 40, 0, 20)
Select_2.ZIndex = 10
Select_2.Font = Enum.Font.SourceSans
Select_2.Text = "Add"
Select_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Select_2.TextSize = 14.000
table.insert(shade3,Select_2)
table.insert(text2,Select_2)

Cmdbar_2.Name = "Cmdbar_2"
Cmdbar_2.Parent = background_2
Cmdbar_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_2.BorderSizePixel = 0
Cmdbar_2.Position = UDim2.new(0, 150, 0, 35)
Cmdbar_2.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_2.ZIndex = 10
Cmdbar_2.Font = Enum.Font.SourceSans
Cmdbar_2.PlaceholderText = "Command"
Cmdbar_2.Text = ""
Cmdbar_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_2.TextSize = 14.000
Cmdbar_2.TextXAlignment = Enum.TextXAlignment.Left

Cmdbar_3.Name = "Cmdbar_3"
Cmdbar_3.Parent = background_2
Cmdbar_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Cmdbar_3.BorderSizePixel = 0
Cmdbar_3.Position = UDim2.new(0, 150, 0, 60)
Cmdbar_3.Size = UDim2.new(0, 150, 0, 20)
Cmdbar_3.ZIndex = 10
Cmdbar_3.Font = Enum.Font.SourceSans
Cmdbar_3.PlaceholderText = "Command 2"
Cmdbar_3.Text = ""
Cmdbar_3.TextColor3 = Color3.fromRGB(255, 255, 255)
Cmdbar_3.TextSize = 14.000
Cmdbar_3.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle.Name = "CreateToggle"
CreateToggle.Parent = background_2
CreateToggle.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CreateToggle.BackgroundTransparency = 1
CreateToggle.BorderSizePixel = 0
CreateToggle.Position = UDim2.new(0, 152, 0, 10)
CreateToggle.Size = UDim2.new(0, 198, 0, 20)
CreateToggle.ZIndex = 10
CreateToggle.Font = Enum.Font.SourceSans
CreateToggle.Text = "Create Toggle"
CreateToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
CreateToggle.TextSize = 14.000
CreateToggle.TextXAlignment = Enum.TextXAlignment.Left
table.insert(text1,CreateToggle)

Button_2.Name = "Button"
Button_2.Parent = CreateToggle
Button_2.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Button_2.BorderSizePixel = 0
Button_2.Position = UDim2.new(1, -20, 0, 0)
Button_2.Size = UDim2.new(0, 20, 0, 20)
Button_2.ZIndex = 10
table.insert(shade3,Button_2)

On_2.Name = "On"
On_2.Parent = Button_2
On_2.BackgroundColor3 = Color3.fromRGB(150, 150, 151)
On_2.BackgroundTransparency = 1
On_2.BorderSizePixel = 0
On_2.Position = UDim2.new(0, 2, 0, 2)
On_2.Size = UDim2.new(0, 16, 0, 16)
On_2.ZIndex = 10
On_2.Font = Enum.Font.SourceSans
On_2.Text = ""
On_2.TextColor3 = Color3.fromRGB(0, 0, 0)
On_2.TextSize = 14.000

shadow_2.Name = "shadow"
shadow_2.Parent = KeybindEditor
shadow_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_2.BorderSizePixel = 0
shadow_2.Size = UDim2.new(0, 360, 0, 20)
shadow_2.ZIndex = 10
table.insert(shade2,shadow_2)

PopupText_2.Name = "PopupText_2"
PopupText_2.Parent = shadow_2
PopupText_2.BackgroundTransparency = 1
PopupText_2.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText_2.ZIndex = 10
PopupText_2.Font = Enum.Font.SourceSans
PopupText_2.Text = "Set Keybinds"
PopupText_2.TextColor3 = Color3.fromRGB(255, 255, 255)
PopupText_2.TextSize = 14.000
PopupText_2.TextWrapped = true
table.insert(text1,PopupText_2)

Exit_2.Name = "Exit_2"
Exit_2.Parent = shadow_2
Exit_2.BackgroundTransparency = 1
Exit_2.Position = UDim2.new(1, -20, 0, 0)
Exit_2.Size = UDim2.new(0, 20, 0, 20)
Exit_2.ZIndex = 10
Exit_2.Text = ""

ExitImage_2.Parent = Exit_2
ExitImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ExitImage_2.BackgroundTransparency = 1
ExitImage_2.Position = UDim2.new(0, 5, 0, 5)
ExitImage_2.Size = UDim2.new(0, 10, 0, 10)
ExitImage_2.ZIndex = 10
ExitImage_2.Image = getcustomasset("infiniteyield/assets/close.png")

PositionsFrame.Name = "PositionsFrame"
PositionsFrame.Parent = Settings
PositionsFrame.Active = true
PositionsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PositionsFrame.BorderSizePixel = 0
PositionsFrame.Size = UDim2.new(0, 250, 0, 175)
PositionsFrame.Position = UDim2.new(0, 0, 0, 175)
PositionsFrame.ZIndex = 10
table.insert(shade1,PositionsFrame)

Close_3.Name = "Close"
Close_3.Parent = PositionsFrame
Close_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_3.BorderSizePixel = 0
Close_3.Position = UDim2.new(0, 205, 0, 150)
Close_3.Size = UDim2.new(0, 40, 0, 20)
Close_3.Font = Enum.Font.SourceSans
Close_3.TextSize = 14
Close_3.Text = "Close"
Close_3.TextColor3 = Color3.new(1, 1, 1)
Close_3.ZIndex = 10
table.insert(shade2,Close_3)
table.insert(text1,Close_3)

Delete_5.Name = "Delete"
Delete_5.Parent = PositionsFrame
Delete_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_5.BorderSizePixel = 0
Delete_5.Position = UDim2.new(0, 50, 0, 150)
Delete_5.Size = UDim2.new(0, 40, 0, 20)
Delete_5.Font = Enum.Font.SourceSans
Delete_5.TextSize = 14
Delete_5.Text = "Clear"
Delete_5.TextColor3 = Color3.new(1, 1, 1)
Delete_5.ZIndex = 10
table.insert(shade2,Delete_5)
table.insert(text1,Delete_5)

Part.Name = "PartGoto"
Part.Parent = PositionsFrame
Part.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Part.BorderSizePixel = 0
Part.Position = UDim2.new(0, 5, 0, 150)
Part.Size = UDim2.new(0, 40, 0, 20)
Part.Font = Enum.Font.SourceSans
Part.TextSize = 14
Part.Text = "Part"
Part.TextColor3 = Color3.new(1, 1, 1)
Part.ZIndex = 10
table.insert(shade2,Part)
table.insert(text1,Part)

Holder_4.Name = "Holder"
Holder_4.Parent = PositionsFrame
Holder_4.BackgroundTransparency = 1
Holder_4.BorderSizePixel = 0
Holder_4.Position = UDim2.new(0, 0, 0, 0)
Holder_4.Selectable = false
Holder_4.Size = UDim2.new(0, 250, 0, 145)
Holder_4.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_4.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_4.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.ScrollBarThickness = 0
Holder_4.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_4.VerticalScrollBarInset = 'Always'
Holder_4.ZIndex = 10

Example_4.Name = "Example"
Example_4.Parent = PositionsFrame
Example_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_4.BorderSizePixel = 0
Example_4.Size = UDim2.new(0, 10, 0, 20)
Example_4.Visible = false
Example_4.Position = UDim2.new(0, 0, 0, -5)
Example_4.ZIndex = 10
table.insert(shade2,Example_4)

Text_5.Name = "Text"
Text_5.Parent = Example_4
Text_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_5.BorderSizePixel = 0
Text_5.Position = UDim2.new(0, 10, 0, 0)
Text_5.Size = UDim2.new(0, 240, 0, 20)
Text_5.Font = Enum.Font.SourceSans
Text_5.TextSize = 14
Text_5.Text = "Position"
Text_5.TextColor3 = Color3.new(1, 1, 1)
Text_5.TextXAlignment = Enum.TextXAlignment.Left
Text_5.ZIndex = 10
table.insert(shade2,Text_5)
table.insert(text1,Text_5)

Delete_6.Name = "Delete"
Delete_6.Parent = Text_5
Delete_6.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_6.BorderSizePixel = 0
Delete_6.Position = UDim2.new(0, 200, 0, 0)
Delete_6.Size = UDim2.new(0, 40, 0, 20)
Delete_6.Font = Enum.Font.SourceSans
Delete_6.TextSize = 14
Delete_6.Text = "Delete"
Delete_6.TextColor3 = Color3.new(0, 0, 0)
Delete_6.ZIndex = 10
table.insert(shade3,Delete_6)
table.insert(text2,Delete_6)

TP.Name = "TP"
TP.Parent = Text_5
TP.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
TP.BorderSizePixel = 0
TP.Position = UDim2.new(0, 155, 0, 0)
TP.Size = UDim2.new(0, 40, 0, 20)
TP.Font = Enum.Font.SourceSans
TP.TextSize = 14
TP.Text = "Goto"
TP.TextColor3 = Color3.new(0, 0, 0)
TP.ZIndex = 10
table.insert(shade3,TP)
table.insert(text2,TP)

AliasesFrame.Name = "AliasesFrame"
AliasesFrame.Parent = Settings
AliasesFrame.Active = true
AliasesFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
AliasesFrame.BorderSizePixel = 0
AliasesFrame.Position = UDim2.new(0, 0, 0, 175)
AliasesFrame.Size = UDim2.new(0, 250, 0, 175)
AliasesFrame.ZIndex = 10
table.insert(shade1,AliasesFrame)

Close_2.Name = "Close"
Close_2.Parent = AliasesFrame
Close_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_2.BorderSizePixel = 0
Close_2.Position = UDim2.new(0, 205, 0, 150)
Close_2.Size = UDim2.new(0, 40, 0, 20)
Close_2.Font = Enum.Font.SourceSans
Close_2.TextSize = 14
Close_2.Text = "Close"
Close_2.TextColor3 = Color3.new(1, 1, 1)
Close_2.ZIndex = 10
table.insert(shade2,Close_2)
table.insert(text1,Close_2)

Delete_3.Name = "Delete"
Delete_3.Parent = AliasesFrame
Delete_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Delete_3.BorderSizePixel = 0
Delete_3.Position = UDim2.new(0, 5, 0, 150)
Delete_3.Size = UDim2.new(0, 40, 0, 20)
Delete_3.Font = Enum.Font.SourceSans
Delete_3.TextSize = 14
Delete_3.Text = "Clear"
Delete_3.TextColor3 = Color3.new(1, 1, 1)
Delete_3.ZIndex = 10
table.insert(shade2,Delete_3)
table.insert(text1,Delete_3)

Holder_3.Name = "Holder"
Holder_3.Parent = AliasesFrame
Holder_3.BackgroundTransparency = 1
Holder_3.BorderSizePixel = 0
Holder_3.Position = UDim2.new(0, 0, 0, 0)
Holder_3.Size = UDim2.new(0, 250, 0, 145)
Holder_3.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_3.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.ScrollBarThickness = 0
Holder_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_3.VerticalScrollBarInset = 'Always'
Holder_3.ZIndex = 10

Example_3.Name = "Example"
Example_3.Parent = AliasesFrame
Example_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_3.BorderSizePixel = 0
Example_3.Size = UDim2.new(0, 10, 0, 20)
Example_3.Visible = false
Example_3.ZIndex = 10
table.insert(shade2,Example_3)

Text_4.Name = "Text"
Text_4.Parent = Example_3
Text_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_4.BorderSizePixel = 0
Text_4.Position = UDim2.new(0, 10, 0, 0)
Text_4.Size = UDim2.new(0, 240, 0, 20)
Text_4.Font = Enum.Font.SourceSans
Text_4.TextSize = 14
Text_4.Text = "honk"
Text_4.TextColor3 = Color3.new(1, 1, 1)
Text_4.TextXAlignment = Enum.TextXAlignment.Left
Text_4.ZIndex = 10
table.insert(shade2,Text_4)
table.insert(text1,Text_4)

Delete_4.Name = "Delete"
Delete_4.Parent = Text_4
Delete_4.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_4.BorderSizePixel = 0
Delete_4.Position = UDim2.new(0, 200, 0, 0)
Delete_4.Size = UDim2.new(0, 40, 0, 20)
Delete_4.Font = Enum.Font.SourceSans
Delete_4.TextSize = 14
Delete_4.Text = "Delete"
Delete_4.TextColor3 = Color3.new(0, 0, 0)
Delete_4.ZIndex = 10
table.insert(shade3,Delete_4)
table.insert(text2,Delete_4)

PluginsFrame.Name = "PluginsFrame"
PluginsFrame.Parent = Settings
PluginsFrame.Active = true
PluginsFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
PluginsFrame.BorderSizePixel = 0
PluginsFrame.Position = UDim2.new(0, 0, 0, 175)
PluginsFrame.Size = UDim2.new(0, 250, 0, 175)
PluginsFrame.ZIndex = 10
table.insert(shade1,PluginsFrame)

Close_4.Name = "Close"
Close_4.Parent = PluginsFrame
Close_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Close_4.BorderSizePixel = 0
Close_4.Position = UDim2.new(0, 205, 0, 150)
Close_4.Size = UDim2.new(0, 40, 0, 20)
Close_4.Font = Enum.Font.SourceSans
Close_4.TextSize = 14
Close_4.Text = "Close"
Close_4.TextColor3 = Color3.new(1, 1, 1)
Close_4.ZIndex = 10
table.insert(shade2,Close_4)
table.insert(text1,Close_4)

Add_3.Name = "Add"
Add_3.Parent = PluginsFrame
Add_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Add_3.BorderSizePixel = 0
Add_3.Position = UDim2.new(0, 5, 0, 150)
Add_3.Size = UDim2.new(0, 40, 0, 20)
Add_3.Font = Enum.Font.SourceSans
Add_3.TextSize = 14
Add_3.Text = "Add"
Add_3.TextColor3 = Color3.new(1, 1, 1)
Add_3.ZIndex = 10
table.insert(shade2,Add_3)
table.insert(text1,Add_3)

Holder_5.Name = "Holder"
Holder_5.Parent = PluginsFrame
Holder_5.BackgroundTransparency = 1
Holder_5.BorderSizePixel = 0
Holder_5.Position = UDim2.new(0, 0, 0, 0)
Holder_5.Selectable = false
Holder_5.Size = UDim2.new(0, 250, 0, 145)
Holder_5.ScrollBarImageColor3 = Color3.fromRGB(78,78,79)
Holder_5.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.CanvasSize = UDim2.new(0, 0, 0, 0)
Holder_5.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.ScrollBarThickness = 0
Holder_5.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Holder_5.VerticalScrollBarInset = 'Always'
Holder_5.ZIndex = 10

Example_5.Name = "Example"
Example_5.Parent = PluginsFrame
Example_5.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Example_5.BorderSizePixel = 0
Example_5.Size = UDim2.new(0, 10, 0, 20)
Example_5.Visible = false
Example_5.ZIndex = 10
table.insert(shade2,Example_5)

Text_6.Name = "Text"
Text_6.Parent = Example_5
Text_6.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Text_6.BorderSizePixel = 0
Text_6.Position = UDim2.new(0, 10, 0, 0)
Text_6.Size = UDim2.new(0, 240, 0, 20)
Text_6.Font = Enum.Font.SourceSans
Text_6.TextSize = 14
Text_6.Text = "F4 > Toggle Fly"
Text_6.TextColor3 = Color3.new(1, 1, 1)
Text_6.TextXAlignment = Enum.TextXAlignment.Left
Text_6.ZIndex = 10
table.insert(shade2,Text_6)
table.insert(text1,Text_6)

Delete_7.Name = "Delete"
Delete_7.Parent = Text_6
Delete_7.BackgroundColor3 = Color3.fromRGB(78, 78, 79)
Delete_7.BorderSizePixel = 0
Delete_7.Position = UDim2.new(0, 200, 0, 0)
Delete_7.Size = UDim2.new(0, 40, 0, 20)
Delete_7.Font = Enum.Font.SourceSans
Delete_7.TextSize = 14
Delete_7.Text = "Delete"
Delete_7.TextColor3 = Color3.new(0, 0, 0)
Delete_7.ZIndex = 10
table.insert(shade3,Delete_7)
table.insert(text2,Delete_7)

PluginEditor.Name = randomString()
PluginEditor.Parent = ScaledHolder
PluginEditor.BorderSizePixel = 0
PluginEditor.Active = true
PluginEditor.BackgroundTransparency = 1
PluginEditor.Position = UDim2.new(0.5, -180, 0, -500)
PluginEditor.Size = UDim2.new(0, 360, 0, 20)
PluginEditor.ZIndex = 10

background_3.Name = "background"
background_3.Parent = PluginEditor
background_3.Active = true
background_3.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_3.BorderSizePixel = 0
background_3.Position = UDim2.new(0, 0, 0, 20)
background_3.Size = UDim2.new(0, 360, 0, 160)
background_3.ZIndex = 10
table.insert(shade1,background_3)

Dark_2.Name = "Dark"
Dark_2.Parent = background_3
Dark_2.Active = true
Dark_2.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
Dark_2.BorderSizePixel = 0
Dark_2.Position = UDim2.new(0, 222, 0, 0)
Dark_2.Size = UDim2.new(0, 2, 0, 160)
Dark_2.ZIndex = 10
table.insert(shade2,Dark_2)

Img.Name = "Img"
Img.Parent = background_3
Img.BackgroundTransparency = 1
Img.Position = UDim2.new(0, 242, 0, 3)
Img.Size = UDim2.new(0, 100, 0, 95)
Img.Image = getcustomasset("infiniteyield/assets/imgstudiopluginlogo.png")
Img.ZIndex = 10

AddPlugin.Name = "AddPlugin"
AddPlugin.Parent = background_3
AddPlugin.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
AddPlugin.BorderSizePixel = 0
AddPlugin.Position = UDim2.new(0, 235, 0, 100)
AddPlugin.Size = UDim2.new(0, 115, 0, 50)
AddPlugin.Font = Enum.Font.SourceSans
AddPlugin.TextSize = 14
AddPlugin.Text = "Add Plugin"
AddPlugin.TextColor3 = Color3.new(1, 1, 1)
AddPlugin.ZIndex = 10
table.insert(shade2,AddPlugin)
table.insert(text1,AddPlugin)

FileName.Name = "FileName"
FileName.Parent = background_3
FileName.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
FileName.BorderSizePixel = 0
FileName.Position = UDim2.new(0.028, 0, 0.625, 0)
FileName.Size = UDim2.new(0, 200, 0, 50)
FileName.Font = Enum.Font.SourceSans
FileName.TextSize = 14
FileName.Text = "Plugin File Name"
FileName.TextColor3 = Color3.new(1, 1, 1)
FileName.ZIndex = 10
table.insert(shade2,FileName)
table.insert(text1,FileName)

About.Name = "About"
About.Parent = background_3
About.BackgroundTransparency = 1
About.BorderSizePixel = 0
About.Position = UDim2.new(0, 17, 0, 10)
About.Size = UDim2.new(0, 187, 0, 49)
About.Font = Enum.Font.SourceSans
About.TextSize = 14
About.Text = "Plugins are .iy files and should be located in the 'workspace' folder of your exploit."
About.TextColor3 = Color3.fromRGB(255, 255, 255)
About.TextWrapped = true
About.TextYAlignment = Enum.TextYAlignment.Top
About.ZIndex = 10
table.insert(text1,About)

Directions_2.Name = "Directions"
Directions_2.Parent = background_3
Directions_2.BackgroundTransparency = 1
Directions_2.BorderSizePixel = 0
Directions_2.Position = UDim2.new(0, 17, 0, 60)
Directions_2.Size = UDim2.new(0, 187, 0, 49)
Directions_2.Font = Enum.Font.SourceSans
Directions_2.TextSize = 14
Directions_2.Text = "Type the name of the plugin file you want to add below."
Directions_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Directions_2.TextWrapped = true
Directions_2.TextYAlignment = Enum.TextYAlignment.Top
Directions_2.ZIndex = 10
table.insert(text1,Directions_2)

shadow_3.Name = "shadow"
shadow_3.Parent = PluginEditor
shadow_3.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_3.BorderSizePixel = 0
shadow_3.Size = UDim2.new(0, 360, 0, 20)
shadow_3.ZIndex = 10
table.insert(shade2,shadow_3)

PopupText_3.Name = "PopupText"
PopupText_3.Parent = shadow_3
PopupText_3.BackgroundTransparency = 1
PopupText_3.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_3.ZIndex = 10
PopupText_3.Font = Enum.Font.SourceSans
PopupText_3.TextSize = 14
PopupText_3.Text = "Add Plugins"
PopupText_3.TextColor3 = Color3.new(1, 1, 1)
PopupText_3.TextWrapped = true
table.insert(text1,PopupText_3)

Exit_3.Name = "Exit"
Exit_3.Parent = shadow_3
Exit_3.BackgroundTransparency = 1
Exit_3.Position = UDim2.new(1, -20, 0, 0)
Exit_3.Size = UDim2.new(0, 20, 0, 20)
Exit_3.Text = ""
Exit_3.ZIndex = 10

ExitImage_3.Parent = Exit_3
ExitImage_3.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_3.BackgroundTransparency = 1
ExitImage_3.Position = UDim2.new(0, 5, 0, 5)
ExitImage_3.Size = UDim2.new(0, 10, 0, 10)
ExitImage_3.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_3.ZIndex = 10

AliasHint.Name = "AliasHint"
AliasHint.Parent = AliasesFrame
AliasHint.BackgroundTransparency = 1
AliasHint.BorderSizePixel = 0
AliasHint.Position = UDim2.new(0, 25, 0, 40)
AliasHint.Size = UDim2.new(0, 200, 0, 50)
AliasHint.Font = Enum.Font.SourceSansItalic
AliasHint.TextSize = 16
AliasHint.Text = "Add aliases by using the 'addalias' command"
AliasHint.TextColor3 = Color3.new(1, 1, 1)
AliasHint.TextStrokeColor3 = Color3.new(1, 1, 1)
AliasHint.TextWrapped = true
AliasHint.ZIndex = 10
table.insert(text1,AliasHint)

PluginsHint.Name = "PluginsHint"
PluginsHint.Parent = PluginsFrame
PluginsHint.BackgroundTransparency = 1
PluginsHint.BorderSizePixel = 0
PluginsHint.Position = UDim2.new(0, 25, 0, 40)
PluginsHint.Size = UDim2.new(0, 200, 0, 50)
PluginsHint.Font = Enum.Font.SourceSansItalic
PluginsHint.TextSize = 16
PluginsHint.Text = "Download plugins from the IY Discord (discord.gg/78ZuWSq)"
PluginsHint.TextColor3 = Color3.new(1, 1, 1)
PluginsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PluginsHint.TextWrapped = true
PluginsHint.ZIndex = 10
table.insert(text1,PluginsHint)

PositionsHint.Name = "PositionsHint"
PositionsHint.Parent = PositionsFrame
PositionsHint.BackgroundTransparency = 1
PositionsHint.BorderSizePixel = 0
PositionsHint.Position = UDim2.new(0, 25, 0, 40)
PositionsHint.Size = UDim2.new(0, 200, 0, 70)
PositionsHint.Font = Enum.Font.SourceSansItalic
PositionsHint.TextSize = 16
PositionsHint.Text = "Use the 'swp' or 'setwaypoint' command to add a position using your character (NOTE: Part teleports will not save)"
PositionsHint.TextColor3 = Color3.new(1, 1, 1)
PositionsHint.TextStrokeColor3 = Color3.new(1, 1, 1)
PositionsHint.TextWrapped = true
PositionsHint.ZIndex = 10
table.insert(text1,PositionsHint)

ToPartFrame.Name = randomString()
ToPartFrame.Parent = ScaledHolder
ToPartFrame.Active = true
ToPartFrame.BackgroundTransparency = 1
ToPartFrame.Position = UDim2.new(0.5, -180, 0, -500)
ToPartFrame.Size = UDim2.new(0, 360, 0, 20)
ToPartFrame.ZIndex = 10

background_4.Name = "background"
background_4.Parent = ToPartFrame
background_4.Active = true
background_4.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
background_4.BorderSizePixel = 0
background_4.Position = UDim2.new(0, 0, 0, 20)
background_4.Size = UDim2.new(0, 360, 0, 117)
background_4.ZIndex = 10
table.insert(shade1,background_4)

ChoosePart.Name = "ChoosePart"
ChoosePart.Parent = background_4
ChoosePart.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
ChoosePart.BorderSizePixel = 0
ChoosePart.Position = UDim2.new(0, 100, 0, 55)
ChoosePart.Size = UDim2.new(0, 75, 0, 30)
ChoosePart.Font = Enum.Font.SourceSans
ChoosePart.TextSize = 14
ChoosePart.Text = "Select Part"
ChoosePart.TextColor3 = Color3.new(1, 1, 1)
ChoosePart.ZIndex = 10
table.insert(shade2,ChoosePart)
table.insert(text1,ChoosePart)

CopyPath.Name = "CopyPath"
CopyPath.Parent = background_4
CopyPath.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
CopyPath.BorderSizePixel = 0
CopyPath.Position = UDim2.new(0, 185, 0, 55)
CopyPath.Size = UDim2.new(0, 75, 0, 30)
CopyPath.Font = Enum.Font.SourceSans
CopyPath.TextSize = 14
CopyPath.Text = "Copy Path"
CopyPath.TextColor3 = Color3.new(1, 1, 1)
CopyPath.ZIndex = 10
table.insert(shade2,CopyPath)
table.insert(text1,CopyPath)

Directions_3.Name = "Directions"
Directions_3.Parent = background_4
Directions_3.BackgroundTransparency = 1
Directions_3.BorderSizePixel = 0
Directions_3.Position = UDim2.new(0, 51, 0, 17)
Directions_3.Size = UDim2.new(0, 257, 0, 32)
Directions_3.Font = Enum.Font.SourceSans
Directions_3.TextSize = 14
Directions_3.Text = 'Click on a part and then click the "Select Part" button below to set it as a teleport location'
Directions_3.TextColor3 = Color3.new(1, 1, 1)
Directions_3.TextWrapped = true
Directions_3.TextYAlignment = Enum.TextYAlignment.Top
Directions_3.ZIndex = 10
table.insert(text1,Directions_3)

Path.Name = "Path"
Path.Parent = background_4
Path.BackgroundTransparency = 1
Path.BorderSizePixel = 0
Path.Position = UDim2.new(0, 0, 0, 94)
Path.Size = UDim2.new(0, 360, 0, 16)
Path.Font = Enum.Font.SourceSansItalic
Path.TextSize = 14
Path.Text = ""
Path.TextColor3 = Color3.new(1, 1, 1)
Path.TextScaled = true
Path.TextWrapped = true
Path.TextYAlignment = Enum.TextYAlignment.Top
Path.ZIndex = 10
table.insert(text1,Path)

shadow_4.Name = "shadow"
shadow_4.Parent = ToPartFrame
shadow_4.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
shadow_4.BorderSizePixel = 0
shadow_4.Size = UDim2.new(0, 360, 0, 20)
shadow_4.ZIndex = 10
table.insert(shade2,shadow_4)

PopupText_5.Name = "PopupText"
PopupText_5.Parent = shadow_4
PopupText_5.BackgroundTransparency = 1
PopupText_5.Size = UDim2.new(1, 0, 0.95, 0)
PopupText_5.ZIndex = 10
PopupText_5.Font = Enum.Font.SourceSans
PopupText_5.TextSize = 14
PopupText_5.Text = "Teleport to Part"
PopupText_5.TextColor3 = Color3.new(1, 1, 1)
PopupText_5.TextWrapped = true
table.insert(text1,PopupText_5)

Exit_4.Name = "Exit"
Exit_4.Parent = shadow_4
Exit_4.BackgroundTransparency = 1
Exit_4.Position = UDim2.new(1, -20, 0, 0)
Exit_4.Size = UDim2.new(0, 20, 0, 20)
Exit_4.Text = ""
Exit_4.ZIndex = 10

ExitImage_5.Parent = Exit_4
ExitImage_5.BackgroundColor3 = Color3.new(1, 1, 1)
ExitImage_5.BackgroundTransparency = 1
ExitImage_5.Position = UDim2.new(0, 5, 0, 5)
ExitImage_5.Size = UDim2.new(0, 10, 0, 10)
ExitImage_5.Image = getcustomasset("infiniteyield/assets/close.png")
ExitImage_5.ZIndex = 10

logs.Name = randomString()
logs.Parent = ScaledHolder
logs.Active = true
logs.BackgroundTransparency = 1
logs.Position = UDim2.new(0, 0, 1, 10)
logs.Size = UDim2.new(0, 338, 0, 20)
logs.ZIndex = 10

shadow.Name = "shadow"
shadow.Parent = logs
shadow.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 0, 0.00999999978, 0)
shadow.Size = UDim2.new(0, 338, 0, 20)
shadow.ZIndex = 10
table.insert(shade2,shadow)

Hide.Name = "Hide"
Hide.Parent = shadow
Hide.BackgroundTransparency = 1
Hide.Position = UDim2.new(1, -40, 0, 0)
Hide.Size = UDim2.new(0, 20, 0, 20)
Hide.ZIndex = 10
Hide.Text = ""

ImageLabel.Parent = Hide
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.Position = UDim2.new(0, 3, 0, 3)
ImageLabel.Size = UDim2.new(0, 14, 0, 14)
ImageLabel.Image = getcustomasset("infiniteyield/assets/minimize.png")
ImageLabel.ZIndex = 10

PopupText.Name = "PopupText"
PopupText.Parent = shadow
PopupText.BackgroundTransparency = 1
PopupText.Size = UDim2.new(1, 0, 0.949999988, 0)
PopupText.ZIndex = 10
PopupText.Font = Enum.Font.SourceSans
PopupText.FontSize = Enum.FontSize.Size14
PopupText.Text = "Logs"
PopupText.TextColor3 = Color3.new(1, 1, 1)
PopupText.TextWrapped = true
table.insert(text1,PopupText)

Exit.Name = "Exit"
Exit.Parent = shadow
Exit.BackgroundTransparency = 1
Exit.Position = UDim2.new(1, -20, 0, 0)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.ZIndex = 10
Exit.Text = ""

ImageLabel_2.Parent = Exit
ImageLabel_2.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel_2.BackgroundTransparency = 1
ImageLabel_2.Position = UDim2.new(0, 5, 0, 5)
ImageLabel_2.Size = UDim2.new(0, 10, 0, 10)
ImageLabel_2.Image = getcustomasset("infiniteyield/assets/close.png")
ImageLabel_2.ZIndex = 10

background.Name = "background"
background.Parent = logs
background.Active = true
background.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
background.BorderSizePixel = 0
background.ClipsDescendants = true
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(0, 338, 0, 245)
background.ZIndex = 10

chat.Name = "chat"
chat.Parent = background
chat.Active = true
chat.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
chat.BorderSizePixel = 0
chat.ClipsDescendants = true
chat.Size = UDim2.new(0, 338, 0, 245)
chat.ZIndex = 10
table.insert(shade1,chat)

Clear.Name = "Clear"
Clear.Parent = chat
Clear.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 5, 0, 220)
Clear.Size = UDim2.new(0, 50, 0, 20)
Clear.ZIndex = 10
Clear.Font = Enum.Font.SourceSans
Clear.FontSize = Enum.FontSize.Size14
Clear.Text = "Clear"
Clear.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear)
table.insert(text1,Clear)

SaveChatlogs.Name = "SaveChatlogs"
SaveChatlogs.Parent = chat
SaveChatlogs.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
SaveChatlogs.BorderSizePixel = 0
SaveChatlogs.Position = UDim2.new(0, 258, 0, 220)
SaveChatlogs.Size = UDim2.new(0, 75, 0, 20)
SaveChatlogs.ZIndex = 10
SaveChatlogs.Font = Enum.Font.SourceSans
SaveChatlogs.FontSize = Enum.FontSize.Size14
SaveChatlogs.Text = "Save To .txt"
SaveChatlogs.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,SaveChatlogs)
table.insert(text1,SaveChatlogs)

Toggle.Name = "Toggle"
Toggle.Parent = chat
Toggle.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle.BorderSizePixel = 0
Toggle.Position = UDim2.new(0, 60, 0, 220)
Toggle.Size = UDim2.new(0, 66, 0, 20)
Toggle.ZIndex = 10
Toggle.Font = Enum.Font.SourceSans
Toggle.FontSize = Enum.FontSize.Size14
Toggle.Text = "Disabled"
Toggle.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle)
table.insert(text1,Toggle)

scroll_2.Name = "scroll"
scroll_2.Parent = chat
scroll_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_2.BorderSizePixel = 0
scroll_2.Position = UDim2.new(0, 5, 0, 25)
scroll_2.Size = UDim2.new(0, 328, 0, 190)
scroll_2.ZIndex = 10
scroll_2.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_2.ScrollBarThickness = 8
scroll_2.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_2)
table.insert(shade2,scroll_2)

join.Name = "join"
join.Parent = background
join.Active = true
join.BackgroundColor3 = Color3.new(0.141176, 0.141176, 0.145098)
join.BorderSizePixel = 0
join.ClipsDescendants = true
join.Size = UDim2.new(0, 338, 0, 245)
join.Visible = false
join.ZIndex = 10
table.insert(shade1,join)

Toggle_2.Name = "Toggle"
Toggle_2.Parent = join
Toggle_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Toggle_2.BorderSizePixel = 0
Toggle_2.Position = UDim2.new(0, 60, 0, 220)
Toggle_2.Size = UDim2.new(0, 66, 0, 20)
Toggle_2.ZIndex = 10
Toggle_2.Font = Enum.Font.SourceSans
Toggle_2.FontSize = Enum.FontSize.Size14
Toggle_2.Text = "Disabled"
Toggle_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Toggle_2)
table.insert(text1,Toggle_2)

Clear_2.Name = "Clear"
Clear_2.Parent = join
Clear_2.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 5, 0, 220)
Clear_2.Size = UDim2.new(0, 50, 0, 20)
Clear_2.ZIndex = 10
Clear_2.Font = Enum.Font.SourceSans
Clear_2.FontSize = Enum.FontSize.Size14
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,Clear_2)
table.insert(text1,Clear_2)

scroll_3.Name = "scroll"
scroll_3.Parent = join
scroll_3.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
scroll_3.BorderSizePixel = 0
scroll_3.Position = UDim2.new(0, 5, 0, 25)
scroll_3.Size = UDim2.new(0, 328, 0, 190)
scroll_3.ZIndex = 10
scroll_3.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
scroll_3.ScrollBarThickness = 8
scroll_3.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
table.insert(scroll,scroll_3)
table.insert(shade2,scroll_3)

selectChat.Name = "selectChat"
selectChat.Parent = background
selectChat.BackgroundColor3 = Color3.new(0.180392, 0.180392, 0.184314)
selectChat.BorderSizePixel = 0
selectChat.Position = UDim2.new(0, 5, 0, 5)
selectChat.Size = UDim2.new(0, 164, 0, 20)
selectChat.ZIndex = 10
selectChat.Font = Enum.Font.SourceSans
selectChat.FontSize = Enum.FontSize.Size14
selectChat.Text = "Chat Logs"
selectChat.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade2,selectChat)
table.insert(text1,selectChat)

selectJoin.Name = "selectJoin"
selectJoin.Parent = background
selectJoin.BackgroundColor3 = Color3.new(0.305882, 0.305882, 0.309804)
selectJoin.BorderSizePixel = 0
selectJoin.Position = UDim2.new(0, 169, 0, 5)
selectJoin.Size = UDim2.new(0, 164, 0, 20)
selectJoin.ZIndex = 10
selectJoin.Font = Enum.Font.SourceSans
selectJoin.FontSize = Enum.FontSize.Size14
selectJoin.Text = "Join Logs"
selectJoin.TextColor3 = Color3.new(1, 1, 1)
table.insert(shade3,selectJoin)
table.insert(text1,selectJoin)

function create(data)
	local insts = {}
	for i,v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end

	for _,v in pairs(data) do
		for prop,val in pairs(v[3]) do
			if type(val) == "table" then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end

	return insts[1]
end

ViewportTextBox = (function()

	local funcs = {}
	funcs.Update = function(self)
		local cursorPos = self.TextBox.CursorPosition
		local text = self.TextBox.Text
		if text == "" then self.TextBox.Position = UDim2.new(0,2,0,0) return end
		if cursorPos == -1 then return end

		local cursorText = text:sub(1,cursorPos-1)
		local pos = nil
		local leftEnd = -self.TextBox.Position.X.Offset
		local rightEnd = leftEnd + self.View.AbsoluteSize.X

		local totalTextSize = TextService:GetTextSize(text,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X
		local cursorTextSize = TextService:GetTextSize(cursorText,self.TextBox.TextSize,self.TextBox.Font,Vector2.new(999999999,100)).X

		if cursorTextSize > rightEnd then
			pos = math.max(-2,cursorTextSize - self.View.AbsoluteSize.X + 2)
		elseif cursorTextSize < leftEnd then
			pos = math.max(-2,cursorTextSize-2)
		elseif totalTextSize < rightEnd then
			pos = math.max(-2,totalTextSize - self.View.AbsoluteSize.X + 2)
		end

		if pos then
			self.TextBox.Position = UDim2.new(0,-pos,0,0)
			self.TextBox.Size = UDim2.new(1,pos,1,0)
		end
	end

	local mt = {}
	mt.__index = funcs

	local function convert(textbox)
		local obj = setmetatable({OffsetX = 0, TextBox = textbox},mt)

		local view = Instance.new("Frame")
		view.BackgroundTransparency = textbox.BackgroundTransparency
		view.BackgroundColor3 = textbox.BackgroundColor3
		view.BorderSizePixel = textbox.BorderSizePixel
		view.BorderColor3 = textbox.BorderColor3
		view.Position = textbox.Position
		view.Size = textbox.Size
		view.ClipsDescendants = true
		view.Name = textbox.Name
		view.ZIndex = 10
		textbox.BackgroundTransparency = 1
		textbox.Position = UDim2.new(0,4,0,0)
		textbox.Size = UDim2.new(1,-8,1,0)
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Name = "Input"
		table.insert(text1,textbox)
		table.insert(shade2,view)

		obj.View = view

		textbox.Changed:Connect(function(prop)
			if prop == "Text" or prop == "CursorPosition" or prop == "AbsoluteSize" then
				obj:Update()
			end
		end)

		obj:Update()

		view.Parent = textbox.Parent
		textbox.Parent = view

		return obj
	end

	return {convert = convert}
end)()

ViewportTextBox.convert(Cmdbar).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_2).View.ZIndex = 10
ViewportTextBox.convert(Cmdbar_3).View.ZIndex = 10

function writefileExploit()
	if writefile then
		return true
	end
end

function readfileExploit()
	if readfile then
		return true
	end
end

function isNumber(str)
	if tonumber(str) ~= nil or str == "inf" then
		return true
	end
end

function vtype(o, t)
	if o == nil then return false end
	if type(o) == "userdata" then return typeof(o) == t end
	return type(o) == t
end

function getRoot(char)
	if char and char:FindFirstChildOfClass("Humanoid") then
		return char:FindFirstChildOfClass("Humanoid").RootPart
	else
		return nil
	end
end

function tools(plr)
	if plr:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool") then
		return true
	end
end

function r15(plr)
	if plr.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
		return true
	end
end

function breakVelocity()
    local V3 = Vector3.new(0, 0, 0)
    for _, v in ipairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity, v.RotVelocity = V3, V3
        end
    end
end

function toClipboard(txt)
	if everyClipboard then
		everyClipboard(tostring(txt)) -- some executor errored without tostring btw so dont call me out for this
		notify("Clipboard", "Copied to clipboard")
	else
		notify("Clipboard", "Your exploit doesn't have the ability to use the clipboard")
	end
end

function chatMessage(str)
	str = tostring(str)
	if not isLegacyChat then
		TextChatService.TextChannels.RBXGeneral:SendAsync(str)
	else
		ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(str, "All")
	end
end

function getHierarchy(obj)
	local fullname
	local period

	if string.find(obj.Name,' ') then
		fullname = '["'..obj.Name..'"]'
		period = false
	else
		fullname = obj.Name
		period = true
	end

	local getS = obj
	local parent = obj
	local service = ''

	if getS.Parent ~= game then
		repeat
			getS = getS.Parent
			service = getS.ClassName
		until getS.Parent == game
	end

	if parent.Parent ~= getS then
		repeat
			parent = parent.Parent
			if string.find(tostring(parent),' ') then
				if period then
					fullname = '["'..parent.Name..'"].'..fullname
				else
					fullname = '["'..parent.Name..'"]'..fullname
				end
				period = false
			else
				if period then
					fullname = parent.Name..'.'..fullname
				else
					fullname = parent.Name..''..fullname
				end
				period = true
			end
		until parent.Parent == getS
	elseif string.find(tostring(parent),' ') then
		fullname = '["'..parent.Name..'"]'
		period = false
	end

	if period then
		return 'game:GetService("'..service..'").'..fullname
	else
		return 'game:GetService("'..service..'")'..fullname
	end
end

AllWaypoints = {}

local cooldown = false
function writefileCooldown(name,data)
	task.spawn(function()
		if not cooldown then
			cooldown = true
			writefile(name, data, true)
		else
			repeat wait() until cooldown == false
			writefileCooldown(name,data)
		end
		wait(3)
		cooldown = false
	end)
end

function dragGUI(gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local delta = input.Position - dragStart
			local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
		end
		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragGUI(logs)
dragGUI(KeybindEditor)
dragGUI(PluginEditor)
dragGUI(ToPartFrame)

eventEditor = (function()
	local events = {}

	local function registerEvent(name,sets)
		events[name] = {
			commands = {},
			sets = sets or {}
		}
	end

	local onEdited = nil

	local function fireEvent(name,...)
		local args = {...}
		local event = events[name]
		if event then
			for i,cmd in pairs(event.commands) do
				local metCondition = true
				for idx,set in pairs(event.sets) do
					local argVal = args[idx]
					local cmdSet = cmd[2][idx]
					local condType = set.Type
					if condType == "Player" then
						if cmdSet == 0 then
							metCondition = metCondition and (tostring(Players.LocalPlayer) == argVal)
						elseif cmdSet ~= 1 then
							metCondition = metCondition and table.find(getPlayer(cmdSet,Players.LocalPlayer),argVal)
						end
					elseif condType == "String" then
						if cmdSet ~= 0 then
							metCondition = metCondition and string.find(argVal:lower(),cmdSet:lower())
						end
					elseif condType == "Number" then
						if cmdSet ~= 0 then
							metCondition = metCondition and tonumber(argVal)<=tonumber(cmdSet)
						end
					end
					if not metCondition then break end
				end

				if metCondition then
					pcall(task.spawn(function()
						local cmdStr = cmd[1]
						for count,arg in pairs(args) do
							cmdStr = cmdStr:gsub("%$"..count,arg)
						end
						if cmdStr:lower():match("plugin") then return end
						wait(cmd[3] or 0)
						execCmd(cmdStr)
					end))
				end
			end
		end
	end

	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderSizePixel=0,Name="EventEditor",Position=UDim2.new(0.5,-175,0,-500),Size=UDim2.new(0,350,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=currentShade2,BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0.95,0),Text="Event Editor",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,202),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={6},Position=UDim2.new(0,5,0,5),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,-10,1,-10),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{8,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={7},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{9,"UIListLayout",{Parent={8},SortOrder=2,}},
		{10,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,ClipsDescendants=true,Name="Settings",Parent={6},Position=UDim2.new(1,0,0,0),Size=UDim2.new(0,150,1,0),ZIndex=10,}},
		{11,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),Name="Slider",Parent={10},Position=UDim2.new(0,-150,0,0),Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.23529413342476,0.23529413342476,0.23529413342476),BorderColor3=Color3.new(0.3137255012989,0.3137255012989,0.3137255012989),BorderSizePixel=0,Name="Line",Parent={11},Size=UDim2.new(0,1,1,0),ZIndex=10,}},
		{13,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,100),Name="List",Parent={11},Position=UDim2.new(0,0,0,25),ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,-25),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",ZIndex=10,}},
		{14,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={13},Size=UDim2.new(1,0,1,0),ZIndex=10,}},
		{15,"UIListLayout",{Parent={14},SortOrder=2,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={11},Size=UDim2.new(1,0,0,20),Text="Event Settings",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{17,"TextButton",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Font=3,Name="Close",BorderSizePixel=0,Parent={11},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="<",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{18,"Folder",{Name="Templates",Parent={10},}},
		{19,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Players",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,86),Visible=false,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={19},Size=UDim2.new(1,0,0,20),Text="Choose Players",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{21,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={19},Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-10,0,20),Text="Any Player",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{22,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={21},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{23,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={22},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{24,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Me",Parent={19},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Me Only",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{25,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={24},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{26,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={25},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{27,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={19},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Custom Player Set",Position=UDim2.new(0,5,0,64),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{28,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={19},Position=UDim2.new(1,-25,0,64),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{29,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={28},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Strings",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={30},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={30},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any String",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={32},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{34,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={33},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="Numbers",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,64),Visible=false,ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={54},Size=UDim2.new(1,0,0,20),Text="Choose String",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Any",Parent={54},Position=UDim2.new(0,5,0,20),Size=UDim2.new(1,-10,0,20),Text="Any Number",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="Button",Parent={56},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{58,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={57},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{59,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={54},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Number",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={54},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{61,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={60},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{35,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,ClearTextOnFocus=false,Font=3,Name="Custom",Parent={30},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),PlaceholderText="Match String",Position=UDim2.new(0,5,0,42),Size=UDim2.new(1,-35,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),BorderSizePixel=0,Name="CustomButton",Parent={30},Position=UDim2.new(1,-25,0,42),Size=UDim2.new(0,20,0,20),ZIndex=10,}},
		{37,"TextButton",{BackgroundColor3=Color3.new(0.58823531866074,0.58823531866074,0.59215688705444),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="On",Parent={36},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),Text="",TextColor3=Color3.new(0,0,0),TextSize=14,ZIndex=10,}},
		{38,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),Name="DelayEditor",Parent={18},Position=UDim2.new(0,0,0,25),Size=UDim2.new(1,0,0,24),Visible=false,ZIndex=10,}},
		{39,"TextBox",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Font=3,Name="Secs",Parent={38},PlaceholderColor3=Color3.new(0.47058826684952,0.47058826684952,0.47058826684952),Position=UDim2.new(0,60,0,2),Size=UDim2.new(1,-65,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Font=3,Name="Label",Parent={39},Position=UDim2.new(0,-55,0,0),Size=UDim2.new(1,0,1,0),Text="Delay (s):",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{41,"Frame",{BackgroundColor3=currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="EventTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{42,"TextButton",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="Expand",Parent={41},Size=UDim2.new(0,20,0,20),Text=">",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=currentText1,BackgroundTransparency=1,Font=3,Name="EventName",Parent={41},Position=UDim2.new(0,25,0,0),Size=UDim2.new(1,-25,0,20),Text="OnSpawn",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{44,"Frame",{BackgroundColor3=Color3.new(0.19607844948769,0.19607844948769,0.19607844948769),BorderSizePixel=0,BackgroundTransparency=1,ClipsDescendants=true,Name="Cmds",Parent={41},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Name="Add",Parent={44},Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{46,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={45},PlaceholderColor3=Color3.new(0.7843137383461,0.7843137383461,0.7843137383461),PlaceholderText="Add new command",Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-10,1,0),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{47,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Holder",Parent={44},Size=UDim2.new(1,0,1,-20),ZIndex=10,}},
		{48,"UIListLayout",{Parent={47},SortOrder=2,}},
		{49,"Frame",{currentShade1,BorderSizePixel=0,ClipsDescendants=true,Name="CmdTemplate",Parent={6},Size=UDim2.new(1,0,0,20),Visible=false,ZIndex=10,}},
		{50,"TextBox",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,ClearTextOnFocus=false,Font=3,Parent={49},PlaceholderColor3=Color3.new(1,1,1),Position=UDim2.new(0,5,0,0),Size=UDim2.new(1,-45,0,20),Text="a\\b\\c\\d",TextColor3=currentText1,TextSize=14,TextXAlignment=0,ZIndex=10,}},
		{51,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Delete",Parent={49},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="X",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{52,"TextButton",{BackgroundColor3=currentShade1,BorderSizePixel=0,Font=3,Name="Settings",Parent={49},Position=UDim2.new(1,-40,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=18,ZIndex=10,}},
		{53,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/settings.png"),Parent={52},Position=UDim2.new(0,2,0,2),Size=UDim2.new(0,16,0,16),ZIndex=10,}},
	})
	main.Name = randomString()
	local mainFrame = main:WaitForChild("Content")
	local eventList = mainFrame:WaitForChild("List")
	local eventListHolder = eventList:WaitForChild("Holder")
	local cmdTemplate = mainFrame:WaitForChild("CmdTemplate")
	local eventTemplate = mainFrame:WaitForChild("EventTemplate")
	local settingsFrame = mainFrame:WaitForChild("Settings"):WaitForChild("Slider")
	local settingsTemplates = mainFrame.Settings:WaitForChild("Templates")
	local settingsList = settingsFrame:WaitForChild("List"):WaitForChild("Holder")
	table.insert(shade2,main.TopBar) table.insert(shade1,mainFrame) table.insert(shade2,eventTemplate)
	table.insert(text1,eventTemplate.EventName) table.insert(shade1,eventTemplate.Cmds.Add) table.insert(shade1,cmdTemplate)
	table.insert(text1,cmdTemplate.TextBox) table.insert(shade2,cmdTemplate.Delete) table.insert(shade2,cmdTemplate.Settings)
	table.insert(scroll,mainFrame.List) table.insert(shade1,settingsFrame) table.insert(shade2,settingsFrame.Line)
	table.insert(shade2,settingsFrame.Close) table.insert(scroll,settingsFrame.List) table.insert(shade2,settingsTemplates.DelayEditor.Secs)
	table.insert(text1,settingsTemplates.DelayEditor.Secs) table.insert(text1,settingsTemplates.DelayEditor.Secs.Label) table.insert(text1,settingsTemplates.Players.Title)
	table.insert(shade3,settingsTemplates.Players.CustomButton) table.insert(shade2,settingsTemplates.Players.Custom) table.insert(text1,settingsTemplates.Players.Custom)
	table.insert(shade3,settingsTemplates.Players.Any.Button) table.insert(shade3,settingsTemplates.Players.Me.Button) table.insert(text1,settingsTemplates.Players.Any)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Strings.Title) table.insert(text1,settingsTemplates.Strings.Any)
	table.insert(shade3,settingsTemplates.Strings.Any.Button) table.insert(shade3,settingsTemplates.Strings.CustomButton) table.insert(text1,settingsTemplates.Strings.Custom)
	table.insert(shade2,settingsTemplates.Strings.Custom)
	table.insert(text1,settingsTemplates.Players.Me) table.insert(text1,settingsTemplates.Numbers.Title) table.insert(text1,settingsTemplates.Numbers.Any)
	table.insert(shade3,settingsTemplates.Numbers.Any.Button) table.insert(shade3,settingsTemplates.Numbers.CustomButton) table.insert(text1,settingsTemplates.Numbers.Custom)
	table.insert(shade2,settingsTemplates.Numbers.Custom)

	local tweenInf = TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)

	local currentlyEditingCmd = nil

	settingsFrame:WaitForChild("Close").MouseButton1Click:Connect(function()
		settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end)

	local function resizeList()
		local size = 0

		for i,v in pairs(eventListHolder:GetChildren()) do
			if v.Name == "EventTemplate" then
				size = size + 20
				if v.Expand.Rotation == 90 then
					size = size + 20*(1+(#events[v.EventName:GetAttribute("RawName")].commands or 0))
				end
			end
		end

		TweenService:Create(eventList,tweenInf,{CanvasSize = UDim2.new(0,0,0,size)}):Play()

		if size > eventList.AbsoluteSize.Y then
			eventListHolder.Size = UDim2.new(1,-8,1,0)
		else
			eventListHolder.Size = UDim2.new(1,0,1,0)
		end
	end

	local function resizeSettingsList()
		local size = 0

		for i,v in pairs(settingsList:GetChildren()) do
			if v:IsA("Frame") then
				size = size + v.AbsoluteSize.Y
			end
		end

		settingsList.Parent.CanvasSize = UDim2.new(0,0,0,size)

		if size > settingsList.Parent.AbsoluteSize.Y then
			settingsList.Size = UDim2.new(1,-8,1,0)
		else
			settingsList.Size = UDim2.new(1,0,1,0)
		end
	end

	local function setupCheckbox(button,callback)
		local enabled = button.On.BackgroundTransparency == 0

		local function update()
			button.On.BackgroundTransparency = (enabled and 0 or 1)
		end

		button.On.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			if callback then callback(enabled) end
		end)

		return {
			Toggle = function(nocall) enabled = not enabled update() if not nocall and callback then callback(enabled) end end,
			Enable = function(nocall) if enabled then return end enabled = true update()if not nocall and callback then callback(enabled) end end,
			Disable = function(nocall) if not enabled then return end enabled = false update()if not nocall and callback then callback(enabled) end end,
			IsEnabled = function() return enabled end
		}
	end

	local function openSettingsEditor(event,cmd)
		currentlyEditingCmd = cmd

		for i,v in pairs(settingsList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		local delayEditor = settingsTemplates.DelayEditor:Clone()
		delayEditor.Secs.FocusLost:Connect(function()
			cmd[3] = tonumber(delayEditor.Secs.Text) or 0
			delayEditor.Secs.Text = cmd[3]
			if onEdited then onEdited() end
		end)
		delayEditor.Secs.Text = cmd[3]
		delayEditor.Visible = true
		table.insert(shade2,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs)
		table.insert(text1,delayEditor.Secs.Label)
		delayEditor.Parent = settingsList

		for i,v in pairs(event.sets) do
			if v.Type == "Player" then
				local template = settingsTemplates.Players:Clone()
				template.Title.Text = v.Name or "Player"

				local me,any,custom

				me = setupCheckbox(template.Me.Button,function(on)
					if not on then return end
					any.Disable()
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					me.Disable()
					custom.Disable()
					cmd[2][i] = 1
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					me.Disable()
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					me:Enable()
				elseif cVal == 1 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(shade3,template.CustomButton)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.Me.Button)
				table.insert(text1,template.Any)
				table.insert(text1,template.Me)
				template.Parent = settingsList
			elseif v.Type == "String" then
				local template = settingsTemplates.Strings:Clone()
				template.Title.Text = v.Name or "String"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					if custom:IsEnabled() then
						cmd[2][i] = customTextBox.Text
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			elseif v.Type == "Number" then
				local template = settingsTemplates.Numbers:Clone()
				template.Title.Text = v.Name or "Number"

				local any,custom

				any = setupCheckbox(template.Any.Button,function(on)
					if not on then return end
					custom.Disable()
					cmd[2][i] = 0
					if onEdited then onEdited() end
				end)

				local customTextBox = template.Custom
				custom = setupCheckbox(template.CustomButton,function(on)
					if not on then return end
					any.Disable()
					cmd[2][i] = customTextBox.Text
					if onEdited then onEdited() end
				end)

				ViewportTextBox.convert(customTextBox)
				customTextBox.FocusLost:Connect(function()
					cmd[2][i] = tonumber(customTextBox.Text) or 0
					customTextBox.Text = cmd[2][i]
					if custom:IsEnabled() then
						if onEdited then onEdited() end
					end
				end)

				local cVal = cmd[2][i]
				if cVal == 0 then
					any:Enable()
				else
					custom:Enable()
					customTextBox.Text = cVal
				end

				template.Visible = true
				table.insert(text1,template.Title)
				table.insert(text1,template.Any)
				table.insert(shade3,template.Any.Button)
				table.insert(shade3,template.CustomButton)
				template.Parent = settingsList
			end
		end
		resizeSettingsList()
		settingsFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
	end

	local function defaultSettings(ev)
		local res = {}

		for i,v in pairs(ev.sets) do
			if v.Type == "Player" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "String" then
				res[#res+1] = v.Default or 0
			elseif v.Type == "Number" then
				res[#res+1] = v.Default or 0
			end
		end

		return res
	end

	local function refreshList()
		for i,v in pairs(eventListHolder:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end

		for name,event in pairs(events) do
			local eventF = eventTemplate:Clone()
			eventF.EventName.Text = name
			eventF.Visible = true
			eventF.EventName:SetAttribute("RawName", name)
			table.insert(shade2,eventF)
			table.insert(text1,eventF.EventName)
			table.insert(shade1,eventF.Cmds.Add)

			local expanded = false
			eventF.Expand.MouseButton1Down:Connect(function()
				expanded = not expanded
				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
				eventF.Expand.Rotation = expanded and 90 or 0
				resizeList()
			end)

			local function refreshCommands()
				for i,v in pairs(eventF.Cmds.Holder:GetChildren()) do
					if v.Name == "CmdTemplate" then
						v:Destroy()
					end
				end

				eventF.EventName.Text = name..(#event.commands > 0 and " ("..#event.commands..")" or "")

				for i,cmd in pairs(event.commands) do
					local cmdF = cmdTemplate:Clone()
					local cmdTextBox = cmdF.TextBox
					ViewportTextBox.convert(cmdTextBox)
					cmdTextBox.Text = cmd[1]
					cmdF.Visible = true
					table.insert(shade1,cmdF)
					table.insert(shade2,cmdF.Delete)
					table.insert(shade2,cmdF.Settings)

					cmdTextBox.FocusLost:Connect(function()
						event.commands[i] = {cmdTextBox.Text,cmd[2],cmd[3]}
						if onEdited then onEdited() end
					end)

					cmdF.Settings.MouseButton1Click:Connect(function()
						openSettingsEditor(event,cmd)
					end)

					cmdF.Delete.MouseButton1Click:Connect(function()
						table.remove(event.commands,i)
						refreshCommands()
						resizeList()

						if currentlyEditingCmd == cmd then
							settingsFrame:TweenPosition(UDim2.new(0,-150,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
						end
						if onEdited then onEdited() end
					end)

					cmdF.Parent = eventF.Cmds.Holder
				end

				eventF:TweenSize(UDim2.new(1,0,0,20 + (expanded and 20*#eventF.Cmds.Holder:GetChildren() or 0)),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			end

			local newBox = eventF.Cmds.Add.TextBox
			ViewportTextBox.convert(newBox)
			newBox.FocusLost:Connect(function(enter)
				if enter then
					event.commands[#event.commands+1] = {newBox.Text,defaultSettings(event),0}
					newBox.Text = ""

					refreshCommands()
					resizeList()
					if onEdited then onEdited() end
				end
			end)

			--eventF:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeList)

			eventF.Parent = eventListHolder

			refreshCommands()
		end

		resizeList()
	end

	local function saveData()
		local result = {}
		for i,v in pairs(events) do
			result[i] = v.commands
		end
		return HttpService:JSONEncode(result)
	end

	local function loadData(str)
		local data = HttpService:JSONDecode(str)
		for i,v in pairs(data) do
			if events[i] then
				events[i].commands = v
			end
		end
	end

	local function addCmd(event,data)
		table.insert(events[event].commands,data)
	end

	local function setOnEdited(f)
		if type(f) == "function" then
			onEdited = f
		end
	end

	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-175,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	return {
		RegisterEvent = registerEvent,
		FireEvent = fireEvent,
		Refresh = refreshList,
		SaveData = saveData,
		LoadData = loadData,
		AddCmd = addCmd,
		Frame = main,
		SetOnEdited = setOnEdited
	}
end)()

reference = (function()
	local main = create({
		{1,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,Name="Main",Position=UDim2.new(0.5,-250,0,-500),Size=UDim2.new(0,500,0,20),ZIndex=10,}},
		{2,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="TopBar",Parent={1},Size=UDim2.new(1,0,0,20),ZIndex=10,}},
		{3,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Title",Parent={2},Size=UDim2.new(1,0,0.94999998807907,0),Text="Reference",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{4,"TextButton",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Close",Parent={2},Position=UDim2.new(1,-20,0,0),Size=UDim2.new(0,20,0,20),Text="",TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=10,}},
		{5,"ImageLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Image=getcustomasset("infiniteyield/assets/close.png"),Parent={4},Position=UDim2.new(0,5,0,5),Size=UDim2.new(0,10,0,10),ZIndex=10,}},
		{6,"Frame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BorderSizePixel=0,Name="Content",Parent={1},Position=UDim2.new(0,0,0,20),Size=UDim2.new(1,0,0,300),ZIndex=10,}},
		{7,"ScrollingFrame",{BackgroundColor3=Color3.new(0.14117647707462,0.14117647707462,0.14509804546833),BackgroundTransparency=1,BorderColor3=Color3.new(0.15686275064945,0.15686275064945,0.15686275064945),BorderSizePixel=0,BottomImage="rbxasset://textures/ui/Scroll/scroll-middle.png",CanvasSize=UDim2.new(0,0,0,1313),Name="List",Parent={6},ScrollBarImageColor3=Color3.new(0.30588236451149,0.30588236451149,0.3098039329052),ScrollBarThickness=8,Size=UDim2.new(1,0,1,0),TopImage="rbxasset://textures/ui/Scroll/scroll-middle.png",VerticalScrollBarInset=2,ZIndex=10,}},
		{8,"UIListLayout",{Parent={7},SortOrder=2,}},
		{9,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,429),ZIndex=10,}},
		{10,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={9},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Special Player Cases",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{11,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={9},Position=UDim2.new(0,8,0,25),Size=UDim2.new(1,-8,0,20),Text="These keywords can be used to quickly select groups of players in commands:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{12,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={9},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{13,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Cases",Parent={9},Position=UDim2.new(0,8,0,55),Size=UDim2.new(1,-16,0,342),ZIndex=10,}},
		{14,"UIListLayout",{Parent={13},SortOrder=2,}},
		{15,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{16,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={15},Size=UDim2.new(1,0,1,0),Text="all",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{17,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={15},Position=UDim2.new(0,15,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{18,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-3,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{19,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={18},Size=UDim2.new(1,0,1,0),Text="others",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{20,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={18},Position=UDim2.new(0,37,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone except you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{21,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-2,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{22,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={21},Size=UDim2.new(1,0,1,0),Text="me",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{23,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={21},Position=UDim2.new(0,19,0,0),Size=UDim2.new(1,0,1,0),Text="- includes your player only",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{24,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{25,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={24},Size=UDim2.new(1,0,1,0),Text="#[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{26,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={24},Position=UDim2.new(0,59,0,0),Size=UDim2.new(1,0,1,0),Text="- gets a specified amount of random players",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{27,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{28,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={27},Size=UDim2.new(1,0,1,0),Text="random",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{29,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={27},Position=UDim2.new(0,44,0,0),Size=UDim2.new(1,0,1,0),Text="- affects a random player",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{30,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{31,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={30},Size=UDim2.new(1,0,1,0),Text="%[team name]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{32,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={30},Position=UDim2.new(0,78,0,0),Size=UDim2.new(1,0,1,0),Text="- includes everyone on a given team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{33,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{34,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={33},Size=UDim2.new(1,0,1,0),Text="allies / team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{35,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={33},Position=UDim2.new(0,63,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{36,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{37,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={36},Size=UDim2.new(1,0,1,0),Text="enemies / nonteam",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{38,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={36},Position=UDim2.new(0,101,0,0),Size=UDim2.new(1,0,1,0),Text="- players who are not on your team",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{39,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{40,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={39},Size=UDim2.new(1,0,1,0),Text="friends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{41,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={39},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{42,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{43,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={42},Size=UDim2.new(1,0,1,0),Text="nonfriends",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{44,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={42},Position=UDim2.new(0,61,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone who is not friends with you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{45,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{46,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={45},Size=UDim2.new(1,0,1,0),Text="guests",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{47,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={45},Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,0,1,0),Text="- guest players (obsolete)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{48,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{49,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={48},Size=UDim2.new(1,0,1,0),Text="bacons",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{50,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={48},Position=UDim2.new(0,40,0,0),Size=UDim2.new(1,0,1,0),Text="- anyone with the \"bacon\" or pal hair",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{51,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{52,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={51},Size=UDim2.new(1,0,1,0),Text="age[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{53,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={51},Position=UDim2.new(0,71,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone below or at the given age",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{54,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{55,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={54},Size=UDim2.new(1,0,1,0),Text="rad[number]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{56,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={54},Position=UDim2.new(0,70,0,0),Size=UDim2.new(1,0,1,0),Text="- includes anyone within the given radius",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{57,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{58,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={57},Size=UDim2.new(1,0,1,0),Text="nearest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{59,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={57},Position=UDim2.new(0,43,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the closest player to you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{60,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{61,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={60},Size=UDim2.new(1,0,1,0),Text="farthest",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{62,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={60},Position=UDim2.new(0,46,0,0),Size=UDim2.new(1,0,1,0),Text="- gets the farthest player from you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{63,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{64,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={63},Size=UDim2.new(1,0,1,0),Text="group[ID]",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{65,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={63},Position=UDim2.new(0,55,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are in a certain group",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{66,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{67,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={66},Size=UDim2.new(1,0,1,0),Text="alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{68,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={66},Position=UDim2.new(0,27,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are alive",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{69,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{70,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={69},Size=UDim2.new(1,0,1,0),Text="dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{71,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={69},Position=UDim2.new(0,29,0,0),Size=UDim2.new(1,0,1,0),Text="- gets players who are dead",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{72,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Name="Case",Parent={13},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,0,0,18),ZIndex=10,}},
		{73,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="CaseName",Parent={72},Size=UDim2.new(1,0,1,0),Text="@username",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{74,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="CaseDesc",Parent={72},Position=UDim2.new(0,66,0,0),Size=UDim2.new(1,0,1,0),Text="- searches for players by username only (ignores displaynames)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{75,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,180),ZIndex=10,}},
		{76,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={75},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Various Operators",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{77,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={75},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{78,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,16),Text="Use commas to separate multiple expressions:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{79,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,75),Size=UDim2.new(1,-8,0,16),Text="Use - to exclude, and + to include players in your expression:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{80,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,91),Size=UDim2.new(1,-8,0,16),Text=";locate %blue-friends (gets players in blue team who aren't your friends)",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{81,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,46),Size=UDim2.new(1,-8,0,16),Text=";locate noob,noob2,bob",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{82,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={75},Position=UDim2.new(0,8,0,120),Size=UDim2.new(1,-8,0,16),Text="Put ! before a command to run it with the last arguments it was ran with:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{83,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={75},Position=UDim2.new(0,8,0,136),Size=UDim2.new(1,-8,0,32),Text="After running ;offset 0 100 0,  you can run !offset anytime to repeat that command with the same arguments that were used to run it last time",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{84,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,154),ZIndex=10,}},
		{85,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={84},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Command Looping",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{86,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="Form: [How many times it loops]^[delay (optional)]^[command]",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{87,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={84},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{88,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,50),Size=UDim2.new(1,-8,0,20),Text="Use the 'breakloops' command to stop all running loops.",TextColor3=Color3.new(1,1,1),TextSize=15,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{89,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={84},Position=UDim2.new(0,8,0,80),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{90,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={84},Position=UDim2.new(0,8,0,98),Size=UDim2.new(1,-8,0,42),Text=";5^btools - gives you 5 sets of btools\n;10^3^drophats - drops your hats every 3 seconds 10 times\n;inf^0.1^animspeed 100 - infinitely loops your animation speed to 100",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{91,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,120),ZIndex=10,}},
		{92,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={91},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Execute Multiple Commands at Once",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{93,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,20),Text="You can execute multiple commands at once using \"\\\"",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{94,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={91},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{95,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={91},Position=UDim2.new(0,8,0,60),Size=UDim2.new(1,-8,0,16),Text="Examples:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{96,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={91},Position=UDim2.new(0,8,0,78),Size=UDim2.new(1,-8,0,32),Text=";drophats\\respawn - drops your hats and respawns you\n;enable inventory\\enable playerlist\\refresh - enables those coregui items and refreshes you",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{97,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{98,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={97},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Browse Command History",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{99,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={97},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the up and down arrow keys to browse recently used commands",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{100,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={97},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{101,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,75),ZIndex=10,}},
		{102,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={101},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Autocomplete in the Command Bar",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{103,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={101},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="While focused on the command bar, you can use the tab key to insert the top suggested command into the command bar.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{104,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={101},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{105,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,175),ZIndex=10,}},
		{106,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={105},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Using Event Binds",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{107,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="Use event binds to set up commands that get executed when certain events happen. You can edit the conditions for an event command to run (such as which player triggers it).",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{108,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={105},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),ZIndex=10,}},
		{109,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,70),Size=UDim2.new(1,-8,0,48),Text="Some events may send arguments; you can use them in your event command by using $ followed by the argument number ($1, $2, etc). You can find out the order and types of these arguments by looking at the settings of the event command.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{110,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Text",Parent={105},Position=UDim2.new(0,8,0,130),Size=UDim2.new(1,-8,0,16),Text="Example:",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{111,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={105},Position=UDim2.new(0,8,0,148),Size=UDim2.new(1,-8,0,16),Text="Setting up 'goto $1' on the OnChatted event will teleport you to any player that chats.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,TextYAlignment=0,ZIndex=10,}},
		{112,"Frame",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Name="Section",Parent={7},Size=UDim2.new(1,0,0,105),ZIndex=10,}},
		{113,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=4,Name="Header",Parent={112},Position=UDim2.new(0,8,0,5),Size=UDim2.new(1,-8,0,20),Text="Get Further Help",TextColor3=Color3.new(1,1,1),TextSize=20,TextXAlignment=0,ZIndex=10,}},
		{114,"TextLabel",{BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1,Font=3,Name="Text",Parent={112},Position=UDim2.new(0,8,0,30),Size=UDim2.new(1,-8,0,32),Text="You can join the Discord server to get support with IY,  and read up on more documentation such as the Plugin API.",TextColor3=Color3.new(1,1,1),TextSize=14,TextWrapped=true,TextXAlignment=0,ZIndex=10,}},
		{115,"Frame",{BackgroundColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),BorderSizePixel=0,Name="Line",Parent={112},Position=UDim2.new(0,10,1,-1),Size=UDim2.new(1,-20,0,1),Visible=false,ZIndex=10,}},
		{116,"TextButton",{BackgroundColor3=Color3.new(0.48627451062202,0.61960786581039,0.85098040103912),BorderColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),Font=4,Name="InviteButton",Parent={112},Position=UDim2.new(0,5,0,75),Size=UDim2.new(1,-10,0,25),Text="Copy Discord Invite Link (https://discord.gg/78ZuWSq)",TextColor3=Color3.new(0.1803921610117,0.1803921610117,0.1843137294054),TextSize=16,ZIndex=10,}},
	})
	for i,v in pairs(main.Content.List:GetDescendants()) do
		if v:IsA("TextLabel") then
			table.insert(text1,v)
		end
	end
	table.insert(scroll,main.Content.List)
	table.insert(shade1,main.Content)
	table.insert(shade2,main.TopBar)
	main.Name = randomString()
	main.TopBar.Close.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0,-500), "InOut", "Quart", 0.5, true, nil)
	end)
	local inviteButton = main:FindFirstChild("InviteButton",true)
	local lastPress = nil
	inviteButton.MouseButton1Click:Connect(function()
		if everyClipboard then
			toClipboard("https://discord.gg/78ZuWSq")
			inviteButton.Text = "Copied"
		else
			inviteButton.Text = "No Clipboard Function, type out the link"
		end
		local pressTime = tick()
		lastPress = pressTime
		wait(2)
		if lastPress ~= pressTime then return end
		inviteButton.Text = "Copy Discord Invite Link (https://discord.gg/78ZuWSq)"
	end)
	dragGUI(main)
	main.Parent = ScaledHolder

	ReferenceButton.MouseButton1Click:Connect(function()
		main:TweenPosition(UDim2.new(0.5,-250,0.5,-150), "InOut", "Quart", 0.5, true, nil)
	end)
end)()

currentShade1 = Color3.fromRGB(16, 9, 32)
currentShade2 = Color3.fromRGB(30, 17, 56)
currentShade3 = Color3.fromRGB(150, 80, 255)
currentText1 = Color3.new(1, 1, 1)
currentText2 = Color3.new(0, 0, 0)
currentScroll = Color3.fromRGB(150, 80, 255)

defaultGuiScale = IsOnMobile and 0.9 or 1
defaultsettings = {
	prefix = ';';
	StayOpen = false;
	guiScale = defaultGuiScale;
	espTransparency = 0.3;
	keepIY = true;
	logsEnabled = false;
	jLogsEnabled = false;
	aliases = {};
	binds = {};
	WayPoints = {};
	PluginsTable = {};
	currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
	currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
	currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
	currentText1 = {currentText1.R,currentText1.G,currentText1.B};
	currentText2 = {currentText2.R,currentText2.G,currentText2.B};
	currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
	eventBinds = eventEditor.SaveData()
}

defaults = HttpService:JSONEncode(defaultsettings)
nosaves = false
useFactorySettings = function()
	prefix = ';'
	StayOpen = false
	guiScale = defaultGuiScale
	KeepInfYield = true
	espTransparency = 0.3
	logsEnabled = false
	jLogsEnabled = false
	logsWebhook = nil
	aliases = {}
	binds = {}
	WayPoints = {}
	PluginsTable = {}
end

function createPopup(title, text)
	local Popup = Instance.new("Frame")
	local background = Instance.new("Frame")
	local Directions = Instance.new("TextLabel")
	local shadow = Instance.new("Frame")
	local PopupText = Instance.new("TextLabel")
	local Exit = Instance.new("TextButton")
	local ExitImage = Instance.new("ImageLabel")

	Popup.Name = randomString()
	Popup.Parent = ScaledHolder
	Popup.Active = true
	Popup.BackgroundTransparency = 1
	Popup.Position = UDim2.new(0.5, -180, 0, -500)
	Popup.Size = UDim2.new(0, 360, 0, 20)
	Popup.ZIndex = 10

	background.Name = "background"
	background.Parent = Popup
	background.Active = true
	background.BackgroundColor3 = Color3.fromRGB(36, 36, 37)
	background.BorderSizePixel = 0
	background.Position = UDim2.new(0, 0, 0, 20)
	background.Size = UDim2.new(0, 360, 0, 205)
	background.ZIndex = 10

	Directions.Name = "Directions"
	Directions.Parent = background
	Directions.BackgroundTransparency = 1
	Directions.BorderSizePixel = 0
	Directions.Position = UDim2.new(0, 10, 0, 10)
	Directions.Size = UDim2.new(0, 340, 0, 185)
	Directions.Font = Enum.Font.SourceSans
	Directions.TextSize = 14
	Directions.Text = text
	Directions.TextColor3 = Color3.new(1, 1, 1)
	Directions.TextWrapped = true
	Directions.TextXAlignment = Enum.TextXAlignment.Left
	Directions.TextYAlignment = Enum.TextYAlignment.Top
	Directions.ZIndex = 10

	shadow.Name = "shadow"
	shadow.Parent = Popup
	shadow.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	shadow.BorderSizePixel = 0
	shadow.Size = UDim2.new(0, 360, 0, 20)
	shadow.ZIndex = 10

	PopupText.Name = "PopupText"
	PopupText.Parent = shadow
	PopupText.BackgroundTransparency = 1
	PopupText.Size = UDim2.new(1, 0, 0.95, 0)
	PopupText.ZIndex = 10
	PopupText.Font = Enum.Font.SourceSans
	PopupText.TextSize = 14
	PopupText.Text = title
	PopupText.TextColor3 = Color3.new(1, 1, 1)
	PopupText.TextWrapped = true

	Exit.Name = "Exit"
	Exit.Parent = shadow
	Exit.BackgroundTransparency = 1
	Exit.Position = UDim2.new(1, -20, 0, 0)
	Exit.Size = UDim2.new(0, 20, 0, 20)
	Exit.Text = ""
	Exit.ZIndex = 10

	ExitImage.Parent = Exit
	ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
	ExitImage.BackgroundTransparency = 1
	ExitImage.Position = UDim2.new(0, 5, 0, 5)
	ExitImage.Size = UDim2.new(0, 10, 0, 10)
	ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
	ExitImage.ZIndex = 10

	Popup:TweenPosition(UDim2.new(0.5, -180, 0, 150), "InOut", "Quart", 0.5, true, nil)

	Exit.MouseButton1Click:Connect(function()
		Popup:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
		task.wait(0.6)
		Popup:Destroy()
	end)
end

local loadedEventData = nil
local jsonAttempts = 0
function saves()
	if writefileExploit() and readfileExploit() and jsonAttempts < 10 then
		local readSuccess, out = readfile("KizzDev_FE2.iy", true)
		if readSuccess then
			if out ~= nil and tostring(out):gsub("%s", "") ~= "" then
				local success, response = pcall(function()
					local json = HttpService:JSONDecode(out)
					if vtype(json.prefix, "string") then prefix = json.prefix else prefix = ';' end
					if vtype(json.StayOpen, "boolean") then StayOpen = json.StayOpen else StayOpen = false end
					if vtype(json.guiScale, "number") then guiScale = json.guiScale else guiScale = defaultGuiScale end
					if vtype(json.keepIY, "boolean") then KeepInfYield = json.keepIY else KeepInfYield = true end
					if vtype(json.espTransparency, "number") then espTransparency = json.espTransparency else espTransparency = 0.3 end
					if vtype(json.logsEnabled, "boolean") then logsEnabled = json.logsEnabled else logsEnabled = false end
					if vtype(json.jLogsEnabled, "boolean") then jLogsEnabled = json.jLogsEnabled else jLogsEnabled = false end
					if vtype(json.logsWebhook, "string") then logsWebhook = json.logsWebhook else logsWebhook = nil end
					if vtype(json.aliases, "table") then aliases = json.aliases else aliases = {} end
					if vtype(json.binds, "table") then binds = json.binds else binds = {} end
					if vtype(json.spawnCmds, "table") then spawnCmds = json.spawnCmds end
					if vtype(json.WayPoints, "table") then AllWaypoints = json.WayPoints else WayPoints = {} AllWaypoints = {} end
					if vtype(json.PluginsTable, "table") then PluginsTable = json.PluginsTable else PluginsTable = {} end
					if vtype(json.currentShade1, "table") then currentShade1 = Color3.new(json.currentShade1[1],json.currentShade1[2],json.currentShade1[3]) end
					if vtype(json.currentShade2, "table") then currentShade2 = Color3.new(json.currentShade2[1],json.currentShade2[2],json.currentShade2[3]) end
					if vtype(json.currentShade3, "table") then currentShade3 = Color3.new(json.currentShade3[1],json.currentShade3[2],json.currentShade3[3]) end
					if vtype(json.currentText1, "table") then currentText1 = Color3.new(json.currentText1[1],json.currentText1[2],json.currentText1[3]) end
					if vtype(json.currentText2, "table") then currentText2 = Color3.new(json.currentText2[1],json.currentText2[2],json.currentText2[3]) end
					if vtype(json.currentScroll, "table") then currentScroll = Color3.new(json.currentScroll[1],json.currentScroll[2],json.currentScroll[3]) end
					if vtype(json.eventBinds, "string") then loadedEventData = json.eventBinds end
				end)
				if not success then
					jsonAttempts = jsonAttempts + 1
					warn("Save Json Error:", response)
					warn("Overwriting Save File")
					writefile("KizzDev_FE2.iy", defaults, true)
					wait()
					saves()
				end
			else
				writefile("KizzDev_FE2.iy", defaults, true)
				wait()
				local dReadSuccess, dOut = readfile("KizzDev_FE2.iy", true)
				if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
					saves()
				else
					nosaves = true
					useFactorySettings()
					createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
				end
			end
		else
			writefile("KizzDev_FE2.iy", defaults, true)
			wait()
			local dReadSuccess, dOut = readfile("KizzDev_FE2.iy", true)
			if dReadSuccess and dOut ~= nil and tostring(dOut):gsub("%s", "") ~= "" then
				saves()
			else
				nosaves = true
				useFactorySettings()
				createPopup("File Error", "There was a problem writing a save file to your PC.\n\nPlease contact the developer/support team for your exploit and tell them writefile/readfile is not working.\n\nYour settings, keybinds, waypoints, and aliases will not save if you continue.\n\nThings to try:\n> Make sure a 'workspace' folder is located in the same folder as your exploit\n> If your exploit is inside of a zip/rar file, extract it.\n> Rejoin the game and try again or restart your PC and try again.")
			end
		end
	else
		if jsonAttempts >= 10 then
			nosaves = true
			useFactorySettings()
			createPopup("File Error", "Sorry, we have attempted to parse your save file, but it is unreadable!\n\nKizzDev is now using factory settings until your exploit's file system works.\n\nYour save file has not been deleted.")
		else
			nosaves = true
			useFactorySettings()
		end
	end
end

saves()

function updatesaves()
	if nosaves == false and writefileExploit() then
		local update = {
			prefix = prefix;
			StayOpen = StayOpen;
			guiScale = guiScale;
			keepIY = KeepInfYield;
			espTransparency = espTransparency;
			logsEnabled = logsEnabled;
			jLogsEnabled = jLogsEnabled;
			logsWebhook = logsWebhook;
			aliases = aliases;
			binds = binds or {};
			WayPoints = AllWaypoints;
			PluginsTable = PluginsTable;
			currentShade1 = {currentShade1.R,currentShade1.G,currentShade1.B};
			currentShade2 = {currentShade2.R,currentShade2.G,currentShade2.B};
			currentShade3 = {currentShade3.R,currentShade3.G,currentShade3.B};
			currentText1 = {currentText1.R,currentText1.G,currentText1.B};
			currentText2 = {currentText2.R,currentText2.G,currentText2.B};
			currentScroll = {currentScroll.R,currentScroll.G,currentScroll.B};
			eventBinds = eventEditor.SaveData()
		}
		writefileCooldown("KizzDev_FE2.iy", HttpService:JSONEncode(update))
	end
end

eventEditor.SetOnEdited(updatesaves)

pWayPoints = {}
WayPoints = {}

if #AllWaypoints > 0 then
	for i = 1, #AllWaypoints do
		if not AllWaypoints[i].GAME or AllWaypoints[i].GAME == PlaceId then
			WayPoints[#WayPoints + 1] = {NAME = AllWaypoints[i].NAME, COORD = {AllWaypoints[i].COORD[1], AllWaypoints[i].COORD[2], AllWaypoints[i].COORD[3]}, GAME = AllWaypoints[i].GAME}
		end
	end
end

if type(binds) ~= "table" then binds = {} end

if type(PluginsTable) == "table" then
	for i = #PluginsTable, 1, -1 do
		if string.sub(PluginsTable[i], -3) ~= ".iy" then
			table.remove(PluginsTable, i)
		end
	end
end

function Time()
	local HOUR = math.floor((tick() % 86400) / 3600)
	local MINUTE = math.floor((tick() % 3600) / 60)
	local SECOND = math.floor(tick() % 60)
	local AP = HOUR > 11 and 'PM' or 'AM'
	HOUR = (HOUR % 12 == 0 and 12 or HOUR % 12)
	HOUR = HOUR < 10 and '0' .. HOUR or HOUR
	MINUTE = MINUTE < 10 and '0' .. MINUTE or MINUTE
	SECOND = SECOND < 10 and '0' .. SECOND or SECOND
	return HOUR .. ':' .. MINUTE .. ':' .. SECOND .. ' ' .. AP
end

PrefixBox.Text = prefix
local SettingsOpen = false
local isHidden = false

if StayOpen == false then
	On.BackgroundTransparency = 1
else
	On.BackgroundTransparency = 0
end

if logsEnabled then
	Toggle.Text = 'Enabled'
else
	Toggle.Text = 'Disabled'
end

if jLogsEnabled then
	Toggle_2.Text = 'Enabled'
else
	Toggle_2.Text = 'Disabled'
end

function maximizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -220), "InOut", "Quart", 0.2, true, nil)
	end
end

minimizeNum = -20
function minimizeHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, minimizeNum), "InOut", "Quart", 0.5, true, nil)
	end
end

function cmdbarHolder()
	if StayOpen == false then
		Holder:TweenPosition(UDim2.new(1, Holder.Position.X.Offset, 1, -45), "InOut", "Quart", 0.5, true, nil)
	end
end

pinNotification = nil
local notifyCount = 0
function notify(text,text2,length)
	task.spawn(function()
		local LnotifyCount = notifyCount+1
		local notificationPinned = false
		notifyCount = notifyCount+1
		if pinNotification then pinNotification:Disconnect() end
		pinNotification = PinButton.MouseButton1Click:Connect(function()
			task.spawn(function()
				pinNotification:Disconnect()
				notificationPinned = true
				Title_2.BackgroundTransparency = 1
				wait(0.5)
				Title_2.BackgroundTransparency = 0
			end)
		end)
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.6)
		local closepressed = false
		if text2 then
			Title_2.Text = text
			Text_2.Text = text2
		else
			Title_2.Text = 'Notification'
			Text_2.Text = text
		end
		Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, -100), "InOut", "Quart", 0.5, true, nil)
		CloseButton.MouseButton1Click:Connect(function()
			Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			closepressed = true
			pinNotification:Disconnect()
		end)
		if length and isNumber(length) then
			wait(length)
		else
			wait(10)
		end
		if LnotifyCount == notifyCount then
			if closepressed == false and notificationPinned == false then
				pinNotification:Disconnect()
				Notification:TweenPosition(UDim2.new(1, Notification.Position.X.Offset, 1, 0), "InOut", "Quart", 0.5, true, nil)
			end
			notifyCount = 0
		end
	end)
end

local lastMessage = nil
local lastLabel = nil
local dupeCount = 1
function CreateLabel(Name, Text)
	if lastMessage == Name..Text then
		dupeCount = dupeCount+1
		lastLabel.Text = Time()..' - ['..Name..']: '..Text..' (x'..dupeCount..')'
	else
		if dupeCount > 1 then dupeCount = 1 end
		if #scroll_2:GetChildren() >= 2546 then
			scroll_2:ClearAllChildren()
		end
		local alls = 0
		for i,v in pairs(scroll_2:GetChildren()) do
			if v then
				alls = v.Size.Y.Offset + alls
			end
			if not v then
				alls = 0
			end
		end
		local tl = Instance.new('TextLabel')
		lastMessage = Name..Text
		lastLabel = tl
		tl.Name = Name
		tl.Parent = scroll_2
		tl.ZIndex = 10
		tl.RichText = true
		tl.Text = Time().." - ["..Name.."]: "..Text
		tl.Text = tl.ContentText
		tl.Size = UDim2.new(0,322,0,84)
		tl.BackgroundTransparency = 1
		tl.BorderSizePixel = 0
		tl.Font = "SourceSans"
		tl.Position = UDim2.new(-1,0,0,alls)
		tl.TextTransparency = 1
		tl.TextScaled = false
		tl.TextSize = 14
		tl.TextWrapped = true
		tl.TextXAlignment = "Left"
		tl.TextYAlignment = "Top"
		tl.TextColor3 = currentText1
		tl.Size = UDim2.new(0,322,0,tl.TextBounds.Y)
		table.insert(text1,tl)
		scroll_2.CanvasSize = UDim2.new(0,0,0,alls+tl.TextBounds.Y)
		scroll_2.CanvasPosition = Vector2.new(0,scroll_2.CanvasPosition.Y+tl.TextBounds.Y)
		tl:TweenPosition(UDim2.new(0,3,0,alls), 'In', 'Quint', 0.5)
		TweenService:Create(tl, TweenInfo.new(1.25, Enum.EasingStyle.Linear), { TextTransparency = 0 }):Play()
	end
end

function CreateJoinLabel(player, userId)
    if #scroll_3:GetChildren() >= 2546 then
        scroll_3:ClearAllChildren()
    end
    local infoFrame = Instance.new("Frame")
    local info1 = Instance.new("TextLabel")
    local info2 = Instance.new("TextLabel")
    local ImageLabel_3 = Instance.new("ImageLabel")
    infoFrame.Name = randomString()
    infoFrame.Parent = scroll_3
    infoFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    infoFrame.BackgroundTransparency = 1
    infoFrame.BorderColor3 = Color3.new(0.105882, 0.164706, 0.207843)
    infoFrame.Size = UDim2.new(1, 0, 0, 50)
    info1.Name = randomString()
    info1.Parent = infoFrame
    info1.BackgroundTransparency = 1
    info1.BorderSizePixel = 0
    info1.Position = UDim2.new(0, 45, 0, 0)
    info1.Size = UDim2.new(0, 135, 1, 0)
    info1.ZIndex = 10
    info1.Font = Enum.Font.SourceSans
    info1.FontSize = Enum.FontSize.Size14
    info1.Text = "Username: " .. player.Name .. "\nJoined Server: " .. Time()
    info1.TextColor3 = Color3.new(1, 1, 1)
    info1.TextWrapped = true
    info1.TextXAlignment = Enum.TextXAlignment.Left
    info2.Name = randomString()
    info2.Parent = infoFrame
    info2.BackgroundTransparency = 1
    info2.BorderSizePixel = 0
    info2.Position = UDim2.new(0, 185, 0, 0)
    info2.Size = UDim2.new(0, 140, 1, -5)
    info2.ZIndex = 10
    info2.Font = Enum.Font.SourceSans
    info2.FontSize = Enum.FontSize.Size14
    info2.Text = "User ID: " .. userId .. "\nAccount Age: " .. player.AccountAge .. "\nJoined Roblox: Loading..."
    info2.TextColor3 = Color3.new(1, 1, 1)
    info2.TextWrapped = true
    info2.TextXAlignment = Enum.TextXAlignment.Left
    info2.TextYAlignment = Enum.TextYAlignment.Center
    ImageLabel_3.Parent = infoFrame
    ImageLabel_3.BackgroundTransparency = 1
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Size = UDim2.new(0, 45, 1, 0)
    ImageLabel_3.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
    scroll_3.CanvasSize = UDim2.new(0, 0, 0, listlayout.AbsoluteContentSize.Y)
    scroll_3.CanvasPosition = Vector2.new(0, scroll_2.CanvasPosition.Y + infoFrame.AbsoluteSize.Y)
    local date = os.date("!%Y-%m-%d", os.time() - (player.AccountAge * 86400))
    local splitDates = string.split(date, "-")
    info2.Text = string.gsub(info2.Text, "Loading...", splitDates[2] .. "/" .. splitDates[3] .. "/" .. splitDates[1])
end

IYMouse.KeyDown:Connect(function(Key)
	if (Key==prefix) then
		RunService.RenderStepped:Wait()
		if KizzFocusCmd then
			KizzFocusCmd()
		else
			Cmdbar:CaptureFocus()
			maximizeHolder()
		end
	end
end)

local lastMinimizeReq = 0
Holder.MouseEnter:Connect(function()
	lastMinimizeReq = 0
	maximizeHolder()
end)

Holder.MouseLeave:Connect(function()
	if not Cmdbar:IsFocused() then
		local reqTime = tick()
		lastMinimizeReq = reqTime
		wait(1)
		if lastMinimizeReq ~= reqTime then return end
		if not Cmdbar:IsFocused() then
			minimizeHolder()
		end
	end
end)

function updateColors(color,ctype)
	if ctype == shade1 then
		for i,v in pairs(shade1) do
			v.BackgroundColor3 = color
		end
		currentShade1 = color
	elseif ctype == shade2 then
		for i,v in pairs(shade2) do
			v.BackgroundColor3 = color
		end
		currentShade2 = color
	elseif ctype == shade3 then
		for i,v in pairs(shade3) do
			v.BackgroundColor3 = color
		end
		currentShade3 = color
	elseif ctype == text1 then
		for i,v in pairs(text1) do
			v.TextColor3 = color
			if v:IsA("TextBox") then
				v.PlaceholderColor3 = color	
			end
		end
		currentText1 = color
	elseif ctype == text2 then
		for i,v in pairs(text2) do
			v.TextColor3 = color
		end
		currentText2 = color
	elseif ctype == scroll then
		for i,v in pairs(scroll) do
			v.ScrollBarImageColor3 = color
		end
		currentScroll = color
	end
end

local colorpickerOpen = false
ColorsButton.MouseButton1Click:Connect(function()
	cache_currentShade1 = currentShade1
	cache_currentShade2 = currentShade2
	cache_currentShade3 = currentShade3
	cache_currentText1 = currentText1
	cache_currentText2 = currentText2
	cache_currentScroll = currentScroll
	if not colorpickerOpen then
		colorpickerOpen = true
		picker = game:GetObjects("rbxassetid://4908465318")[1]
		picker.Name = randomString()
		picker.Parent = ScaledHolder

		local ColorPicker do
			ColorPicker = {}

			ColorPicker.new = function()
				local newMt = setmetatable({},{})

				local pickerGui = picker.ColorPicker
				local pickerTopBar = pickerGui.TopBar
				local pickerExit = pickerTopBar.Exit
				local pickerFrame = pickerGui.Content
				local colorSpace = pickerFrame.ColorSpaceFrame.ColorSpace
				local colorStrip = pickerFrame.ColorStrip
				local previewFrame = pickerFrame.Preview
				local basicColorsFrame = pickerFrame.BasicColors
				local customColorsFrame = pickerFrame.CustomColors
				local defaultButton = pickerFrame.Default
				local cancelButton = pickerFrame.Cancel
				local shade1Button = pickerFrame.Shade1
				local shade2Button = pickerFrame.Shade2
				local shade3Button = pickerFrame.Shade3
				local text1Button = pickerFrame.Text1
				local text2Button = pickerFrame.Text2
				local scrollButton = pickerFrame.Scroll

				local colorScope = colorSpace.Scope
				local colorArrow = pickerFrame.ArrowFrame.Arrow

				local hueInput = pickerFrame.Hue.Input
				local satInput = pickerFrame.Sat.Input
				local valInput = pickerFrame.Val.Input

				local redInput = pickerFrame.Red.Input
				local greenInput = pickerFrame.Green.Input
				local blueInput = pickerFrame.Blue.Input

				local mouse = IYMouse

				local hue,sat,val = 0,0,1
				local red,green,blue = 1,1,1
				local chosenColor = Color3.new(0,0,0)

				local basicColors = {Color3.new(0,0,0),Color3.new(0.66666668653488,0,0),Color3.new(0,0.33333334326744,0),Color3.new(0.66666668653488,0.33333334326744,0),Color3.new(0,0.66666668653488,0),Color3.new(0.66666668653488,0.66666668653488,0),Color3.new(0,1,0),Color3.new(0.66666668653488,1,0),Color3.new(0,0,0.49803924560547),Color3.new(0.66666668653488,0,0.49803924560547),Color3.new(0,0.33333334326744,0.49803924560547),Color3.new(0.66666668653488,0.33333334326744,0.49803924560547),Color3.new(0,0.66666668653488,0.49803924560547),Color3.new(0.66666668653488,0.66666668653488,0.49803924560547),Color3.new(0,1,0.49803924560547),Color3.new(0.66666668653488,1,0.49803924560547),Color3.new(0,0,1),Color3.new(0.66666668653488,0,1),Color3.new(0,0.33333334326744,1),Color3.new(0.66666668653488,0.33333334326744,1),Color3.new(0,0.66666668653488,1),Color3.new(0.66666668653488,0.66666668653488,1),Color3.new(0,1,1),Color3.new(0.66666668653488,1,1),Color3.new(0.33333334326744,0,0),Color3.new(1,0,0),Color3.new(0.33333334326744,0.33333334326744,0),Color3.new(1,0.33333334326744,0),Color3.new(0.33333334326744,0.66666668653488,0),Color3.new(1,0.66666668653488,0),Color3.new(0.33333334326744,1,0),Color3.new(1,1,0),Color3.new(0.33333334326744,0,0.49803924560547),Color3.new(1,0,0.49803924560547),Color3.new(0.33333334326744,0.33333334326744,0.49803924560547),Color3.new(1,0.33333334326744,0.49803924560547),Color3.new(0.33333334326744,0.66666668653488,0.49803924560547),Color3.new(1,0.66666668653488,0.49803924560547),Color3.new(0.33333334326744,1,0.49803924560547),Color3.new(1,1,0.49803924560547),Color3.new(0.33333334326744,0,1),Color3.new(1,0,1),Color3.new(0.33333334326744,0.33333334326744,1),Color3.new(1,0.33333334326744,1),Color3.new(0.33333334326744,0.66666668653488,1),Color3.new(1,0.66666668653488,1),Color3.new(0.33333334326744,1,1),Color3.new(1,1,1)}
				local customColors = {}

				dragGUI(picker)

				local function updateColor(noupdate)
					local relativeX,relativeY,relativeStripY = 219 - hue*219, 199 - sat*199, 199 - val*199
					local hsvColor = Color3.fromHSV(hue,sat,val)

					if noupdate == 2 or not noupdate then
						hueInput.Text = tostring(math.ceil(359*hue))
						satInput.Text = tostring(math.ceil(255*sat))
						valInput.Text = tostring(math.floor(255*val))
					end
					if noupdate == 1 or not noupdate then
						redInput.Text = tostring(math.floor(255*red))
						greenInput.Text = tostring(math.floor(255*green))
						blueInput.Text = tostring(math.floor(255*blue))
					end

					chosenColor = Color3.new(red,green,blue)

					colorScope.Position = UDim2.new(0,relativeX-9,0,relativeY-9)
					colorStrip.ImageColor3 = Color3.fromHSV(hue,sat,1)
					colorArrow.Position = UDim2.new(0,-2,0,relativeStripY-4)
					previewFrame.BackgroundColor3 = chosenColor

					newMt.Color = chosenColor
					if newMt.Changed then newMt:Changed(chosenColor) end
				end

				local function colorSpaceInput()
					local relativeX = mouse.X - colorSpace.AbsolutePosition.X
					local relativeY = mouse.Y - colorSpace.AbsolutePosition.Y

					if relativeX < 0 then relativeX = 0 elseif relativeX > 219 then relativeX = 219 end
					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end

					hue = (219 - relativeX)/219
					sat = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function colorStripInput()
					local relativeY = mouse.Y - colorStrip.AbsolutePosition.Y

					if relativeY < 0 then relativeY = 0 elseif relativeY > 199 then relativeY = 199 end	

					val = (199 - relativeY)/199

					local hsvColor = Color3.fromHSV(hue,sat,val)
					red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b

					updateColor()
				end

				local function hookButtons(frame,func)
					frame.ArrowFrame.Up.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum + 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum + 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Up.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Up.BackgroundTransparency = 1
						end
					end)

					frame.ArrowFrame.Down.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 0.5
						elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
							local releaseEvent,runEvent

							local startTime = tick()
							local pressing = true
							local startNum = tonumber(frame.Text)

							if not startNum then return end

							releaseEvent = UserInputService.InputEnded:Connect(function(input)
								if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
								releaseEvent:Disconnect()
								pressing = false
							end)

							startNum = startNum - 1
							func(startNum)
							while pressing do
								if tick()-startTime > 0.3 then
									startNum = startNum - 1
									func(startNum)
								end
								wait(0.1)
							end
						end
					end)

					frame.ArrowFrame.Down.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement then
							frame.ArrowFrame.Down.BackgroundTransparency = 1
						end
					end)
				end

				colorSpace.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorSpaceInput()
							end
						end)

						colorSpaceInput()
					end
				end)

				colorStrip.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local releaseEvent,mouseEvent

						releaseEvent = UserInputService.InputEnded:Connect(function(input)
							if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
							releaseEvent:Disconnect()
							mouseEvent:Disconnect()
						end)

						mouseEvent = UserInputService.InputChanged:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseMovement then
								colorStripInput()
							end
						end)

						colorStripInput()
					end
				end)

				local function updateHue(str)
					local num = tonumber(str)
					if num then
						hue = math.clamp(math.floor(num),0,359)/359
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						hueInput.Text = tostring(hue*359)
						updateColor(1)
					end
				end
				hueInput.FocusLost:Connect(function() updateHue(hueInput.Text) end) hookButtons(hueInput,updateHue)

				local function updateSat(str)
					local num = tonumber(str)
					if num then
						sat = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						satInput.Text = tostring(sat*255)
						updateColor(1)
					end
				end
				satInput.FocusLost:Connect(function() updateSat(satInput.Text) end) hookButtons(satInput,updateSat)

				local function updateVal(str)
					local num = tonumber(str)
					if num then
						val = math.clamp(math.floor(num),0,255)/255
						local hsvColor = Color3.fromHSV(hue,sat,val)
						red,green,blue = hsvColor.r,hsvColor.g,hsvColor.b
						valInput.Text = tostring(val*255)
						updateColor(1)
					end
				end
				valInput.FocusLost:Connect(function() updateVal(valInput.Text) end) hookButtons(valInput,updateVal)

				local function updateRed(str)
					local num = tonumber(str)
					if num then
						red = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						redInput.Text = tostring(red*255)
						updateColor(2)
					end
				end
				redInput.FocusLost:Connect(function() updateRed(redInput.Text) end) hookButtons(redInput,updateRed)

				local function updateGreen(str)
					local num = tonumber(str)
					if num then
						green = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						greenInput.Text = tostring(green*255)
						updateColor(2)
					end
				end
				greenInput.FocusLost:Connect(function() updateGreen(greenInput.Text) end) hookButtons(greenInput,updateGreen)

				local function updateBlue(str)
					local num = tonumber(str)
					if num then
						blue = math.clamp(math.floor(num),0,255)/255
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						blueInput.Text = tostring(blue*255)
						updateColor(2)
					end
				end
				blueInput.FocusLost:Connect(function() updateBlue(blueInput.Text) end) hookButtons(blueInput,updateBlue)

				local colorChoice = Instance.new("TextButton")
				colorChoice.Name = "Choice"
				colorChoice.Size = UDim2.new(0,25,0,18)
				colorChoice.BorderColor3 = Color3.new(96/255,96/255,96/255)
				colorChoice.Text = ""
				colorChoice.AutoButtonColor = false
				colorChoice.ZIndex = 10

				local row = 0
				local column = 0
				for i,v in pairs(basicColors) do
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = v
					newColor.Position = UDim2.new(0,1 + 30*column,0,21 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						red,green,blue = v.r,v.g,v.b
						local newColor = Color3.new(red,green,blue)
						hue,sat,val = Color3.toHSV(newColor)
						updateColor()
					end)	

					newColor.Parent = basicColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				row = 0
				column = 0
				for i = 1,12 do
					local color = customColors[i] or Color3.new(0,0,0)
					local newColor = colorChoice:Clone()
					newColor.BackgroundColor3 = color
					newColor.Position = UDim2.new(0,1 + 30*column,0,20 + 23*row)

					newColor.MouseButton1Click:Connect(function()
						local curColor = customColors[i] or Color3.new(0,0,0)
						red,green,blue = curColor.r,curColor.g,curColor.b
						hue,sat,val = Color3.toHSV(curColor)
						updateColor()
					end)

					newColor.MouseButton2Click:Connect(function()
						customColors[i] = chosenColor
						newColor.BackgroundColor3 = chosenColor
					end)

					newColor.Parent = customColorsFrame
					column = column + 1
					if column == 6 then row = row + 1 column = 0 end
				end

				shade1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade1) end end)
				shade1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0.4 end end)
				shade1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade1Button.BackgroundTransparency = 0 end end)

				shade2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade2) end end)
				shade2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0.4 end end)
				shade2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade2Button.BackgroundTransparency = 0 end end)

				shade3Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,shade3) end end)
				shade3Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0.4 end end)
				shade3Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then shade3Button.BackgroundTransparency = 0 end end)

				text1Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text1) end end)
				text1Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0.4 end end)
				text1Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text1Button.BackgroundTransparency = 0 end end)

				text2Button.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,text2) end end)
				text2Button.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0.4 end end)
				text2Button.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then text2Button.BackgroundTransparency = 0 end end)

				scrollButton.MouseButton1Click:Connect(function() if newMt.Confirm then newMt:Confirm(chosenColor,scroll) end end)
				scrollButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0.4 end end)
				scrollButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then scrollButton.BackgroundTransparency = 0 end end)

				cancelButton.MouseButton1Click:Connect(function() if newMt.Cancel then newMt:Cancel() end end)
				cancelButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0.4 end end)
				cancelButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then cancelButton.BackgroundTransparency = 0 end end)

				defaultButton.MouseButton1Click:Connect(function() if newMt.Default then newMt:Default() end end)
				defaultButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0.4 end end)
				defaultButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then defaultButton.BackgroundTransparency = 0 end end)

				pickerExit.MouseButton1Click:Connect(function()
					picker:TweenPosition(UDim2.new(0.5, -219, 0, -500), "InOut", "Quart", 0.5, true, nil)
				end)

				updateColor()

				newMt.SetColor = function(self,color)
					red,green,blue = color.r,color.g,color.b
					hue,sat,val = Color3.toHSV(color)
					updateColor()
				end

				return newMt
			end
		end

		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)

		local Npicker = ColorPicker.new()
		Npicker.Confirm = function(self,color,ctype) updateColors(color,ctype) wait() updatesaves() end
		Npicker.Cancel = function(self)
			updateColors(cache_currentShade1,shade1)
			updateColors(cache_currentShade2,shade2)
			updateColors(cache_currentShade3,shade3)
			updateColors(cache_currentText1,text1)
			updateColors(cache_currentText2,text2)
			updateColors(cache_currentScroll,scroll)
			wait()
			updatesaves()
		end
		Npicker.Default = function(self)
			updateColors(Color3.fromRGB(16, 9, 32),shade1)
			updateColors(Color3.fromRGB(30, 17, 56),shade2)
			updateColors(Color3.fromRGB(150, 80, 255),shade3)
			updateColors(Color3.new(1, 1, 1),text1)
			updateColors(Color3.new(0, 0, 0),text2)
			updateColors(Color3.fromRGB(150, 80, 255),scroll)
			wait()
			updatesaves()
		end
	else
		picker:TweenPosition(UDim2.new(0.5, -219, 0, 100), "InOut", "Quart", 0.5, true, nil)
	end
end)


SettingsButton.MouseButton1Click:Connect(function()
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	else SettingsOpen = false
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.5, true, nil)
	end
end)

On.MouseButton1Click:Connect(function()
	if isHidden == false then
		if StayOpen == false then
			StayOpen = true
			On.BackgroundTransparency = 0
		else
			StayOpen = false
			On.BackgroundTransparency = 1
		end
		updatesaves()
	end
end)

Clear.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_2:GetChildren()) do
		child:Destroy()
	end
	scroll_2.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Clear_2.MouseButton1Down:Connect(function()
	for _, child in pairs(scroll_3:GetChildren()) do
		child:Destroy()
	end
	scroll_3.CanvasSize = UDim2.new(0, 0, 0, 10)
end)

Toggle.MouseButton1Down:Connect(function()
	if logsEnabled then
		logsEnabled = false
		Toggle.Text = 'Disabled'
		updatesaves()
	else
		logsEnabled = true
		Toggle.Text = 'Enabled'
		updatesaves()
	end
end)

Toggle_2.MouseButton1Down:Connect(function()
	if jLogsEnabled then
		jLogsEnabled = false
		Toggle_2.Text = 'Disabled'
		updatesaves()
	else
		jLogsEnabled = true
		Toggle_2.Text = 'Enabled'
		updatesaves()
	end
end)

selectChat.MouseButton1Down:Connect(function()
	join.Visible = false
	chat.Visible = true
	table.remove(shade3,table.find(shade3,selectChat))
	table.remove(shade2,table.find(shade2,selectJoin))
	table.insert(shade2,selectChat)
	table.insert(shade3,selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
end)

selectJoin.MouseButton1Down:Connect(function()
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3,table.find(shade3,selectJoin))
	table.remove(shade2,table.find(shade2,selectChat))
	table.insert(shade2,selectJoin)
	table.insert(shade3,selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
end)

if not writefileExploit() then
	notify("Saves", "Your exploit does not support read/write file. Your settings will not save.")
end

avatarcache = {}
function sendChatWebhook(player, message)
	if httprequest and vtype(logsWebhook, "string") then
		local id = player.UserId
		local avatar = avatarcache[id]
		if not avatar then
			local d = HttpService:JSONDecode(httprequest({
				Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. id .. "&size=420x420&format=Png&isCircular=false",
				Method = "GET"
			}).Body)["data"]
			avatar = d and d[1].state == "Completed" and d[1].imageUrl or "https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/assets/plain.png"
			avatarcache[id] = avatar
		end
		local log = HttpService:JSONEncode({
			content = message,
			avatar_url = avatar,
			username = formatUsername(player),
			allowed_mentions = {parse = {}}
		})
		httprequest({
			Url = logsWebhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = log
		})
	end
end

ChatLog = function(player)
	player.Chatted:Connect(function(message)
		if logsEnabled == true then
			CreateLabel(player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

JoinLog = function(plr)
	if jLogsEnabled == true then
		CreateJoinLabel(plr,plr.UserId)
	end
end

CleanFileName = function(name)
	return tostring(name):gsub("[*\\?:<>|]+", ""):sub(1, 175)
end

SaveChatlogs.MouseButton1Down:Connect(function()
	if writefileExploit() then
		if #scroll_2:GetChildren() > 0 then
			notify("Loading",'Hold on a sec')
			local placeName = CleanFileName(MarketplaceService:GetProductInfo(PlaceId).Name)
			local writelogs = '-- KizzDev Chat logs for "'..placeName..'"\n'
			for _, child in pairs(scroll_2:GetChildren()) do
				writelogs = writelogs..'\n'..child.Text
			end
			local writelogsFile = tostring(writelogs)
			local fileext = 0
			local function nameFile()
				local file
				pcall(function() file = readfile(placeName..' Chat Logs ('..fileext..').txt') end)
				if file then
					fileext = fileext+1
					nameFile()
				else
					writefileCooldown(placeName..' Chat Logs ('..fileext..').txt', writelogsFile)
				end
			end
			nameFile()
			notify('Chat Logs','Saved chat logs to the workspace folder within your exploit folder.')
		end
	else
		notify('Chat Logs','Your exploit does not support write file. You cannot save chat logs.')
	end
end)

if isLegacyChat then
	for _, plr in pairs(Players:GetPlayers()) do
		ChatLog(plr)
	end
end

Players.PlayerRemoving:Connect(function(player)
	if ESPenabled or CHMSenabled or COREGUI:FindFirstChild(player.Name..'_LC') then
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == player.Name..'_ESP' or v.Name == player.Name..'_LC' or v.Name == player.Name..'_CHMS' then
				v:Destroy()
			end
		end
	end
	if viewing ~= nil and player == viewing then
		workspace.CurrentCamera.CameraSubject = Players.LocalPlayer.Character
		viewing = nil
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		notify('Spectate','View turned off (player left)')
	end
	eventEditor.FireEvent("OnLeave", player.Name)
end)

Exit.MouseButton1Down:Connect(function()
	logs:TweenPosition(UDim2.new(0, 0, 1, 10), "InOut", "Quart", 0.3, true, nil)
end)

Hide.MouseButton1Down:Connect(function()
	if logs.Position ~= UDim2.new(0, 0, 1, -20) then
		logs:TweenPosition(UDim2.new(0, 0, 1, -20), "InOut", "Quart", 0.3, true, nil)
	else
		logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
	end
end)

EventBind.MouseButton1Click:Connect(function()
	eventEditor.Frame:TweenPosition(UDim2.new(0.5,-175,0.5,-101), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Keybinds.MouseButton1Click:Connect(function()
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Add.MouseButton1Click:Connect(function()
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, 260), "InOut", "Quart", 0.5, true, nil)
end)

Delete.MouseButton1Click:Connect(function()
	binds = {}
	refreshbinds()
	updatesaves()
	notify('Keybinds Updated','Removed all keybinds')
end)

Close_2.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Aliases.MouseButton1Click:Connect(function()
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

Close_3.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

Positions.MouseButton1Click:Connect(function()
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
end)

local selectionBox = Instance.new("SelectionBox")
selectionBox.Name = randomString()
selectionBox.Color3 = Color3.new(255,255,255)
selectionBox.Adornee = nil
selectionBox.Parent = PARENT

local selected = Instance.new("SelectionBox")
selected.Name = randomString()
selected.Color3 = Color3.new(0,166,0)
selected.Adornee = nil
selected.Parent = PARENT

local ActivateHighlight = nil
local ClickSelect = nil
function selectPart()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, 335), "InOut", "Quart", 0.5, true, nil)
	local function HighlightPart()
		if selected.Adornee ~= IYMouse.Target then
			selectionBox.Adornee = IYMouse.Target
		else
			selectionBox.Adornee = nil
		end
	end
	ActivateHighlight = IYMouse.Move:Connect(HighlightPart)
	local function SelectPart()
		if IYMouse.Target ~= nil then
			selected.Adornee = IYMouse.Target
			Path.Text = getHierarchy(IYMouse.Target)
		end
	end
	ClickSelect = IYMouse.Button1Down:Connect(SelectPart)
end

Part.MouseButton1Click:Connect(function()
	selectPart()
end)

Exit_4.MouseButton1Click:Connect(function()
	ToPartFrame:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	if ActivateHighlight then
		ActivateHighlight:Disconnect()
	end
	if ClickSelect then
		ClickSelect:Disconnect()
	end
	selectionBox.Adornee = nil
	selected.Adornee = nil
	Path.Text = ""
end)

CopyPath.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		toClipboard(Path.Text)
	else
		notify('Copy Path','Select a part to copy its path')
	end
end)

ChoosePart.MouseButton1Click:Connect(function()
	if Path.Text ~= "" then
		local tpNameExt = ''
		local function handleWpNames()
			local FoundDupe = false
			for i,v in pairs(pWayPoints) do
				if v.NAME:lower() == selected.Adornee.Name:lower()..tpNameExt then
					FoundDupe = true
				end
			end
			if not FoundDupe then
				notify('Modified Waypoints',"Created waypoint: "..selected.Adornee.Name..tpNameExt)
				pWayPoints[#pWayPoints + 1] = {NAME = selected.Adornee.Name..tpNameExt, COORD = {selected.Adornee}}
			else
				if isNumber(tpNameExt) then
					tpNameExt = tpNameExt+1
				else
					tpNameExt = 1
				end
				handleWpNames()
			end
		end
		handleWpNames()
		refreshwaypoints()
	else
		notify('Part Selection','Select a part first')
	end
end)

cmds={}
customAlias = {}
Delete_3.MouseButton1Click:Connect(function()
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

PrefixBox:GetPropertyChangedSignal("Text"):Connect(function()
	prefix = PrefixBox.Text
	Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
	updatesaves()
end)

function CamViewport()
	if workspace.CurrentCamera then
		return workspace.CurrentCamera.ViewportSize.X
	end
end

function UpdateToViewport()
	if Holder.Position.X.Offset < -CamViewport() then
		Holder:TweenPosition(UDim2.new(1, -CamViewport(), Holder.Position.Y.Scale, Holder.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
		Notification:TweenPosition(UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
	end
end
CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)

function updateCamera(child, parent)
	if parent ~= workspace then
		CamMoved:Disconnect()
		CameraChanged:Disconnect()
		repeat wait() until workspace.CurrentCamera
		CameraChanged = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateToViewport)
		CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)
	end
end
CamMoved = workspace.CurrentCamera.AncestryChanged:Connect(updateCamera)

function dragMain(dragpoint,gui)
	task.spawn(function()
		local dragging
		local dragInput
		local dragStart = Vector3.new(0,0,0)
		local startPos
		local function update(input)
			local pos = -250
			local delta = input.Position - dragStart
			if startPos.X.Offset + delta.X <= -500 then
				local Position = UDim2.new(1, -250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = 250
			else
				local Position = UDim2.new(1, -500, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position}):Play()
				pos = -250
			end
			if startPos.X.Offset + delta.X <= -250 and -CamViewport() <= startPos.X.Offset + delta.X then
				local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + pos, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			elseif startPos.X.Offset + delta.X > -500 then
				local Position = UDim2.new(1, -250, gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
			elseif -CamViewport() > startPos.X.Offset + delta.X then
				gui:TweenPosition(UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset), "InOut", "Quart", 0.04, true, nil)
				local Position = UDim2.new(1, -CamViewport(), gui.Position.Y.Scale, gui.Position.Y.Offset)
				TweenService:Create(gui, TweenInfo.new(.20), {Position = Position}):Play()
				local Position2 = UDim2.new(1, -CamViewport() + 250, Notification.Position.Y.Scale, Notification.Position.Y.Offset)
				TweenService:Create(Notification, TweenInfo.new(.20), {Position = Position2}):Play()
			end
		end
		dragpoint.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		dragpoint.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)
end

dragMain(Title,Holder)

Match = function(name,str)
	str = str:gsub("%W", "%%%1")
	return name:lower():find(str:lower()) and true
end

local canvasPos = Vector2.new(0,0)
local topCommand = nil
local function updateCommandCanvasSize(frame)
	local scale = (Scale and Scale.Scale) or 1
	if scale <= 0 then scale = 1 end
	local contentY = cmdListLayout.AbsoluteContentSize.Y
	local unscaledY = math.ceil(contentY / scale)
	frame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, unscaledY))
end
cmdListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	updateCommandCanvasSize(CMDsF)
end)
IndexContents = function(str,bool,cmdbar,Ianim)
	CMDsF.CanvasPosition = Vector2.new(0,0)
	local SizeY = 0
	local indexnum = 0
	local frame = CMDsF
	topCommand = nil
	local chunks = {}
	if str:sub(#str,#str) == "\\" then str = "" end
	for w in string.gmatch(str,"[^\\]+") do
		table.insert(chunks,w)
	end
	if #chunks > 0 then str = chunks[#chunks] end
	if str:sub(1,1) == "!" then str = str:sub(2) end
	for i,v in next, frame:GetChildren() do
		if v:IsA("TextButton") then
			if bool then
				if Match(v.Text,str) then
					indexnum = indexnum + 1
					v.Visible = true
					if topCommand == nil then
						topCommand = v.Text
					end
				else
					v.Visible = false
				end
			else
				v.Visible = true
				if topCommand == nil then
					topCommand = v.Text
				end
			end
		end
	end
	updateCommandCanvasSize(frame)
	if not Ianim then
		if indexnum == 0 or string.find(str, " ") then
			if not cmdbar then
				minimizeHolder()
			elseif cmdbar then
				cmdbarHolder()
			end
		else
			maximizeHolder()
		end
	else
		minimizeHolder()
	end
end

task.spawn(function()
	if not isLegacyChat then return end
	local chatbox
	local success, result = pcall(function() chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar end)
	if success then
		local function chatboxFocused()
			canvasPos = CMDsF.CanvasPosition
		end
		local chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)

		local function Index()
			if chatbox.Text:lower():sub(1,1) == prefix then
				if SettingsOpen == true then
					wait(0.2)
					CMDsF.Visible = true
					Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
				end
				IndexContents(PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar.Text:lower():sub(2),true)
			else
				minimizeHolder()
				if SettingsOpen == true then
					wait(0.2)
					Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
					CMDsF.Visible = false
				end
			end
		end
		local chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)

		local function chatboxFocusLost(enterpressed)
			if not enterpressed or chatbox.Text:lower():sub(1,1) ~= prefix then
				IndexContents('',true)
			end
			CMDsF.CanvasPosition = canvasPos
			minimizeHolder()
		end
		local chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)

		PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.ChildAdded:Connect(function(newbar)
			wait()
			if newbar:FindFirstChild('BoxFrame') then
				chatbox = PlayerGui:WaitForChild("Chat").Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
				if chatboxFocusedC then chatboxFocusedC:Disconnect() end
				chatboxFocusedC = chatbox.Focused:Connect(chatboxFocused)
				if chatboxFunc then chatboxFunc:Disconnect() end
				chatboxFunc = chatbox:GetPropertyChangedSignal("Text"):Connect(Index)
				if chatboxFocusLostC then chatboxFocusLostC:Disconnect() end
				chatboxFocusLostC = chatbox.FocusLost:Connect(chatboxFocusLost)
			end
		end)
		--else
		--print('Custom chat detected. Will not provide suggestions for commands typed in the chat.')
	end
end)

function autoComplete(str,curText)
	local endingChar = {"[", "/", "(", " "}
	local stop = 0
	for i=1,#str do
		local c = str:sub(i,i)
		if table.find(endingChar, c) then
			stop = i
			break
		end
	end
	curText = curText or Cmdbar.Text
	local subPos = 0
	local pos = 1
	local findRes = string.find(curText,"\\",pos)
	while findRes do
		subPos = findRes
		pos = findRes+1
		findRes = string.find(curText,"\\",pos)
	end
	if curText:sub(subPos+1,subPos+1) == "!" then subPos = subPos + 1 end
	Cmdbar.Text = curText:sub(1,subPos) .. str:sub(1, stop - 1)..' '
	RunService.RenderStepped:Wait()
	Cmdbar.Text = Cmdbar.Text:gsub( '\t', '' )
	Cmdbar.CursorPosition = #Cmdbar.Text+1--1020
end

CMDs = {}
CMDs[#CMDs + 1] = {NAME = 'discord / support / help', DESC = 'Invite to the original Infinite Yield Discord server (credit to the IY team).'}
CMDs[#CMDs + 1] = {NAME = 'guiscale [number]', DESC = 'Changes the size of the GUI. [number] accepts decimals and whole numbers. Min is 0.4 and Max is 2'}
CMDs[#CMDs + 1] = {NAME = 'console', DESC = 'Opens the Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'oldconsole', DESC = 'Loads an old-themed Roblox console'}
CMDs[#CMDs + 1] = {NAME = 'explorer / dex', DESC = 'Opens Dex++ by Chillz'}
CMDs[#CMDs + 1] = {NAME = 'moondex / mdex', DESC = 'Opens Dex by Moon'}
CMDs[#CMDs + 1] = {NAME = 'remotespy / rspy', DESC = 'Opens Cobalt to intercept incoming and outgoing network traffic'}
CMDs[#CMDs + 1] = {NAME = 'simplespy / sspy', DESC = 'Opens Simple Spy V3 to intercept remote calls from the client to the server'}
CMDs[#CMDs + 1] = {NAME = 'audiologger / alogger', DESC = 'Opens Edges audio logger'}
CMDs[#CMDs + 1] = {NAME = 'serverinfo / info', DESC = 'Gives you info about the server'}
CMDs[#CMDs + 1] = {NAME = 'jobid', DESC = 'Copies the games JobId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'notifyjobid', DESC = 'Notifies you the games JobId'}
CMDs[#CMDs + 1] = {NAME = 'rejoin / rj [reposition]', DESC = 'Makes you rejoin the game'}
CMDs[#CMDs + 1] = {NAME = 'inviteprompt [player]', DESC = 'Prompts the user of your choice that they had invited you. Requires a rejoin to function.'}
CMDs[#CMDs + 1] = {NAME = 'autorejoin / autorj', DESC = 'Automatically rejoins the server if you get kicked/disconnected'}
CMDs[#CMDs + 1] = {NAME = 'serverhop / shop', DESC = 'Teleports you to a different server'}
CMDs[#CMDs + 1] = {NAME = 'gameteleport / gametp [place ID]', DESC = 'Joins a game by ID'}
CMDs[#CMDs + 1] = {NAME = 'antiidle / antiafk', DESC = 'Prevents the game from kicking you for being idle/AFK'}
CMDs[#CMDs + 1] = {NAME = 'datalimit [num]', DESC = 'Sets outgoing KBPS limit'}
CMDs[#CMDs + 1] = {NAME = 'replicationlag / backtrack [num]', DESC = 'Sets IncomingReplicationLag'}
CMDs[#CMDs + 1] = {NAME = 'creatorid / creator', DESC = 'Notifies you the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'copycreatorid / copycreator', DESC = 'Copies the creators UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'setcreatorid / setcreator', DESC = 'Sets your UserId to the creators UserId'}
CMDs[#CMDs + 1] = {NAME = 'noprompts', DESC = 'Prevents the game from showing you purchase/premium prompts'}
CMDs[#CMDs + 1] = {NAME = 'showprompts', DESC = 'Allows the game to show purchase/premium prompts again'}
CMDs[#CMDs + 1] = {NAME = 'enable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'disable [inventory/playerlist/chat/reset/emotes/all]', DESC = 'Toggles visibility of CoreGui items'}
CMDs[#CMDs + 1] = {NAME = 'showguis', DESC = 'Shows any invisible GUIs'}
CMDs[#CMDs + 1] = {NAME = 'unshowguis', DESC = 'Undoes showguis'}
CMDs[#CMDs + 1] = {NAME = 'hideguis', DESC = 'Hides any GUIs in PlayerGui'}
CMDs[#CMDs + 1] = {NAME = 'unhideguis', DESC = 'Undoes hideguis'}
CMDs[#CMDs + 1] = {NAME = 'guidelete', DESC = 'Enables backspace to delete GUI'}
CMDs[#CMDs + 1] = {NAME = 'unguidelete / noguidelete', DESC = 'Disables guidelete'}
CMDs[#CMDs + 1] = {NAME = 'hideiy', DESC = 'Hides the main IY GUI'}
CMDs[#CMDs + 1] = {NAME = 'showiy / unhideiy', DESC = 'Shows IY again'}
CMDs[#CMDs + 1] = {NAME = 'keepiy', DESC = 'Auto execute KizzDev when you teleport through servers'}
CMDs[#CMDs + 1] = {NAME = 'unkeepiy', DESC = 'Disables keepiy'}
CMDs[#CMDs + 1] = {NAME = 'togglekeepiy', DESC = 'Toggles keepiy'}
CMDs[#CMDs + 1] = {NAME = 'removeads / adblock', DESC = 'Automatically removes ad billboards'}
CMDs[#CMDs + 1] = {NAME = 'savegame / saveplace', DESC = 'Saves the game you are in to a file'}
CMDs[#CMDs + 1] = {NAME = 'clearerror', DESC = 'Clears the annoying box and blur when a game kicks you'}
CMDs[#CMDs + 1] = {NAME = 'antigameplaypaused', DESC = 'Clears the annoying box shown when a game is loading assets due to network lag'}
CMDs[#CMDs + 1] = {NAME = 'unantigameplaypaused', DESC = 'Disables antigameplaypaused'}
CMDs[#CMDs + 1] = {NAME = 'clientantikick / antikick (CLIENT)', DESC = 'Prevents LocalScripts from kicking you'}
CMDs[#CMDs + 1] = {NAME = 'clientantiteleport / antiteleport (CLIENT)', DESC = 'Prevents LocalScripts from teleporting you'}
CMDs[#CMDs + 1] = {NAME = 'allowrejoin / allowrj (CLIENT)', DESC = 'Toggles if antiteleport allows you to rejoin or not'}
CMDs[#CMDs + 1] = {NAME = 'cancelteleport / canceltp', DESC = 'Cancels teleports in progress'}
CMDs[#CMDs + 1] = {NAME = 'volume / vol [0-10]', DESC = 'Adjusts your game volume on a scale of 0 to 10'}
CMDs[#CMDs + 1] = {NAME = 'antilag / boostfps / lowgraphics', DESC = 'Lowers game quality in an attempt to boost FPS'}
CMDs[#CMDs + 1] = {NAME = 'setfpscap / fpscap / maxfps', DESC = 'Sets FPS cap'}
CMDs[#CMDs + 1] = {NAME = 'record / rec', DESC = 'Starts Roblox recorder'}
CMDs[#CMDs + 1] = {NAME = 'screenshot / scrnshot', DESC = 'Takes a screenshot'}
CMDs[#CMDs + 1] = {NAME = 'togglefullscreen / togglefs', DESC = 'Toggles fullscreen'}
CMDs[#CMDs + 1] = {NAME = 'notify [text]', DESC = 'Sends you a notification with the provided text'}
CMDs[#CMDs + 1] = {NAME = 'lastcommand / lastcmd', DESC = 'Executes the previous command used'}
CMDs[#CMDs + 1] = {NAME = 'notifyping / ping', DESC = 'Notify yourself your ping'}
CMDs[#CMDs + 1] = {NAME = 'norender', DESC = 'Disables 3D Rendering to decrease the amount of CPU the client uses'}
CMDs[#CMDs + 1] = {NAME = 'render', DESC = 'Enables 3D Rendering'}
CMDs[#CMDs + 1] = {NAME = '2022materials / use2022materials', DESC = 'Enables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'un2022materials / unuse2022materials', DESC = 'Disables 2022 material textures'}
CMDs[#CMDs + 1] = {NAME = 'alignmentkeys', DESC = 'Enables the left and right alignment keys (comma and period)'}
CMDs[#CMDs + 1] = {NAME = 'unalignmentkeys / noalignmentkeys', DESC = 'Disables the alignment keys'}
CMDs[#CMDs + 1] = {NAME = 'ctrllock', DESC = 'Binds Shiftlock to LeftControl'}
CMDs[#CMDs + 1] = {NAME = 'unctrllock', DESC = 'Re-binds Shiftlock to LeftShift'}
CMDs[#CMDs + 1] = {NAME = 'exit / shutdown / leave', DESC = 'Exits the game'}
CMDs[#CMDs + 1] = {NAME = 'removecmd / deletecmd', DESC = 'Removes a command until the script is reloaded'}
CMDs[#CMDs + 1] = {NAME = 'breakloops / break (cmd loops)', DESC = 'Stops any cmd loops (;100^1^cmd)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'noclip', DESC = 'Go through objects'}
CMDs[#CMDs + 1] = {NAME = 'unnoclip / clip', DESC = 'Disables noclip'}
CMDs[#CMDs + 1] = {NAME = 'togglenoclip', DESC = 'Toggles noclip'}
CMDs[#CMDs + 1] = {NAME = 'fly [speed]', DESC = 'Makes you fly'}
CMDs[#CMDs + 1] = {NAME = 'unfly', DESC = 'Disables fly'}
CMDs[#CMDs + 1] = {NAME = 'togglefly', DESC = 'Toggles fly'}
CMDs[#CMDs + 1] = {NAME = 'flyspeed [num]', DESC = 'Set fly speed (default is 20)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclefly / vfly [speed]', DESC = 'Makes you fly in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'unvehiclefly / unvfly', DESC = 'Disables vehicle fly'}
CMDs[#CMDs + 1] = {NAME = 'vehicleflyspeed / vflyspeed [num]', DESC = 'Set vehicle fly speed'}
CMDs[#CMDs + 1] = {NAME = 'cframefly / cfly [speed]', DESC = 'Makes you fly, bypassing some anti cheats (works on mobile)'}
CMDs[#CMDs + 1] = {NAME = 'uncframefly / uncfly', DESC = 'Disables cfly'}
CMDs[#CMDs + 1] = {NAME = 'cframeflyspeed / cflyspeed [num]', DESC = 'Sets cfly speed'}
CMDs[#CMDs + 1] = {NAME = 'qefly [true / false]', DESC = 'Enables or disables the Q and E hotkeys for fly'}
CMDs[#CMDs + 1] = {NAME = 'vehiclenoclip / vnoclip', DESC = 'Turns off vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'vehicleclip / vclip / unvnoclip', DESC = 'Enables vehicle collision'}
CMDs[#CMDs + 1] = {NAME = 'float / platform', DESC = 'Spawns a platform beneath you causing you to float'}
CMDs[#CMDs + 1] = {NAME = 'unfloat / noplatform', DESC = 'Removes the platform'}
CMDs[#CMDs + 1] = {NAME = 'togglefloat', DESC = 'Toggles float'}
CMDs[#CMDs + 1] = {NAME = 'swim', DESC = 'Allows you to swim in the air'}
CMDs[#CMDs + 1] = {NAME = 'unswim / noswim', DESC = 'Stops you from swimming everywhere'}
CMDs[#CMDs + 1] = {NAME = 'toggleswim', DESC = 'Toggles swimming'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'setwaypoint / swp [name]', DESC = 'Sets a waypoint at your position'}
CMDs[#CMDs + 1] = {NAME = 'waypointpos / wpp [name] [X Y Z]', DESC = 'Sets a waypoint with specified coordinates'}
CMDs[#CMDs + 1] = {NAME = 'waypoints', DESC = 'Shows a list of currently active waypoints'}
CMDs[#CMDs + 1] = {NAME = 'showwaypoints / showwp', DESC = 'Shows all currently set waypoints'}
CMDs[#CMDs + 1] = {NAME = 'hidewaypoints / hidewp', DESC = 'Hides shown waypoints'}
CMDs[#CMDs + 1] = {NAME = 'waypoint / wp [name]', DESC = 'Teleports player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'tweenwaypoint / twp [name]', DESC = 'Tweens player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'walktowaypoint / wtwp [name]', DESC = 'Walks player to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'deletewaypoint / dwp [name]', DESC = 'Deletes a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'clearwaypoints / cwp', DESC = 'Clears all waypoints'}
CMDs[#CMDs + 1] = {NAME = 'cleargamewaypoints / cgamewp', DESC = 'Clears all waypoints for the game you are in'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'goto [player] [request stream]', DESC = 'Go to a player'}
CMDs[#CMDs + 1] = {NAME = 'tweengoto / tgoto [player]', DESC = 'Tween to a player (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'tweenspeed / tspeed [num]', DESC = 'Sets how fast all tween commands go (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'vehiclegoto / vgoto [player]', DESC = 'Go to a player while in a vehicle'}
CMDs[#CMDs + 1] = {NAME = 'loopgoto [player] [distance] [delay]', DESC = 'Loop teleport to a player'}
CMDs[#CMDs + 1] = {NAME = 'unloopgoto', DESC = 'Stops teleporting you to a player'}
CMDs[#CMDs + 1] = {NAME = 'pulsetp / ptp [player] [seconds]', DESC = 'Teleports you to a player for a specified amount of time'}
CMDs[#CMDs + 1] = {NAME = 'clientbring / cbring [player] (CLIENT)', DESC = 'Bring a player'}
CMDs[#CMDs + 1] = {NAME = 'loopbring [player] [distance] [delay] (CLIENT)', DESC = 'Loop brings a player to you (useful for killing)'}
CMDs[#CMDs + 1] = {NAME = 'unloopbring [player]', DESC = 'Undoes loopbring'}
CMDs[#CMDs + 1] = {NAME = 'freeze / fr [player] (CLIENT)', DESC = 'Freezes a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeanims', DESC = 'Freezes your animations / pauses your animations - Does not work on default animations'}
CMDs[#CMDs + 1] = {NAME = 'unfreezeanims', DESC = 'Unfreezes your animations / plays your animations'}
CMDs[#CMDs + 1] = {NAME = 'thaw / unfr [player] (CLIENT)', DESC = 'Unfreezes a player'}
CMDs[#CMDs + 1] = {NAME = 'anchor', DESC = 'Anchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'unanchor', DESC = 'Unanchors your characters RootPart'}
CMDs[#CMDs + 1] = {NAME = 'tpposition / tppos [X Y Z]', DESC = 'Teleports you to certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweentpposition / ttppos [X Y Z]', DESC = 'Tween to coordinates (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'offset [X Y Z]', DESC = 'Offsets you by certain coordinates'}
CMDs[#CMDs + 1] = {NAME = 'tweenoffset / toffset [X Y Z]', DESC = 'Tween offset (bypasses some anti cheats)'}
CMDs[#CMDs + 1] = {NAME = 'thru [num]', DESC = 'Teleports you [num] studs ahead of where your character is facing'}
CMDs[#CMDs + 1] = {NAME = 'notifyposition / notifypos [player]', DESC = 'Notifies you the coordinates of a character'}
CMDs[#CMDs + 1] = {NAME = 'copyposition / copypos [player]', DESC = 'Copies the coordinates of a character to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'walktoposition / walktopos [X Y Z]', DESC = 'Makes you walk to a coordinate'}
CMDs[#CMDs + 1] = {NAME = 'spawnpoint / spawn [delay]', DESC = 'Sets a position where you will spawn'}
CMDs[#CMDs + 1] = {NAME = 'nospawnpoint / nospawn', DESC = 'Removes your custom spawn point'}
CMDs[#CMDs + 1] = {NAME = 'flashback / diedtp', DESC = 'Teleports you to where you last died'}
CMDs[#CMDs + 1] = {NAME = 'walltp', DESC = 'Teleports you above/over any wall you run into'}
CMDs[#CMDs + 1] = {NAME = 'nowalltp / unwalltp', DESC = 'Disables walltp'}
CMDs[#CMDs + 1] = {NAME = 'teleporttool / tptool', DESC = 'Gives you a teleport tool'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'logs', DESC = 'Opens the logs GUI'}
CMDs[#CMDs + 1] = {NAME = 'chatlogs / clogs', DESC = 'Log what people say or whisper'}
CMDs[#CMDs + 1] = {NAME = 'joinlogs / jlogs', DESC = 'Log when people join'}
CMDs[#CMDs + 1] = {NAME = 'chatlogswebhook / logswebhook [url]', DESC = 'Set a Discord webhook for chatlogs to go to (provide no URL to disable this)'}
CMDs[#CMDs + 1] = {NAME = 'chat / say [text]', DESC = 'Makes you chat a string (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'vsay [text]', DESC = 'Say anything uncensored (CLIENT)'}
CMDs[#CMDs + 1] = {NAME = 'spam [text]', DESC = 'Makes you spam the chat'}
CMDs[#CMDs + 1] = {NAME = 'unspam / nospam', DESC = 'Turns off spam'}
CMDs[#CMDs + 1] = {NAME = 'whisper / pm [player] [text]', DESC = 'Makes you whisper a string to someone (possible mute bypass)'}
CMDs[#CMDs + 1] = {NAME = 'pmspam [player] [text]', DESC = 'Makes you spam a players whispers'}
CMDs[#CMDs + 1] = {NAME = 'unpmspam / nopmspam [player]', DESC = 'Turns off pm spam'}
CMDs[#CMDs + 1] = {NAME = 'spamspeed [num]', DESC = 'How quickly you spam (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'bubblechat (CLIENT)', DESC = 'Enables bubble chat for your client'}
CMDs[#CMDs + 1] = {NAME = 'unbubblechat / nobubblechat', DESC = 'Disables the bubblechat command'}
CMDs[#CMDs + 1] = {NAME = 'chatwindow', DESC = 'Enables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'unchatwindow / nochatwindow', DESC = 'Disables the chat window for your client'}
CMDs[#CMDs + 1] = {NAME = 'darkchat', DESC = 'Makes the chat window dark for your client'}
CMDs[#CMDs + 1] = {NAME = 'listento [player]', DESC = 'Listens to the area around a player. Can also eavesdrop with voice chat'}
CMDs[#CMDs + 1] = {NAME = 'unlistento', DESC = 'Disables listento'}
CMDs[#CMDs + 1] = {NAME = 'muteallvoices / muteallvcs', DESC = 'Mutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'unmuteallvoices / unmuteallvcs', DESC = 'Unmutes voice chat for all players'}
CMDs[#CMDs + 1] = {NAME = 'mutevc [player]', DESC = 'Mutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'unmutevc [player]', DESC = 'Unmutes the voice chat of a player'}
CMDs[#CMDs + 1] = {NAME = 'phonebook / call', DESC = 'Prompts the Roblox phonebook UI to let you call your friends. Needs voice chat enabled'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'esp', DESC = 'View all players and their status'}
CMDs[#CMDs + 1] = {NAME = 'espteam', DESC = 'ESP but teammates are green and bad guys are red'}
CMDs[#CMDs + 1] = {NAME = 'noesp / unesp / unespteam', DESC = 'Removes ESP'}
CMDs[#CMDs + 1] = {NAME = 'esptransparency [number]', DESC = 'Changes the transparency of ESP related commands'}
CMDs[#CMDs + 1] = {NAME = 'partesp [part name]', DESC = 'Highlights a part'}
CMDs[#CMDs + 1] = {NAME = 'unpartesp / nopartesp [part name]', DESC = 'removes partesp'}
CMDs[#CMDs + 1] = {NAME = 'chams', DESC = 'ESP but without text in the way'}
CMDs[#CMDs + 1] = {NAME = 'nochams / unchams', DESC = 'Removes chams'}
CMDs[#CMDs + 1] = {NAME = 'locate [player]', DESC = 'View a single player and their status'}
CMDs[#CMDs + 1] = {NAME = 'unlocate / nolocate [player]', DESC = 'Removes locate'}
CMDs[#CMDs + 1] = {NAME = 'xray', DESC = 'Makes all parts in workspace transparent'}
CMDs[#CMDs + 1] = {NAME = 'unxray / noxray', DESC = 'Restores transparency to all parts in workspace'}
CMDs[#CMDs + 1] = {NAME = 'loopxray', DESC = 'Makes all parts in workspace transparent but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopxray', DESC = 'Unloops xray'}
CMDs[#CMDs + 1] = {NAME = 'togglexray', DESC = 'Toggles xray'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'view / spectate [player]', DESC = 'View a player'}
CMDs[#CMDs + 1] = {NAME = 'viewpart / viewp [part name]', DESC = 'View a part'}
CMDs[#CMDs + 1] = {NAME = 'unview / unspectate', DESC = 'Stops viewing player/part'}
CMDs[#CMDs + 1] = {NAME = 'freecam / fcam / fc', DESC = 'Allows you to freely move camera around the game'}
CMDs[#CMDs + 1] = {NAME = 'freecampos / fcpos [X Y Z]', DESC = 'Moves / opens freecam in a certain position'}
CMDs[#CMDs + 1] = {NAME = 'freecamwaypoint / fcwp [name]', DESC = 'Moves / opens freecam to a waypoint'}
CMDs[#CMDs + 1] = {NAME = 'freecamgoto / fcgoto / fctp [player]', DESC = 'Moves / opens freecam to a player'}
CMDs[#CMDs + 1] = {NAME = 'unfreecam / unfc', DESC = 'Disables freecam'}
CMDs[#CMDs + 1] = {NAME = 'freecamspeed / fcspeed [num]', DESC = 'Adjusts freecam speed (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'notifyfreecamposition / notifyfcpos', DESC = 'Noitifies you your freecam coordinates'}
CMDs[#CMDs + 1] = {NAME = 'copyfreecamposition / copyfcpos', DESC = 'Copies your freecam coordinates to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'gotocamera / gotocam', DESC = 'Teleports you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'tweengotocam / tgotocam', DESC = 'Tweens you to the location of your camera'}
CMDs[#CMDs + 1] = {NAME = 'firstp', DESC = 'Forces camera to go into first person'}
CMDs[#CMDs + 1] = {NAME = 'thirdp', DESC = 'Allows camera to go into third person'}
CMDs[#CMDs + 1] = {NAME = 'noclipcam / nccam', DESC = 'Allows camera to go through objects like walls'}
CMDs[#CMDs + 1] = {NAME = 'maxzoom [num]', DESC = 'Sets maximum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'minzoom [num]', DESC = 'Sets minimum camera zoom'}
CMDs[#CMDs + 1] = {NAME = 'camdistance [num]', DESC = 'Changes camera distance from your player'}
CMDs[#CMDs + 1] = {NAME = 'fov [num]', DESC = 'Adjusts field of view (default is 70)'}
CMDs[#CMDs + 1] = {NAME = 'fixcam / restorecam', DESC = 'Fixes camera'}
CMDs[#CMDs + 1] = {NAME = 'enableshiftlock / enablesl', DESC = 'Enables the shift lock option'}
CMDs[#CMDs + 1] = {NAME = 'lookat [player]', DESC = 'Moves your camera view to a player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'btools (CLIENT)', DESC = 'Gives you building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'f3x (CLIENT)', DESC = 'Gives you F3X building tools (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'partname / partpath', DESC = 'Allows you to click a part to see its path & name'}
CMDs[#CMDs + 1] = {NAME = 'delete [instance name] (CLIENT)', DESC = 'Removes any part with a certain name from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'deleteclass / dc [class name] (CLIENT)', DESC = 'Removes any part with a certain classname from the workspace (DOES NOT REPLICATE)'}
CMDs[#CMDs + 1] = {NAME = 'lockworkspace / lockws', DESC = 'Locks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'unlockworkspace / unlockws', DESC = 'Unlocks the whole workspace'}
CMDs[#CMDs + 1] = {NAME = 'invisibleparts / invisparts (CLIENT)', DESC = 'Shows invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'uninvisibleparts / uninvisparts (CLIENT)', DESC = 'Makes parts affected by invisparts return to normal'}
CMDs[#CMDs + 1] = {NAME = 'deleteinvisparts / dip (CLIENT)', DESC = 'Deletes invisible parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopart [part name]', DESC = 'Moves your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopart / tgotopart [part name]', DESC = 'Tweens your character to a part or multiple parts'}
CMDs[#CMDs + 1] = {NAME = 'gotopartclass / gpc [class name]', DESC = 'Moves your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'tweengotopartclass / tgpc [class name]', DESC = 'Tweens your character to a part or multiple parts based on classname'}
CMDs[#CMDs + 1] = {NAME = 'gotomodel [part name]', DESC = 'Moves your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'tweengotomodel / tgotomodel [part name]', DESC = 'Tweens your character to a model or multiple models'}
CMDs[#CMDs + 1] = {NAME = 'gotopartdelay / gotomodeldelay [num]', DESC = 'Adjusts how quickly you teleport to each part (default is 0.1)'}
CMDs[#CMDs + 1] = {NAME = 'bringpart [part name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character'}
CMDs[#CMDs + 1] = {NAME = 'bringpartclass / bpc [class name] (CLIENT)', DESC = 'Moves a part or multiple parts to your character based on classname'}
CMDs[#CMDs + 1] = {NAME = 'noclickdetectorlimits / nocdlimits', DESC = 'Sets all click detectors MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireclickdetectors / firecd [name]', DESC = 'Uses all click detectors in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'firetouchinterests / touchinterests [name]', DESC = 'Uses all touchinterests in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'noproximitypromptlimits / nopplimits', DESC = 'Sets all proximity prompts MaxActivationDistance to math.huge'}
CMDs[#CMDs + 1] = {NAME = 'fireproximityprompts / firepp [name]', DESC = 'Uses all proximity prompts in a game or uses the optional name'}
CMDs[#CMDs + 1] = {NAME = 'instantproximityprompts / instantpp', DESC = 'Disable the cooldown for proximity prompts'}
CMDs[#CMDs + 1] = {NAME = 'uninstantproximityprompts / uninstantpp', DESC = 'Undo the cooldown removal'}
CMDs[#CMDs + 1] = {NAME = 'tpunanchored / tpua [player]', DESC = 'Teleports unanchored parts to a player'}
CMDs[#CMDs + 1] = {NAME = 'freezeunanchored / freezeua', DESC = 'Freezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'thawunanchored / thawua / unfreezeua', DESC = 'Unfreezes unanchored parts'}
CMDs[#CMDs + 1] = {NAME = 'removeterrain / rterrain / noterrain', DESC = 'Removes all terrain'}
CMDs[#CMDs + 1] = {NAME = 'clearnilinstances / nonilinstances / cni', DESC = 'Removes nil instances'}
CMDs[#CMDs + 1] = {NAME = 'destroyheight / dh [num]', DESC = 'Sets FallenPartsDestroyHeight'}
CMDs[#CMDs + 1] = {NAME = 'fakeout', DESC = 'Tp to the void and then back (useful to kill people attached to you)'}
CMDs[#CMDs + 1] = {NAME = 'antivoid', DESC = 'Prevents you from falling into the void by launching you upwards'}
CMDs[#CMDs + 1] = {NAME = 'unantivoid / noantivoid', DESC = 'Disables antivoid'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'fullbright / fb (CLIENT)', DESC = 'Makes the map brighter / more visible'}
CMDs[#CMDs + 1] = {NAME = 'loopfullbright / loopfb (CLIENT)', DESC = 'Makes the map brighter / more visible but looped'}
CMDs[#CMDs + 1] = {NAME = 'unloopfullbright / unloopfb', DESC = 'Unloops fullbright'}
CMDs[#CMDs + 1] = {NAME = 'ambient [num] [num] [num] (CLIENT)', DESC = 'Changes ambient'}
CMDs[#CMDs + 1] = {NAME = 'day (CLIENT)', DESC = 'Changes the time to day for the client'}
CMDs[#CMDs + 1] = {NAME = 'night (CLIENT)', DESC = 'Changes the time to night for the client'}
CMDs[#CMDs + 1] = {NAME = 'nofog (CLIENT)', DESC = 'Removes fog'}
CMDs[#CMDs + 1] = {NAME = 'brightness [num] (CLIENT)', DESC = 'Changes the brightness lighting property'}
CMDs[#CMDs + 1] = {NAME = 'globalshadows / gshadows (CLIENT)', DESC = 'Enables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'unglobalshadows / ungshadows (CLIENT)', DESC = 'Disables global shadows'}
CMDs[#CMDs + 1] = {NAME = 'restorelighting / rlighting', DESC = 'Restores Lighting properties'}
CMDs[#CMDs + 1] = {NAME = 'light [radius] [brightness] (CLIENT)', DESC = 'Gives your player dynamic light'}
CMDs[#CMDs + 1] = {NAME = 'nolight / unlight', DESC = 'Removes dynamic light from your player'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'inspect / examine [player]', DESC = 'Opens InspectMenu for a certain player'}
CMDs[#CMDs + 1] = {NAME = 'age [player]', DESC = 'Tells you the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'chatage [player]', DESC = 'Chats the age of a player'}
CMDs[#CMDs + 1] = {NAME = 'joindate / jd [player]', DESC = 'Tells you the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'chatjoindate / cjd [player]', DESC = 'Chats the date the player joined Roblox'}
CMDs[#CMDs + 1] = {NAME = 'copyname / copyuser [player]', DESC = 'Copies a players full username to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'userid / id [player]', DESC = 'Notifies a players UserId'}
CMDs[#CMDs + 1] = {NAME = 'copyplaceid / placeid', DESC = 'Copies the current PlaceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copygameid / gameid', DESC = 'Copies the current GameId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'copyuserid / copyid [player]', DESC = 'Copies a players UserId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'appearanceid / aid [player]', DESC = 'Notifies a players AppearanceId'}
CMDs[#CMDs + 1] = {NAME = 'copyappearanceid / caid [player]', DESC = 'Copies a players AppearanceId to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'bang [player] [speed]', DESC = 'owo'}
CMDs[#CMDs + 1] = {NAME = 'unbang', DESC = 'uwu'}
CMDs[#CMDs + 1] = {NAME = 'jerk', DESC = 'Makes you jork it'}
CMDs[#CMDs + 1] = {NAME = 'scare / spook [player]', DESC = 'Teleports in front of a player for half a second'}
CMDs[#CMDs + 1] = {NAME = 'carpet [player]', DESC = 'Be someones carpet'}
CMDs[#CMDs + 1] = {NAME = 'uncarpet', DESC = 'Undoes carpet'}
CMDs[#CMDs + 1] = {NAME = 'friend [player]', DESC = 'Sends a friend request to certain players'}
CMDs[#CMDs + 1] = {NAME = 'unfriend [player]', DESC = 'Unfriends certain players'}
CMDs[#CMDs + 1] = {NAME = 'headsit [player]', DESC = 'Sit on a players head'}
CMDs[#CMDs + 1] = {NAME = 'walkto / follow [player]', DESC = 'Follow a player'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalkto / pathfindfollow [player]', DESC = 'Follow a player using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'pathfindwalktowaypoint / pathfindwalktowp [waypoint]', DESC = 'Walk to a waypoint using pathfinding'}
CMDs[#CMDs + 1] = {NAME = 'unwalkto / unfollow', DESC = 'Stops following a player'}
CMDs[#CMDs + 1] = {NAME = 'orbit [player] [speed] [distance]', DESC = 'Makes your character orbit around a player with an optional speed and an optional distance'}
CMDs[#CMDs + 1] = {NAME = 'unorbit', DESC = 'Disables orbit'}
CMDs[#CMDs + 1] = {NAME = 'stareat / stare [player]', DESC = 'Stare / look at a player'}
CMDs[#CMDs + 1] = {NAME = 'unstareat / unstare [player]', DESC = 'Disables stareat'}
CMDs[#CMDs + 1] = {NAME = 'rolewatch [group id] [role name]', DESC = 'Notify if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchstop / unrolewatch', DESC = 'Disable Rolewatch'}
CMDs[#CMDs + 1] = {NAME = 'rolewatchleave', DESC = 'Toggle if you should leave the game if someone from a watched group joins the server'}
CMDs[#CMDs + 1] = {NAME = 'staffwatch', DESC = 'Notify if a staff member of the game joins the server'}
CMDs[#CMDs + 1] = {NAME = 'unstaffwatch', DESC = 'Disable Staffwatch'}
CMDs[#CMDs + 1] = {NAME = 'findfriendgroups', DESC = 'Notifies you if any players are friends with each other'}
CMDs[#CMDs + 1] = {NAME = 'handlekill / hkill [player] [radius] (TOOL)', DESC = 'Kills a player using tool damage (YOU NEED A TOOL)'}
CMDs[#CMDs + 1] = {NAME = 'fling', DESC = 'Flings anyone you touch'}
CMDs[#CMDs + 1] = {NAME = 'unfling', DESC = 'Disables the fling command'}
CMDs[#CMDs + 1] = {NAME = 'flyfling [speed]', DESC = 'Basically the invisfling command but not invisible'}
CMDs[#CMDs + 1] = {NAME = 'unflyfling', DESC = 'Disables the flyfling command'}
CMDs[#CMDs + 1] = {NAME = 'walkfling', DESC = 'Basically fling but no spinning'}
CMDs[#CMDs + 1] = {NAME = 'unwalkfling / nowalkfling', DESC = 'Disables walkfling'}
CMDs[#CMDs + 1] = {NAME = 'invisfling', DESC = 'Enables invisible fling (the invis part is patched, try using the god command before using this)'}
CMDs[#CMDs + 1] = {NAME = 'antifling', DESC = 'Disables player collisions to prevent you from being flung'}
CMDs[#CMDs + 1] = {NAME = 'unantifling', DESC = 'Disables antifling'}
CMDs[#CMDs + 1] = {NAME = 'loopoof', DESC = 'Loops everyones character sounds (everyone can hear)'}
CMDs[#CMDs + 1] = {NAME = 'unloopoof', DESC = 'Stops the oof chaos'}
CMDs[#CMDs + 1] = {NAME = 'muteboombox [player]', DESC = 'Mutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'unmuteboombox [player]', DESC = 'Unmutes someones boombox'}
CMDs[#CMDs + 1] = {NAME = 'hitboxes', DESC = 'Shows all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'unhitboxes', DESC = 'Stops showing all rendered bounding boxes'}
CMDs[#CMDs + 1] = {NAME = 'hitbox [player] [size] [transparency]', DESC = 'Expands the hitbox for players HumanoidRootPart (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'headsize [player] [size]', DESC = 'Expands the head size for players Head (default is 1)'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'reset', DESC = 'Resets your character normally'}
CMDs[#CMDs + 1] = {NAME = 'respawn', DESC = 'Respawns you'}
CMDs[#CMDs + 1] = {NAME = 'refresh / re', DESC = 'Respawns and brings you back to the same position'}
CMDs[#CMDs + 1] = {NAME = 'god', DESC = 'Makes your character difficult to kill in most games'}
CMDs[#CMDs + 1] = {NAME = 'invisible / invis', DESC = 'Makes you invisible to other players'}
CMDs[#CMDs + 1] = {NAME = 'visible / vis', DESC = 'Makes you visible to other players'}
CMDs[#CMDs + 1] = {NAME = 'toolinvisible / toolinvis / tinvis', DESC = 'Makes you invisible to other players and able to use tools'}
CMDs[#CMDs + 1] = {NAME = 'speed / ws / walkspeed [num]', DESC = 'Change your walkspeed (default is 16)'}
CMDs[#CMDs + 1] = {NAME = 'spoofspeed / spoofws [num]', DESC = 'Spoofs your WalkSpeed on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopspeed / loopws [num]', DESC = 'Loops your walkspeed'}
CMDs[#CMDs + 1] = {NAME = 'unloopspeed / unloopws', DESC = 'Turns off loopspeed'}
CMDs[#CMDs + 1] = {NAME = 'hipheight / hheight [num]', DESC = 'Adjusts hip height'}
CMDs[#CMDs + 1] = {NAME = 'jumppower / jpower / jp [num]', DESC = 'Change a players jump height (default is 50)'}
CMDs[#CMDs + 1] = {NAME = 'spoofjumppower / spoofjp [num]', DESC = 'Spoofs your JumpPower on the Client'}
CMDs[#CMDs + 1] = {NAME = 'loopjumppower / loopjp [num]', DESC = 'Loops your jump height'}
CMDs[#CMDs + 1] = {NAME = 'unloopjumppower / unloopjp', DESC = 'Turns off loopjumppower'}
CMDs[#CMDs + 1] = {NAME = 'maxslopeangle / msa [num]', DESC = 'Adjusts MaxSlopeAngle'}
CMDs[#CMDs + 1] = {NAME = 'gravity / grav [num] (CLIENT)', DESC = 'Change your gravity'}
CMDs[#CMDs + 1] = {NAME = 'sit', DESC = 'Makes your character sit'}
CMDs[#CMDs + 1] = {NAME = 'lay / laydown', DESC = 'Makes your character lay down'}
CMDs[#CMDs + 1] = {NAME = 'sitwalk', DESC = 'Makes your character sit while still being able to walk'}
CMDs[#CMDs + 1] = {NAME = 'nosit', DESC = 'Prevents your character from sitting'}
CMDs[#CMDs + 1] = {NAME = 'unnosit', DESC = 'Disables nosit'}
CMDs[#CMDs + 1] = {NAME = 'jump', DESC = 'Makes your character jump'}
CMDs[#CMDs + 1] = {NAME = 'infinitejump / infjump', DESC = 'Allows you to climb into the air by repeatedly pressing jump'}
CMDs[#CMDs + 1] = {NAME = 'uninfinitejump / uninfjump', DESC = 'Disables infinitejump'}
CMDs[#CMDs + 1] = {NAME = 'flyjump', DESC = 'Infinite jump that continuously flies upward just by holding the jump button'}
CMDs[#CMDs + 1] = {NAME = 'unflyjump', DESC = 'Disables flyjump'}
CMDs[#CMDs + 1] = {NAME = 'autojump / ajump', DESC = 'Automatically jumps when you run into an object'}
CMDs[#CMDs + 1] = {NAME = 'unautojump / unajump', DESC = 'Disables autojump'}
CMDs[#CMDs + 1] = {NAME = 'edgejump / ejump', DESC = 'Automatically jumps when you get to the edge of an object'}
CMDs[#CMDs + 1] = {NAME = 'unedgejump / unejump', DESC = 'Disables edgejump'}
CMDs[#CMDs + 1] = {NAME = 'platformstand / stun', DESC = 'Enables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'unplatformstand / unstun', DESC = 'Disables PlatformStand'}
CMDs[#CMDs + 1] = {NAME = 'norotate / noautorotate', DESC = 'Disables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'unnorotate / autorotate', DESC = 'Enables AutoRotate'}
CMDs[#CMDs + 1] = {NAME = 'enablestate [StateType]', DESC = 'Enables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'disablestate [StateType]', DESC = 'Disables a humanoid state type'}
CMDs[#CMDs + 1] = {NAME = 'team [team name] (CLIENT)', DESC = 'Changes your team. Sometimes fools LocalScripts.'}
CMDs[#CMDs + 1] = {NAME = 'nobillboardgui / nobgui / noname', DESC = 'Removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'loopnobgui / loopnoname', DESC = 'Loop removes billboard and surface GUIs from your players (i.e. name GUIs at cafes)'}
CMDs[#CMDs + 1] = {NAME = 'unloopnobgui / unloopnoname', DESC = 'Disables loopnobgui'}
CMDs[#CMDs + 1] = {NAME = 'noarms', DESC = 'Removes your arms'}
CMDs[#CMDs + 1] = {NAME = 'nolegs', DESC = 'Removes your legs'}
CMDs[#CMDs + 1] = {NAME = 'nolimbs', DESC = 'Removes your limbs'}
CMDs[#CMDs + 1] = {NAME = 'naked (CLIENT)', DESC = 'Removes your clothing'}
CMDs[#CMDs + 1] = {NAME = 'noface / removeface', DESC = 'Removes your face'}
CMDs[#CMDs + 1] = {NAME = 'blockhead', DESC = 'Turns your head into a block'}
CMDs[#CMDs + 1] = {NAME = 'blockhats', DESC = 'Turns your hats into blocks'}
CMDs[#CMDs + 1] = {NAME = 'blocktool', DESC = 'Turns the currently selected tool into a block'}
CMDs[#CMDs + 1] = {NAME = 'creeper', DESC = 'Makes you look like a creeper'}
CMDs[#CMDs + 1] = {NAME = 'drophats', DESC = 'Drops your hats'}
CMDs[#CMDs + 1] = {NAME = 'nohats / deletehats / rhats', DESC = 'Deletes your hats'}
CMDs[#CMDs + 1] = {NAME = 'hatspin / spinhats', DESC = 'Spins your characters accessories'}
CMDs[#CMDs + 1] = {NAME = 'unhatspin / unspinhats', DESC = 'Undoes spinhats'}
CMDs[#CMDs + 1] = {NAME = 'clearhats / cleanhats', DESC = 'Clears hats in the workspace'}
CMDs[#CMDs + 1] = {NAME = 'chardelete / cd [instance name]', DESC = 'Removes any part with a certain name from your character'}
CMDs[#CMDs + 1] = {NAME = 'chardeleteclass / cdc [class name]', DESC = 'Removes any part with a certain classname from your character'}
CMDs[#CMDs + 1] = {NAME = 'deletevelocity / dv / removeforces', DESC = 'Removes any velocity / force instances in your character'}
CMDs[#CMDs + 1] = {NAME = 'weaken [num]', DESC = 'Makes your character less dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unweaken', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'strengthen [num]', DESC = 'Makes your character more dense via CustomPhysicalProperties'}
CMDs[#CMDs + 1] = {NAME = 'unstrengthen', DESC = 'Sets your characters CustomPhysicalProperties to default'}
CMDs[#CMDs + 1] = {NAME = 'breakvelocity', DESC = 'Sets your characters velocity to 0'}
CMDs[#CMDs + 1] = {NAME = 'spin [speed]', DESC = 'Spins your character'}
CMDs[#CMDs + 1] = {NAME = 'unspin', DESC = 'Disables spin'}
CMDs[#CMDs + 1] = {NAME = 'split', DESC = 'Splits your character in half'}
CMDs[#CMDs + 1] = {NAME = 'nilchar', DESC = 'Sets your characters parent to nil'}
CMDs[#CMDs + 1] = {NAME = 'unnilchar / nonilchar', DESC = 'Sets your characters parent to workspace'}
CMDs[#CMDs + 1] = {NAME = 'noroot / removeroot / rroot', DESC = 'Removes your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'replaceroot', DESC = 'Replaces your characters HumanoidRootPart'}
CMDs[#CMDs + 1] = {NAME = 'clearcharappearance / clearchar / clrchar', DESC = 'Removes all accessory, shirt, pants, charactermesh, and bodycolors'}
CMDs[#CMDs + 1] = {NAME = 'tpwalk / teleportwalk [num]', DESC = 'Teleports you to your move direction'}
CMDs[#CMDs + 1] = {NAME = 'untpwalk / unteleportwalk', DESC = 'Undoes tpwalk / teleportwalk'}
CMDs[#CMDs + 1] = {NAME = 'trip', DESC = 'Makes your character fall over'}
CMDs[#CMDs + 1] = {NAME = 'wallwalk / walkonwalls', DESC = 'Walk on walls'}
CMDs[#CMDs + 1] = {NAME = 'promptr6', DESC = 'Prompts the game to switch your rig type to R6'}
CMDs[#CMDs + 1] = {NAME = 'promptr15', DESC = 'Prompts the game to switch your rig type to R15'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'animation / anim [ID] [speed]', DESC = 'Makes your character perform an animation (must be an animation on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'emote / em [ID] [speed]', DESC = 'Makes your character perform an emote (must be on the marketplace or by Roblox/StickMasterLuke to replicate)'}
CMDs[#CMDs + 1] = {NAME = 'dance', DESC = 'Makes you  d a n c e'}
CMDs[#CMDs + 1] = {NAME = 'undance', DESC = 'Stops dance animations'}
CMDs[#CMDs + 1] = {NAME = 'defemote [emote]', DESC = 'Plays default emote'}
CMDs[#CMDs + 1] = {NAME = 'spasm', DESC = 'Makes you  c r a z y'}
CMDs[#CMDs + 1] = {NAME = 'unspasm', DESC = 'Stops spasm'}
CMDs[#CMDs + 1] = {NAME = 'headthrow', DESC = 'Simply makes you throw your head'}
CMDs[#CMDs + 1] = {NAME = 'noanim', DESC = 'Disables your animations'}
CMDs[#CMDs + 1] = {NAME = 'reanim', DESC = 'Restores your animations'}
CMDs[#CMDs + 1] = {NAME = 'animspeed [num]', DESC = 'Changes the speed of your current animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimation / copyanim / copyemote [player]', DESC = 'Copies someone elses animation'}
CMDs[#CMDs + 1] = {NAME = 'copyanimationid / copyanimid / copyemoteid [player]', DESC = 'Copies your AnimationId or someone elses to your clipboard'}
CMDs[#CMDs + 1] = {NAME = 'loopanimation / loopanim', DESC = 'Loops your current animation'}
CMDs[#CMDs + 1] = {NAME = 'stopanimations / stopanims', DESC = 'Stops running animations'}
CMDs[#CMDs + 1] = {NAME = 'refreshanimations / refreshanims', DESC = 'Refreshes animations'}
CMDs[#CMDs + 1] = {NAME = 'allowcustomanim / allowcustomanimations', DESC = 'Lets you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = 'unallowcustomanim / unallowcustomanimations', DESC = 'Doesnt let you use custom animation packs instead'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'autoclick [click delay] [release delay]', DESC = 'Automatically clicks your mouse with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautoclick / noautoclick', DESC = 'Turns off autoclick'}
CMDs[#CMDs + 1] = {NAME = 'autokeypress [key] [down delay] [up delay]', DESC = 'Automatically presses a key with a set delay'}
CMDs[#CMDs + 1] = {NAME = 'unautokeypress', DESC = 'Stops autokeypress'}
CMDs[#CMDs + 1] = {NAME = 'hovername', DESC = 'Shows a players username when your mouse is hovered over them'}
CMDs[#CMDs + 1] = {NAME = 'unhovername / nohovername', DESC = 'Turns off hovername'}
CMDs[#CMDs + 1] = {NAME = 'mousesensitivity / ms [0-10]', DESC = 'Sets your mouse sensitivity (affects first person and right click drag) (default is 1)'}
CMDs[#CMDs + 1] = {NAME = 'clickdelete', DESC = 'Go to Settings > Keybinds > Add for click delete'}
CMDs[#CMDs + 1] = {NAME = 'clickteleport', DESC = 'Go to Settings > Keybinds > Add for click teleport'}
CMDs[#CMDs + 1] = {NAME = 'clickfor', DESC = 'Click a player to run (click type) (player)'}
CMDs[#CMDs + 1] = {NAME = 'unclickfor', DESC = 'Disables clickfor'}
CMDs[#CMDs + 1] = {NAME = 'clicktype [type]', DESC = 'Sets click type'}
CMDs[#CMDs + 1] = {NAME = 'mouseteleport / mousetp', DESC = 'Teleports your character to your mouse. This is recommended as a keybind'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'tools', DESC = 'Copies tools from ReplicatedStorage and Lighting'}
CMDs[#CMDs + 1] = {NAME = 'notools / removetools / deletetools', DESC = 'Removes tools from character and backpack'}
CMDs[#CMDs + 1] = {NAME = 'deleteselectedtool / dst', DESC = 'Removes any currently selected tools'}
CMDs[#CMDs + 1] = {NAME = 'grabtools', DESC = 'Automatically get tools that are dropped'}
CMDs[#CMDs + 1] = {NAME = 'ungrabtools / nograbtools', DESC = 'Disables grabtools'}
CMDs[#CMDs + 1] = {NAME = 'copytools [player] (CLIENT)', DESC = 'Copies a players tools'}
CMDs[#CMDs + 1] = {NAME = 'dupetools / clonetools [num]', DESC = 'Duplicates your inventory tools a set amount of times'}
CMDs[#CMDs + 1] = {NAME = 'droptools', DESC = 'Drops your tools'}
CMDs[#CMDs + 1] = {NAME = 'droppabletools', DESC = 'Makes your tools droppable'}
CMDs[#CMDs + 1] = {NAME = 'equiptools', DESC = 'Equips every tool in your inventory at once'}
CMDs[#CMDs + 1] = {NAME = 'unequiptools', DESC = 'Unequips every tool you are currently holding at once'}
CMDs[#CMDs + 1] = {NAME = 'removespecifictool [name]', DESC = 'Automatically remove a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'unremovespecifictool [name]', DESC = 'Stops removing a specific tool from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'clearremovespecifictool', DESC = 'Stop removing all specific tools from your inventory'}
CMDs[#CMDs + 1] = {NAME = 'reach [num]', DESC = 'Increases the hitbox of your held tool'}
CMDs[#CMDs + 1] = {NAME = 'boxreach [num]', DESC = 'Increases the hitbox of your held tool in a box shape'}
CMDs[#CMDs + 1] = {NAME = 'unreach / noreach', DESC = 'Turns off reach'}
CMDs[#CMDs + 1] = {NAME = 'grippos [X Y Z]', DESC = 'Changes your current tools grip position'}
CMDs[#CMDs + 1] = {NAME = 'usetools [amount] [delay]', DESC = 'Activates all tools in your backpack at the same time'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addalias [cmd] [alias]', DESC = 'Adds an alias to a command'}
CMDs[#CMDs + 1] = {NAME = 'removealias [alias]', DESC = 'Removes a custom alias'}
CMDs[#CMDs + 1] = {NAME = 'clraliases', DESC = 'Removes all custom aliases'}
CMDs[#CMDs + 1] = {NAME = '', DESC = ''}
CMDs[#CMDs + 1] = {NAME = 'addplugin / plugin [name]', DESC = 'Add a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'removeplugin / deleteplugin [name]', DESC = 'Remove a plugin via command'}
CMDs[#CMDs + 1] = {NAME = 'reloadplugin [name]', DESC = 'Reloads a plugin'}
CMDs[#CMDs + 1] = {NAME = 'addallplugins / loadallplugins', DESC = 'Adds all available plugins from the workspace folder'}
-- wait()

for i = 1, #CMDs do
	local newcmd = Example:Clone()
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = CMDs[i].NAME
	newcmd.Name = "CMD"
	table.insert(text1, newcmd)
	if CMDs[i].DESC ~= "" then
		newcmd:SetAttribute("Title", CMDs[i].NAME)
		newcmd:SetAttribute("Desc", CMDs[i].DESC)
		newcmd.MouseButton1Down:Connect(function()
			if not IsOnMobile and newcmd.Visible and newcmd.TextTransparency == 0 then
				local currentText = Cmdbar.Text
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text, currentText)
				maximizeHolder()
			end
		end)
	end
end

IndexContents("", true)

function checkTT()
	local t
	local guisAtPosition = COREGUI:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)

	for _, gui in pairs(guisAtPosition) do
		if gui.Parent == CMDsF then
			t = gui
		end
	end

	if t ~= nil and t:GetAttribute("Title") ~= nil then
		local x = IYMouse.X
		local y = IYMouse.Y
		local xP
		local yP
		if IYMouse.X > 200 then
			xP = x - 201
		else
			xP = x + 21
		end
		if IYMouse.Y > (IYMouse.ViewSizeY-96) then
			yP = y - 97
		else
			yP = y
		end
		Tooltip.Position = UDim2.new(0, xP, 0, yP)
		Description.Text = t:GetAttribute("Desc")
		if t:GetAttribute("Title") ~= nil then
			Title_3.Text = t:GetAttribute("Title")
		else
			Title_3.Text = ''
		end
		Tooltip.Visible = true
	else
		Tooltip.Visible = false
	end
end

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

function GetInTable(Table, Name)
	for i = 1, #Table do
		if Table[i] == Name then
			return i
		end
	end
	return false
end

function respawn(plr)
	if invisRunning then TurnVisible() end
    local char = plr.Character
    local hum = char:FindFirstChildWhichIsA("Humanoid")
	local archive = workspace.FallenPartsDestroyHeight
	local camType = workspace.CurrentCamera.CameraType
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.FallenPartsDestroyHeight = 0/0
    getRoot(char).Position = Vector3.yAxis * archive
	task.wait(plr:GetNetworkPing())
	workspace.FallenPartsDestroyHeight = archive
	repeat task.wait() until not char.Parent or not hum.Parent or (hum and hum.Health <= 0)
	if hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
end

local refreshCmd = false
function refresh(plr)
	refreshCmd = true
	local root = getRoot(plr.Character)
	local pos = root.CFrame
	local pos1 = workspace.CurrentCamera.CFrame
	respawn(plr)
	task.spawn(function()
		local char = plr.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		while not humanoid do
			wait()
			humanoid = char:FindFirstChildOfClass("Humanoid")
		end
		humanoid.RootPart.CFrame, workspace.CurrentCamera.CFrame = pos, task.wait() and pos1
		refreshCmd = false
	end)
end

local lastDeath

function onDied()
	task.spawn(function()
		if pcall(function() Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') end) and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
			Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				if getRoot(Players.LocalPlayer.Character) then
					lastDeath = getRoot(Players.LocalPlayer.Character).CFrame
				end
			end)
		else
			wait(2)
			onDied()
		end
	end)
end

Clip = true
spDelay = 0.1
Players.LocalPlayer.CharacterAdded:Connect(function()
	NOFLY()
	floating = false

	if not Clip then
		execCmd('clip')
	end

	repeat wait() until getRoot(Players.LocalPlayer.Character)

	pcall(function()
		if spawnpoint and not refreshCmd and spawnpos ~= nil then
			wait(spDelay)
			getRoot(Players.LocalPlayer.Character).CFrame = spawnpos
		end
	end)

	onDied()
end)

onDied()

local booly = {
    truthy = { ["true"] = true, ["t"] = true, ["1"] = true, ["yes"] = true, ["y"] = true, ["on"] = true, ["enable"] = true, ["enabled"] = true },
    falsy = { ["false"] = true, ["f"] = true, ["0"] = true, ["no"] = true, ["n"] = true, ["off"] = true, ["disable"] = true, ["disabled"] = true },
}

function parseBoolean(raw, default)
    raw = tostring(raw):lower()
    if booly.truthy[raw] then return true end
    if booly.falsy[raw] then return false end
    return default or false
end

function getstring(begin, args)
    return table.concat(args or cargs, " ", begin)
end

findCmd=function(cmd_name)
	for i,v in pairs(cmds)do
		if v.NAME:lower()==cmd_name:lower() or FindInTable(v.ALIAS,cmd_name:lower()) then
			return v
		end
	end
	return customAlias[cmd_name:lower()]
end

function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end

cmdHistory = {}
local lastCmds = {}
local historyCount = 0
local split=" "
local lastBreakTime = 0
function execCmd(cmdStr,speaker,store)
	cmdStr = cmdStr:gsub("%s+$", "")
	task.spawn(function()
		local rawCmdStr = cmdStr
		cmdStr = string.gsub(cmdStr, "\\\\", "%%BackSlash%%")

		local commandsToRun = splitString(cmdStr, "\\")
		for i, v in pairs(commandsToRun) do
			v = string.gsub(v, "%%BackSlash%%", "\\")
			local x, y, num = v:find("^(%d+)%^")
			local cmdDelay = 0
			local infTimes = false

			if num then
				v = v:sub(y + 1)
				local x, y, del = v:find("^([%d%.]+)%^")
				if del then
					v = v:sub(y + 1)
					cmdDelay = tonumber(del) or 0
				end
			else
				local x, y = v:find("^inf%^")
				if x then
					infTimes = true
					v = v:sub(y + 1)
					local x, y, del = v:find("^([%d%.]+)%^")
					if del then
						v = v:sub(y + 1)
						del = tonumber(del) or 1
						cmdDelay = (del > 0 and del or 1)
					else
						cmdDelay = 1
					end
				end
			end
			num = tonumber(num or 1)

			if v:sub(1, 1) == "!" then
				local chunks = splitString(v:sub(2), split)
				if chunks[1] and lastCmds[chunks[1]] then v = lastCmds[chunks[1]] end
			end

			local args = splitString(v, split)
			local cmdName = args[1]
			local cmd = findCmd(cmdName)
			if cmd then
				table.remove(args, 1)
				cargs = args
				if not speaker then speaker = Players.LocalPlayer end

				if store then
					if speaker == Players.LocalPlayer then
						if cmdHistory[1] ~= rawCmdStr and rawCmdStr:sub(1, 11) ~= "lastcommand" and rawCmdStr:sub(1, 7) ~= "lastcmd" then
							table.insert(cmdHistory, 1, rawCmdStr)
						end
					end
					if #cmdHistory > 30 then table.remove(cmdHistory) end

					lastCmds[cmdName] = v
				end

				local cmdStartTime = tick()
				if infTimes then
					while lastBreakTime < cmdStartTime do
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
						end
						wait(cmdDelay)
					end
				else
					for rep = 1, num do
						if lastBreakTime > cmdStartTime then break end
						local success, err = pcall(cmd.FUNC, args, speaker)
						if not success and _G.IY_DEBUG then
							warn("Command Error:", cmdName, err)
							notify("Command Error: " .. cmdName, "Check console")
						end
						if success and type(err) == "string" and not table.find(args, "nonotify") then
							notify("Command: " .. cmdName, err)
						end
						if cmdDelay ~= 0 then wait(cmdDelay) end
					end
				end
			end
		end
	end)
end

function addcmd(name,alias,func,plgn)
	cmds[#cmds+1]=
		{
			NAME=name;
			ALIAS=alias or {};
			FUNC=func;
			PLUGIN=plgn;
		}
end

function removecmd(cmd)
	if cmd ~= " " then
		for i = #cmds,1,-1 do
			if cmds[i].NAME == cmd or FindInTable(cmds[i].ALIAS,cmd) then
				table.remove(cmds, i)
				for a,c in pairs(CMDsF:GetChildren()) do
					if string.find(c.Text, "^"..cmd.."$") or string.find(c.Text, "^"..cmd.." ") or string.find(c.Text, " "..cmd.."$") or string.find(c.Text, " "..cmd.." ") then
						c.TextTransparency = 0.7
						c.MouseButton1Click:Connect(function()
							notify(c.Text, "Command has been disabled by you or a plugin")
						end)
					end
				end
			end
		end
	end
end

function overridecmd(name, func)
	local cmd = findCmd(name)
	if cmd and cmd.FUNC then cmd.FUNC = func end
end

function addbind(cmd,key,iskeyup,toggle)
	if toggle then
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
				TOGGLE = toggle;
			}
	else
		binds[#binds+1]=
			{
				COMMAND=cmd;
				KEY=key;
				ISKEYUP=iskeyup;
			}
	end
end

function addcmdtext(text,name,desc)
	local newcmd = Example:Clone()
	local tooltipText = tostring(text)
	local tooltipDesc = tostring(desc)
	newcmd.Parent = CMDsF
	newcmd.Visible = false
	newcmd.Text = text
	newcmd.Name = 'PLUGIN_'..name
	table.insert(text1,newcmd)
	if desc and desc ~= '' then
		newcmd:SetAttribute("Title", tooltipText)
		newcmd:SetAttribute("Desc", tooltipDesc)
		newcmd.MouseButton1Down:Connect(function()
			if newcmd.Visible and newcmd.TextTransparency == 0 then
				Cmdbar:CaptureFocus()
				autoComplete(newcmd.Text)
				maximizeHolder()
			end
		end)
	end
end

local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}

function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end

function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end

function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

function formatUsername(player)
	if player.DisplayName ~= player.Name then
		return string.format("%s (%s)", player.Name, player.DisplayName)
	end
	return player.Name
end

getprfx=function(strn)
	if strn:sub(1,string.len(prefix))==prefix then return{'cmd',string.len(prefix)+1}
	end return
end

function do_exec(str, plr)
	str = str:gsub('/e ', '')
	local t = getprfx(str)
	if not t then return end
	str = str:sub(t[2])
	if t[1]=='cmd' then
		execCmd(str, plr, true)
		IndexContents('',true,false,true)
		CMDsF.CanvasPosition = canvasPos
	end
end

lastTextBoxString,lastTextBoxCon,lastEnteredString = nil,nil,nil

UserInputService.TextBoxFocused:Connect(function(obj)
	if lastTextBoxCon then lastTextBoxCon:Disconnect() end
	if obj == Cmdbar then lastTextBoxString = nil return end
	lastTextBoxString = obj.Text
	lastTextBoxCon = obj:GetPropertyChangedSignal("Text"):Connect(function()
		if not (UserInputService:IsKeyDown(Enum.KeyCode.Return) or UserInputService:IsKeyDown(Enum.KeyCode.KeypadEnter)) then
			lastTextBoxString = obj.Text
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
	if gameProcessed then
		if Cmdbar and Cmdbar:IsFocused() then
			if input.KeyCode == Enum.KeyCode.Up then
				historyCount = historyCount + 1
				if historyCount > #cmdHistory then historyCount = #cmdHistory end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			elseif input.KeyCode == Enum.KeyCode.Down then
				historyCount = historyCount - 1
				if historyCount < 0 then historyCount = 0 end
				Cmdbar.Text = cmdHistory[historyCount] or ""
				Cmdbar.CursorPosition = 1020
			end
		elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
			lastEnteredString = lastTextBoxString
		end
	end
end)

Players.LocalPlayer.Chatted:Connect(function()
	wait()
	if lastEnteredString then
		local message = lastEnteredString
		lastEnteredString = nil
		do_exec(message, Players.LocalPlayer)
	end
end)

Cmdbar.PlaceholderText = "Command Bar ("..prefix..")"
Cmdbar:GetPropertyChangedSignal("Text"):Connect(function()
	if Cmdbar:IsFocused() then
		IndexContents(Cmdbar.Text,true,true)
	end
end)

local tabComplete = nil
tabAllowed = true
Cmdbar.FocusLost:Connect(function(enterpressed)
	if enterpressed then
		local cmdbarText = Cmdbar.Text:gsub("^"..prefix,"")
		execCmd(cmdbarText,Players.LocalPlayer,true)
	end
	if tabComplete then tabComplete:Disconnect() end
	wait()
	if not Cmdbar:IsFocused() then
		Cmdbar.Text = ""
		IndexContents('',true,false,true)
		if SettingsOpen == true then
			wait(0.2)
			Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.2, true, nil)
			CMDsF.Visible = false
		end
	end
	CMDsF.CanvasPosition = canvasPos
end)

Cmdbar.Focused:Connect(function()
	historyCount = 0
	canvasPos = CMDsF.CanvasPosition
	if SettingsOpen == true then
		wait(0.2)
		CMDsF.Visible = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 220), "InOut", "Quart", 0.2, true, nil)
	end
	tabComplete = UserInputService.InputBegan:Connect(function(input,gameProcessed)
		if Cmdbar:IsFocused() then
			if tabAllowed == true and input.KeyCode == Enum.KeyCode.Tab and topCommand ~= nil then
				autoComplete(topCommand)
			end
		else
			tabComplete:Disconnect()
		end
	end)
end)

ESPenabled = false
CHMSenabled = false

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function ESP(plr, logic)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					if logic == true then
						a.Color = BrickColor.new(plr.TeamColor == Players.LocalPlayer.TeamColor and "Bright green" or "Bright red")
					else
						a.Color = plr.TeamColor
					end
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr, logic)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end

function CHMS(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_CHMS' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_CHMS') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_CHMS'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			local addedFunc
			local teamChange
			local CHMSremoved
			addedFunc = plr.CharacterAdded:Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					teamChange:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					addedFunc:Disconnect()
				else
					teamChange:Disconnect()
					addedFunc:Disconnect()
				end
			end)
			teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
				if CHMSenabled then
					ESPholder:Destroy()
					addedFunc:Disconnect()
					repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
					CHMS(plr)
					teamChange:Disconnect()
				else
					teamChange:Disconnect()
				end
			end)
			CHMSremoved = ESPholder.AncestryChanged:Connect(function()
				teamChange:Disconnect()
				addedFunc:Disconnect()
				CHMSremoved:Disconnect()
			end)
		end
	end)
end

function Locate(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_LC' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_LC') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_LC'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local lcLoopFunc
				local addedFunc
				local teamChange
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPholder ~= nil and ESPholder.Parent ~= nil then
						lcLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						Locate(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function lcLoop()
					if COREGUI:FindFirstChild(plr.Name..'_LC') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						lcLoopFunc:Disconnect()
					end
				end
				lcLoopFunc = RunService.RenderStepped:Connect(lcLoop)
			end
		end
	end)
end

local bindsGUI = KeybindEditor
local awaitingInput = false
local keySelected = false

function refreshbinds()
	if Holder_2 then
		Holder_2:ClearAllChildren()
		Holder_2.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #binds do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newbind = Example_2:Clone()
			newbind.Parent = Holder_2
			newbind.Visible = true
			newbind.Position = UDim2.new(0,0,0, Position + 5)
			table.insert(shade2,newbind)
			table.insert(shade2,newbind.Text)
			table.insert(text1,newbind.Text)
			table.insert(shade3,newbind.Text.Delete)
			table.insert(text2,newbind.Text.Delete)
			local input = tostring(binds[i].KEY)
			local key
			if input == 'RightClick' or input == 'LeftClick' then
				key = input
			else
				key = input:sub(14)
			end
			if binds[i].TOGGLE then
				newbind.Text.Text = key.." > "..binds[i].COMMAND.." / "..binds[i].TOGGLE
			else
				newbind.Text.Text = key.." > "..binds[i].COMMAND.."  "..(binds[i].ISKEYUP and "(keyup)" or "(keydown)")
			end
			Holder_2.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newbind.Text.Delete.MouseButton1Click:Connect(function()
				unkeybind(binds[i].COMMAND,binds[i].KEY)
			end)
		end
	end
end

refreshbinds()

toggleOn = {}

function unkeybind(cmd,key)
	for i = #binds,1,-1 do
		if binds[i].COMMAND == cmd and binds[i].KEY == key then
			toggleOn[binds[i]] = nil
			table.remove(binds, i)
		end
	end
	refreshbinds()
	updatesaves()
	if key == 'RightClick' or key == 'LeftClick' then
		notify('Keybinds Updated','Unbinded '..key..' from '..cmd)
	else
		notify('Keybinds Updated','Unbinded '..key:sub(14)..' from '..cmd)
	end
end

PositionsFrame.Delete.MouseButton1Click:Connect(function()
	execCmd('cpos')
end)

function refreshwaypoints()
	if #WayPoints > 0 or #pWayPoints > 0 then
		PositionsHint:Destroy()
	end
	if Holder_4 then
		Holder_4:ClearAllChildren()
		Holder_4.CanvasSize = UDim2.new(0, 0, 0, 10)
		local YSize = 25
		local num = 1
		for i = 1, #WayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = WayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..WayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..WayPoints[i].NAME)
			end)
			num = num+1
		end
		for i = 1, #pWayPoints do
			local Position = ((num * YSize) - YSize)
			local newpoint = Example_4:Clone()
			newpoint.Parent = Holder_4
			newpoint.Visible = true
			newpoint.Position = UDim2.new(0,0,0, Position + 5)
			newpoint.Text.Text = pWayPoints[i].NAME
			table.insert(shade2,newpoint)
			table.insert(shade2,newpoint.Text)
			table.insert(text1,newpoint.Text)
			table.insert(shade3,newpoint.Text.Delete)
			table.insert(text2,newpoint.Text.Delete)
			table.insert(shade3,newpoint.Text.TP)
			table.insert(text2,newpoint.Text.TP)
			Holder_4.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newpoint.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('dpos '..pWayPoints[i].NAME)
			end)
			newpoint.Text.TP.MouseButton1Click:Connect(function()
				execCmd("loadpos "..pWayPoints[i].NAME)
			end)
			num = num+1
		end
	end
end

refreshwaypoints()

function refreshaliases()
	if #aliases > 0 then
		AliasHint:Destroy()
	end
	if Holder_3 then
		Holder_3:ClearAllChildren()
		Holder_3.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i = 1, #aliases do
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newalias = Example_3:Clone()
			newalias.Parent = Holder_3
			newalias.Visible = true
			newalias.Position = UDim2.new(0,0,0, Position + 5)
			newalias.Text.Text = aliases[i].CMD.." > "..aliases[i].ALIAS
			table.insert(shade2,newalias)
			table.insert(shade2,newalias.Text)
			table.insert(text1,newalias.Text)
			table.insert(shade3,newalias.Text.Delete)
			table.insert(text2,newalias.Text.Delete)
			Holder_3.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newalias.Text.Delete.MouseButton1Click:Connect(function()
				execCmd('removealias '..aliases[i].ALIAS)
			end)
		end
	end
end

local bindChosenKeyUp = false

BindTo.MouseButton1Click:Connect(function()
	awaitingInput = true
	BindTo.Text = 'Press something'
end)

BindTriggerSelect.MouseButton1Click:Connect(function()
	bindChosenKeyUp = not bindChosenKeyUp
	BindTriggerSelect.Text = bindChosenKeyUp and "KeyUp" or "KeyDown"
end)

newToggle = false
Cmdbar_3.Parent.Visible = false
On_2.MouseButton1Click:Connect(function()
	if newToggle == false then newToggle = true
		On_2.BackgroundTransparency = 0
		Cmdbar_3.Parent.Visible = true
		BindTriggerSelect.Visible = false
	else newToggle = false
		On_2.BackgroundTransparency = 1
		Cmdbar_3.Parent.Visible = false
		BindTriggerSelect.Visible = true
	end
end)

Add_2.MouseButton1Click:Connect(function()
	if keySelected then
		if string.find(Cmdbar_2.Text, "\\\\") or string.find(Cmdbar_3.Text, "\\\\") then
			notify('Keybind Error','Only use one backslash to keybind multiple commands into one keybind or command')
		else
			if newToggle and Cmdbar_3.Text ~= '' and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,false,Cmdbar_3.Text)
			elseif not newToggle and Cmdbar_2.text ~= '' then
				addbind(Cmdbar_2.Text,keyPressed,bindChosenKeyUp)
			else
				return
			end
			refreshbinds()
			updatesaves()
			if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
				notify('Keybinds Updated','Binded '..keyPressed..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			else
				notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to '..Cmdbar_2.Text..(newToggle and " / "..Cmdbar_3.Text or ""))
			end
		end
	end
end)

Exit_2.MouseButton1Click:Connect(function()
	Cmdbar_2.Text = 'Command'
	Cmdbar_3.Text = 'Command 2'
	BindTo.Text = 'Click to bind'
	bindChosenKeyUp = false
	BindTriggerSelect.Text = "KeyDown"
	keySelected = false
	KeybindEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
end)

function onInputBegan(input,gameProcessed)
	if awaitingInput then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			keyPressed = tostring(input.KeyCode)
			BindTo.Text = keyPressed:sub(14)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			keyPressed = 'LeftClick'
			BindTo.Text = 'LeftClick'
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			keyPressed = 'RightClick'
			BindTo.Text = 'RightClick'
		end
		awaitingInput = false
		keySelected = true
	end
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if not v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					if v.TOGGLE then
						local isOn = toggleOn[v] == true
						toggleOn[v] = not isOn
						if isOn then
							execCmd(v.TOGGLE,Players.LocalPlayer)
						else
							execCmd(v.COMMAND,Players.LocalPlayer)
						end
					else
						execCmd(v.COMMAND,Players.LocalPlayer)
					end
				end
			end
		end
	end
end

function onInputEnded(input,gameProcessed)
	if not gameProcessed and #binds > 0 then
		for i,v in pairs(binds) do
			if v.ISKEYUP then
				if (input.UserInputType == Enum.UserInputType.Keyboard and v.KEY:lower()==tostring(input.KeyCode):lower()) or (input.UserInputType == Enum.UserInputType.MouseButton1 and v.KEY:lower()=='leftclick') or (input.UserInputType == Enum.UserInputType.MouseButton2 and v.KEY:lower()=='rightclick') then
					execCmd(v.COMMAND,Players.LocalPlayer)
				end
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

ClickTP.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clicktp',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click tp')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click tp')
		end
	end
end)

ClickDelete.Select.MouseButton1Click:Connect(function()
	if keySelected then
		addbind('clickdel',keyPressed,bindChosenKeyUp)
		refreshbinds()
		updatesaves()
		if keyPressed == 'RightClick' or keyPressed == 'LeftClick' then
			notify('Keybinds Updated','Binded '..keyPressed..' to click delete')
		else
			notify('Keybinds Updated','Binded '..keyPressed:sub(14)..' to click delete')
		end
	end
end)

local function clicktpFunc()
	pcall(function()
		local character = Players.LocalPlayer.Character
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.SeatPart then
			humanoid.Sit = false
			wait(0.1)
		end

		local hipHeight = humanoid and humanoid.HipHeight > 0 and (humanoid.HipHeight + 1)
		local rootPart = getRoot(character)
		local rootPartPosition = rootPart.Position
		local hitPosition = IYMouse.Hit.Position
		local newCFrame = CFrame.new(
			hitPosition, 
			Vector3.new(rootPartPosition.X, hitPosition.Y, rootPartPosition.Z)
		) * CFrame.Angles(0, math.pi, 0)

		rootPart.CFrame = newCFrame + Vector3.new(0, hipHeight or 4, 0)
		breakVelocity()
	end)
end

clickFor = false
clickType = "bang"
IYMouse.Button1Down:Connect(function()
	for i,v in pairs(binds) do
		if v.COMMAND == 'clicktp' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and Players.LocalPlayer.Character then
				clicktpFunc()
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) and Players.LocalPlayer.Character then
				clicktpFunc()
			end
		elseif v.COMMAND == 'clickdel' then
			local input = v.KEY
			if input == 'RightClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif input == 'LeftClick' and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				pcall(function() IYMouse.Target:Destroy() end)
			elseif UserInputService:IsKeyDown(Enum.KeyCode[input:sub(14)]) then
				pcall(function() IYMouse.Target:Destroy() end)
			end
		end
	end

	if clickFor and IYMouse.Target then
		pcall(function()
			local tmodel = IYMouse.Target:FindFirstAncestorOfClass("Model")
			if tmodel and tmodel:FindFirstChild("Humanoid") then
				local target = Players:GetPlayerFromCharacter(tmodel)
				if target and target ~= Players.LocalPlayer then
					execCmd(clickType .. " " .. target.Name) -- potential feat: save clickType to a file?
				end
			end
		end)
	end
end)

PluginsGUI = PluginEditor.background

function addPlugin(name)
	if name:lower() == 'plugin file name' or name:lower() == 'iy_fe.iy' or name == 'iy_fe' then
		notify('Plugin Error','Please enter a valid plugin')
	else
		local file
		local fileName
		if name:sub(-3) == '.iy' then
			pcall(function() file = readfile(name) end)
			fileName = name
		else
			pcall(function() file = readfile(name..'.iy') end)
			fileName = name..'.iy'
		end
		if file then
			if not FindInTable(PluginsTable, fileName) then
				table.insert(PluginsTable, fileName)
				LoadPlugin(fileName)
				refreshplugins()
				pcall(eventEditor.Refresh)
			else
				notify('Plugin Error','This plugin is already added')
			end
		else
			notify('Plugin Error','Cannot locate file "'..fileName..'". Is the file in the correct folder?')
		end
	end
end

function deletePlugin(name)
	local pName = name..'.iy'
	if name:sub(-3) == '.iy' then
		pName = name
	end
	for i = #cmds,1,-1 do
		if cmds[i].PLUGIN == pName then
			table.remove(cmds, i)
		end
	end
	for i,v in pairs(CMDsF:GetChildren()) do
		if v.Name == 'PLUGIN_'..pName then
			v:Destroy()
		end
	end
	for i,v in pairs(PluginsTable) do
		if v == pName then
			table.remove(PluginsTable, i)
			notify('Removed Plugin',pName..' was removed')
		end
	end
	IndexContents('',true)
	refreshplugins()
end

function refreshplugins(dontSave)
	if #PluginsTable > 0 then
		PluginsHint:Destroy()
	end
	if Holder_5 then
		Holder_5:ClearAllChildren()
		Holder_5.CanvasSize = UDim2.new(0, 0, 0, 10)
		for i,v in pairs(PluginsTable) do
			local pName = v
			local YSize = 25
			local Position = ((i * YSize) - YSize)
			local newplugin = Example_5:Clone()
			newplugin.Parent = Holder_5
			newplugin.Visible = true
			newplugin.Position = UDim2.new(0,0,0, Position + 5)
			newplugin.Text.Text = pName
			table.insert(shade2,newplugin)
			table.insert(shade2,newplugin.Text)
			table.insert(text1,newplugin.Text)
			table.insert(shade3,newplugin.Text.Delete)
			table.insert(text2,newplugin.Text.Delete)
			Holder_5.CanvasSize = UDim2.new(0,0,0, Position + 30)
			newplugin.Text.Delete.MouseButton1Click:Connect(function()
				deletePlugin(pName)
			end)
		end
		if not dontSave then
			updatesaves()
		end
	end
end

local PluginCache
function LoadPlugin(val,startup)
	local plugin

	function CatchedPluginLoad()
		plugin = loadfile(val)()
	end

	function handlePluginError(plerror)
		notify('Plugin Error','An error occurred with the plugin, "'..val..'" and it could not be loaded')
		if FindInTable(PluginsTable,val) then
			for i,v in pairs(PluginsTable) do
				if v == val then
					table.remove(PluginsTable,i)
				end
			end
		end
		updatesaves()

		print("Original Error: "..tostring(plerror))
		print("Plugin Error, stack traceback: "..tostring(debug.traceback()))

		plugin = nil

		return false
	end

	xpcall(CatchedPluginLoad, handlePluginError)

	if plugin ~= nil then
		if not startup then
			notify('Loaded Plugin',"Name: "..plugin["PluginName"].."\n".."Description: "..plugin["PluginDescription"])
		end
		addcmdtext('',val)
		addcmdtext(string.upper('--'..plugin["PluginName"]),val,plugin["PluginDescription"])
		if plugin["Commands"] then
			for i,v in pairs(plugin["Commands"]) do 
				local cmdExt = ''
				local cmdName = i
				local function handleNames()
					cmdName = i
					if findCmd(cmdName..cmdExt) then
						if isNumber(cmdExt) then
							cmdExt = cmdExt+1
						else
							cmdExt = 1
						end
						handleNames()
					else
						cmdName = cmdName..cmdExt
					end
				end
				handleNames()
				addcmd(cmdName, v["Aliases"], v["Function"], val)
				if v["ListName"] then
					local newName = v.ListName
					local cmdNames = {i,unpack(v.Aliases)}
					for i,v in pairs(cmdNames) do
						newName = newName:gsub(v,v..cmdExt)
					end
					addcmdtext(newName,val,v["Description"])
				else
					addcmdtext(cmdName,val,v["Description"])
				end
			end
		end
		IndexContents('',true)
	elseif plugin == nil then
		plugin = nil
	end
end

function FindPlugins()
	if PluginsTable ~= nil and type(PluginsTable) == "table" then
		for i,v in pairs(PluginsTable) do
			LoadPlugin(v,true)
		end
		refreshplugins(true)
	end
end

AddPlugin.MouseButton1Click:Connect(function()
	addPlugin(PluginsGUI.FileName.Text)
end)

Exit_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, -500), "InOut", "Quart", 0.5, true, nil)
	FileName.Text = 'Plugin File Name'
end)

Add_3.MouseButton1Click:Connect(function()
	PluginEditor:TweenPosition(UDim2.new(0.5, -180, 0, 310), "InOut", "Quart", 0.5, true, nil)
end)

Plugins.MouseButton1Click:Connect(function()
	if writefileExploit() then
		PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
		wait(0.5)
		SettingsHolder.Visible = false
	else
		notify('Incompatible Exploit','Your exploit is unable to use plugins (missing read/writefile)')
	end
end)

Close_4.MouseButton1Click:Connect(function()
	SettingsHolder.Visible = true
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
end)

local TeleportCheck = false
Players.LocalPlayer.OnTeleport:Connect(function(State)
	-- isi getgenv().KIZZDEV_LOADER dengan string loader KizzDev kamu, contoh:
	-- getgenv().KIZZDEV_LOADER = "loadstring(game:HttpGet('URL_KAMU'))()"
	local kizzLoader = type(getgenv) == "function" and getgenv().KIZZDEV_LOADER
	if KeepInfYield and (not TeleportCheck) and queueteleport and type(kizzLoader) == "string" then
		TeleportCheck = true
		queueteleport(kizzLoader)
	end
end)

addcmd('addalias',{},function(args, speaker)
	if #args < 2 then return end
	local cmd = string.lower(args[1])
	local alias = string.lower(args[2])
	for i,v in pairs(cmds) do
		if v.NAME:lower()==cmd or FindInTable(v.ALIAS,cmd) then
			customAlias[alias] = v
			aliases[#aliases + 1] = {CMD = cmd, ALIAS = alias}
			notify('Aliases Modified',"Added "..alias.." as an alias to "..cmd)
			updatesaves()
			refreshaliases()
			break
		end
	end
end)

addcmd('removealias',{},function(args, speaker)
	if #args < 1 then return end
	local alias = string.lower(args[1])
	if customAlias[alias] then
		local cmd = customAlias[alias].NAME
		customAlias[alias] = nil
		for i = #aliases,1,-1 do
			if aliases[i].ALIAS == tostring(alias) then
				table.remove(aliases, i)
			end
		end
		notify('Aliases Modified',"Removed the alias "..alias.." from "..cmd)
		updatesaves()
		refreshaliases()
	end
end)

addcmd('clraliases',{},function(args, speaker)
	customAlias = {}
	aliases = {}
	notify('Aliases Modified','Removed all aliases')
	updatesaves()
	refreshaliases()
end)

addcmd('discord', {'support', 'help'}, function(args, speaker)
	if everyClipboard then
		toClipboard('https://discord.com/invite/78ZuWSq')
		notify('Discord Invite', 'Copied to clipboard!\ndiscord.gg/78ZuWSq')
	else
		notify('Discord Invite', 'discord.gg/78ZuWSq')
	end
	if httprequest then
		httprequest({
			Url = 'http://127.0.0.1:6463/rpc?v=1',
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json',
				Origin = 'https://discord.com'
			},
			Body = HttpService:JSONEncode({
				cmd = 'INVITE_BROWSER',
				nonce = HttpService:GenerateGUID(false),
				args = {code = '78ZuWSq'}
			})
		})
	end
end)

addcmd('keepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = true
		notify('KeepKizz','KizzDev will now run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('unkeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = false
		notify('KeepKizz','KizzDev will no longer run after you teleport')
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

addcmd('togglekeepiy', {}, function(args, speaker)
	if queueteleport then
		KeepInfYield = not KeepInfYield
		updatesaves()
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing queue_on_teleport)')
	end
end)

local canOpenServerinfo = true
addcmd('serverinfo',{'info','sinfo'},function(args, speaker)
	if not canOpenServerinfo then return end
	canOpenServerinfo = false
	task.spawn(function()
		local FRAME = Instance.new("Frame")
		local shadow = Instance.new("Frame")
		local PopupText = Instance.new("TextLabel")
		local Exit = Instance.new("TextButton")
		local ExitImage = Instance.new("ImageLabel")
		local background = Instance.new("Frame")
		local TextLabel = Instance.new("TextLabel")
		local TextLabel2 = Instance.new("TextLabel")
		local TextLabel3 = Instance.new("TextLabel")
		local Time = Instance.new("TextLabel")
		local appearance = Instance.new("TextLabel")
		local maxplayers = Instance.new("TextLabel")
		local name = Instance.new("TextLabel")
		local placeid = Instance.new("TextLabel")
		local playerid = Instance.new("TextLabel")
		local players = Instance.new("TextLabel")
		local CopyApp = Instance.new("TextButton")
		local CopyPlrID = Instance.new("TextButton")
		local CopyPlcID = Instance.new("TextButton")
		local CopyPlcName = Instance.new("TextButton")

		FRAME.Name = randomString()
		FRAME.Parent = ScaledHolder
		FRAME.Active = true
		FRAME.BackgroundTransparency = 1
		FRAME.Position = UDim2.new(0.5, -130, 0, -500)
		FRAME.Size = UDim2.new(0, 250, 0, 20)
		FRAME.ZIndex = 10
		dragGUI(FRAME)

		shadow.Name = "shadow"
		shadow.Parent = FRAME
		shadow.BackgroundColor3 = currentShade2
		shadow.BorderSizePixel = 0
		shadow.Size = UDim2.new(0, 250, 0, 20)
		shadow.ZIndex = 10
		table.insert(shade2,shadow)

		PopupText.Name = "PopupText"
		PopupText.Parent = shadow
		PopupText.BackgroundTransparency = 1
		PopupText.Size = UDim2.new(1, 0, 0.95, 0)
		PopupText.ZIndex = 10
		PopupText.Font = Enum.Font.SourceSans
		PopupText.TextSize = 14
		PopupText.Text = "Server"
		PopupText.TextColor3 = currentText1
		PopupText.TextWrapped = true
		table.insert(text1,PopupText)

		Exit.Name = "Exit"
		Exit.Parent = shadow
		Exit.BackgroundTransparency = 1
		Exit.Position = UDim2.new(1, -20, 0, 0)
		Exit.Size = UDim2.new(0, 20, 0, 20)
		Exit.Text = ""
		Exit.ZIndex = 10

		ExitImage.Parent = Exit
		ExitImage.BackgroundColor3 = Color3.new(1, 1, 1)
		ExitImage.BackgroundTransparency = 1
		ExitImage.Position = UDim2.new(0, 5, 0, 5)
		ExitImage.Size = UDim2.new(0, 10, 0, 10)
		ExitImage.Image = getcustomasset("infiniteyield/assets/close.png")
		ExitImage.ZIndex = 10

		background.Name = "background"
		background.Parent = FRAME
		background.Active = true
		background.BackgroundColor3 = currentShade1
		background.BorderSizePixel = 0
		background.Position = UDim2.new(0, 0, 1, 0)
		background.Size = UDim2.new(0, 250, 0, 250)
		background.ZIndex = 10
		table.insert(shade1,background)

		TextLabel.Name = "Text Label"
		TextLabel.Parent = background
		TextLabel.BackgroundTransparency = 1
		TextLabel.BorderSizePixel = 0
		TextLabel.Position = UDim2.new(0, 5, 0, 80)
		TextLabel.Size = UDim2.new(0, 100, 0, 20)
		TextLabel.ZIndex = 10
		TextLabel.Font = Enum.Font.SourceSansLight
		TextLabel.TextSize = 20
		TextLabel.Text = "Run Time:"
		TextLabel.TextColor3 = currentText1
		TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel)

		TextLabel2.Name = "Text Label2"
		TextLabel2.Parent = background
		TextLabel2.BackgroundTransparency = 1
		TextLabel2.BorderSizePixel = 0
		TextLabel2.Position = UDim2.new(0, 5, 0, 130)
		TextLabel2.Size = UDim2.new(0, 100, 0, 20)
		TextLabel2.ZIndex = 10
		TextLabel2.Font = Enum.Font.SourceSansLight
		TextLabel2.TextSize = 20
		TextLabel2.Text = "Statistics:"
		TextLabel2.TextColor3 = currentText1
		TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel2)

		TextLabel3.Name = "Text Label3"
		TextLabel3.Parent = background
		TextLabel3.BackgroundTransparency = 1
		TextLabel3.BorderSizePixel = 0
		TextLabel3.Position = UDim2.new(0, 5, 0, 10)
		TextLabel3.Size = UDim2.new(0, 100, 0, 20)
		TextLabel3.ZIndex = 10
		TextLabel3.Font = Enum.Font.SourceSansLight
		TextLabel3.TextSize = 20
		TextLabel3.Text = "Local Player:"
		TextLabel3.TextColor3 = currentText1
		TextLabel3.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,TextLabel3)

		Time.Name = "Time"
		Time.Parent = background
		Time.BackgroundTransparency = 1
		Time.BorderSizePixel = 0
		Time.Position = UDim2.new(0, 5, 0, 105)
		Time.Size = UDim2.new(0, 100, 0, 20)
		Time.ZIndex = 10
		Time.Font = Enum.Font.SourceSans
		Time.FontSize = Enum.FontSize.Size14
		Time.Text = "LOADING"
		Time.TextColor3 = currentText1
		Time.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,Time)

		appearance.Name = "appearance"
		appearance.Parent = background
		appearance.BackgroundTransparency = 1
		appearance.BorderSizePixel = 0
		appearance.Position = UDim2.new(0, 5, 0, 55)
		appearance.Size = UDim2.new(0, 100, 0, 20)
		appearance.ZIndex = 10
		appearance.Font = Enum.Font.SourceSans
		appearance.FontSize = Enum.FontSize.Size14
		appearance.Text = "Appearance: LOADING"
		appearance.TextColor3 = currentText1
		appearance.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,appearance)

		maxplayers.Name = "maxplayers"
		maxplayers.Parent = background
		maxplayers.BackgroundTransparency = 1
		maxplayers.BorderSizePixel = 0
		maxplayers.Position = UDim2.new(0, 5, 0, 175)
		maxplayers.Size = UDim2.new(0, 100, 0, 20)
		maxplayers.ZIndex = 10
		maxplayers.Font = Enum.Font.SourceSans
		maxplayers.FontSize = Enum.FontSize.Size14
		maxplayers.Text = "LOADING"
		maxplayers.TextColor3 = currentText1
		maxplayers.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,maxplayers)

		name.Name = "name"
		name.Parent = background
		name.BackgroundTransparency = 1
		name.BorderSizePixel = 0
		name.Position = UDim2.new(0, 5, 0, 215)
		name.Size = UDim2.new(0, 240, 0, 30)
		name.ZIndex = 10
		name.Font = Enum.Font.SourceSans
		name.FontSize = Enum.FontSize.Size14
		name.Text = "Place Name: LOADING"
		name.TextColor3 = currentText1
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		table.insert(text1,name)

		placeid.Name = "placeid"
		placeid.Parent = background
		placeid.BackgroundTransparency = 1
		placeid.BorderSizePixel = 0
		placeid.Position = UDim2.new(0, 5, 0, 195)
		placeid.Size = UDim2.new(0, 100, 0, 20)
		placeid.ZIndex = 10
		placeid.Font = Enum.Font.SourceSans
		placeid.FontSize = Enum.FontSize.Size14
		placeid.Text = "Place ID: LOADING"
		placeid.TextColor3 = currentText1
		placeid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,placeid)

		playerid.Name = "playerid"
		playerid.Parent = background
		playerid.BackgroundTransparency = 1
		playerid.BorderSizePixel = 0
		playerid.Position = UDim2.new(0, 5, 0, 35)
		playerid.Size = UDim2.new(0, 100, 0, 20)
		playerid.ZIndex = 10
		playerid.Font = Enum.Font.SourceSans
		playerid.FontSize = Enum.FontSize.Size14
		playerid.Text = "Player ID: LOADING"
		playerid.TextColor3 = currentText1
		playerid.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,playerid)

		players.Name = "players"
		players.Parent = background
		players.BackgroundTransparency = 1
		players.BorderSizePixel = 0
		players.Position = UDim2.new(0, 5, 0, 155)
		players.Size = UDim2.new(0, 100, 0, 20)
		players.ZIndex = 10
		players.Font = Enum.Font.SourceSans
		players.FontSize = Enum.FontSize.Size14
		players.Text = "LOADING"
		players.TextColor3 = currentText1
		players.TextXAlignment = Enum.TextXAlignment.Left
		table.insert(text1,players)

		CopyApp.Name = "CopyApp"
		CopyApp.Parent = background
		CopyApp.BackgroundColor3 = currentShade2
		CopyApp.BorderSizePixel = 0
		CopyApp.Position = UDim2.new(0, 210, 0, 55)
		CopyApp.Size = UDim2.new(0, 35, 0, 20)
		CopyApp.Font = Enum.Font.SourceSans
		CopyApp.TextSize = 14
		CopyApp.Text = "Copy"
		CopyApp.TextColor3 = currentText1
		CopyApp.ZIndex = 10
		table.insert(shade2,CopyApp)
		table.insert(text1,CopyApp)

		CopyPlrID.Name = "CopyPlrID"
		CopyPlrID.Parent = background
		CopyPlrID.BackgroundColor3 = currentShade2
		CopyPlrID.BorderSizePixel = 0
		CopyPlrID.Position = UDim2.new(0, 210, 0, 35)
		CopyPlrID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlrID.Font = Enum.Font.SourceSans
		CopyPlrID.TextSize = 14
		CopyPlrID.Text = "Copy"
		CopyPlrID.TextColor3 = currentText1
		CopyPlrID.ZIndex = 10
		table.insert(shade2,CopyPlrID)
		table.insert(text1,CopyPlrID)

		CopyPlcID.Name = "CopyPlcID"
		CopyPlcID.Parent = background
		CopyPlcID.BackgroundColor3 = currentShade2
		CopyPlcID.BorderSizePixel = 0
		CopyPlcID.Position = UDim2.new(0, 210, 0, 195)
		CopyPlcID.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcID.Font = Enum.Font.SourceSans
		CopyPlcID.TextSize = 14
		CopyPlcID.Text = "Copy"
		CopyPlcID.TextColor3 = currentText1
		CopyPlcID.ZIndex = 10
		table.insert(shade2,CopyPlcID)
		table.insert(text1,CopyPlcID)

		CopyPlcName.Name = "CopyPlcName"
		CopyPlcName.Parent = background
		CopyPlcName.BackgroundColor3 = currentShade2
		CopyPlcName.BorderSizePixel = 0
		CopyPlcName.Position = UDim2.new(0, 210, 0, 215)
		CopyPlcName.Size = UDim2.new(0, 35, 0, 20)
		CopyPlcName.Font = Enum.Font.SourceSans
		CopyPlcName.TextSize = 14
		CopyPlcName.Text = "Copy"
		CopyPlcName.TextColor3 = currentText1
		CopyPlcName.ZIndex = 10
		table.insert(shade2,CopyPlcName)
		table.insert(text1,CopyPlcName)

		local SINFOGUI = background
		FRAME:TweenPosition(UDim2.new(0.5, -130, 0, 100), "InOut", "Quart", 0.5, true, nil) 
		wait(0.5)
		Exit.MouseButton1Click:Connect(function()
			FRAME:TweenPosition(UDim2.new(0.5, -130, 0, -500), "InOut", "Quart", 0.5, true, nil) 
			wait(0.6)
			FRAME:Destroy()
			canOpenServerinfo = true
		end)
		local Asset = MarketplaceService:GetProductInfo(PlaceId)
		SINFOGUI.name.Text = "Place Name: " .. Asset.Name
		SINFOGUI.playerid.Text = "Player ID: " ..speaker.UserId
		SINFOGUI.maxplayers.Text = Players.MaxPlayers.. " Players Max"
		SINFOGUI.placeid.Text = "Place ID: " ..PlaceId

		CopyApp.MouseButton1Click:Connect(function()
			toClipboard(speaker.CharacterAppearanceId)
		end)
		CopyPlrID.MouseButton1Click:Connect(function()
			toClipboard(speaker.UserId)
		end)
		CopyPlcID.MouseButton1Click:Connect(function()
			toClipboard(PlaceId)
		end)
		CopyPlcName.MouseButton1Click:Connect(function()
			toClipboard(Asset.Name)
		end)

		repeat
			players = Players:GetPlayers()
			SINFOGUI.players.Text = #players.. " Player(s)"
			SINFOGUI.appearance.Text = "Appearance: " ..speaker.CharacterAppearanceId
			local seconds = math.floor(workspace.DistributedGameTime)
			local minutes = math.floor(workspace.DistributedGameTime / 60)
			local hours = math.floor(workspace.DistributedGameTime / 60 / 60)
			local seconds = seconds - (minutes * 60)
			local minutes = minutes - (hours * 60)
			if hours < 1 then if minutes < 1 then
					SINFOGUI.Time.Text = seconds .. " Second(s)" else
					SINFOGUI.Time.Text = minutes .. " Minute(s), " .. seconds .. " Second(s)"
				end
			else
				SINFOGUI.Time.Text = hours .. " Hour(s), " .. minutes .. " Minute(s), " .. seconds .. " Second(s)"
			end
			wait(1)
		until SINFOGUI.Parent == nil
	end)
end)

addcmd("jobid", {}, function(args, speaker)
	toClipboard("roblox://placeId=" .. PlaceId .. "&gameInstanceId=" .. JobId)
end)

addcmd('notifyjobid',{},function(args, speaker)
	notify('JobId / PlaceId',JobId..' / '..PlaceId)
end)

addcmd('breakloops',{'break'},function(args, speaker)
	lastBreakTime = tick()
end)

addcmd('gametp',{'gameteleport'},function(args, speaker)
	TeleportService:Teleport(args[1])
end)

teleportRespawnHandler = [[
local ok, data = pcall(function() return game:GetService("TeleportService"):GetLocalPlayerTeleportData() end)
if ok and typeof(data) == "CFrame" then
    local Players = game:GetService("Players")
    local ME = Players.LocalPlayer
    while not ME do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        ME = Players.LocalPlayer
    end

    local Character = ME.Character or ME.CharacterAdded:Wait()
    Character:WaitForChild("HumanoidRootPart")

    local t = tick()
    while (tick() - t) <= 0.3 do
        Character:PivotTo(data)
        task.wait()
    end
end
]]
addcmd("rejoin", {"rj"}, function(args, speaker)
    local data = nil
    if parseBoolean(args[1], false) == true then
        if queueteleport then
            if speaker.Character then
                data = speaker.Character:GetPivot()
                queueteleport(teleportRespawnHandler)
            end
        else
            notify("Incompatible Exploit", "Your exploit does not support this argument (missing queue_on_teleport)")
        end
    end

    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("\nRejoining...")
        task.wait(0.3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer, data)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer, nil, data)
    end
end)

addcmd("inviteprompt", {}, function(args, speaker)
    local player = getPlayer(args[1], speaker)[1]
    local target = player and Players:FindFirstChild(player)
    if not target then return end
    local success, err = pcall(function()
        ExperienceService:LaunchExperience({
            placeId = PlaceId,
            gameInstanceId = JobId,
            referredByPlayerId = target.UserId
        })
    end)
    if success then
        return "Prompted user. Rejoin for it to work."
    else
        return "There was an error in game:GetService('ExperienceService'):LaunchExperience(). Contact the developer of your exploit."
    end
end)

addcmd("autorejoin", {"autorj"}, function(args, speaker)
	GuiService.ErrorMessageChanged:Connect(function()
		execCmd("rejoin")
	end)
	notify("Auto Rejoin", "Auto rejoin enabled")
end)

addcmd("serverhop", {"shop"}, function(args, speaker)
	-- thanks to Amity for fixing
	local servers = {}
	local req = game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
	local body = HttpService:JSONDecode(req)

	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
				table.insert(servers, 1, v.id)
			end
		end
	end

	if #servers > 0 then
		TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], Players.LocalPlayer)
	else
		return notify("Serverhop", "Couldn't find a server.")
	end
end)

addcmd("exit", {"shutdown", "leave"}, function(args, speaker)
	game:Shutdown()
end)

local NoclipParts = {}
local Noclipping = nil
addcmd("noclip", {}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = false
    task.wait(0.1)
    NoclipParts = {}
    Noclipping = RunService.Stepped:Connect(function()
        if Clip == false and speaker.Character ~= nil then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                    NoclipParts[child] = true
                end
            end
        end
    end)
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Enabled")
end)

addcmd("unnoclip", {"clip"}, function(args, speaker)
    pcall(function() Noclipping:Disconnect() end)
    Clip = true
    task.wait(0.1)
    for child, _ in pairs(NoclipParts) do
        if typeof(child) == "Instance" and child:IsA("BasePart") and child.Parent then
            child.CanCollide = true
        end
    end
    NoclipParts = {}
    if args[1] and args[1] == "nonotify" then return end
    notify("Noclip", "Noclip Disabled")
end)

addcmd("togglenoclip", {}, function(args, speaker)
    execCmd(Clip and "noclip" or "unnoclip")
end)

FLYING = false
QEfly = true
iyflyspeed = 1
vehicleflyspeed = 1
function sFLY(vfly)
	local plr = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end

	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end

	local T = getRoot(char)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end

				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()

			if humanoid then humanoid.PlatformStand = false end
		end)
	end

	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() camera.CameraType = Enum.CameraType.Track end)
	end)

	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then
			CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then
			CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then
			CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then
			CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then
			CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local velocityHandlerName = randomString()
local gyroHandlerName = randomString()
local mfly1
local mfly2

local unmobilefly = function(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		root:FindFirstChild(velocityHandlerName):Destroy()
		root:FindFirstChild(gyroHandlerName):Destroy()
		speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
		mfly1:Disconnect()
		mfly2:Disconnect()
	end)
end

local mobilefly = function(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true

	local root = getRoot(speaker.Character)
	local camera = workspace.CurrentCamera
	local v3none = Vector3.new()
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf = Vector3.new(9e9, 9e9, 9e9)

	local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero

	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50

	mfly1 = speaker.CharacterAdded:Connect(function()
		local bv = Instance.new("BodyVelocity")
		bv.Name = velocityHandlerName
		bv.Parent = root
		bv.MaxForce = v3zero
		bv.Velocity = v3zero

		local bg = Instance.new("BodyGyro")
		bg.Name = gyroHandlerName
		bg.Parent = root
		bg.MaxTorque = v3inf
		bg.P = 1000
		bg.D = 50
	end)

	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VelocityHandler = root:FindFirstChild(velocityHandlerName)
			local GyroHandler = root:FindFirstChild(gyroHandlerName)

			VelocityHandler.MaxForce = v3inf
			GyroHandler.MaxTorque = v3inf
			if not vfly then humanoid.PlatformStand = true end
			GyroHandler.CFrame = camera.CoordinateFrame
			VelocityHandler.Velocity = v3none

			local direction = controlModule:GetMoveVector()
			if direction.X > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.X < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z > 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
			if direction.Z < 0 then
				VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50))
			end
		end
	end)
end

addcmd('fly',{},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY()
	else
		mobilefly(speaker)
	end
	if args[1] and isNumber(args[1]) then
		iyflyspeed = args[1]
	end
end)

addcmd('flyspeed',{'flysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		iyflyspeed = speed
	end
end)

addcmd('unfly',{'nofly','novfly','unvehiclefly','novehiclefly','unvfly'},function(args, speaker)
	if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
end)

addcmd('vfly',{'vehiclefly'},function(args, speaker)
	if not IsOnMobile then
		NOFLY()
		wait()
		sFLY(true)
	else
		mobilefly(speaker, true)
	end
	if args[1] and isNumber(args[1]) then
		vehicleflyspeed = args[1]
	end
end)

addcmd('togglevfly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY(true) else mobilefly(speaker, true) end
	end
end)

addcmd('vflyspeed',{'vflysp','vehicleflyspeed','vehicleflysp'},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		vehicleflyspeed = speed
	end
end)

addcmd('qefly',{'flyqe'},function(args, speaker)
	if args[1] == 'false' then
		QEfly = false
	else
		QEfly = true
	end
end)

addcmd('togglefly',{},function(args, speaker)
	if FLYING then
		if not IsOnMobile then NOFLY() else unmobilefly(speaker) end
	else
		if not IsOnMobile then sFLY() else mobilefly(speaker) end
	end
end)

CFspeed = 50
addcmd('cframefly', {'cfly'}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		CFspeed = args[1]
	end

	-- Full credit to peyton#9148 (apeyton)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
	local Head = speaker.Character:WaitForChild("Head")
	Head.Anchored = true
	if CFloop then CFloop:Disconnect() end
	CFloop = RunService.Heartbeat:Connect(function(deltaTime)
		local moveDirection = speaker.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
		local headCFrame = Head.CFrame
		local camera = workspace.CurrentCamera
		local cameraCFrame = camera.CFrame
		local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
		cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
		local cameraPosition = cameraCFrame.Position
		local headPosition = headCFrame.Position

		local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
		Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
	end)
end)

addcmd('uncframefly',{'uncfly'},function(args, speaker)
	if CFloop then
		CFloop:Disconnect()
		speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
		local Head = speaker.Character:WaitForChild("Head")
		Head.Anchored = false
	end
end)

addcmd('cframeflyspeed',{'cflyspeed'},function(args, speaker)
	if isNumber(args[1]) then
		CFspeed = args[1]
	end
end)

floating = false
local beganListener: RBXScriptConnection
local endListener: RBXScriptConnection
local floatingFunc: RBXScriptConnection

addcmd('float', {'platform'},function(args, speaker)
	local pchar = speaker.Character
	floatName = randomString()
	floating = true
	
	if pchar and not pchar:FindFirstChild(floatName) then
		task.spawn(function()
			local floatPoint = -3.1
			local floatPart = Instance.new('Part')
			floatPart.Name = floatName
			floatPart.Parent = pchar
			floatPart.Transparency = 1
			floatPart.Size = Vector3.new(2, 0.2, 1.5)
			floatPart.Anchored = true
			
			notify('Float', 'Started floating (Q = down & E = up)')
			
			beganListener = UserInputService.InputBegan:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint -= 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint += 1.5
				end
			end)
			endListener = UserInputService.InputEnded:Connect(function(key, processed)
				if processed then return end

				if key.KeyCode == Enum.KeyCode.Q then
					floatPoint += 0.5
				end
				if key.KeyCode == Enum.KeyCode.E then
					floatPoint -= 1.5
				end
			end)
			
			floatDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
				floatingFunc:Disconnect()
				floatPart:Destroy()
				floatDied:Disconnect()
				beganListener:Disconnect()
				endListener:Disconnect()
				floatName = nil
			end)
			local function floatPadLoop()
				if pchar:FindFirstChild(floatName) and getRoot(pchar) then
					floatPart.CFrame = getRoot(pchar).CFrame * CFrame.new(0, floatPoint, 0)
				else
					floatingFunc:Disconnect()
					floatPart:Destroy()
					floatDied:Disconnect()
					beganListener:Disconnect()
					endListener:Disconnect()
					floatName = nil
				end
			end			
			floatingFunc = RunService.PreAnimation:Connect(floatPadLoop)
		end)
	end
end)

addcmd('unfloat',{'nofloat','unplatform','noplatform'},function(args, speaker)
	floating = false
	local pchar = speaker.Character
	notify('Float', 'Stopped floating')
	if pchar:FindFirstChild(floatName) then
		pchar:FindFirstChild(floatName):Destroy()
	end
	if floatDied then
		floatingFunc:Disconnect()
		floatDied:Disconnect()
		beganListener:Disconnect()
		endListener:Disconnect()
		floatName = nil
	end
end)

addcmd('togglefloat',{},function(args, speaker)
	if floating then
		execCmd('unfloat')
	else
		execCmd('float')
	end
end)

swimming = false
local oldgrav = workspace.Gravity
local swimbeat = nil
addcmd('swim',{},function(args, speaker)
	if not swimming and speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		oldgrav = workspace.Gravity
		workspace.Gravity = 0
		local swimDied = function()
			workspace.Gravity = oldgrav
			swimming = false
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		gravReset = Humanoid.Died:Connect(swimDied)
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, false)
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		swimbeat = RunService.Heartbeat:Connect(function()
			pcall(function()
				getRoot(speaker.Character).Velocity = ((Humanoid.MoveDirection ~= Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(speaker.Character).Velocity or Vector3.new())
			end)
		end)
		swimming = true
	end
end)

addcmd('unswim',{'noswim'},function(args, speaker)
	if speaker and speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid") then
		workspace.Gravity = oldgrav
		swimming = false
		if gravReset then
			gravReset:Disconnect()
		end
		if swimbeat ~= nil then
			swimbeat:Disconnect()
			swimbeat = nil
		end
		local Humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
		local enums = Enum.HumanoidStateType:GetEnumItems()
		table.remove(enums, table.find(enums, Enum.HumanoidStateType.None))
		for i, v in pairs(enums) do
			Humanoid:SetStateEnabled(v, true)
		end
	end
end)

addcmd('toggleswim',{},function(args, speaker)
	if swimming then
		execCmd('unswim')
	else
		execCmd('swim')
	end
end)

addcmd('setwaypoint',{'swp','setwp','spos','saveposition','savepos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		local torso = getRoot(speaker.Character)
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {math.floor(torso.Position.X), math.floor(torso.Position.Y), math.floor(torso.Position.Z)}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypointpos',{'wpp','setwaypointposition','setpos','setwaypoint','setwaypointpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if getRoot(speaker.Character) then
		notify('Modified Waypoints',"Created waypoint: "..getstring(1, args))
		WayPoints[#WayPoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		if AllWaypoints ~= nil then
			AllWaypoints[#AllWaypoints + 1] = {NAME = WPName, COORD = {args[2], args[3], args[4]}, GAME = PlaceId}
		end
	end	
	refreshwaypoints()
	updatesaves()
end)

addcmd('waypoints',{'positions'},function(args, speaker)
	if SettingsOpen == false then SettingsOpen = true
		Settings:TweenPosition(UDim2.new(0, 0, 0, 45), "InOut", "Quart", 0.5, true, nil)
		CMDsF.Visible = false
	end
	KeybindsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	AliasesFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PluginsFrame:TweenPosition(UDim2.new(0, 0, 0, 175), "InOut", "Quart", 0.5, true, nil)
	PositionsFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true, nil)
	wait(0.5)
	SettingsHolder.Visible = false
	maximizeHolder()
end)

waypointParts = {}
addcmd('showwaypoints',{'showwp','showwps'},function(args, speaker)
	execCmd('hidewaypoints')
	wait()
	for i,_ in pairs(WayPoints) do
		local x = WayPoints[i].COORD[1]
		local y = WayPoints[i].COORD[2]
		local z = WayPoints[i].COORD[3]
		local part = Instance.new("Part")
		part.Size = Vector3.new(5,5,5)
		part.CFrame = CFrame.new(x,y,z)
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		table.insert(waypointParts,part)
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = part
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = part.Size
		view.Parent = part
	end
	for i,v in pairs(pWayPoints) do
		local view = Instance.new("BoxHandleAdornment")
		view.Adornee = pWayPoints[i].COORD[1]
		view.AlwaysOnTop = true
		view.ZIndex = 10
		view.Size = pWayPoints[i].COORD[1].Size
		view.Parent = pWayPoints[i].COORD[1]
		table.insert(waypointParts,view)
	end
end)

addcmd('hidewaypoints',{'hidewp','hidewps'},function(args, speaker)
	for i,v in pairs(waypointParts) do
		v:Destroy()
	end
	waypointParts = {}
end)

addcmd('waypoint',{'wp','lpos','loadposition','loadpos'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				local x = WayPoints[i].COORD[1]
				local y = WayPoints[i].COORD[2]
				local z = WayPoints[i].COORD[3]
				getRoot(speaker.Character).CFrame = CFrame.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				getRoot(speaker.Character).CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

tweenSpeed = 1
addcmd('tweenspeed',{'tspeed'},function(args, speaker)
	local newSpeed = args[1] or 1
	if tonumber(newSpeed) then
		tweenSpeed = tonumber(newSpeed)
	end
end)

addcmd('tweenwaypoint',{'twp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(x,y,z)}):Play()
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pWayPoints[i].COORD[1].Position)}):Play()
			end
		end
	end
end)

addcmd('walktowaypoint',{'wtwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(x,y,z)
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(pWayPoints[i].COORD[1].Position)
			end
		end
	end
end)

addcmd('deletewaypoint',{'dwp','dpos','deleteposition','deletepos'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.NAME:lower() == tostring(getstring(1, args)):lower() then
				if not v.GAME or v.GAME == PlaceId then
					table.remove(AllWaypoints, i)
				end
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.NAME:lower() == tostring(getstring(1, args)):lower() then
			notify('Modified Waypoints',"Deleted waypoint: " .. v.NAME)
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
end)

addcmd('clearwaypoints',{'cwp','clearpositions','cpos','clearpos'},function(args, speaker)
	WayPoints = {}
	pWayPoints = {}
	refreshwaypoints()
	updatesaves()
	AllWaypoints = {}
	notify('Modified Waypoints','Removed all waypoints')
end)

addcmd('cleargamewaypoints',{'cgamewp'},function(args, speaker)
	for i,v in pairs(WayPoints) do
		if v.GAME == PlaceId then
			table.remove(WayPoints, i)
		end
	end
	if AllWaypoints ~= nil and #AllWaypoints > 0 then
		for i,v in pairs(AllWaypoints) do
			if v.GAME == PlaceId then
				table.remove(AllWaypoints, i)
			end
		end
	end
	for i,v in pairs(pWayPoints) do
		if v.GAME == PlaceId then
			table.remove(pWayPoints, i)
		end
	end
	refreshwaypoints()
	updatesaves()
	notify('Modified Waypoints','Deleted game waypoints')
end)


local coreGuiTypeNames = {
	-- predefined aliases
	["inventory"] = Enum.CoreGuiType.Backpack,
	["leaderboard"] = Enum.CoreGuiType.PlayerList,
	["emotes"] = Enum.CoreGuiType.EmotesMenu
}

-- Load the full list of enums
for _, enumItem in ipairs(Enum.CoreGuiType:GetEnumItems()) do
	coreGuiTypeNames[enumItem.Name:lower()] = enumItem
end

addcmd('enable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", true)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
			end
		end
	end
end)

addcmd('disable',{},function(args, speaker)
	local input = args[1] and args[1]:lower()
	if input then
		if input == "reset" then
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			local coreGuiType = coreGuiTypeNames[input]
			if coreGuiType then
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		end
	end
end)

local invisGUIS = {}
addcmd('showguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and not v.Visible then
			v.Visible = true
			if not FindInTable(invisGUIS,v) then
				table.insert(invisGUIS,v)
			end
		end
	end
end)

addcmd('unshowguis',{},function(args, speaker)
	for i,v in pairs(invisGUIS) do
		v.Visible = false
	end
	invisGUIS = {}
end)

local hiddenGUIS = {}
addcmd('hideguis',{},function(args, speaker)
	for i,v in pairs(PlayerGui:GetDescendants()) do
		if (v:IsA("Frame") or v:IsA("ImageLabel") or v:IsA("ScrollingFrame")) and v.Visible then
			v.Visible = false
			if not FindInTable(hiddenGUIS,v) then
				table.insert(hiddenGUIS,v)
			end
		end
	end
end)

addcmd('unhideguis',{},function(args, speaker)
	for i,v in pairs(hiddenGUIS) do
		v.Visible = true
	end
	hiddenGUIS = {}
end)

function deleteGuisAtPos()
	pcall(function()
		local guisAtPosition = PlayerGui:GetGuiObjectsAtPosition(IYMouse.X, IYMouse.Y)
		for _, gui in pairs(guisAtPosition) do
			if gui.Visible == true then
				gui:Destroy()
			end
		end
	end)
end

local deleteGuiInput
addcmd('guidelete',{},function(args, speaker)
	deleteGuiInput = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent then
			if input.KeyCode == Enum.KeyCode.Backspace then
				deleteGuisAtPos()
			end
		end
	end)
	notify('GUI Delete Enabled','Hover over a GUI and press backspace to delete it')
end)

addcmd('unguidelete',{'noguidelete'},function(args, speaker)
	if deleteGuiInput then deleteGuiInput:Disconnect() end
	notify('GUI Delete Disabled','GUI backspace delete has been disabled')
end)

local wasStayOpen = StayOpen
addcmd('hideiy',{},function(args, speaker)
	isHidden = true
	wasStayOpen = StayOpen
	if StayOpen == true then
		StayOpen = false
		On.BackgroundTransparency = 1
	end
	minimizeNum = 0
	minimizeHolder()
	if not (args[1] and tostring(args[1]) == 'nonotify') then notify('IY Hidden','You can press the prefix key to access the command bar') end
end)

addcmd('showiy',{'unhideiy'},function(args, speaker)
	isHidden = false
	minimizeNum = -20
	if wasStayOpen then
		maximizeHolder()
		StayOpen = true
		On.BackgroundTransparency = 0
	else
		minimizeHolder()
	end
end)

addcmd('rec', {'record'}, function(args, speaker)
	return COREGUI:ToggleRecording()
end)

addcmd('screenshot', {'scrnshot'}, function(args, speaker)
	return COREGUI:TakeScreenshot()
end)

addcmd('togglefs', {'togglefullscreen'}, function(args, speaker)
	return GuiService:ToggleFullscreen()
end)

addcmd('inspect', {'examine'}, function(args, speaker)
	for _, v in ipairs(getPlayer(args[1], speaker)) do
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(Players[v].UserId)
	end
end)

addcmd("savegame", {"saveplace"}, function(args, speaker)
	if saveinstance then
		notify("Loading", "Downloading game. This will take a while")
		saveinstance()
		notify("Game Saved", "Saved place to the workspace folder within your exploit folder.")
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing saveinstance)")
	end
end)

addcmd("clearerror", {"clearerrors"}, function(args, speaker)
    GuiService:ClearError()
end)

addcmd("antigameplaypaused", {}, function(args, speaker)
    pcall(function() networkPaused:Disconnect() end)
    networkPaused = COREGUI.RobloxGui.ChildAdded:Connect(function(obj)
        if obj.Name == "CoreScripts/NetworkPause" then
            obj:Destroy()
        end
    end)
    COREGUI.RobloxGui["CoreScripts/NetworkPause"]:Destroy()
end)

addcmd("unantigameplaypaused", {}, function(args, speaker)
    networkPaused:Disconnect()
end)

addcmd('clientantikick',{'antikick'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end
	local LocalPlayer = Players.LocalPlayer
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    	local method = getnamecallmethod and getnamecallmethod() or ""
    	if select(1, ...) == LocalPlayer and method == "Kick" or method == "kick" then
        	return nil
    	end
    	return oldNamecall(...)
	end))
	hookfunction(LocalPlayer.Kick, newcclosure(function(self, _)
    	if self ~= lp then
        	error("Expected ':' not '.' calling member function Kick", 2)
    	end
    	return nil
	end))

	notify('Client Antikick','Client anti kick is now active (only effective on LocalScript kick)')
end)

allow_rj = true
addcmd('clientantiteleport',{'antiteleport'},function(args, speaker)
	if not hookmetamethod then 
		return notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
	end

	local oldTp; oldTp = hookfunction(TeleportService.Teleport, newcclosure(function(self, placeId, player, _teleportData, customLoadingScreen)
		if checkcaller() or (allow_rj and placeId == game.PlaceId) then
			return oldTp(self, placeId, player, _teleportData, customLoadingScreen)
		end
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function Teleport", 2)
		end
		if placeId == nil then
			error("Argument 1 missing or nil", 2)
		end
		if typeof(placeId) ~= "number" and placeId ~= true then
			error(`Unable to cast {typeof(placeId)} to int64`, 2)
		elseif placeId == true then
			-- somehow raise raiseTeleportInitFailedEvent
			return
		end
		if typeof(customLoadingScreen) ~= "Instance" and customLoadingScreen ~= nil then
			error("Unable to cast value to Object", 2)
		end
		return nil
	end))
	hookfunction(TeleportService.TeleportAsync, newcclosure(function(self, placeId, players, teleportOptions)
		if self ~= TeleportService then
			error("Expected ':' not '.' calling member function TeleportAsync", 2)
		end
		if players == nil then
			error("Argument 2 missing or nil", 2)
		end
		if typeof(players) ~= "table" then
			error("Unable to cast value to Objects", 2)
		end
		error("TeleportUnknown must be called from a Server", 2)
	end))
	local oldNamecall; oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
		local nmc = getnamecallmethod()
		if select(1, ...) == TeleportService and nmc == "teleport" or nmc == "Teleport" or nmc == "TeleportToPlaceInstance" or nmc == "TeleportAsync" then
			if checkcaller() or (allow_rj and select(2, ...) == game.PlaceId) then
				return oldNamecall(...)
			end
			return
		end
		return oldNamecall(...)
	end))

	notify('Client AntiTP','Client anti teleport is now active (only effective on LocalScript teleport)')
end)

addcmd('allowrejoin',{'allowrj'},function(args, speaker)
	allow_rj = not allow_rj
	notify("Client AntiTP", `Scripts now may{allow_rj and "" or " not"} make you rejoin the server`)
end)

addcmd("cancelteleport", {"canceltp"}, function(args, speaker)
	TeleportService:TeleportCancel()
end)

addcmd("volume",{ "vol"}, function(args, speaker)
	UserSettings():GetService("UserGameSettings").MasterVolume = args[1]/10
end)

addcmd("antilag", {"boostfps", "lowgraphics"}, function(args, speaker)
	local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e9
	Lighting.FogStart = 9e9
	settings().Rendering.QualityLevel = 1
	for _, v in pairs(game:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CastShadow = false
			v.Material = "Plastic"
			v.Reflectance = 0
			v.BackSurface = "SmoothNoOutlines"
			v.BottomSurface = "SmoothNoOutlines"
			v.FrontSurface = "SmoothNoOutlines"
			v.LeftSurface = "SmoothNoOutlines"
			v.RightSurface = "SmoothNoOutlines"
			v.TopSurface = "SmoothNoOutlines"
		elseif v:IsA("Decal") then
			v.Transparency = 1
			v.Texture = ""
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		end
	end
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	workspace.DescendantAdded:Connect(function(child)
		task.spawn(function()
			if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
				RunService.Heartbeat:Wait()
				child:Destroy()
			elseif child:IsA("BasePart") then
				child.CastShadow = false
			end
		end)
	end)
end)

addcmd("setfpscap", {"fpscap", "maxfps"}, function(args, speaker)
	if fpscaploop then
		task.cancel(fpscaploop)
		fpscaploop = nil
	end

	local fpsCap = 60
	local num = tonumber(args[1]) or 1e6
	if num == "none" then
		return
	elseif num > 0 then
		fpsCap = num
	else
		return notify("Invalid argument", "Please provide a number above 0 or 'none'.")
	end

	if setfpscap and type(setfpscap) == "function" then
		setfpscap(fpsCap)
	else
		fpscaploop = task.spawn(function()
			local timer = os.clock()
			while true do
				if os.clock() >= timer + 1 / fpsCap then
					timer = os.clock()
					task.wait()
				end
			end
		end)
	end
end)

addcmd('notify',{},function(args, speaker)
	notify(getstring(1, args))
end)

addcmd('lastcommand',{'lastcmd'},function(args, speaker)
	if cmdHistory[1]:sub(1,11) ~= 'lastcommand' and cmdHistory[1]:sub(1,7) ~= 'lastcmd' then
		execCmd(cmdHistory[1])
	end
end)

addcmd('esp',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('espteam',{},function(args, speaker)
	if not CHMSenabled then
		ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				ESP(v, true)
			end
		end
	else
		notify('ESP','Disable chams (nochams) before using esp')
	end
end)

addcmd('noesp',{'unesp','unespteam'},function(args, speaker)
	ESPenabled = false
	for i,c in pairs(COREGUI:GetChildren()) do
		if string.sub(c.Name, -4) == '_ESP' then
			c:Destroy()
		end
	end
end)

addcmd("esptransparency", {}, function(args, speaker)
    espTransparency = tonumber(args[1]) or 0.3
    if ESPenabled then execCmd("esp") end
    if CHMSenabled then execCmd("chams") end
    updatesaves()
end)

local espParts = {}
local partEspTrigger = nil
function partAdded(part)
	if #espParts > 0 then
		if FindInTable(espParts,part.Name:lower()) then
			local a = Instance.new("BoxHandleAdornment")
			a.Name = part.Name:lower().."_PESP"
			a.Parent = part
			a.Adornee = part
			a.AlwaysOnTop = true
			a.ZIndex = 0
			a.Size = part.Size
			a.Transparency = espTransparency
			a.Color = BrickColor.new("Lime green")
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
	end
end

addcmd('partesp',{},function(args, speaker)
	local partEspName = getstring(1, args):lower()
	if not FindInTable(espParts,partEspName) then
		table.insert(espParts,partEspName)
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partEspName then
				local a = Instance.new("BoxHandleAdornment")
				a.Name = partEspName.."_PESP"
				a.Parent = v
				a.Adornee = v
				a.AlwaysOnTop = true
				a.ZIndex = 0
				a.Size = v.Size
				a.Transparency = espTransparency
				a.Color = BrickColor.new("Lime green")
			end
		end
	end
	if partEspTrigger == nil then
		partEspTrigger = workspace.DescendantAdded:Connect(partAdded)
	end
end)

addcmd('unpartesp',{'nopartesp'},function(args, speaker)
	if args[1] then
		local partEspName = getstring(1, args):lower()
		if FindInTable(espParts,partEspName) then
			table.remove(espParts, GetInTable(espParts, partEspName))
		end
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name == partEspName..'_PESP' then
				v:Destroy()
			end
		end
	else
		partEspTrigger:Disconnect()
		partEspTrigger = nil
		espParts = {}
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BoxHandleAdornment") and v.Name:sub(-5) == '_PESP' then
				v:Destroy()
			end
		end
	end
end)

addcmd('chams',{},function(args, speaker)
	if not ESPenabled then
		CHMSenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= speaker.Name then
				CHMS(v)
			end
		end
	else
		notify('Chams','Disable ESP (noesp) before using chams')
	end
end)

addcmd('nochams',{'unchams'},function(args, speaker)
	CHMSenabled = false
	for i,v in pairs(Players:GetPlayers()) do
		local chmsplr = v
		for i,c in pairs(COREGUI:GetChildren()) do
			if c.Name == chmsplr.Name..'_CHMS' then
				c:Destroy()
			end
		end
	end
end)

addcmd('locate',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		Locate(Players[v])
	end
end)

addcmd('nolocate',{'unlocate'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if args[1] then
		for i,v in pairs(players) do
			for i,c in pairs(COREGUI:GetChildren()) do
				if c.Name == Players[v].Name..'_LC' then
					c:Destroy()
				end
			end
		end
	else
		for i,c in pairs(COREGUI:GetChildren()) do
			if string.sub(c.Name, -3) == '_LC' then
				c:Destroy()
			end
		end
	end
end)

viewing = nil
addcmd('view',{'spectate'},function(args, speaker)
	StopFreecam()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if viewDied then
			viewDied:Disconnect()
			viewChanged:Disconnect()
		end
		viewing = Players[v]
		workspace.CurrentCamera.CameraSubject = viewing.Character
		notify('Spectate','Viewing ' .. Players[v].Name)
		local function viewDiedFunc()
			repeat wait() until Players[v].Character ~= nil and getRoot(Players[v].Character)
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewDied = Players[v].CharacterAdded:Connect(viewDiedFunc)
		local function viewChangedFunc()
			workspace.CurrentCamera.CameraSubject = viewing.Character
		end
		viewChanged = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(viewChangedFunc)
	end
end)

addcmd('viewpart',{'viewp'},function(args, speaker)
	StopFreecam()
	if args[1] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
				wait(0.1)
				workspace.CurrentCamera.CameraSubject = v
			end
		end
	end
end)

addcmd('unview',{'unspectate'},function(args, speaker)
	StopFreecam()
	if viewing ~= nil then
		viewing = nil
		notify('Spectate','View turned off')
	end
	if viewDied then
		viewDied:Disconnect()
		viewChanged:Disconnect()
	end
	workspace.CurrentCamera.CameraSubject = speaker.Character
end)


fcRunning = false
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local newCamera = workspace.CurrentCamera
	if newCamera then
		Camera = newCamera
	end
end)

local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()

local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			ContextActionService:BindActionAtPriority("FreecamKeyboard",Keypress,false,INPUT_PRIORITY,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.E,
				Enum.KeyCode.Q,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down
			)
			ContextActionService:BindActionAtPriority("FreecamMousePan",MousePan,false,INPUT_PRIORITY,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			ContextActionService:UnbindAction("FreecamKeyboard")
			ContextActionService:UnbindAction("FreecamMousePan")
		end
	end
end

function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = Camera.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local function StepFreecam(dt)
	local vel = velSpring:Update(dt, Input.Vel(dt))
	local pan = panSpring:Update(dt, Input.Pan(dt))

	local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

	cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
	cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

	local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
	cameraPos = cameraCFrame.p

	Camera.CFrame = cameraCFrame
	Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
	Camera.FieldOfView = cameraFov
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = Camera.FieldOfView
		Camera.FieldOfView = 70

		cameraType = Camera.CameraType
		Camera.CameraType = Enum.CameraType.Custom

		cameraCFrame = Camera.CFrame
		cameraFocus = Camera.Focus

		mouseIconEnabled = UserInputService.MouseIconEnabled
		UserInputService.MouseIconEnabled = true

		mouseBehavior = UserInputService.MouseBehavior
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		Camera.FieldOfView = 70

		Camera.CameraType = cameraType
		cameraType = nil

		Camera.CFrame = cameraCFrame
		cameraCFrame = nil

		Camera.Focus = cameraFocus
		cameraFocus = nil

		UserInputService.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		UserInputService.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

function StartFreecam(pos)
	if fcRunning then
		StopFreecam()
	end
	local cameraCFrame = Camera.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = Camera.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
	Input.StartCapture()
	fcRunning = true
end

function StopFreecam()
    if not fcRunning then return end
    Input.StopCapture()
    RunService:UnbindFromRenderStep("Freecam")
    PlayerState.Pop()
    workspace.Camera.FieldOfView = 70
    fcRunning = false
end

addcmd("freecam", {"fcam", "fc"},function(args, speaker)
    StartFreecam()
end)

addcmd("freecampos", {"fcpos", "fcp", "freecamposition", "fcposition"},function(args, speaker)
    if not args[1] then return end
    local freecamPos = CFrame.new(args[1], args[2], args[3])
    StartFreecam(freecamPos)
end)

addcmd('freecamwaypoint',{'fcwp'},function(args, speaker)
	local WPName = tostring(getstring(1, args))
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			local x = WayPoints[i].COORD[1]
			local y = WayPoints[i].COORD[2]
			local z = WayPoints[i].COORD[3]
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(x,y,z))
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				StartFreecam(CFrame.new(pWayPoints[i].COORD[1].Position))
			end
		end
	end
end)

addcmd('freecamgoto',{'fcgoto','freecamtp','fctp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		StartFreecam(getRoot(Players[v].Character).CFrame)
	end
end)

addcmd('unfreecam',{'nofreecam','unfc','nofc'},function(args, speaker)
	StopFreecam()
end)

addcmd('freecamspeed',{'fcspeed'},function(args, speaker)
	local FCspeed = args[1] or 1
	if isNumber(FCspeed) then
		NAV_KEYBOARD_SPEED = Vector3.new(FCspeed, FCspeed, FCspeed)
	end
end)

addcmd('notifyfreecamposition',{'notifyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		notify("Current Position", Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('copyfreecamposition',{'copyfcpos'},function(args, speaker)
	if fcRunning then
		local X,Y,Z = workspace.CurrentCamera.CFrame.Position.X,workspace.CurrentCamera.CFrame.Position.Y,workspace.CurrentCamera.CFrame.Position.Z
		local Format, Round = string.format, math.round
		toClipboard(Format("%s, %s, %s", Round(X), Round(Y), Round(Z)))
	end
end)

addcmd('gotocamera',{'gotocam','tocam'},function(args, speaker)
	getRoot(speaker.Character).CFrame = workspace.Camera.CFrame
end)

addcmd('tweengotocamera',{'tweengotocam','tgotocam','ttocam'},function(args, speaker)
	TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = workspace.Camera.CFrame}):Play()
end)

addcmd('fov',{},function(args, speaker)
	local fov = args[1] or 70
	if isNumber(fov) then
		workspace.CurrentCamera.FieldOfView = fov
	end
end)

local preMaxZoom = Players.LocalPlayer.CameraMaxZoomDistance
local preMinZoom = Players.LocalPlayer.CameraMinZoomDistance
addcmd('lookat',{},function(args, speaker)
	if speaker.CameraMaxZoomDistance ~= 0.5 then
		preMaxZoom = speaker.CameraMaxZoomDistance
		preMinZoom = speaker.CameraMinZoomDistance
	end
	speaker.CameraMaxZoomDistance = 0.5
	speaker.CameraMinZoomDistance = 0.5
	wait()
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local target = Players[v].Character
		if target and target:FindFirstChild('Head') then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, target.Head.CFrame.p)
			wait(0.1)
		end
	end
	speaker.CameraMaxZoomDistance = preMaxZoom
	speaker.CameraMinZoomDistance = preMinZoom
end)

addcmd('fixcam',{'restorecam'},function(args, speaker)
	StopFreecam()
	execCmd('unview')
	workspace.CurrentCamera:remove()
	wait(.1)
	repeat wait() until speaker.Character ~= nil
	workspace.CurrentCamera.CameraSubject = speaker.Character:FindFirstChildWhichIsA('Humanoid')
	workspace.CurrentCamera.CameraType = "Custom"
	speaker.CameraMinZoomDistance = 0.5
	speaker.CameraMaxZoomDistance = 400
	speaker.CameraMode = "Classic"
	speaker.Character.Head.Anchored = false
end)

addcmd("enableshiftlock", {"enablesl", "shiftlock"}, function(args, speaker)
	local function enableShiftlock() 
		speaker.DevEnableMouseLock = true 
	end
	speaker:GetPropertyChangedSignal("DevEnableMouseLock"):Connect(enableShiftlock)
	enableShiftlock()
	notify("Shiftlock", "Shift lock should now be available")
end)

addcmd('firstp',{},function(args, speaker)
	speaker.CameraMode = "LockFirstPerson"
end)

addcmd('thirdp',{},function(args, speaker)
	speaker.CameraMode = "Classic"
end)

addcmd('noclipcam', {'nccam'}, function(args, speaker)
	local sc = (debug and debug.setconstant) or setconstant
	local gc = (debug and debug.getconstants) or getconstants
	if not sc or not getgc or not gc then
		return notify('Incompatible Exploit', 'Your exploit does not support this command (missing setconstant or getconstants or getgc)')
	end
	local pop = speaker.PlayerScripts.PlayerModule.CameraModule.ZoomController.Popper
	for _, v in pairs(getgc()) do
		if type(v) == 'function' and getfenv(v).script == pop then
			for i, v1 in pairs(gc(v)) do
				if tonumber(v1) == .25 then
					sc(v, i, 0)
				elseif tonumber(v1) == 0 then
					sc(v, i, .25)
				end
			end
		end
	end
end)

addcmd('maxzoom',{},function(args, speaker)
	speaker.CameraMaxZoomDistance = args[1]
end)

addcmd('minzoom',{},function(args, speaker)
	speaker.CameraMinZoomDistance = args[1]
end)

addcmd('camdistance',{},function(args, speaker)
	local camMax = speaker.CameraMaxZoomDistance
	local camMin = speaker.CameraMinZoomDistance
	if camMax < tonumber(args[1]) then
		camMax = args[1]
	end
	speaker.CameraMaxZoomDistance = args[1]
	speaker.CameraMinZoomDistance = args[1]
	wait()
	speaker.CameraMaxZoomDistance = camMax
	speaker.CameraMinZoomDistance = camMin
end)

addcmd('unlockws',{'unlockworkspace'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = false
		end
	end
end)

addcmd('lockws',{'lockworkspace'},function(args, speaker) 
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Locked = true
		end
	end
end)

addcmd('delete',{'remove'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('deleteclass',{'removeclass','deleteclassname','removeclassname','dc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('chardelete',{'charremove','cd'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted ' ..getstring(1, args))
end)

addcmd('chardeleteclass',{'charremoveclass','chardeleteclassname','charremoveclassname','cdc'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() then
			v:Destroy()
		end
	end
	notify('Item(s) Deleted','Deleted items with ClassName ' ..getstring(1, args))
end)

addcmd('deletevelocity',{'dv','removevelocity','removeforces'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("RocketPropulsion") or v:IsA("BodyThrust") or v:IsA("BodyAngularVelocity") or v:IsA("AngularVelocity") or v:IsA("BodyForce") or v:IsA("VectorForce") or v:IsA("LineForce") then
			v:Destroy()
		end
	end
end)

addcmd('deleteinvisparts',{'deleteinvisibleparts','dip'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}
addcmd('invisibleparts',{'invisparts'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			if not table.find(shownParts,v) then
				table.insert(shownParts,v)
			end
			v.Transparency = 0
		end
	end
end)

addcmd('uninvisibleparts',{'uninvisparts'},function(args, speaker)
	for i,v in pairs(shownParts) do
		v.Transparency = 1
	end
	shownParts = {}
end)

addcmd("btools", {}, function(args, speaker)
	for i = 1, 4 do
		local Tool = Instance.new("HopperBin")
		Tool.BinType = i
		Tool.Name = randomString()
		Tool.Parent = speaker:FindFirstChildWhichIsA("Backpack")
	end
end)

addcmd("f3x", {"fex"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
end)

addcmd("partpath", {"partname"}, function(args, speaker)
	selectPart()
end)

local antiAfkCon = nil
addcmd("antiafk", {"antiidle"}, function(args, speaker)
    if getconnections then
        for _, c in getconnections(speaker.Idled) do
            pcall(function() c:Disable() end) -- supposed to "pause" it
            pcall(function() c:Disconnect() end) -- supposed to disconnect it
        end
    end

    pcall(function() antiAfkCon:Disconnect() end)
    antiAfkCon = speaker.Idled:Connect(function()
        local VirtualInputManager = Instance.new("VirtualInputManager")
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:Destroy()
    end)

    if not (args[1] and tostring(args[1]) == "nonotify") then notify("Anti Idle", "Anti idle is enabled") end
end)

addcmd("datalimit", {}, function(args, speaker)
	local kbps = tonumber(args[1])
	if kbps then
		Services.NetworkClient:SetOutgoingKBPSLimit(kbps)
	end
end)

addcmd("replicationlag", {"backtrack"}, function(args, speaker)
	if tonumber(args[1]) then
		settings():GetService("NetworkSettings").IncomingReplicationLag = args[1]
	end
end)

addcmd("noprompts", {"nopurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = false
end)

addcmd("showprompts", {"showpurchaseprompts"}, function(args, speaker)
	COREGUI.PurchasePromptApp.Enabled = true
end)

promptNewRig = function(speaker, rig)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		AvatarEditorService:PromptSaveAvatar(humanoid.HumanoidDescription, Enum.HumanoidRigType[rig])
		local result = AvatarEditorService.PromptSaveAvatarCompleted:Wait()
		if result == Enum.AvatarPromptResult.Success then
			execCmd("reset")
		end
	end
end

addcmd("promptr6", {}, function(args, speaker)
	promptNewRig(speaker, "R6")
end)

addcmd("promptr15", {}, function(args, speaker)
	promptNewRig(speaker, "R15")
end)

addcmd("wallwalk", {"walkonwalls"}, function(args, speaker)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
end)

addcmd('age',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	notify('Account Age',table.concat(ages, ',\n'))
end)

addcmd('chatage',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local ages = {}
	for i,v in pairs(players) do
		local p = Players[v]
		table.insert(ages, p.Name.."'s age is: "..p.AccountAge)
	end
	local chatString = table.concat(ages, ', ')
	chatMessage(chatString)
end)

addcmd('joindate',{'jd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	notify('Join Date (Month/Day/Year)',table.concat(dates, ',\n'))
end)

addcmd('chatjoindate',{'cjd'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local dates = {}
	for i,v in pairs(players) do
		local p = Players[v]

		local secondsOld = p.AccountAge * 24 * 60 * 60
		local now = os.time()
		local dateJoined  = p.Name .. " joined: " .. os.date("%m/%d/%y", now - secondsOld)

		table.insert(dates, dateJoined)
	end
	local chatString = table.concat(dates, ', ')
	chatMessage(chatString)
end)

addcmd('copyname',{'copyuser'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local name = tostring(Players[v].Name)
		toClipboard(name)
	end
end)

addcmd('userid',{'id'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		notify('User ID',id)
	end
end)

addcmd("copyplaceid", {"placeid"}, function(args, speaker)
	toClipboard(PlaceId)
end)

addcmd("copygameid", {"gameid"}, function(args, speaker)
	toClipboard(game.GameId)
end)

addcmd('copyid',{'copyuserid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local id = tostring(Players[v].UserId)
		toClipboard(id)
	end
end)

addcmd('creatorid',{'creator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		notify('Creator ID',game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Creator ID',OwnerID)
	end
end)

addcmd('copycreatorid',{'copycreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		toClipboard(game.CreatorId)
		notify('Copied ID','Copied creator ID to clipboard')
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		toClipboard(OwnerID)
		notify('Copied ID','Copied creator ID to clipboard')
	end
end)

addcmd('setcreatorid',{'setcreator'},function(args, speaker)
	if game.CreatorType == Enum.CreatorType.User then
		speaker.UserId = game.CreatorId
		notify('Set ID','Set UserId to '..game.CreatorId)
	elseif game.CreatorType == Enum.CreatorType.Group then
		local OwnerID = GroupService:GetGroupInfoAsync(game.CreatorId).Owner.Id
		speaker.UserId = OwnerID
		notify('Set ID','Set UserId to '..OwnerID)
	end
end)

addcmd('appearanceid',{'aid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		notify('Appearance ID',aid)
	end
end)

addcmd('copyappearanceid',{'caid'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local aid = tostring(Players[v].CharacterAppearanceId)
		toClipboard(aid)
	end
end)

addcmd('norender',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(false)
end)

addcmd('render',{},function(args, speaker)
	RunService:Set3dRenderingEnabled(true)
end)

addcmd('2022materials',{'use2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", true)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd('un2022materials',{'unuse2022materials'},function(args, speaker)
	if sethidden then
		sethidden(MaterialService, "Use2022Materials", false)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing sethiddenproperty)')
	end
end)

addcmd("goto", {"to"}, function(args, speaker)
	local character = speaker and speaker.Character
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	if humanoid == nil then return end

	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		task.wait(0.1)
	end

	local waitForStream = parseBoolean(args[2], false)
	for _, name in getPlayer(args[1], speaker) do
		local targetCharacter = Players[name].Character
		if targetCharacter ~= nil then
			local targetPivot = targetCharacter:GetPivot()
			local targetPosition = targetPivot.Position

			if waitForStream and workspace.StreamingEnabled then
				task.spawn(speaker.RequestStreamAroundAsync, speaker, targetPosition, 5)
				targetCharacter:WaitForChild("HumanoidRootPart", 5)
			end

			speaker.Character:PivotTo(CFrame.new(targetPosition + (targetPivot.LookVector * 3), targetPosition))
			breakVelocity()
			break
		end
	end
end)

addcmd("tweengoto", {"tgoto", "tto", "tweento"}, function(args, speaker)
    local character = speaker and speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

    local oldState = humanoid and humanoid:GetStateEnabled(Enum.HumanoidStateType.Seated)
    if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end

    local players = getPlayer(args[1], speaker)
    for _, v in pairs(players) do
        if Players[v].Character ~= nil then
            if humanoid and humanoid.SeatPart then
                humanoid.Sit = false
                task.wait(0.1)
            end
            TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {
                CFrame = getRoot(Players[v].Character):GetPivot() + Vector3.new(3, 1, 0)
            }):Play()
        end
    end
    execCmd("breakvelocity")

    if type(oldState) == "boolean" then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, oldState)
    end
end)

addcmd("vehiclegoto", {"vgoto", "vtp", "vehicletp"}, function(args, speaker)
    local character = speaker.Character
    local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if not humanoid then return end

    local seat = humanoid.SeatPart
    local vehicleModel = if seat then seat:FindFirstAncestorWhichIsA("Model") else nil
    if vehicleModel == nil then
        notify("Vehicle Goto", "Make sure you're sitting in a vehicle.")
        return
    end

    for _, v in getPlayer(args[1], speaker) do
        if Players[v].Character == nil then continue end

        local root = getRoot(Players[v].Character)
        if root == nil then continue end

        vehicleModel:PivotTo(root:GetPivot())
        break
    end
end)

addcmd('pulsetp',{'ptp'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			local startPos = getRoot(speaker.Character).CFrame
			local seconds = args[2] or 1
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
			wait(seconds)
			getRoot(speaker.Character).CFrame = startPos
		end
	end
	execCmd('breakvelocity')
end)

local vnoclipParts = {}
addcmd('vehiclenoclip',{'vnoclip'},function(args, speaker)
	vnoclipParts = {}
	local seat = speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart
	local vehicleModel = seat.Parent
	repeat
		if vehicleModel.ClassName ~= "Model" then
			vehicleModel = vehicleModel.Parent
		end
	until vehicleModel.ClassName == "Model"
	wait(0.1)
	execCmd('noclip')
	for i,v in pairs(vehicleModel:GetDescendants()) do
		if v:IsA("BasePart") and v.CanCollide then
			table.insert(vnoclipParts,v)
			v.CanCollide = false
		end
	end
end)

addcmd("vehicleclip", {"vclip", "unvnoclip", "unvehiclenoclip"}, function(args, speaker)
	execCmd("clip")
	for i, v in pairs(vnoclipParts) do
		v.CanCollide = true
	end
	vnoclipParts = {}
end)

addcmd("togglevnoclip", {}, function(args, speaker)
	execCmd(Clip and "vnoclip" or "vclip")
end)

addcmd('clientbring',{'cbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if Players[v].Character:FindFirstChildOfClass('Humanoid') then
				Players[v].Character:FindFirstChildOfClass('Humanoid').Sit = false
			end
			wait()
			getRoot(Players[v].Character).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(3,1,0)
		end
	end
end)

local bringT = {}
addcmd('loopbring',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			if Players[v].Name ~= speaker.Name and not FindInTable(bringT, Players[v].Name) then
				table.insert(bringT, Players[v].Name)
				local plrName = Players[v].Name
				local pchar=Players[v].Character
				local distance = 3
				if args[2] and isNumber(args[2]) then
					distance = args[2]
				end
				local lDelay = 0
				if args[3] and isNumber(args[3]) then
					lDelay = args[3]
				end
				repeat
					for i,c in pairs(players) do
						if Players:FindFirstChild(v) then
							pchar = Players[v].Character
							if pchar~= nil and Players[v].Character ~= nil and getRoot(pchar) and speaker.Character ~= nil and getRoot(speaker.Character) then
								getRoot(pchar).CFrame = getRoot(speaker.Character).CFrame + Vector3.new(distance,1,0)
							end
							wait(lDelay)
						else 
							for a,b in pairs(bringT) do if b == plrName then table.remove(bringT, a) end end
						end
					end
				until not FindInTable(bringT, plrName)
			end
		end)
	end
end)

addcmd('unloopbring',{'noloopbring'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(bringT) do if b == Players[v].Name then table.remove(bringT, a) end end
		end)
	end
end)

local walkto = false
local waypointwalkto = false
addcmd('walkto',{'follow'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalkto',{'pathfindfollow'},function(args, speaker)
	walkto = false
	wait()
	local players = getPlayer(args[1], speaker)
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	for i,v in pairs(players)do
		if Players[v].Character ~= nil then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			walkto = true
			repeat wait()
				local success, response = pcall(function()
					path:ComputeAsync(getRoot(speaker.Character).Position, getRoot(Players[v].Character).Position)
					local waypoints = path:GetWaypoints()
					local distance 
					for waypointIndex, waypoint in pairs(waypoints) do
						local waypointPosition = waypoint.Position
						hum:MoveTo(waypointPosition)
						repeat 
							distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
							wait()
						until
						distance <= 5
					end	 
				end)
				if not success then
					speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(getRoot(Players[v].Character).Position)
				end
			until Players[v].Character == nil or not getRoot(Players[v].Character) or walkto == false
		end
	end
end)

addcmd('pathfindwalktowaypoint',{'pathfindwalktowp'},function(args, speaker)
	waypointwalkto = false
	wait()
	local WPName = tostring(getstring(1, args))
	local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	local path = PathService:CreatePath()
	if speaker.Character then
		for i,_ in pairs(WayPoints) do
			if tostring(WayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = Vector3.new(WayPoints[i].COORD[1], WayPoints[i].COORD[2], WayPoints[i].COORD[3])
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
		for i,_ in pairs(pWayPoints) do
			if tostring(pWayPoints[i].NAME):lower() == tostring(WPName):lower() then
				if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
					speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
					wait(.1)
				end
				local TrueCoords = pWayPoints[i].COORD[1].Position
				waypointwalkto = true
				repeat wait()
					local success, response = pcall(function()
						path:ComputeAsync(getRoot(speaker.Character).Position, TrueCoords)
						local waypoints = path:GetWaypoints()
						local distance 
						for waypointIndex, waypoint in pairs(waypoints) do
							local waypointPosition = waypoint.Position
							hum:MoveTo(waypointPosition)
							repeat 
								distance = (waypointPosition - hum.Parent.PrimaryPart.Position).magnitude
								wait()
							until
							distance <= 5
						end
					end)
					if not success then
						speaker.Character:FindFirstChildOfClass('Humanoid'):MoveTo(TrueCoords)
					end
				until not speaker.Character or waypointwalkto == false
			end
		end
	end
end)

addcmd('unwalkto',{'nowalkto','unfollow','nofollow'},function(args, speaker)
	walkto = false
	waypointwalkto = false
end)

addcmd("orbit", {}, function(args, speaker)
	execCmd("unorbit nonotify")

	local target = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = getRoot(speaker.Character)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")

	if target and target.Character and getRoot(target.Character) and root and humanoid then
		local rotation = 0
		local speed = tonumber(args[2]) or 0.2
		local distance = tonumber(args[3]) or 6

		orbit1 = RunService.Stepped:Connect(function()
			breakVelocity()
			rotation = rotation + speed

			local targetRoot = getRoot(target.Character).Position
			local orbitPosition = (CFrame.new(targetRoot) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)).Position
			root.CFrame = CFrame.lookAt(orbitPosition, Vector3.new(targetRoot.X, orbitPosition.Y, targetRoot.Z))
		end)

		orbit2 = humanoid.Died:Connect(function() execCmd("unorbit") end)

		orbit3 = humanoid.Seated:Connect(function(value)
			if value then execCmd("unorbit") end
		end)

		notify("Orbit", "Started orbiting " .. formatUsername(target))
	end
end)

addcmd("unorbit", {}, function(args, speaker)
	if orbit1 then orbit1:Disconnect() end
	if orbit2 then orbit2:Disconnect() end
	if orbit3 then orbit3:Disconnect() end
	if args[1] ~= "nonotify" then notify("Orbit", "Stopped orbiting player") end
end)


addcmd('freeze',{'fr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("BasePart") and not x.Anchored then
						x.Anchored = true
					end
				end
			end)
		end
	end
end)


addcmd('thaw',{'unfreeze','unfr'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x.Name ~= floatName and x:IsA("BasePart") and x.Anchored then
						x.Anchored = false
					end
				end
			end)
		end
	end
end)

addcmd("anchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = true
end)

addcmd("unanchor", {}, function(args, speaker)
    getRoot(speaker.Character).Anchored = false
end)

oofing = false
addcmd('loopoof',{},function(args, speaker)
	oofing = true
	repeat wait(0.1)
		for i,v in pairs(Players:GetPlayers()) do
			if v.Character ~= nil and v.Character:FindFirstChild'Head' then
				for _,x in pairs(v.Character.Head:GetChildren()) do
					if x:IsA'Sound' then x.Playing = true end
				end
			end
		end
	until oofing == false
end)

addcmd('unloopoof',{},function(args, speaker)
	oofing = false
end)

local notifiedRespectFiltering = false
addcmd('muteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
				for i, x in next, Players[v]:FindFirstChildOfClass("Backpack"):GetDescendants() do
					if x:IsA("Sound") and x.Playing == true then
						x.Playing = false
					end
				end
			end)
		end
	end
end)

addcmd('unmuteboombox',{},function(args, speaker)
	if not notifiedRespectFiltering and SoundService.RespectFilteringEnabled then notifiedRespectFiltering = true notify('RespectFilteringEnabled','RespectFilteringEnabled is set to true (the command will still work but may only be clientsided)') end
	local players = getPlayer(args[1], speaker)
	if players ~= nil then
		for i,v in pairs(players) do
			task.spawn(function()
				for i, x in next, Players[v].Character:GetDescendants() do
					if x:IsA("Sound") and x.Playing == false then
						x.Playing = true
					end
				end
			end)
		end
	end
end)

addcmd("reset", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	else
		speaker.Character:BreakJoints()
	end
end)

addcmd('freezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(0)
	end
end)

addcmd('unfreezeanims',{},function(args, speaker)
	local Humanoid = speaker.Character:FindFirstChildOfClass("Humanoid") or speaker.Character:FindFirstChildOfClass("AnimationController")
	local ActiveTracks = Humanoid:GetPlayingAnimationTracks()
	for _, v in pairs(ActiveTracks) do
		v:AdjustSpeed(1)
	end
end)

addcmd("respawn", {}, function(args, speaker)
	respawn(speaker)
end)

addcmd("refresh", {"re"}, function(args, speaker)
	refresh(speaker)
end)

addcmd("god", {}, function(args, speaker)
	local Cam = workspace.CurrentCamera
	local Char, Pos = speaker.Character, Cam.CFrame
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local nHuman = Human:Clone()
	nHuman.Parent = char
	speaker.Character = nil
	nHuman:SetStateEnabled(15, false)
	nHuman:SetStateEnabled(1, false)
	nHuman:SetStateEnabled(0, false)
	nHuman.BreakJointsOnDeath = true
	Human:Destroy()
	speaker.Character = char
	Cam.CameraSubject = nHuman
	Cam.CFrame = task.wait() and pos
	nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local Script = Char:FindFirstChild("Animate")
	if Script then
		Script.Disabled = true
		task.wait()
		Script.Disabled = false
	end
	nHuman.Health = nHuman.MaxHealth
end)

invisRunning = false
addcmd('invisible',{'invis'},function(args, speaker)
	if invisRunning then return end
	invisRunning = true
	-- Full credit to AmokahFox @V3rmillion
	local Player = speaker
	repeat wait(.1) until Player.Character
	local Character = Player.Character
	Character.Archivable = true
	local IsInvis = false
	local IsRunning = true
	local InvisibleCharacter = Character:Clone()
	InvisibleCharacter.Parent = Lighting
	local Void = workspace.FallenPartsDestroyHeight
	InvisibleCharacter.Name = ""
	local CF

	local invisFix = RunService.Stepped:Connect(function()
		pcall(function()
			local IsInteger
			if tostring(Void):find'-' then
				IsInteger = true
			else
				IsInteger = false
			end
			local Pos = Player.Character.Humanoid.RootPart.Position
			local Pos_String = tostring(Pos)
			local Pos_Seperate = Pos_String:split(', ')
			local X = tonumber(Pos_Seperate[1])
			local Y = tonumber(Pos_Seperate[2])
			local Z = tonumber(Pos_Seperate[3])
			if IsInteger == true then
				if Y <= Void then
					Respawn()
				end
			elseif IsInteger == false then
				if Y >= Void then
					Respawn()
				end
			end
		end)
	end)

	for i,v in pairs(InvisibleCharacter:GetDescendants())do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = .5
			end
		end
	end

	function Respawn()
		IsRunning = false
		if IsInvis == true then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				IsInvis = false
				InvisibleCharacter.Parent = nil
				invisRunning = false
			end)
		elseif IsInvis == false then
			pcall(function()
				Player.Character = Character
				wait()
				Character.Parent = workspace
				Character:FindFirstChildWhichIsA'Humanoid':Destroy()
				TurnVisible()
			end)
		end
	end

	local invisDied
	invisDied = InvisibleCharacter:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
		Respawn()
		invisDied:Disconnect()
	end)

	if IsInvis == true then return end
	IsInvis = true
	CF = workspace.CurrentCamera.CFrame
	local CF_1 = Player.Character.Humanoid.RootPart.CFrame
	Character:MoveTo(Vector3.new(0,math.pi*1000000,0))
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	wait(.2)
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	InvisibleCharacter = InvisibleCharacter
	Character.Parent = Lighting
	InvisibleCharacter.Parent = workspace
	InvisibleCharacter.Humanoid.RootPart.CFrame = CF_1
	Player.Character = InvisibleCharacter
	execCmd('fixcam')
	Player.Character.Animate.Disabled = true
	Player.Character.Animate.Disabled = false

	function TurnVisible()
		if IsInvis == false then return end
		invisFix:Disconnect()
		invisDied:Disconnect()
		CF = workspace.CurrentCamera.CFrame
		Character = Character
		local CF_1 = Player.Character.Humanoid.RootPart.CFrame
		Character.Humanoid.RootPart.CFrame = CF_1
		InvisibleCharacter:Destroy()
		Player.Character = Character
		Character.Parent = workspace
		IsInvis = false
		Player.Character.Animate.Disabled = true
		Player.Character.Animate.Disabled = false
		invisDied = Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
			Respawn()
			invisDied:Disconnect()
		end)
		invisRunning = false
	end
	notify('Invisible','You now appear invisible to other players')
end)

addcmd("visible", {"vis","uninvisible"}, function(args, speaker)
	TurnVisible()
end)

addcmd("toggleinvis", {}, function(args, speaker)
	execCmd(invisRunning and "visible" or "invisible")
end)

addcmd('toolinvisible',{'toolinvis','tinvis'},function(args, speaker)
	local Char  = Players.LocalPlayer.Character
	local touched = false
	local tpdback = false
	local box = Instance.new('Part')
	box.Anchored = true
	box.CanCollide = true
	box.Size = Vector3.new(10,1,10)
	box.Position = Vector3.new(0,10000,0)
	box.Parent = workspace
	local boxTouched = box.Touched:connect(function(part)
		if (part.Parent.Name == Players.LocalPlayer.Name) then
			if touched == false then
				touched = true
				local function apply()
					local no = Char.Humanoid.RootPart:Clone()
					task.wait(.25)
					Char.Humanoid.RootPart:Destroy()
					no.Parent = Char
					Char:MoveTo(loc)
					touched = false
				end
				if Char then
					apply()
				end
			end
		end
	end)
	repeat wait() until Char
	local cleanUp
	cleanUp = Players.LocalPlayer.CharacterAdded:connect(function(char)
		boxTouched:Disconnect()
		box:Destroy()
		cleanUp:Disconnect()
	end)
	loc = Char.Humanoid.RootPart.Position
	Char:MoveTo(box.Position + Vector3.new(0,.5,0))
end)

addcmd("strengthen", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
			end
		end
	end
end)

addcmd("weaken", {}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			if args[1] then
				child.CustomPhysicalProperties = PhysicalProperties.new(-args[1], 0.3, 0.5)
			else
				child.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
			end
		end
	end
end)

addcmd("unweaken", {"unstrengthen"}, function(args, speaker)
	for _, child in pairs(speaker.Character:GetDescendants()) do
		if child.ClassName == "Part" then
			child.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
		end
	end
end)

addcmd("breakvelocity", {}, function(args, speaker)
	local BeenASecond, V3 = false, Vector3.new(0, 0, 0)
	delay(1, function()
		BeenASecond = true
	end)
	while not BeenASecond do
		for _, v in ipairs(speaker.Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity, v.RotVelocity = V3, V3
			end
		end
		wait()
	end
end)

addcmd('jpower',{'jumppower','jp'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
		end
	end
end)

addcmd("maxslopeangle", {"msa"}, function(args, speaker)
	local sangle = args[1] or 89
	if isNumber(sangle) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").MaxSlopeAngle = sangle
	end
end)

addcmd("gravity", {"grav"}, function(args, speaker)
	local grav = args[1] or oldgrav
	if isNumber(grav) then
		workspace.Gravity = grav
	end
end)

addcmd("hipheight", {"hheight"}, function(args, speaker)
	local hipHeight = args[1] or (r15(speaker) and 2.1 or 0)
	if isNumber(hipHeight) then
		speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = hipHeight
	end
end)

addcmd("dance", {}, function(args, speaker)
	pcall(execCmd, "undance")
	local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
	if r15(speaker) then
		dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
	danceTrack = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	danceTrack.Looped = true
	danceTrack:Play()
end)

addcmd("undance", {"nodance"}, function(args, speaker)
	danceTrack:Stop()
	danceTrack:Destroy()
end)

addcmd("defemote", {}, function(args, speaker)
	if args[1] then
		if speaker.Character then
			speaker.Character.Animate.PlayEmote:Invoke(getstring(1, args))
		end
	end
end)

addcmd('nolimbs',{'rlimbs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" or
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" or
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('noarms',{'rarms'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperArm" or
				v.Name == "LeftUpperArm" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Arm" or
				v.Name == "Left Arm" then
				v:Destroy()
			end
		end
	end
end)

addcmd('nolegs',{'rlegs'},function(args, speaker)
	if r15(speaker) then
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "RightUpperLeg" or
				v.Name == "LeftUpperLeg" then
				v:Destroy()
			end
		end
	else
		for i,v in pairs(speaker.Character:GetChildren()) do
			if v:IsA("BasePart") and
				v.Name == "Right Leg" or
				v.Name == "Left Leg" then
				v:Destroy()
			end
		end
	end
end)

addcmd("sit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid").Sit = true
end)

addcmd("lay", {"laydown"}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	humanoid.Sit = true
	task.wait(0.1)
	humanoid.RootPart.CFrame = humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
	for _, v in ipairs(humanoid:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

addcmd("sitwalk", {}, function(args, speaker)
	local anims = speaker.Character.Animate
	local sit = anims.sit:FindFirstChildWhichIsA("Animation").AnimationId
	anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sit
	anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sit
	speaker.Character:FindFirstChildWhichIsA("Humanoid").HipHeight = not r15(speaker) and -1.5 or 0.5
end)

addcmd("nosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end)

addcmd("unnosit", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Seated, true)
end)

addcmd("jump", {}, function(args, speaker)
	speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end)

local infJump
infJumpDebounce = false
addcmd("infjump", {"infinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
	infJump = UserInputService.JumpRequest:Connect(function()
		if not infJumpDebounce then
			infJumpDebounce = true
			speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			wait()
			infJumpDebounce = false
		end
	end)
end)

addcmd("uninfjump", {"uninfinitejump", "noinfjump", "noinfinitejump"}, function(args, speaker)
	if infJump then infJump:Disconnect() end
	infJumpDebounce = false
end)

local flyjump
addcmd("flyjump", {}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
	flyjump = UserInputService.JumpRequest:Connect(function()
		speaker.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end)
end)

addcmd("unflyjump", {"noflyjump"}, function(args, speaker)
	if flyjump then flyjump:Disconnect() end
end)

local HumanModCons = {}
addcmd('autojump',{'ajump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	local function autoJump()
		if Char and Human then
			local check1 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position-Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			local check2 = workspace:FindPartOnRay(Ray.new(Human.RootPart.Position+Vector3.new(0,1.5,0), Human.RootPart.CFrame.lookVector*3), Human.Parent)
			if check1 or check2 then
				Human.Jump = true
			end
		end
	end
	autoJump()
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		autoJump()
		HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or RunService.RenderStepped:Connect(autoJump)
	end)
end)

addcmd('unautojump',{'noautojump', 'noajump', 'unajump'},function(args, speaker)
	HumanModCons.ajLoop = (HumanModCons.ajLoop and HumanModCons.ajLoop:Disconnect() and false) or nil
	HumanModCons.ajCA = (HumanModCons.ajCA and HumanModCons.ajCA:Disconnect() and false) or nil
end)

addcmd('edgejump',{'ejump'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	-- Full credit to NoelGamer06 @V3rmillion
	local state
	local laststate
	local lastcf
	local function edgejump()
		if Char and Human then
			laststate = state
			state = Human:GetState()
			if laststate ~= state and state == Enum.HumanoidStateType.Freefall and laststate ~= Enum.HumanoidStateType.Jumping then
				Char.Humanoid.RootPart.CFrame = lastcf
				Char.Humanoid.RootPart.Velocity = Vector3.new(Char.Humanoid.RootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, Char.Humanoid.RootPart.Velocity.Z)
			end
			lastcf = Char.Humanoid.RootPart.CFrame
		end
	end
	edgejump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
		Char, Human = nChar, nChar:WaitForChild("Humanoid")
		edgejump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgejump)
	end)
end)

addcmd('unedgejump',{'noedgejump', 'noejump', 'unejump'},function(args, speaker)
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or nil
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or nil
end)

addcmd("team", {}, function(args, speaker)
	local teamName = getstring(1, args)
	local team = nil
	local root = speaker.Character and getRoot(speaker.Character)
	for _, v in ipairs(Teams:GetChildren()) do
		if v.Name:lower():match(teamName:lower()) then
			team = v
			break
		end
	end
	if not team then
		return notify("Invalid Team", teamName .. " is not a valid team")
	end
	if root and firetouchinterest then
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("SpawnLocation") and v.BrickColor == team.TeamColor and v.AllowTeamChangeOnTouch == true then
				firetouchinterest(v, root, 0)
				firetouchinterest(v, root, 1)
				break
			end
		end
	else
		speaker.Team = team
	end
end)

addcmd('nobgui',{'unbgui','nobillboardgui','unbillboardgui','noname','rohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
end)

addcmd('loopnobgui',{'loopunbgui','loopnobillboardgui','loopunbillboardgui','loopnoname','looprohg'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants())do
		if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
			v:Destroy()
		end
	end
	local function charPartAdded(part)
		if part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
			wait()
			part:Destroy()
		end
	end
	charPartTrigger = speaker.Character.DescendantAdded:Connect(charPartAdded)
end)

addcmd('unloopnobgui',{'unloopunbgui','unloopnobillboardgui','unloopunbillboardgui','unloopnoname','unlooprohg'},function(args, speaker)
	if charPartTrigger then
		charPartTrigger:Disconnect()
	end
end)

addcmd('spasm',{},function(args, speaker)
	if not r15(speaker) then
		local pchar=speaker.Character
		local AnimationId = "33796059"
		SpasmAnim = Instance.new("Animation")
		SpasmAnim.AnimationId = "rbxassetid://"..AnimationId
		Spasm = pchar:FindFirstChildOfClass('Humanoid'):LoadAnimation(SpasmAnim)
		Spasm:Play()
		Spasm:AdjustSpeed(99)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('unspasm',{'nospasm'},function(args, speaker)
	Spasm:Stop()
	SpasmAnim:Destroy()
end)

addcmd('headthrow',{},function(args, speaker)
	if not r15(speaker) then
		local AnimationId = "35154961"
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..AnimationId
		local k = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(Anim)
		k:Play(0)
		k:AdjustSpeed(1)
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

local function anim2track(asset_id)
	local objs = game:GetObjects(asset_id)
	for i = 1, #objs do
		if objs[i]:IsA("Animation") then
			return objs[i].AnimationId
		end
	end
	return asset_id
end

addcmd("animation", {"anim"}, function(args, speaker)
	local animid = tostring(args[1])
	if not animid:find("rbxassetid://") then
		animid = "rbxassetid://" .. animid
	end
	animid = anim2track(animid)
	local animation = Instance.new("Animation")
	animation.AnimationId = animid
	local anim = speaker.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animation)
	anim.Priority = Enum.AnimationPriority.Movement
	anim:Play()
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd("emote", {"em"}, function(args, speaker)
	local anim = humanoid:PlayEmoteAndGetAnimTrackById(args[1])
	if args[2] then anim:AdjustSpeed(tostring(args[2])) end
end)

addcmd('noanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = true
end)

addcmd('reanim',{},function(args, speaker)
	speaker.Character.Animate.Disabled = false
end)

addcmd('animspeed',{},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:AdjustSpeed(tonumber(args[1] or 1))
	end
end)

addcmd('copyanimation',{'copyanim','copyemote'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for _,v in ipairs(players)do
		local char = Players[v].Character
		for _, v1 in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			v1:Stop()
		end
		for _, v1 in pairs(Players[v].Character:FindFirstChildOfClass('Humanoid'):GetPlayingAnimationTracks()) do
			if not string.find(v1.Animation.AnimationId, "507768375") then
				local ANIM = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(v1.Animation)
				ANIM:Play(.1, 1, v1.Speed)
				ANIM.TimePosition = v1.TimePosition
				task.spawn(function()
					v1.Stopped:Wait()
					ANIM:Stop()
					ANIM:Destroy()
				end)
			end
		end
	end
end)

addcmd("copyanimationid", {"copyanimid", "copyemoteid"}, function(args, speaker)
	local copyAnimId = function(player)
		local found = "Animations Copied"

		for _, v in pairs(player.Character:FindFirstChildWhichIsA("Humanoid"):GetPlayingAnimationTracks()) do
			local animationId = v.Animation.AnimationId
			local assetId = animationId:find("rbxassetid://") and animationId:match("%d+")

			if not string.find(animationId, "507768375") and not string.find(animationId, "180435571") then
				if assetId then
					local success, result = pcall(function()
						return MarketplaceService:GetProductInfo(tonumber(assetId)).Name
					end)
					local name = success and result or "Failed to get name"
					found = found .. "\n\nName: " .. name .. "\nAnimation Id: " .. animationId
				else
					found = found .. "\n\nAnimation Id: " .. animationId
				end
			end
		end

		if found ~= "Animations Copied" then
			toClipboard(found)
		else
			notify("Animations", "No animations to copy")
		end
	end

	if args[1] then
		copyAnimId(Players[getPlayer(args[1], speaker)[1]])
	else
		copyAnimId(speaker)
	end
end)

addcmd('stopanimations',{'stopanims','stopanim'},function(args, speaker)
	local Char = speaker.Character
	local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")

	for i,v in next, Hum:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

addcmd('refreshanimations', {'refreshanimation', 'refreshanims', 'refreshanim'}, function(args, speaker)
	local Char = speaker.Character or speaker.CharacterAdded:Wait()
	local Human = Char and Char:WaitForChild('Humanoid', 15)
	local Animate = Char and Char:WaitForChild('Animate', 15)
	if not Human or not Animate then
		return notify('Refresh Animations', 'Failed to get Animate/Humanoid')
	end
	Animate.Disabled = true
	for _, v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
	Animate.Disabled = false
end)

addcmd('allowcustomanim', {'allowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = true
	execCmd('refreshanimations')
end)

addcmd('unallowcustomanim', {'unallowcustomanimations'}, function(args, speaker)
	StarterPlayer.AllowCustomAnimations = false
	execCmd('refreshanimations')
end)

addcmd('loopanimation', {'loopanim'},function(args, speaker)
	local Char = speaker.Character
	local Human = Char and Char.FindFirstChildWhichIsA(Char, "Humanoid")
	for _, v in ipairs(Human.GetPlayingAnimationTracks(Human)) do
		v.Looped = true
	end
end)

addcmd('tpposition',{'tppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		getRoot(char).CFrame = CFrame.new(tpX,tpY,tpZ)
	end
end)

addcmd('tweentpposition',{'ttppos'},function(args, speaker)
	if #args < 3 then return end
	local tpX,tpY,tpZ = tonumber((args[1]:gsub(",", ""))),tonumber((args[2]:gsub(",", ""))),tonumber((args[3]:gsub(",", "")))
	local char = speaker.Character
	if char and getRoot(char) then
		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX,tpY,tpZ)}):Play()
	end
end)

addcmd("offset", {}, function(args, speaker)
    if #args < 3 then return end
    speaker.Character:TranslateBy(Vector3.new(tonumber(args[1]) or 0, tonumber(args[2]) or 0, tonumber(args[3]) or 0))
end)

addcmd("tweenoffset", {"toffset"}, function(args, speaker)
    if #args < 3 then return end
    local tpX, tpY, tpZ = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    local root = getRoot(speaker.Character)
    local pos = root.Position + Vector3.new(tpX, tpY, tpZ)
    TweenService:Create(root, TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)}):Play()
    breakVelocity()
end)

addcmd("clickteleport", {}, function(args, speaker)
    if speaker ~= Players.LocalPlayer then return end
    notify("Click TP", "Go to Settings > Keybinds > Add to set up click teleport")
end)

addcmd("mouseteleport", {"mousetp"}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local pos = IYMouse.Hit
    if root and pos then
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end
end)

addcmd("tptool", {"teleporttool"}, function(args, speaker)
    local TpTool = Instance.new("Tool")
    TpTool.Name = "Teleport Tool"
    TpTool.RequiresHandle = false
    TpTool.Parent = speaker:FindFirstChildOfClass("Backpack")
    TpTool.Activated:Connect(function()
        local root = getRoot(speaker.Character)
        local pos = IYMouse.Hit
        if not root or not pos then return end
        root.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z, select(4, root.CFrame:components()))
        breakVelocity()
    end)
end)

addcmd("thru", {}, function(args, speaker)
    local root = getRoot(speaker.Character)
    local num = tonumber(args[1]) or 5
    local pos = root.CFrame.Position + (root.CFrame.LookVector * num)
    root.CFrame = CFrame.new(pos, pos + root.CFrame.LookVector)
end)

addcmd('clickdelete',{},function(args, speaker)
	if speaker == Players.LocalPlayer then
		notify('Click Delete','Go to Settings > Keybinds > Add to set up click delete')
	end
end)

addcmd('getposition',{'getpos','notifypos','notifyposition'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		notify('Current Position',roundedPos)
	end
end)

addcmd('copyposition',{'copypos'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		local char = Players[v].Character
		local pos = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		pos = pos and pos.Position
		if not pos then
			return notify('Getposition Error','Missing character')
		end
		local roundedPos = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
		toClipboard(roundedPos)
	end
end)

addcmd('walktopos',{'walktoposition'},function(args, speaker)
	if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
		wait(.1)
	end
	speaker.Character:FindFirstChildOfClass('Humanoid').WalkToPoint = Vector3.new(args[1],args[2],args[3])
end)

addcmd('speed',{'ws','walkspeed'},function(args, speaker)
	if args[2] then
		local speed = args[2] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	else
		local speed = args[1] or 16
		if isNumber(speed) then
			speaker.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = speed
		end
	end
end)

addcmd('spoofspeed',{'spoofws','spoofwalkspeed'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setspeed;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return setspeed or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					setspeed = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopspeed',{'loopws'},function(args, speaker)
	local speed = args[1] or 16
	if args[2] then
		speed = args[2] or 16
	end
	if isNumber(speed) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function WalkSpeedChange()
			if Char and Human then
				Human.WalkSpeed = speed
			end
		end
		WalkSpeedChange()
		HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			WalkSpeedChange()
			HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
		end)
	end
end)

addcmd('unloopspeed',{'unloopws'},function(args, speaker)
	HumanModCons.wsLoop = (HumanModCons.wsLoop and HumanModCons.wsLoop:Disconnect() and false) or nil
	HumanModCons.wsCA = (HumanModCons.wsCA and HumanModCons.wsCA:Disconnect() and false) or nil
end)

addcmd('spoofjumppower',{'spoofjp'},function(args, speaker)
	if args[1] and isNumber(args[1]) then
		if hookmetamethod then
			local char = speaker.Character
			local setpower;
			local index; index = hookmetamethod(game, "__index", function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return setpower or args[1]
				end
				return index(self, key)
			end)
			local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					setpower = tonumber(value)
				end
				return newindex(self, key, value)
			end)
		else
			notify('Incompatible Exploit','Your exploit does not support this command (missing hookmetamethod)')
		end
	end
end)

addcmd('loopjumppower',{'loopjp','loopjpower'},function(args, speaker)
	local jpower = args[1] or 50
	if isNumber(jpower) then
		local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
		local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
		local function JumpPowerChange()
			if Char and Human then
				if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = jpower
				else
					speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = jpower
				end
			end
		end
		JumpPowerChange()
		HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(nChar)
			Char, Human = nChar, nChar:WaitForChild("Humanoid")
			JumpPowerChange()
			HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or Human:GetPropertyChangedSignal("JumpPower"):Connect(JumpPowerChange)
		end)
	end
end)

addcmd('unloopjumppower',{'unloopjp','unloopjpower'},function(args, speaker)
	local Char = speaker.Character or workspace:FindFirstChild(speaker.Name)
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
	HumanModCons.jpLoop = (HumanModCons.jpLoop and HumanModCons.jpLoop:Disconnect() and false) or nil
	HumanModCons.jpCA = (HumanModCons.jpCA and HumanModCons.jpCA:Disconnect() and false) or nil
	if Char and Human then
		if speaker.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
		else
			speaker.Character:FindFirstChildOfClass('Humanoid').JumpHeight  = 50
		end
	end
end)

addcmd('tools',{'gears'},function(args, speaker)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(Lighting)
	local function copy(instance)
		for i,c in pairs(instance:GetChildren())do
			if c:IsA('Tool') or c:IsA('HopperBin') then
				c:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
			end
			copy(c)
		end
	end
	copy(ReplicatedStorage)
	notify('Tools','Copied tools from ReplicatedStorage and Lighting')
end)

addcmd('notools',{'rtools','clrtools','removetools','deletetools','dtools'},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd('deleteselectedtool',{'dst'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA('Tool') or v:IsA('HopperBin') then
			v:Destroy()
		end
	end
end)

addcmd("console", {}, function(args, speaker)
	StarterGui:SetCore("DevConsoleVisible", true)
end)

addcmd('oldconsole',{},function(args, speaker)
	-- Thanks wally!!
	notify("Loading",'Hold on a sec')
	local _, str = pcall(function()
		return game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/console.lua", true)
	end)

	local s, e = loadstring(str)
	if typeof(s) ~= "function" then
		return
	end

	local success, message = pcall(s)
	if (not success) then
		if printconsole then
			printconsole(message)
		elseif printoutput then
			printoutput(message)
		end
	end
	wait(1)
	notify('Console','Press F9 to open the console')
end)

addcmd("explorer", {"dex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
end)

addcmd("moondex", {"mdex"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addcmd("remotespy", {"rspy", "cobalt", "cspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to notpoiu, creator of Cobalt
    loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
end)

addcmd("simplespy", {"sspy"}, function(args, speaker)
    notify("Loading", "Hold on a sec")
    -- Full credit to exx, creator of SimpleSpy
    -- also thanks to Amity for fixing
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

addcmd('audiologger',{'alogger'},function(args, speaker)
	notify("Loading",'Hold on a sec')
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua'),true))()
end)

local loopgoto = nil
addcmd('loopgoto',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		loopgoto = nil
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		loopgoto = Players[v]
		local distance = 3
		if args[2] and isNumber(args[2]) then
			distance = args[2]
		end
		local lDelay = 0
		if args[3] and isNumber(args[3]) then
			lDelay = args[3]
		end
		repeat
			if Players:FindFirstChild(v) then
				if Players[v].Character ~= nil then
					getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,1,0)
				end
				wait(lDelay)
			else
				loopgoto = nil
			end
		until loopgoto ~= Players[v]
	end
end)

addcmd('unloopgoto',{'noloopgoto'},function(args, speaker)
	loopgoto = nil
end)

addcmd('headsit',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	if headSit then headSit:Disconnect() end
	for i,v in pairs(players)do
		speaker.Character:FindFirstChildOfClass('Humanoid').Sit = true
		headSit = RunService.Heartbeat:Connect(function()
			if Players:FindFirstChild(Players[v].Name) and Players[v].Character ~= nil and getRoot(Players[v].Character) and getRoot(speaker.Character) and speaker.Character:FindFirstChildOfClass('Humanoid').Sit == true then
				getRoot(speaker.Character).CFrame = getRoot(Players[v].Character).CFrame * CFrame.Angles(0,math.rad(0),0)* CFrame.new(0,1.6,0.4)
			else
				headSit:Disconnect()
			end
		end)
	end
end)

addcmd('chat',{'say'},function(args, speaker)
	local cString = getstring(1, args)
	chatMessage(cString)
end)

addcmd("vsay", {}, function(args, speaker)
	if speaker.Character and speaker.Character:FindFirstChild("Head") then
		game.Chat:Chat(speaker.Character.Head, getstring(1, args), Enum.ChatColor.White)
	end
end)

spamming = false
spamspeed = 1
addcmd('spam',{},function(args, speaker)
	spamming = true
	local spamstring = getstring(1, args)
	repeat wait(spamspeed)
		chatMessage(spamstring)
	until spamming == false
end)

addcmd('nospam',{'unspam'},function(args, speaker)
	spamming = false
end)

addcmd('whisper',{'pm'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			local pmstring = getstring(2, args)
			chatMessage("/w "..plrName.." "..pmstring)
		end)
	end
end)

pmspamming = {}
addcmd('pmspam',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			local plrName = Players[v].Name
			if FindInTable(pmspamming, plrName) then return end
			table.insert(pmspamming, plrName)
			local pmspamstring = getstring(2, args)
			repeat
				if Players:FindFirstChild(v) then
					wait(spamspeed)
					chatMessage("/w "..plrName.." "..pmspamstring)
				else
					for a,b in pairs(pmspamming) do if b == plrName then table.remove(pmspamming, a) end end
				end
			until not FindInTable(pmspamming, plrName)
		end)
	end
end)

addcmd('nopmspam',{'unpmspam'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for a,b in pairs(pmspamming) do
				if b == Players[v].Name then
					table.remove(pmspamming, a)
				end
			end
		end)
	end
end)

addcmd('spamspeed',{},function(args, speaker)
	local speed = args[1] or 1
	if isNumber(speed) then
		spamspeed = speed
	end
end)

addcmd('bubblechat',{},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

addcmd('unbubblechat',{'nobubblechat'},function(args, speaker)
	if isLegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
end)

addcmd("chatwindow", {}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = true
end)

addcmd("unchatwindow", {"nochatwindow"}, function(args, speaker)
	TextChatService.ChatWindowConfiguration.Enabled = false
end)

addcmd("darkchat", {}, function(args, speaker)
    local BCC = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
    local CWC = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
    local CIBC = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
    if BCC then
        BCC.Enabled = true
        BCC.BackgroundColor3 = Color3.fromRGB()
        BCC.BackgroundTransparency = 0.3
        BCC.TailVisible = true
        BCC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
    end
    if CWC then
        CWC.Enabled = true
        CWC.BackgroundColor3 = Color3.fromRGB()
        CWC.BackgroundTransparency = 0.3
        CWC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CWC.TextStrokeColor3 = Color3.fromRGB()
        CWC.TextStrokeTransparency = 0.5
    end
    if CIBC then
        CIBC.Enabled = true
        CIBC.BackgroundColor3 = Color3.fromRGB()
        CIBC.BackgroundTransparency = 0.5
        CIBC.PlaceholderColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextColor3 = Color3.fromRGB(0xFF, 0xFF, 0xFF)
        CIBC.TextStrokeColor3 = Color3.fromRGB()
        CIBC.TextStrokeTransparency = 0.5
    end
end)

addcmd('blockhead',{},function(args, speaker)
	speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
end)

addcmd('blockhats',{},function(args, speaker)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		for i,c in pairs(v:GetDescendants()) do
			if c:IsA("SpecialMesh") then
				c:Destroy()
			end
		end
	end
end)

addcmd('blocktool',{},function(args, speaker)
	for _,v in pairs(speaker.Character:GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			for i,c in pairs(v:GetDescendants()) do
				if c:IsA("SpecialMesh") then
					c:Destroy()
				end
			end
		end
	end
end)

addcmd('creeper',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character.LeftUpperArm:Destroy()
		speaker.Character.RightUpperArm:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	else
		speaker.Character.Head:FindFirstChildOfClass("SpecialMesh"):Destroy()
		speaker.Character["Left Arm"]:Destroy()
		speaker.Character["Right Arm"]:Destroy()
		speaker.Character:FindFirstChildOfClass("Humanoid"):RemoveAccessories()
	end
end)

function getTorso(x)
	x = x or Players.LocalPlayer.Character
	return x:FindFirstChild("Torso") or x:FindFirstChild("UpperTorso") or x:FindFirstChild("LowerTorso") or x:FindFirstChild("HumanoidRootPart")
end

addcmd("bang", {"rape"}, function(args, speaker)
	execCmd("unbang")
	wait()
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	bangAnim = Instance.new("Animation")
	bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(args[2] or 3)
	bangDied = humanoid.Died:Connect(function()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		bangLoop:Disconnect()
	end)
	if args[1] then
		local players = getPlayer(args[1], speaker)
		for _, v in pairs(players) do
			local bangplr = Players[v].Name
			local bangOffet = CFrame.new(0, 0, 1.1)
			bangLoop = RunService.Stepped:Connect(function()
				pcall(function()
					local otherRoot = getTorso(Players[bangplr].Character)
					getRoot(speaker.Character).CFrame = otherRoot.CFrame * bangOffet
				end)
			end)
			break
		end
	end
end)

addcmd("unbang", {"unrape"}, function(args, speaker)
	if bangDied then
		bangDied:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangLoop:Disconnect()
	end
end)

addcmd('carpet',{},function(args, speaker)
	if not r15(speaker) then
		execCmd('uncarpet')
		wait()
		local players = getPlayer(args[1], speaker)
		for i,v in pairs(players)do
			carpetAnim = Instance.new("Animation")
			carpetAnim.AnimationId = "rbxassetid://282574440"
			carpet = speaker.Character:FindFirstChildOfClass('Humanoid'):LoadAnimation(carpetAnim)
			carpet:Play(.1, 1, 1)
			local carpetplr = Players[v].Name
			carpetDied = speaker.Character:FindFirstChildOfClass'Humanoid'.Died:Connect(function()
				carpetLoop:Disconnect()
				carpet:Stop()
				carpetAnim:Destroy()
				carpetDied:Disconnect()
			end)
			carpetLoop = RunService.Heartbeat:Connect(function()
				pcall(function()
					getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[carpetplr].Character).CFrame
				end)
			end)
		end
	else
		notify('R6 Required','This command requires the r6 rig type')
	end
end)

addcmd('uncarpet',{'nocarpet'},function(args, speaker)
	if carpetLoop then
		carpetLoop:Disconnect()
		carpetDied:Disconnect()
		carpet:Stop()
		carpetAnim:Destroy()
	end
end)

addcmd('friend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RequestFriendship(Players[v])
	end
end)

addcmd('unfriend',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		speaker:RevokeFriendship(Players[v])
	end
end)

addcmd('bringpart',{},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

addcmd('bringpartclass',{'bpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			v.CFrame = getRoot(speaker.Character).CFrame
		end
	end
end)

gotopartDelay = 0.1
addcmd('gotopart',{'topart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopart',{'tgotopart','ttopart'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotopartclass',{'gpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v.CFrame
		end
	end
end)

addcmd('tweengotopartclass',{'tgpc'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.ClassName:lower() == getstring(1, args):lower() and v:IsA("BasePart") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v.CFrame}):Play()
		end
	end
end)

addcmd('gotomodel',{'tomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			getRoot(speaker.Character).CFrame = v:GetModelCFrame()
		end
	end
end)

addcmd('tweengotomodel',{'tgotomodel','ttomodel'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v.Name:lower() == getstring(1, args):lower() and v:IsA("Model") then
			if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			wait(gotopartDelay)
			TweenService:Create(getRoot(speaker.Character), TweenInfo.new(tweenSpeed, Enum.EasingStyle.Linear), {CFrame = v:GetModelCFrame()}):Play()
		end
	end
end)

addcmd('gotopartdelay',{},function(args, speaker)
	local gtpDelay = args[1] or 0.1
	if isNumber(gtpDelay) then
		gotopartDelay = gtpDelay
	end
end)

addcmd('noclickdetectorlimits',{'nocdlimits','removecdlimits'},function(args, speaker)
	for i,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireclickdetectors',{'firecd','firecds'}, function(args, speaker)
	if fireclickdetector then
		if args[1] then
			local name = getstring(1, args):lower()
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") and descendant.Name:lower() == name or descendant.Parent.Name:lower() == name then
					fireclickdetector(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ClickDetector") then
					fireclickdetector(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireclickdetector)")
	end
end)

addcmd('noproximitypromptlimits',{'nopplimits','removepplimits'},function(args, speaker)
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			v.MaxActivationDistance = math.huge
		end
	end
end)

addcmd('fireproximityprompts',{'firepp'},function(args, speaker)
	if fireproximityprompt then
		if args[1] then
			local name = getstring(1, args)
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") and descendant.Name == name or descendant.Parent.Name == name then
					fireproximityprompt(descendant)
				end
			end
		else
			for _, descendant in ipairs(workspace:GetDescendants()) do
				if descendant:IsA("ProximityPrompt") then
					fireproximityprompt(descendant)
				end
			end
		end
	else
		notify("Incompatible Exploit", "Your exploit does not support this command (missing fireproximityprompt)")
	end
end)

local PromptButtonHoldBegan = nil
addcmd('instantproximityprompts',{'instantpp'},function(args, speaker)
	if fireproximityprompt then
		execCmd("uninstantproximityprompts")
		wait(0.1)
		PromptButtonHoldBegan = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
			fireproximityprompt(prompt)
		end)
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing fireproximityprompt)')
	end
end)

addcmd('uninstantproximityprompts',{'uninstantpp'},function(args, speaker)
	if PromptButtonHoldBegan ~= nil then
		PromptButtonHoldBegan:Disconnect()
		PromptButtonHoldBegan = nil
	end
end)

addcmd('notifyping',{'ping'},function(args, speaker)
	notify("Ping", math.round(speaker:GetNetworkPing() * 1000) .. "ms")
end)

addcmd('grabtools', {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	for _, child in ipairs(workspace:GetChildren()) do
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end

	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	grabtoolsFunc = workspace.ChildAdded:Connect(function(child)
		if speaker.Character and child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
			humanoid:EquipTool(child)
		end
	end)

	notify("Grabtools", "Picking up any dropped tools")
end)

addcmd('nograbtools',{'ungrabtools'},function(args, speaker)
	if grabtoolsFunc then 
		grabtoolsFunc:Disconnect() 
	end

	notify("Grabtools", "Grabtools has been disabled")
end)

local specifictoolremoval = {}
addcmd('removespecifictool',{},function(args, speaker)
	if args[1] and speaker:FindFirstChildOfClass("Backpack") then
		local tool = string.lower(getstring(1, args))
		local RST = RunService.RenderStepped:Connect(function()
			if speaker:FindFirstChildOfClass("Backpack") then
				for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
					if v.Name:lower() == tool then
						v:Remove()
					end
				end
			end
		end)
		specifictoolremoval[tool] = RST
	end
end)

addcmd('unremovespecifictool',{},function(args, speaker)
	if args[1] then
		local tool = string.lower(getstring(1, args))
		if specifictoolremoval[tool] ~= nil then
			specifictoolremoval[tool]:Disconnect()
			specifictoolremoval[tool] = nil
		end
	end
end)

addcmd('clearremovespecifictool',{},function(args, speaker)
	for obj in pairs(specifictoolremoval) do
		specifictoolremoval[obj]:Disconnect()
		specifictoolremoval[obj] = nil
	end
end)

addcmd('light',{},function(args, speaker)
	local light = Instance.new("PointLight")
	light.Parent = getRoot(speaker.Character)
	light.Range = 30
	if args[1] then
		light.Brightness = args[2]
		light.Range = args[1]
	else
		light.Brightness = 5
	end
end)

addcmd('unlight',{'nolight'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v.ClassName == "PointLight" then
			v:Destroy()
		end
	end
end)

addcmd('copytools',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players)do
		task.spawn(function()
			for i,v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
				if v:IsA('Tool') or v:IsA('HopperBin') then
					v:Clone().Parent = speaker:FindFirstChildOfClass("Backpack")
				end
			end
		end)
	end
end)

addcmd('naked',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
end)

addcmd('noface',{'removeface'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Decal") and v.Name == 'face' then
			v:Destroy()
		end
	end
end)

addcmd('spawnpoint',{'spawn'},function(args, speaker)
	spawnpos = getRoot(speaker.Character).CFrame
	spawnpoint = true
	spDelay = tonumber(args[1]) or 0.1
	notify('Spawn Point','Spawn point created at '..tostring(spawnpos))
end)

addcmd('nospawnpoint',{'nospawn','removespawnpoint'},function(args, speaker)
	spawnpoint = false
	notify('Spawn Point','Removed spawn point')
end)

addcmd('flashback',{'diedtp'},function(args, speaker)
	if lastDeath ~= nil then
		if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
			speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
			wait(.1)
		end
		getRoot(speaker.Character).CFrame = lastDeath
	end
end)

addcmd('hatspin',{'spinhats'},function(args, speaker)
	execCmd('unhatspin')
	wait(.5)
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		local keep = Instance.new("BodyPosition") keep.Name = randomString() keep.Parent = v.Handle
		local spin = Instance.new("BodyAngularVelocity") spin.Name = randomString() spin.Parent = v.Handle
		v.Handle:FindFirstChildOfClass("Weld"):Destroy()
		if args[1] then
			spin.AngularVelocity = Vector3.new(0, args[1], 0)
			spin.MaxTorque = Vector3.new(0, args[1] * 2, 0)
		else
			spin.AngularVelocity = Vector3.new(0, 100, 0)
			spin.MaxTorque = Vector3.new(0, 200, 0)
		end
		keep.P = 30000
		keep.D = 50
		spinhats = RunService.Stepped:Connect(function()
			pcall(function()
				keep.Position = Players.LocalPlayer.Character.Head.Position
			end)
		end)
	end
end)

addcmd('unhatspin',{'unspinhats'},function(args, speaker)
	if spinhats then
		spinhats:Disconnect()
	end
	for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
		v.Parent = workspace
		for i,c in pairs(v.Handle) do
			if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
				c:Destroy()
			end
		end
		wait()
		v.Parent = speaker.Character
	end
end)

addcmd('clearhats',{'cleanhats'},function(args, speaker)
	if firetouchinterest then
		local Player = Players.LocalPlayer
		local Character = Player.Character
		local Old = getRoot(Character).CFrame
		local Hats = {}

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(Hats, child)
			end
		end

		for _, accessory in ipairs(Character:FindFirstChildOfClass("Humanoid"):GetAccessories()) do
			accessory:Destroy()
		end

		for i = 1, #Hats do
			repeat RunService.Heartbeat:wait() until Hats[i]
			firetouchinterest(Hats[i].Handle,getRoot(Character),0)
			repeat RunService.Heartbeat:wait() until Character:FindFirstChildOfClass("Accessory")
			Character:FindFirstChildOfClass("Accessory"):Destroy()
			repeat RunService.Heartbeat:wait() until not Character:FindFirstChildOfClass("Accessory")
		end

		execCmd("reset")

		Player.CharacterAdded:Wait()

		for i = 1,20 do 
			RunService.Heartbeat:Wait()
			if getRoot(Player.Character) then
				getRoot(Player.Character).Humanoid.RootPart.CFrame = Old
			end
		end
	else
		notify("Incompatible Exploit","Your exploit does not support this command (missing firetouchinterest)")
	end
end)

addcmd('split',{},function(args, speaker)
	if r15(speaker) then
		speaker.Character.UpperTorso.Waist:Destroy()
	else
		notify('R15 Required','This command requires the r15 rig type')
	end
end)

addcmd('nilchar',{},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = nil
	end
end)

addcmd('unnilchar',{'nonilchar'},function(args, speaker)
	if speaker.Character ~= nil then
		speaker.Character.Parent = workspace
	end
end)

addcmd('noroot',{'removeroot','rroot'},function(args, speaker)
	if speaker.Character ~= nil then
		local char = Players.LocalPlayer.Character
		char.Parent = nil
		char.Humanoid.RootPart:Destroy()
		char.Parent = workspace
	end
end)

addcmd('replaceroot',{'replacerootpart'},function(args, speaker)
	if speaker.Character ~= nil and getRoot(speaker.Character) then
		local Char = speaker.Character
		local OldParent = Char.Parent
		local HRP = Char and getRoot(Char)
		local OldPos = HRP.CFrame
		Char.Parent = game
		local HRP1 = HRP:Clone()
		HRP1.Parent = Char
		HRP = HRP:Destroy()
		HRP1.CFrame = OldPos
		Char.Parent = OldParent
	end
end)

addcmd('clearcharappearance',{'clearchar','clrchar'},function(args, speaker)
	speaker:ClearCharacterAppearance()
end)

addcmd('equiptools',{},function(args, speaker)
	for i,v in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent = speaker.Character
		end
	end
end)

addcmd('unequiptools',{},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

local function GetHandleTools(p)
	p = p or Players.LocalPlayer
	local r = {}
	for _, v in ipairs(p.Character and p.Character:GetChildren() or {}) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	for _, v in ipairs(p.Backpack:GetChildren()) do
		if v.IsA(v, "BackpackItem") and v.FindFirstChild(v, "Handle") then
			r[#r + 1] = v
		end
	end
	return r
end
addcmd('dupetools', {'clonetools'}, function(args, speaker)
	local LOOP_NUM = tonumber(args[1]) or 1
	local OrigPos = speaker.Character.Humanoid.RootPart.Position
	local Tools, TempPos = {}, Vector3.new(math.random(-2e5, 2e5), 2e5, math.random(-2e5, 2e5))
	for i = 1, LOOP_NUM do
		local Human = speaker.Character:WaitForChild("Humanoid")
		wait(.1, Human.Parent:MoveTo(TempPos))
		Human.RootPart.Anchored = speaker:ClearCharacterAppearance(wait(.1)) or true
		local t = GetHandleTools(speaker)
		while #t > 0 do
			for _, v in ipairs(t) do
				task.spawn(function()
					for _ = 1, 25 do
						v.Parent = speaker.Character
						v.Handle.Anchored = true
					end
					for _ = 1, 5 do
						v.Parent = workspace
					end
					table.insert(Tools, v.Handle)
				end)
			end
			t = GetHandleTools(speaker)
		end
		wait(.1)
		speaker.Character = speaker.Character:Destroy()
		speaker.CharacterAdded:Wait():WaitForChild("Humanoid").Parent:MoveTo(LOOP_NUM == i and OrigPos or TempPos, wait(.1))
		if i == LOOP_NUM or i % 5 == 0 then
			local HRP = speaker.Character.Humanoid.RootPart
			if type(firetouchinterest) == "function" then
				for _, v in ipairs(Tools) do
					v.Anchored = not firetouchinterest(v, HRP, 1, firetouchinterest(v, HRP, 0)) and false or false
				end
			else
				for _, v in ipairs(Tools) do
					task.spawn(function()
						local x = v.CanCollide
						v.CanCollide = false
						v.Anchored = false
						for _ = 1, 10 do
							v.CFrame = HRP.CFrame
							wait()
						end
						v.CanCollide = x
					end)
				end
			end
			wait(.1)
			Tools = {}
		end
		TempPos = TempPos + Vector3.new(10, math.random(-5, 5), 0)
	end
end)

addcmd('touchinterests', {'touchinterest', 'firetouchinterests', 'firetouchinterest'}, function(args, speaker)
	local Root = getRoot(speaker.Character) or speaker.Character:FindFirstChildWhichIsA("BasePart")

	if not firetouchinterest then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
		return
	end

	local function Touch(x)
		x = x.FindFirstAncestorWhichIsA(x, "Part")
		if x then
			return task.spawn(function()
				firetouchinterest(x, Root, 1, wait() and firetouchinterest(x, Root, 0))
			end)
		end
		x.CFrame = Root.CFrame
	end

	if args[1] then
		local name = getstring(1, args):lower()
		print(name..' -name')
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("TouchTransmitter") and v.Name:lower() == name or v.Parent.Name:lower() == name then
				Touch(v)
			end
		end
	else
		for _, v in ipairs(workspace:GetDescendants()) do
			if v.IsA(v, "TouchTransmitter") then
				Touch(v)
			end
		end
	end
end)

addcmd('fullbright',{'fb','fullbrightness'},function(args, speaker)
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end)

addcmd('loopfullbright',{'loopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
	local function brightFunc()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end

	brightLoop = RunService.RenderStepped:Connect(brightFunc)
end)

addcmd('unloopfullbright',{'unloopfb'},function(args, speaker)
	if brightLoop then
		brightLoop:Disconnect()
	end
end)

addcmd('ambient',{},function(args, speaker)
	Lighting.Ambient = Color3.new(args[1],args[2],args[3])
	Lighting.OutdoorAmbient = Color3.new(args[1],args[2],args[3])
end)

addcmd('day',{},function(args, speaker)
	Lighting.ClockTime = 14
end)

addcmd('night',{},function(args, speaker)
	Lighting.ClockTime = 0
end)

addcmd('nofog',{},function(args, speaker)
	Lighting.FogEnd = 100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

addcmd('brightness',{},function(args, speaker)
	Lighting.Brightness = args[1]
end)

addcmd("globalshadows", {"gshadows"}, function(args, speaker)
    Lighting.GlobalShadows = true
end)

addcmd("unglobalshadows", {"ungshadows"}, function(args, speaker)
    Lighting.GlobalShadows = false
end)

origsettings = {abt = Lighting.Ambient, oabt = Lighting.OutdoorAmbient, brt = Lighting.Brightness, time = Lighting.ClockTime, fe = Lighting.FogEnd, fs = Lighting.FogStart, gs = Lighting.GlobalShadows}

addcmd('restorelighting',{'rlighting'},function(args, speaker)
	Lighting.Ambient = origsettings.abt
	Lighting.OutdoorAmbient = origsettings.oabt
	Lighting.Brightness = origsettings.brt
	Lighting.ClockTime = origsettings.time
	Lighting.FogEnd = origsettings.fe
	Lighting.FogStart = origsettings.fs
	Lighting.GlobalShadows = origsettings.gs
end)

addcmd('stun',{'platformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
end)

addcmd('unstun',{'nostun','unplatformstand','noplatformstand'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
end)

addcmd('norotate',{'noautorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = false
end)

addcmd('unnorotate',{'autorotate'},function(args, speaker)
	speaker.Character:FindFirstChildOfClass('Humanoid').AutoRotate  = true
end)

addcmd('enablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, true)
end)

addcmd('disablestate',{},function(args, speaker)
	local x = args[1]
	if not tonumber(x) then
		local x = Enum.HumanoidStateType[args[1]]
	end
	speaker.Character:FindFirstChildOfClass("Humanoid"):SetStateEnabled(x, false)
end)

addcmd('drophats',{'drophat'},function(args, speaker)
	if speaker.Character then
		for _,v in pairs(speaker.Character:FindFirstChildOfClass('Humanoid'):GetAccessories()) do
			v.Parent = workspace
		end
	end
end)

addcmd('deletehats',{'nohats','rhats'},function(args, speaker)
	for i,v in next, speaker.Character:GetDescendants() do
		if v:IsA("Accessory") then
			for i,p in next, v:GetDescendants() do
				if p:IsA("Weld") then
					p:Destroy()
				end
			end
		end
	end
end)

addcmd('droptools',{'droptool'},function(args, speaker)
	for i,v in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = Players.LocalPlayer.Character
		end
	end
	wait()
	for i,v in pairs(Players.LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = workspace
		end
	end
end)

addcmd('droppabletools',{},function(args, speaker)
	if speaker.Character then
		for _,obj in pairs(speaker.Character:GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
	if speaker:FindFirstChildOfClass("Backpack") then
		for _,obj in pairs(speaker:FindFirstChildOfClass("Backpack"):GetChildren()) do
			if obj:IsA("Tool") then
				obj.CanBeDropped = true
			end
		end
	end
end)

local currentToolSize = ""
local currentGripPos = ""
addcmd('reach',{},function(args, speaker)
	execCmd('unreach')
	wait()
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			if args[1] then
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,args[1])
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			else
				currentToolSize = v.Handle.Size
				currentGripPos = v.GripPos
				local a = Instance.new("SelectionBox")
				a.Name = "SelectionBoxCreated"
				a.Parent = v.Handle
				a.Adornee = v.Handle
				v.Handle.Massless = true
				v.Handle.Size = Vector3.new(0.5,0.5,60)
				v.GripPos = Vector3.new(0,0,0)
				speaker.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
			end
		end
	end
end)

addcmd("boxreach", {}, function(args, speaker)
	execCmd("unreach")
	wait()
	for i, v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			local size = tonumber(args[1]) or 60
			currentToolSize = v.Handle.Size
			currentGripPos = v.GripPos
			local a = Instance.new("SelectionBox")
			a.Name = "SelectionBoxCreated"
			a.Parent = v.Handle
			a.Adornee = v.Handle
			v.Handle.Massless = true
			v.Handle.Size = Vector3.new(size, size, size)
			v.GripPos = Vector3.new(0, 0, 0)
			speaker.Character:FindFirstChildOfClass("Humanoid"):UnequipTools()
		end
	end
end)

addcmd('unreach',{'noreach','unboxreach'},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Handle.Size = currentToolSize
			v.GripPos = currentGripPos
			v.Handle.SelectionBoxCreated:Destroy()
		end
	end
end)

addcmd('grippos',{},function(args, speaker)
	for i,v in pairs(speaker.Character:GetDescendants()) do
		if v:IsA("Tool") then
			v.Parent = speaker:FindFirstChildOfClass("Backpack")
			v.GripPos = Vector3.new(args[1],args[2],args[3])
			v.Parent = speaker.Character
		end
	end
end)

addcmd('usetools', {}, function(args, speaker)
	local Backpack = speaker:FindFirstChildOfClass("Backpack")
	local amount = tonumber(args[1]) or 1
	local delay_ = tonumber(args[2]) or false
	for _, v in ipairs(Backpack:GetChildren()) do
		v.Parent = speaker.Character
		task.spawn(function()
			for _ = 1, amount do
				v:Activate()
				if delay_ then
					wait(delay_)
				end
			end
			v.Parent = Backpack
		end)
	end
end)

addcmd("logs", {}, function(args, speaker)
	logsEnabled = true
	jLogsEnabled = true
	Toggle.Text = "Enabled"
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogs", {"clogs"}, function(args, speaker)
	logsEnabled = true
	join.Visible = false
	chat.Visible = true
	table.remove(shade3, table.find(shade3, selectChat))
	table.remove(shade2, table.find(shade2, selectJoin))
	table.insert(shade2, selectChat)
	table.insert(shade3, selectJoin)
	selectJoin.BackgroundColor3 = currentShade3
	selectChat.BackgroundColor3 = currentShade2
	Toggle.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("joinlogs", {"jlogs"}, function(args, speaker)
	jLogsEnabled = true
	chat.Visible = false
	join.Visible = true	
	table.remove(shade3, table.find(shade3, selectJoin))
	table.remove(shade2, table.find(shade2, selectChat))
	table.insert(shade2, selectJoin)
	table.insert(shade3, selectChat)
	selectChat.BackgroundColor3 = currentShade3
	selectJoin.BackgroundColor3 = currentShade2
	Toggle_2.Text = "Enabled"
	logs:TweenPosition(UDim2.new(0, 0, 1, -265), "InOut", "Quart", 0.3, true, nil)
end)

addcmd("chatlogswebhook", {"logswebhook"}, function(args, speaker)
	if not httprequest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing request)")
	end
	logsWebhook = args[1] or nil
	updatesaves()
end)

flinging = false
addcmd('fling',{},function(args, speaker)
	flinging = false
	for _, child in next, speaker.Character:GetDescendants() do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
		end
	end
	execCmd('noclip nonotify')
	task.wait(.1)
	local bambam = Instance.new("BodyAngularVelocity")
	bambam.Name = randomString()
	bambam.Parent = getRoot(speaker.Character)
	bambam.AngularVelocity = Vector3.new(0,99999,0)
	bambam.MaxTorque = Vector3.new(0,math.huge,0)
	bambam.P = math.huge
	for i, v in next, speaker.Character:GetChildren() do
		if v:IsA("BasePart") then
			v.Massless = true
			v.Velocity = Vector3.zero
		end
	end
	flinging = true
	flingDied = speaker.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
		execCmd('unfling')
	end)
	repeat
		bambam.AngularVelocity = Vector3.new(0,99999,0)
		task.wait(.2)
		bambam.AngularVelocity = Vector3.new(0,0,0)
		task.wait(.1)
	until flinging == false
end)

addcmd('unfling',{'nofling'},function(args, speaker)
	execCmd('clip nonotify')
	if flingDied then flingDied:Disconnect() end
	flinging = false
	task.wait(.1)
	local speakerChar = speaker.Character
	if not speakerChar or not getRoot(speakerChar) then return end
	for _, v in next, speakerChar:GetDescendants() do
		if v:IsA("BasePart") then
			v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
			v.Massless = false
			v.Velocity = Vector3.zero
		elseif v:IsA("BodyAngularVelocity") then
			v:Destroy()
		end
	end
end)

addcmd('togglefling',{},function(args, speaker)
	if flinging then
		execCmd('unfling')
	else
		execCmd('fling')
	end
end)

addcmd("flyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling")
	task.wait()
	vehicleflyspeed = tonumber(args[1]) or vehicleflyspeed
	execCmd("vehiclefly\\walkfling")
end)

addcmd("unflyfling", {}, function(args, speaker)
	execCmd("unvehiclefly\\unwalkfling\\breakvelocity")
end)

addcmd("toggleflyfling", {}, function(args, speaker)
	execCmd(flinging and "unflyfling" or "flyfling")
end)

walkflinging = false
addcmd("walkfling", {}, function(args, speaker)
	execCmd("unwalkfling")
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			execCmd("unwalkfling")
		end)
	end

	execCmd("noclip nonotify")
	walkflinging = true
	repeat RunService.Heartbeat:Wait()
		local character = speaker.Character
		local root = getRoot(character)
		local vel, movel = nil, 0.1

		while not (character and character.Parent and root and root.Parent) do
			RunService.Heartbeat:Wait()
			character = speaker.Character
			root = getRoot(character)
		end

		vel = root.Velocity
		root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)

		RunService.RenderStepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel
		end

		RunService.Stepped:Wait()
		if character and character.Parent and root and root.Parent then
			root.Velocity = vel + Vector3.new(0, movel, 0)
			movel = movel * -1
		end
	until walkflinging == false
end)

addcmd("unwalkfling", {"nowalkfling"}, function(args, speaker)
	walkflinging = false
	execCmd("unnoclip nonotify")
end)

addcmd("togglewalkfling", {}, function(args, speaker)
	execCmd(walkflinging and "unwalkfling" or "walkfling")
end)

addcmd('invisfling',{},function(args, speaker)
	local ch = speaker.Character
	ch:FindFirstChildWhichIsA("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	local prt=Instance.new("Model")
	prt.Parent = speaker.Character
	local z1 = Instance.new("Part")
	z1.Name="Torso"
	z1.CanCollide = false
	z1.Anchored = true
	local z2 = Instance.new("Part")
	z2.Name="Head"
	z2.Parent = prt
	z2.Anchored = true
	z2.CanCollide = false
	local z3 =Instance.new("Humanoid")
	z3.Name="Humanoid"
	z3.Parent = prt
	z1.Position = Vector3.new(0,9999,0)
	speaker.Character=prt
	wait(3)
	speaker.Character=ch
	wait(3)
	local Hum = Instance.new("Humanoid")
	z2:Clone()
	Hum.Parent = speaker.Character
	local root =  getRoot(speaker.Character)
	for i,v in pairs(speaker.Character:GetChildren()) do
		if v ~= root and  v.Name ~= "Humanoid" then
			v:Destroy()
		end
	end
	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)
	local invisflingStepped
	invisflingStepped = RunService.Stepped:Connect(function()
		if speaker.Character and getRoot(speaker.Character) then
			getRoot(speaker.Character).CanCollide = false
		else
			invisflingStepped:Disconnect()
		end
	end)
	sFLY()
	workspace.CurrentCamera.CameraSubject = root
	local bambam = Instance.new("BodyThrust")
	bambam.Parent = getRoot(speaker.Character)
	bambam.Force = Vector3.new(99999,99999*10,99999)
	bambam.Location = getRoot(speaker.Character).Position
end)

addcmd("clickfor", {}, function(args, speaker)
	clickFor = true
end)

addcmd("unclickfor", {}, function(args, speaker)
	clickFor = false
end)

addcmd("clicktype", {}, function(args, speaker)
	clickType = args[1]:lower() or "bang"
	return "Assigned as " .. clickType
end)

addcmd("antifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
	antifling = RunService.Stepped:Connect(function()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= speaker and player.Character then
				for _, v in pairs(player.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
			end
		end
	end)
end)

addcmd("unantifling", {}, function(args, speaker)
	if antifling then
		antifling:Disconnect()
		antifling = nil
	end
end)

addcmd("toggleantifling", {}, function(args, speaker)
	execCmd(antifling and "unantifling" or "antifling")
end)

function attach(speaker,target)
	if tools(speaker) then
		local char = speaker.Character
		local tchar = target.Character
		local hum = speaker.Character:FindFirstChildOfClass("Humanoid")
		local hrp = getRoot(speaker.Character)
		local hrp2 = getRoot(target.Character)
		hum.Name = "1"
		local newHum = hum:Clone()
		newHum.Parent = char
		newHum.Name = "Humanoid"
		wait()
		hum:Destroy()
		workspace.CurrentCamera.CameraSubject = char
		newHum.DisplayDistanceType = "None"
		local tool = speaker:FindFirstChildOfClass("Backpack"):FindFirstChildOfClass("Tool") or speaker.Character:FindFirstChildOfClass("Tool")
		tool.Parent = char
		hrp.CFrame = hrp2.CFrame * CFrame.new(0, 0, 0) * CFrame.new(math.random(-100, 100)/200,math.random(-100, 100)/200,math.random(-100, 100)/200)
		local n = 0
		repeat
			wait(.1)
			n = n + 1
			hrp.CFrame = hrp2.CFrame
		until (tool.Parent ~= char or not hrp or not hrp2 or not hrp.Parent or not hrp2.Parent or n > 250) and n > 2
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function kill(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = CFrame.new(999999, workspace.FallenPartsDestroyHeight + 5,999999)
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd("handlekill", {"hkill"}, function(args, speaker)
	if not firetouchinterest then
		return notify("Incompatible Exploit", "Your exploit does not support this command (missing firetouchinterest)")
	end
	if not speaker.Character then return end
	local tool = speaker.Character:FindFirstChildWhichIsA("Tool")
	local handle = tool and tool:FindFirstChild("Handle")
	if not handle then
		return notify("Handle Kill", "You need to hold a \"Tool\" that does damage on touch. For example a common Sword tool.")
	end
	local range = tonumber(args[2]) or math.huge
	if range ~= math.huge then notify("Handle Kill", ("Started!\nRadius: %s"):format(tostring(range):upper())) end

	while task.wait() and speaker.Character and tool.Parent and tool.Parent == speaker.Character do
		for _, plr in next, getPlayer(args[1], speaker) do
			plr = Players[plr]
			if plr ~= speaker and plr.Character then
				local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
				local root = hum and getRoot(plr.Character)

				if root and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead and speaker:DistanceFromCharacter(root.Position) <= range then
					firetouchinterest(handle, root, 1)
					firetouchinterest(handle, root, 0)
				end
			end
		end
	end

	notify("Handle Kill", "Stopped!")
end)

tpwalkStack = 0
addcmd("teleportwalk", {"tpwalk"}, function(args, speaker)
    pcall(function() tpwalking:Disconnect() end)

    local character = speaker.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local speed = (args[1] and isNumber(args[1])) and tonumber(args[1]) or 1

    if parseBoolean(args[2]) then
        tpwalkStack = tpwalkStack + speed
    end

    tpwalking = RunService.Heartbeat:Connect(function(delta)
        if not (character and humanoid and humanoid.Parent) then
            tpwalking:Disconnect()
            return
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            character:TranslateBy(humanoid.MoveDirection * (speed + tpwalkStack) * delta * 10)
        end
    end)
end)

addcmd("unteleportwalk", {"untpwalk"}, function(args, speaker)
    tpwalkStack = 0
    tpwalking:Disconnect()
end)

function bring(speaker,target,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = NormPos
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

function teleport(speaker,target,target2,fast)
	if tools(speaker) then
		if target ~= nil then
			local NormPos = getRoot(speaker.Character).CFrame
			if not fast then
				refresh(speaker)
				wait()
				repeat wait() until speaker.Character ~= nil and getRoot(speaker.Character)
				wait(0.3)
			end
			local hrp = getRoot(speaker.Character)
			local hrp2 = getRoot(target2.Character)
			attach(speaker,target)
			repeat
				wait()
				hrp.CFrame = hrp2.CFrame
			until not getRoot(target.Character) or not getRoot(speaker.Character)
			wait(1)
			local char = speaker.CharacterAdded:Wait()
			local humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			while not humanoid:IsA("Humanoid") do
				humanoid = char:FindFirstChildOfClass("Humanoid") or char.ChildAdded:Wait()
			end
			humanoid.RootPart.CFrame = NormPos
		end
	else
		notify('Tool Required','You need to have an item in your inventory to use this command')
	end
end

addcmd('spin',{},function(args, speaker)
	local spinSpeed = 20
	if args[1] and isNumber(args[1]) then
		spinSpeed = args[1]
	end
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
	local Spin = Instance.new("BodyAngularVelocity")
	Spin.Name = "Spinning"
	Spin.Parent = getRoot(speaker.Character)
	Spin.MaxTorque = Vector3.new(0, math.huge, 0)
	Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
end)

addcmd('unspin',{},function(args, speaker)
	for i,v in pairs(getRoot(speaker.Character):GetChildren()) do
		if v.Name == "Spinning" then
			v:Destroy()
		end
	end
end)

xrayEnabled = false
function xray()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
			v.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
		end
	end
end

addcmd("xray", {}, function(args, speaker)
	xrayEnabled = true
	xray()
end)

addcmd("unxray", {"noxray"}, function(args, speaker)
	xrayEnabled = false
	xray()
end)

addcmd("togglexray", {}, function(args, speaker)
	xrayEnabled = not xrayEnabled
	xray()
end)

addcmd("loopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayLoop = RunService.RenderStepped:Connect(function()
		xrayEnabled = true
		xray()
	end)
end)

addcmd("unloopxray", {}, function(args, speaker)
	pcall(function() xrayLoop:Disconnect() end)
	xrayEnabled = false
	xray()
end)

local walltpTouch = nil
addcmd('walltp',{},function(args, speaker)
	local torso
	if r15(speaker) then
		torso = speaker.Character.UpperTorso
	else
		torso = speaker.Character.Torso
	end
	local function touchedFunc(hit)
		local Root = getRoot(speaker.Character)
		if hit:IsA("BasePart") and hit.Position.Y > Root.Position.Y - speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight then
			local hitP = getRoot(hit.Parent)
			if hitP ~= nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hitP.Size.Z/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			elseif hitP == nil then
				Root.CFrame = hit.CFrame * CFrame.new(Root.CFrame.lookVector.X,hit.Size.Y/2 + speaker.Character:FindFirstChildOfClass('Humanoid').HipHeight,Root.CFrame.lookVector.Z)
			end
		end
	end
	walltpTouch = torso.Touched:Connect(touchedFunc)
end)

addcmd('unwalltp',{'nowalltp'},function(args, speaker)
	if walltpTouch then
		walltpTouch:Disconnect()
	end
end)

autoclicking = false
addcmd('autoclick',{},function(args, speaker)
	if mouse1press and mouse1release then
		execCmd('unautoclick')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[1] and isNumber(args[1]) then clickDelay = args[1] end
		if args[2] and isNumber(args[2]) then releaseDelay = args[2] end
		autoclicking = true
		cancelAutoClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoclicking = false
					cancelAutoClick:Disconnect()
				end
			end
		end)
		notify('Auto Clicker',"Press [backspace] and [=] at the same time to stop")
		repeat wait(clickDelay)
			mouse1press()
			wait(releaseDelay)
			mouse1release()
		until autoclicking == false
	else
		notify('Auto Clicker',"Your exploit doesn't have the ability to use the autoclick")
	end
end)

addcmd('unautoclick',{'noautoclick'},function(args, speaker)
	autoclicking = false
	if cancelAutoClick then cancelAutoClick:Disconnect() end
end)

addcmd('mousesensitivity',{'ms'},function(args, speaker)
	UserInputService.MouseDeltaSensitivity = args[1]
end)

local nameBox = nil
local nbSelection = nil
addcmd('hovername',{},function(args, speaker)
	execCmd('unhovername')
	wait()
	nameBox = Instance.new("TextLabel")
	nameBox.Name = randomString()
	nameBox.Parent = ScaledHolder
	nameBox.BackgroundTransparency = 1
	nameBox.Size = UDim2.new(0,200,0,30)
	nameBox.Font = Enum.Font.Code
	nameBox.TextSize = 16
	nameBox.Text = ""
	nameBox.TextColor3 = Color3.new(1, 1, 1)
	nameBox.TextStrokeTransparency = 0
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.ZIndex = 10
	nbSelection = Instance.new('SelectionBox')
	nbSelection.Name = randomString()
	nbSelection.LineThickness = 0.03
	nbSelection.Color3 = Color3.new(1, 1, 1)
	local function updateNameBox()
		local t
		local target = IYMouse.Target

		if target then
			local humanoid = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				t = humanoid.Parent
			end
		end

		if t ~= nil then
			local x = IYMouse.X
			local y = IYMouse.Y
			local xP
			local yP
			if IYMouse.X > 200 then
				xP = x - 205
				nameBox.TextXAlignment = Enum.TextXAlignment.Right
			else
				xP = x + 25
				nameBox.TextXAlignment = Enum.TextXAlignment.Left
			end
			nameBox.Position = UDim2.new(0, xP, 0, y)
			nameBox.Text = t.Name
			nameBox.Visible = true
			nbSelection.Parent = t
			nbSelection.Adornee = t
		else
			nameBox.Visible = false
			nbSelection.Parent = nil
			nbSelection.Adornee = nil
		end
	end
	nbUpdateFunc = IYMouse.Move:Connect(updateNameBox)
end)

addcmd('unhovername',{'nohovername'},function(args, speaker)
	if nbUpdateFunc then
		nbUpdateFunc:Disconnect()
		nameBox:Destroy()
		nbSelection:Destroy()
	end
end)

addcmd('headsize',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if Players[v] ~= speaker and Players[v].Character:FindFirstChild('Head') then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Head = Players[v].Character:FindFirstChild('Head')
			if Head:IsA("BasePart") then
				Head.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Head.Size = Vector3.new(2,1,1)
				else
					Head.Size = Size
				end
			end
		end
	end
end)

addcmd('hitbox',{},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local transparency = args[3] and tonumber(args[3]) or 0.4
	for i,v in pairs(players) do
		if Players[v] ~= speaker and getRoot(Players[v].Character) then
			local sizeArg = tonumber(args[2])
			local Size = Vector3.new(sizeArg,sizeArg,sizeArg)
			local Root = getRoot(Players[v].Character)
			if Root:IsA("BasePart") then
				Root.CanCollide = false
				if not args[2] or sizeArg == 1 then
					Root.Size = Vector3.new(2,1,1)
					Root.Transparency = transparency
				else
					Root.Size = Size
					Root.Transparency = transparency
				end
			end
		end
	end
end)

addcmd("hitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = true
end)

addcmd("unhitboxes", {}, function(args, speaker)
    settings():GetService("RenderSettings").ShowBoundingBoxes = false
end)

addcmd('stareat',{'stare'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		if stareLoop then
			stareLoop:Disconnect()
		end
		if not getRoot(Players.LocalPlayer.Character) and getRoot(Players[v].Character) then return end
		local function stareFunc()
			if Players.LocalPlayer.Character.PrimaryPart and Players:FindFirstChild(v) and Players[v].Character ~= nil and getRoot(Players[v].Character) then
				local chrPos=Players.LocalPlayer.Character.PrimaryPart.Position
				local tPos=getRoot(Players[v].Character).Position
				local modTPos=Vector3.new(tPos.X,chrPos.Y,tPos.Z)
				local newCF=CFrame.new(chrPos,modTPos)
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCF)
			elseif not Players:FindFirstChild(v) then
				stareLoop:Disconnect()
			end
		end

		stareLoop = RunService.RenderStepped:Connect(stareFunc)
	end
end)

addcmd('unstareat',{'unstare','nostare','nostareat'},function(args, speaker)
	if stareLoop then
		stareLoop:Disconnect()
	end
end)

RolewatchData = {Group = 0, Role = "", Leave = false}
RolewatchConnection = Players.PlayerAdded:Connect(function(player)
	if RolewatchData.Group == 0 then return end
	if player:IsInGroup(RolewatchData.Group) then
		if tostring(player:GetRoleInGroup(RolewatchData.Group)):lower() == RolewatchData.Role:lower() then
			if RolewatchData.Leave == true then
				Players.LocalPlayer:Kick("\n\nRolewatch\nPlayer \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"\n")
			else
				notify("Rolewatch", "Player \"" .. tostring(player.Name) .. "\" has joined with the Role \"" .. RolewatchData.Role .. "\"")
			end
		end
	end
end)

addcmd("rolewatch", {}, function(args, speaker)
	local groupId = tonumber(args[1] or 0)
	local roleName = args[2] and tostring(getstring(2, args))
	if groupId and roleName then
		RolewatchData.Group = groupId
		RolewatchData.Role = roleName
		notify("Rolewatch", "Watching Group ID \"" .. tostring(groupId) .. "\" for Role \"" .. roleName .. "\"")
	end
end)

addcmd("rolewatchstop", {}, function(args, speaker)
	RolewatchData.Group = 0
	RolewatchData.Role = ""
	RolewatchData.Leave = false
	notify("Rolewatch", "Disabled")
end)

addcmd("rolewatchleave", {"unrolewatch"}, function(args, speaker)
	RolewatchData.Leave = not RolewatchData.Leave
	notify("Rolewatch", RolewatchData.Leave and "Leave has been Enabled" or "Leave has been Disabled")
end)

staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

getStaffRole = function(player)
	local playerRole = player:GetRoleInGroup(game.CreatorId)
	local result = {Role = playerRole, Staff = false}
	if player:IsInGroup(1200769) then
		result.Role = "Roblox Employee"
		result.Staff = true
	end
	for _, role in pairs(staffRoles) do
		if string.find(string.lower(playerRole), role) then
			result.Staff = true
		end
	end
	return result
end

addcmd("staffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	if game.CreatorType == Enum.CreatorType.Group then
		local found = {}
		staffwatchjoin = Players.PlayerAdded:Connect(function(player)
			local result = getStaffRole(player)
			if result.Staff then
				notify("Staffwatch", formatUsername(player) .. " is a " .. result.Role)
			end
		end)
		for _, player in pairs(Players:GetPlayers()) do
			local result = getStaffRole(player)
			if result.Staff then
				table.insert(found, formatUsername(player) .. " is a " .. result.Role)
			end
		end
		if #found > 0 then
			notify("Staffwatch", table.concat(found, ",\n"))
		else
			notify("Staffwatch", "Enabled")
		end
	else
		notify("Staffwatch", "Game is not owned by a Group")
	end
end)

addcmd("unstaffwatch", {}, function(args, speaker)
	if staffwatchjoin then
		staffwatchjoin:Disconnect()
	end
	notify("Staffwatch", "Disabled")
end)

local function playerGroups()
    local players = Players:GetPlayers()
    local graph = {}
    local seen = {}
    local groups = {}

    for _, p in ipairs(players) do
        graph[p] = {}
    end

    for i = 1, #players do
        for j = i + 1, #players do
            local p1 = players[i]
            local p2 = players[j]

            local success, result = pcall(function()
                return p1:IsFriendsWithAsync(p2.UserId)
            end)

            if success and result then
                table.insert(graph[p1], p2)
                table.insert(graph[p2], p1)
            end
        end
    end

    local function dfs(player, group)
        seen[player] = true
        table.insert(group, player)

        for _, possible in ipairs(graph[player]) do
            if not seen[possible] then
                dfs(possible, group)
            end
        end
    end

    for _, p in ipairs(players) do
        if not seen[p] then
            local group = {}
            dfs(p, group)
            table.insert(groups, group)
        end
    end

    return groups
end

addcmd("findfriendgroups", {}, function(args, speaker)
    notify("Checking Players", "This might take a while (slow function)")

    local groups = playerGroups()
    local playerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)

    local result = ""
    local index = 1
    local found = 0

    for _, group in ipairs(groups) do
        if #group == 1 then continue end
        local names = {}
        for _, player in ipairs(group) do
            table.insert(names, playerList and player.DisplayName or player.Name)
        end
        result = result .. index .. ". " .. table.concat(names, ", ") .. "\n"
        index = index + 1
        found = found + 1
    end

    createPopup("Friend Groups", found == 0 and "None" or result)
end)

addcmd('removeterrain',{'rterrain','noterrain'},function(args, speaker)
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

addcmd('clearnilinstances',{'nonilinstances','cni'},function(args, speaker)
	if getnilinstances then
		for i,v in pairs(getnilinstances()) do
			v:Destroy()
		end
	else
		notify('Incompatible Exploit','Your exploit does not support this command (missing getnilinstances)')
	end
end)

addcmd('destroyheight',{'dh'},function(args, speaker)
	local dh = args[1] or -500
	if isNumber(dh) then
		workspace.FallenPartsDestroyHeight = dh
	end
end)

OrgDestroyHeight = workspace.FallenPartsDestroyHeight
addcmd("antivoid", {}, function(args, speaker)
	execCmd("unantivoid nonotify")
	task.wait()
	antivoidloop = RunService.Stepped:Connect(function()
		local root = getRoot(speaker.Character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
		end
	end)
	if args[1] ~= "nonotify" then notify("antivoid", "Enabled") end
end)

addcmd("unantivoid", {"noantivoid"}, function(args, speaker)
	pcall(function() antivoidloop:Disconnect() end)
	antivoidloop = nil
	if args[1] ~= "nonotify" then notify("antivoid", "Disabled") end
end)

antivoidWasEnabled = false
addcmd("fakeout", {}, function(args, speaker)
	local root = getRoot(speaker.Character)
	local oldpos = root.CFrame
	if antivoidloop then
		execCmd("unantivoid nonotify")
		antivoidWasEnabled = true
	end
	workspace.FallenPartsDestroyHeight = 0/1/0
	root.CFrame = CFrame.new(Vector3.new(0, OrgDestroyHeight - 25, 0))
	task.wait(1)
	root.CFrame = oldpos
	workspace.FallenPartsDestroyHeight = OrgDestroyHeight
	if antivoidWasEnabled then
		execCmd("antivoid nonotify")
		antivoidWasEnabled = false
	end
end)

addcmd("trip", {}, function(args, speaker)
	local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local root = speaker.Character and getRoot(speaker.Character)
	if humanoid and root then
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		root.Velocity = root.CFrame.LookVector * 30
	end
end)

addcmd("removeads", {"adblock"}, function(args, speaker)
	while wait() do
		pcall(function()
			for i, v in pairs(workspace:GetDescendants()) do
				if v:IsA("PackageLink") then
					if v.Parent:FindFirstChild("ADpart") then
						v.Parent:Destroy()
					end
					if v.Parent:FindFirstChild("AdGuiAdornee") then
						v.Parent.Parent:Destroy()
					end
				end
			end
		end)
	end
end)

addcmd("scare", {"spook"}, function(args, speaker)
	local players = getPlayer(args[1], speaker)
	local oldpos = nil

	for _, v in pairs(players) do
		local root = speaker.Character and getRoot(speaker.Character)
		local target = Players[v]
		local targetRoot = target and target.Character and getRoot(target.Character)

		if root and targetRoot and target ~= speaker then
			oldpos = root.CFrame
			root.CFrame = targetRoot.CFrame + targetRoot.CFrame.lookVector * 2
			root.CFrame = CFrame.new(root.Position, targetRoot.Position)
			task.wait(0.5)
			root.CFrame = oldpos
		end
	end
end)

addcmd("alignmentkeys", {}, function(args, speaker)
	alignmentKeys = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma then workspace.CurrentCamera:PanUnits(-1) end
		if input.KeyCode == Enum.KeyCode.Period then workspace.CurrentCamera:PanUnits(1) end
	end)
	alignmentKeysEmotes = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

addcmd("unalignmentkeys", {"noalignmentkeys"}, function(args, speaker)
	if type(alignmentKeysEmotes) == "boolean" then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, alignmentKeysEmotes)
	end
	alignmentKeys:Disconnect()
end)

addcmd("ctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftControl"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftControl"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("unctrllock", {}, function(args, speaker)
	local mouseLockController = speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:FindFirstChild("BoundKeys")

	if boundKeys then
		boundKeys.Value = "LeftShift"
	else
		boundKeys = Instance.new("StringValue")
		boundKeys.Name = "BoundKeys"
		boundKeys.Value = "LeftShift"
		boundKeys.Parent = mouseLockController
	end
end)

addcmd("listento", {}, function(args, speaker)
	execCmd("unlistento")
	if not args[1] then return end

	local player = Players:FindFirstChild(getPlayer(args[1], speaker)[1])
	local root = player and player.Character and getRoot(player.Character)

	if root then
		SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
		listentoChar = player.CharacterAdded:Connect(function()
			repeat task.wait() until Players[player.Name].Character ~= nil and getRoot(Players[player.Name].Character)
			SoundService:SetListener(Enum.ListenerType.ObjectPosition, getRoot(Players[player.Name].Character))
		end)
	end
end)

addcmd("unlistento", {}, function(args, speaker)
	SoundService:SetListener(Enum.ListenerType.Camera)
	listentoChar:Disconnect()
end)

addcmd("jerk", {}, function(args, speaker)
	local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
	local backpack = speaker:FindFirstChildWhichIsA("Backpack")
	if not humanoid or not backpack then return end

	local tool = Instance.new("Tool")
	tool.Name = "Jerk Off"
	tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's justr say. My peanits."
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	while task.wait() do
		if not jorkin then continue end

		local isR15 = r15(speaker)
		if not track then
			local anim = Instance.new("Animation")
			anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(isR15 and 0.7 or 0.65)
		track.TimePosition = 0.6
		task.wait(0.1)
		while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

addcmd("guiscale", {}, function(args, speaker)
	if args[1] and isNumber(args[1]) then
		local scale = tonumber(args[1])
		if scale % 1 == 0 then scale = scale / 100 end
		-- me when i divide and it explodes
		if scale == 0.01 then scale = 1 end
		if scale == 0.02 then scale = 2 end

		if scale >= 0.4 and scale <= 2 then
			guiScale = scale
		end
	else
		guiScale = defaultGuiScale
	end

	Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale)
	updatesaves()
end)

addcmd("muteallvoices", {"muteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(true)
end)

addcmd("unmuteallvoices", {"unmuteallvcs"}, function(args, speaker)
	Services.VoiceChatInternal:SubscribePauseAll(false)
end)

addcmd("mutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, true)
	end
end)

addcmd("unmutevc", {}, function(args, speaker)
	for _, plr in getPlayer(args[1], speaker) do
		if Players[plr] == speaker then continue end
		Services.VoiceChatInternal:SubscribePause(Players[plr].UserId, false)
	end
end)

addcmd("phonebook", {"call"}, function(args, speaker)
	local success, canInvite = pcall(function()
		return SocialService:CanSendCallInviteAsync(speaker)
	end)
	if success and canInvite then
		SocialService:PromptPhoneBook(speaker, "")
	else
		notify("Phonebook", "It seems you're not able to call anyone. Sorry!")
	end
end)

local freezingua = nil
frozenParts = {}
addcmd('freezeunanchored',{'freezeua'},function(args, speaker)
	local badnames = {
		"Head",
		"UpperTorso",
		"LowerTorso",
		"RightUpperArm",
		"LeftUpperArm",
		"RightLowerArm",
		"LeftLowerArm",
		"RightHand",
		"LeftHand",
		"RightUpperLeg",
		"LeftUpperLeg",
		"RightLowerLeg",
		"LeftLowerLeg",
		"RightFoot",
		"LeftFoot",
		"Torso",
		"Right Arm",
		"Left Arm",
		"Right Leg",
		"Left Leg",
		"HumanoidRootPart"
	}
	local function FREEZENOOB(v)
		if v:IsA("BasePart" or "UnionOperation") and v.Anchored == false then
			local BADD = false
			for i = 1,#badnames do
				if v.Name == badnames[i] then
					BADD = true
				end
			end
			if speaker.Character and v:IsDescendantOf(speaker.Character) then
				BADD = true
			end
			if BADD == false then
				for i,c in pairs(v:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local bodypos = Instance.new("BodyPosition")
				bodypos.Parent = v
				bodypos.Position = v.Position
				bodypos.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				local bodygyro = Instance.new("BodyGyro")
				bodygyro.Parent = v
				bodygyro.CFrame = v.CFrame
				bodygyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
				if not table.find(frozenParts,v) then
					table.insert(frozenParts,v)
				end
			end
		end
	end
	for i,v in pairs(workspace:GetDescendants()) do
		FREEZENOOB(v)
	end
	freezingua = workspace.DescendantAdded:Connect(FREEZENOOB)
end)

addcmd('thawunanchored',{'thawua','unfreezeunanchored','unfreezeua'},function(args, speaker)
	if freezingua then
		freezingua:Disconnect()
	end
	for i,v in pairs(frozenParts) do
		for i,c in pairs(v:GetChildren()) do
			if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
				c:Destroy()
			end
		end
	end
	frozenParts = {}
end)

addcmd('tpunanchored',{'tpua'},function(args, speaker)
	local players = getPlayer(args[1], speaker)
	for i,v in pairs(players) do
		local Forces = {}
		for _,part in pairs(workspace:GetDescendants()) do
			if Players[v].Character:FindFirstChild('Head') and part:IsA("BasePart" or "UnionOperation" or "Model") and part.Anchored == false and not part:IsDescendantOf(speaker.Character) and part.Name == "Torso" == false and part.Name == "Head" == false and part.Name == "Right Arm" == false and part.Name == "Left Arm" == false and part.Name == "Right Leg" == false and part.Name == "Left Leg" == false and part.Name == "HumanoidRootPart" == false then
				for i,c in pairs(part:GetChildren()) do
					if c:IsA("BodyPosition") or c:IsA("BodyGyro") then
						c:Destroy()
					end
				end
				local ForceInstance = Instance.new("BodyPosition")
				ForceInstance.Parent = part
				ForceInstance.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				table.insert(Forces, ForceInstance)
				if not table.find(frozenParts,part) then
					table.insert(frozenParts,part)
				end
			end
		end
		for i,c in pairs(Forces) do
			c.Position = Players[v].Character.Head.Position
		end
	end
end)

keycodeMap = {
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["a"] = 0x41,
	["b"] = 0x42,
	["c"] = 0x43,
	["d"] = 0x44,
	["e"] = 0x45,
	["f"] = 0x46,
	["g"] = 0x47,
	["h"] = 0x48,
	["i"] = 0x49,
	["j"] = 0x4A,
	["k"] = 0x4B,
	["l"] = 0x4C,
	["m"] = 0x4D,
	["n"] = 0x4E,
	["o"] = 0x4F,
	["p"] = 0x50,
	["q"] = 0x51,
	["r"] = 0x52,
	["s"] = 0x53,
	["t"] = 0x54,
	["u"] = 0x55,
	["v"] = 0x56,
	["w"] = 0x57,
	["x"] = 0x58,
	["y"] = 0x59,
	["z"] = 0x5A,
	["enter"] = 0x0D,
	["shift"] = 0x10,
	["ctrl"] = 0x11,
	["alt"] = 0x12,
	["pause"] = 0x13,
	["capslock"] = 0x14,
	["spacebar"] = 0x20,
	["space"] = 0x20,
	["pageup"] = 0x21,
	["pagedown"] = 0x22,
	["end"] = 0x23,
	["home"] = 0x24,
	["left"] = 0x25,
	["up"] = 0x26,
	["right"] = 0x27,
	["down"] = 0x28,
	["insert"] = 0x2D,
	["delete"] = 0x2E,
	["f1"] = 0x70,
	["f2"] = 0x71,
	["f3"] = 0x72,
	["f4"] = 0x73,
	["f5"] = 0x74,
	["f6"] = 0x75,
	["f7"] = 0x76,
	["f8"] = 0x77,
	["f9"] = 0x78,
	["f10"] = 0x79,
	["f11"] = 0x7A,
	["f12"] = 0x7B,
}
autoKeyPressing = false
cancelAutoKeyPress = nil

addcmd('autokeypress',{'keypress'},function(args, speaker)
	if keypress and keyrelease and args[1] then
		local code = keycodeMap[args[1]:lower()]
		if not code then notify('Auto Key Press',"Invalid key") return end
		execCmd('unautokeypress')
		wait()
		local clickDelay = 0.1
		local releaseDelay = 0.1
		if args[2] and isNumber(args[2]) then clickDelay = args[2] end
		if args[3] and isNumber(args[3]) then releaseDelay = args[3] end
		autoKeyPressing = true
		cancelAutoKeyPress = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if not gameProcessedEvent then
				if (input.KeyCode == Enum.KeyCode.Backspace and UserInputService:IsKeyDown(Enum.KeyCode.Equals)) or (input.KeyCode == Enum.KeyCode.Equals and UserInputService:IsKeyDown(Enum.KeyCode.Backspace)) then
					autoKeyPressing = false
					cancelAutoKeyPress:Disconnect()
				end
			end
		end)
		notify("Auto Key Press", "Press [backspace] and [=] at the same time to stop (or type 'unautokeypress')")
		repeat wait(clickDelay)
			keypress(code)
			wait(releaseDelay)
			keyrelease(code)
		until autoKeyPressing == false
		if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() keyrelease(code) end
	else
		notify("Auto Key Press", "Your exploit does not support this command (missing keypress or keyrelease)")
	end
end)

addcmd('unautokeypress',{'noautokeypress','unkeypress','nokeypress'},function(args, speaker)
	autoKeyPressing = false
	if cancelAutoKeyPress then cancelAutoKeyPress:Disconnect() end
end)

addcmd('addplugin',{'plugin'},function(args, speaker)
	addPlugin(getstring(1, args))
end)

addcmd('removeplugin',{'deleteplugin'},function(args, speaker)
	deletePlugin(getstring(1, args))
end)

addcmd('reloadplugin',{},function(args, speaker)
	local pluginName = getstring(1, args)
	deletePlugin(pluginName)
	wait(1)
	addPlugin(pluginName)
end)

addcmd("addallplugins", {"loadallplugins"}, function(args, speaker)
	if not listfiles or not isfolder then
		notify("Incompatible Exploit", "Your exploit does not support this command (missing listfiles/isfolder)")
		return
	end

	for _, filePath in ipairs(listfiles("")) do
		local fileName = filePath:match("([^/\\]+%.iy)$")

		if fileName and
			fileName:lower() ~= "iy_fe.iy" and
			not isfolder(fileName) and
			not table.find(PluginsTable, fileName)
		then
			addPlugin(fileName)
		end
	end
end)

addcmd('removecmd',{'deletecmd'},function(args, speaker)
	removecmd(args[1])
end)

addcmd("debug", {}, function(args, speaker)
    _G.IY_DEBUG = parseBoolean(args[1], true)
    return _G.IY_DEBUG and "Enabled" or "Disabled"
end)

if false and IsOnMobile then
	local QuickCapture = Instance.new("TextButton")
	local UICorner = Instance.new("UICorner")
	QuickCapture.Name = randomString()
	QuickCapture.Parent = PARENT
	QuickCapture.BackgroundColor3 = Color3.fromRGB(46, 46, 47)
	QuickCapture.BackgroundTransparency = 0.14
	QuickCapture.Position = UDim2.new(0.489, 0, 0, 0)
	QuickCapture.Size = UDim2.new(0, 32, 0, 33)
	QuickCapture.Font = Enum.Font.SourceSansBold
	QuickCapture.Text = "IY"
	QuickCapture.TextColor3 = Color3.fromRGB(255, 255, 255)
	QuickCapture.TextSize = 20
	QuickCapture.TextWrapped = true
	QuickCapture.ZIndex = 10
	QuickCapture.Draggable = true
	UICorner.Name = randomString()
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = QuickCapture
	QuickCapture.MouseButton1Click:Connect(function()
		Cmdbar:CaptureFocus()
		maximizeHolder()
	end)
	table.insert(shade1, QuickCapture)
	table.insert(text1, QuickCapture)
end

pcall(function() Scale.Scale = math.max(Holder.AbsoluteSize.X / 1920, guiScale) end)
Scale.Parent = ScaledHolder
ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
Scale:GetPropertyChangedSignal("Scale"):Connect(function()
	ScaledHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1 / Scale.Scale)
	for _, v in ScaledHolder:GetDescendants() do
		if v:IsA("GuiObject") and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end)

updateColors(currentShade1,shade1)
updateColors(currentShade2,shade2)
updateColors(currentShade3,shade3)
updateColors(currentText1,text1)
updateColors(currentText2,text2)
updateColors(currentScroll,scroll)

if PluginsTable ~= nil or PluginsTable ~= {} then
	FindPlugins(PluginsTable)
end

-- Events
eventEditor.RegisterEvent("OnExecute")
eventEditor.RegisterEvent("OnSpawn",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDied",{
	{Type="Player",Name="Player Filter ($1)"}
})
eventEditor.RegisterEvent("OnDamage",{
	{Type="Player",Name="Player Filter ($1)"},
	{Type="Number",Name="Below Health ($2)"}
})
eventEditor.RegisterEvent("OnKilled",{
	{Type="Player",Name="Victim Player ($1)"},
	{Type="Player",Name="Killer Player ($2)",Default = 1}
})
eventEditor.RegisterEvent("OnJoin",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnLeave",{
	{Type="Player",Name="Player Filter ($1)",Default = 1}
})
eventEditor.RegisterEvent("OnChatted",{
	{Type="Player",Name="Player Filter ($1)",Default = 1},
	{Type="String",Name="Message Filter ($2)"}
})

function hookCharEvents(plr, instant)
	task.spawn(function()
		local char = plr.Character
		if not char then return end

		local humanoid = char:WaitForChild("Humanoid", 10)
		if not humanoid or not humanoid:IsA("Humanoid") then return end

		local oldHealth = humanoid.Health
		humanoid.HealthChanged:Connect(function(health)
			local change = math.abs(oldHealth - health)
			if oldHealth > health then
				eventEditor.FireEvent("OnDamage", plr.Name, tonumber(health))
			end
			oldHealth = health
		end)

		humanoid.Died:Connect(function()
			eventEditor.FireEvent("OnDied", plr.Name)

			local killedBy = humanoid:FindFirstChild("creator")
			if killedBy and killedBy:IsA("ObjectValue") and killedBy.Value and killedBy.Value.Parent then
				eventEditor.FireEvent("OnKilled", plr.Name, killedBy.Name)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(plr)
	eventEditor.FireEvent("OnJoin",plr.Name)
	if isLegacyChat then plr.Chatted:Connect(function(msg) eventEditor.FireEvent("OnChatted",tostring(plr),msg) end) end
	plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn",tostring(plr)) hookCharEvents(plr) end)
	JoinLog(plr)
	if isLegacyChat then ChatLog(plr) end
	if ESPenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		ESP(plr)
	end
	if CHMSenabled then
		repeat wait(1) until plr.Character and getRoot(plr.Character)
		CHMS(plr)
	end
end)

if not isLegacyChat then
	TextChatService.MessageReceived:Connect(function(textChatMessage)
		if textChatMessage.TextSource and textChatMessage.Status ~= Enum.TextChatMessageStatus.InvalidTextChannelPermissions then
			local player = Players:GetPlayerByUserId(textChatMessage.TextSource.UserId)
			if not player then return end

            local message = textChatMessage.Text
            pcall(function() if textChatMessage.WasRewritten == true then message = "(rephrased) " .. textChatMessage.RewrittenText end end)

			if logsEnabled == true then
				CreateLabel(player.Name, message)
			end
			if player.UserId == Players.LocalPlayer.UserId then
				do_exec(message, Players.LocalPlayer)
			end
			eventEditor.FireEvent("OnChatted", player.Name, message)
			sendChatWebhook(player, message)
		end
	end)
end

for _, plr in pairs(Players:GetPlayers()) do
	pcall(function()
		plr.CharacterAdded:Connect(function() eventEditor.FireEvent("OnSpawn", tostring(plr)) hookCharEvents(plr) end)
		hookCharEvents(plr)
	end)
end

if spawnCmds and #spawnCmds > 0 then
	for i,v in pairs(spawnCmds) do
		eventEditor.AddCmd("OnSpawn",{v.COMMAND or "",{0},v.DELAY or 0})
	end
	updatesaves()
end

if loadedEventData then eventEditor.LoadData(loadedEventData) end
eventEditor.Refresh()

eventEditor.FireEvent("OnExecute")

if aliases and #aliases > 0 then
	local cmdMap = {}
	for i,v in pairs(cmds) do
		cmdMap[v.NAME:lower()] = v
		for _,alias in pairs(v.ALIAS) do
			cmdMap[alias:lower()] = v
		end
	end
	for i = 1, #aliases do
		local cmd = string.lower(aliases[i].CMD)
		local alias = string.lower(aliases[i].ALIAS)
		if cmdMap[cmd] then
			customAlias[alias] = cmdMap[cmd]
		end
	end
	refreshaliases()
end

IYMouse.Move:Connect(checkTT)

CaptureService.CaptureBegan:Connect(function()
	PARENT.Enabled = false
end)

CaptureService.CaptureEnded:Connect(function()
	task.delay(0.1, function()
		PARENT.Enabled = true
	end)
end)

-- (cek versi & pengumuman server Infinite Yield dihapus di KizzDev)


-- =====================================================================
-- KizzDev: Home panel + animasi loading + intro baru
-- (Infinite Yield dibuat oleh Edge, Zwolf, Moon, Toon, Peyton, ATP)
-- =====================================================================
local KIZZ_CYAN = Color3.fromRGB(170, 90, 255)
local KIZZ_BG = Color3.fromRGB(16, 9, 32)
local KIZZ_BG2 = Color3.fromRGB(32, 18, 60)

-- garis tepi cyan di window utama & notifikasi
pcall(function()
	for _, obj in ipairs({Holder, Notification}) do
		local st = Instance.new("UIStroke")
		st.Color = KIZZ_CYAN
		st.Thickness = 1.5
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Parent = obj
	end
	Title.TextColor3 = KIZZ_CYAN
end)

-- ---------- KIZZDEV HUB v2 (gaya Rayfield, tema ungu anime) ----------
local displayName = Players.LocalPlayer.DisplayName
local KizzHub = {}
pcall(function() Holder.Visible = false end) -- panel klasik di bawah disembunyikan

-- >>> ISI DI SINI kalau mau pakai gambar sendiri (link https langsung ke png/jpg, atau rbxassetid://ID) <<<
local KIZZ_BANNER_URL = "" -- banner/header (contoh: gambar anime ungu lebar)
local KIZZ_AVATAR_URL = "" -- foto profil bulat (kosong = pakai headshot Roblox kamu)

local P = {
	bg = Color3.fromRGB(14, 8, 28),
	side = Color3.fromRGB(22, 12, 44),
	cell = Color3.fromRGB(32, 18, 60),
	accent = Color3.fromRGB(160, 80, 255),
	accent2 = Color3.fromRGB(255, 90, 220),
	text = Color3.new(1, 1, 1),
	sub = Color3.fromRGB(175, 155, 215),
}

local function kizzAsset(src)
	if type(src) ~= "string" or src == "" then return nil end
	if src:match("^%d+$") then return "rbxassetid://" .. src end
	if src:match("^rbxassetid://") or src:match("^rbxthumb://") or src:match("^rbxasset://") then return src end
	if src:match("^https?://") and writefile and isfile and makefolder and isfolder then
		local ok, res = pcall(function()
			if not isfolder("kizzdev") then makefolder("kizzdev") end
			local clean = src:gsub("[^%w]", "")
			local path = "kizzdev/img_" .. clean:sub(-30) .. ".png"
			if not isfile(path) then writefile(path, game:HttpGet(src)) end
			return getcustomasset(path)
		end)
		if ok and res and res ~= "" then return res end
	end
	return nil
end

-- ===== gambar bawaan (tertanam di script, tidak perlu upload/link) =====
KizzHub.IMG = {
	logo = "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",
	bg = "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",
}
function KizzHub.embedded(name)
	local data = KizzHub.IMG[name]
	if not data then return nil end
	if not (writefile and isfile and getcustomasset) then return nil end
	local ok, res = pcall(function()
		if makefolder and isfolder and not isfolder("kizzdev") then makefolder("kizzdev") end
		local path = "kizzdev/kizz_" .. name .. "_v1.jpg"
		if not isfile(path) then
			local A = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
			local map = {}
			for i = 1, 64 do map[A:byte(i)] = i - 1 end
			local s = data:gsub("[^%w%+/=]", "")
			local pad = (s:sub(-2) == "==" and 2) or (s:sub(-1) == "=" and 1) or 0
			local out, n = {}, 0
			for i = 1, #s, 4 do
				local a, b, c, d = s:byte(i, i + 3)
				local v = (map[a] or 0) * 262144 + (map[b] or 0) * 4096 + (map[c] or 0) * 64 + (map[d] or 0)
				n = n + 1
				out[n] = string.char(math.floor(v / 65536) % 256, math.floor(v / 256) % 256, v % 256)
				if n % 6000 == 0 then task.wait() end
			end
			local bin = table.concat(out)
			if pad > 0 then bin = bin:sub(1, #bin - pad) end
			writefile(path, bin)
		end
		return getcustomasset(path)
	end)
	if ok and res and res ~= "" then return res end
	return nil
end

local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
	return c
end

local function gradientStroke(obj, thick, c1, c2)
	local st = Instance.new("UIStroke")
	st.Color = Color3.new(1, 1, 1)
	st.Thickness = thick
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Parent = obj
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1),
		ColorSequenceKeypoint.new(0.5, c2),
		ColorSequenceKeypoint.new(1, c1),
	})
	g.Parent = st
	task.spawn(function()
		local r = 0
		while g.Parent do
			r = (r + 3) % 360
			g.Rotation = r
			task.wait(0.03)
		end
	end)
	return st, g
end

local function accentGradient(obj)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(P.accent, P.accent2)
	g.Parent = obj
	return g
end

local function gradBtn(parent, text, size, pos, textSize, z, radius)
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.Text = ""
	b.Size = size
	b.Position = pos
	b.ZIndex = z
	b.Parent = parent
	corner(b, radius)
	local bg = Instance.new("Frame")
	bg.BackgroundColor3 = Color3.new(1, 1, 1)
	bg.BorderSizePixel = 0
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.ZIndex = z
	bg.Parent = b
	corner(bg, radius)
	accentGradient(bg)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 1, 0)
	l.Font = Enum.Font.GothamBold
	l.TextSize = textSize
	l.Text = text
	l.TextColor3 = Color3.new(1, 1, 1)
	l.ZIndex = z + 1
	l.Parent = b
	return b, bg, l
end

local function makeDraggable(handle, target, onClickOnly)
	local dragging, moved, dragStart, startPos = false, false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			if d.Magnitude > 6 then moved = true end
			if moved then
				local sc = (Scale and Scale.Scale) or 1
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X / sc, startPos.Y.Scale, startPos.Y.Offset + d.Y / sc)
			end
		end
	end)
	return function() return moved end
end

do
	local HUB_W, HUB_H = 510, 345
	local SIDE_W = 124
	local featureCount = 0

	-- ===== window utama =====
	local root = Instance.new("Frame")
	root.Name = randomString()
	root.Parent = ScaledHolder
	root.Active = true
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(HUB_W, HUB_H)
	root.BackgroundColor3 = P.bg
	root.BorderSizePixel = 0
	root.ZIndex = 20
	root.Visible = false
	corner(root, 14)
	local bgGrad = Instance.new("UIGradient")
	bgGrad.Rotation = 90
	bgGrad.Color = ColorSequence.new(Color3.fromRGB(28, 14, 56), Color3.fromRGB(10, 5, 22))
	bgGrad.Parent = root
	gradientStroke(root, 2, P.accent, P.accent2)
	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 0.6
	rootScale.Parent = root

	-- latar gambar (diisi async setelah gambar siap)
	do
		local bgImg = Instance.new("ImageLabel")
		bgImg.Name = "KizzBG"
		bgImg.BackgroundTransparency = 1
		bgImg.Size = UDim2.new(1, 0, 1, 0)
		bgImg.ScaleType = Enum.ScaleType.Crop
		bgImg.ImageTransparency = 0
		bgImg.ZIndex = 20
		bgImg.Visible = false
		bgImg.Parent = root
		corner(bgImg, 14)
		local dim = Instance.new("Frame")
		dim.Name = "KizzBGDim"
		dim.BackgroundColor3 = Color3.fromRGB(8, 3, 18)
		dim.BackgroundTransparency = 0.5
		dim.BorderSizePixel = 0
		dim.Size = UDim2.new(1, 0, 1, 0)
		dim.ZIndex = 20
		dim.Visible = false
		dim.Parent = root
		corner(dim, 14)
	end

	-- glow / banner header
	local glow = Instance.new("Frame")
	glow.BackgroundColor3 = P.accent
	glow.BorderSizePixel = 0
	glow.Size = UDim2.new(1, 0, 0, 86)
	glow.ZIndex = 20
	glow.Parent = root
	corner(glow, 14)
	local glowG = Instance.new("UIGradient")
	glowG.Rotation = 90
	glowG.Transparency = NumberSequence.new(0.55, 1)
	glowG.Color = ColorSequence.new(P.accent, P.accent2)
	glowG.Parent = glow

	local banner = Instance.new("ImageLabel")
	banner.BackgroundTransparency = 1
	banner.Size = UDim2.new(1, 0, 0, 96)
	banner.ScaleType = Enum.ScaleType.Crop
	banner.ImageTransparency = 0.2
	banner.ZIndex = 21
	banner.Visible = false
	banner.Parent = root
	corner(banner, 14)
	local bannerFade = Instance.new("UIGradient")
	bannerFade.Rotation = 90
	bannerFade.Transparency = NumberSequence.new(0, 1)
	bannerFade.Parent = banner

	-- ===== top bar =====
	local top = Instance.new("Frame")
	top.BackgroundTransparency = 1
	top.Size = UDim2.new(1, -76, 0, 40)
	top.ZIndex = 23
	top.Parent = root

	local titleL = Instance.new("TextLabel")
	titleL.BackgroundTransparency = 1
	titleL.Position = UDim2.new(0, 14, 0, 4)
	titleL.Size = UDim2.new(0, 110, 0, 30)
	titleL.Font = Enum.Font.GothamBlack
	titleL.TextSize = 22
	titleL.Text = "KizzDev"
	titleL.TextColor3 = Color3.new(1, 1, 1)
	titleL.TextXAlignment = Enum.TextXAlignment.Left
	titleL.ZIndex = 24
	titleL.Parent = top
	accentGradient(titleL)

	local subL = Instance.new("TextLabel")
	subL.BackgroundTransparency = 1
	subL.Position = UDim2.new(0, 124, 0, 11)
	subL.Size = UDim2.new(1, -130, 0, 16)
	subL.Font = Enum.Font.GothamMedium
	subL.TextSize = 11
	subL.Text = "Hub"
	subL.TextColor3 = P.sub
	subL.TextXAlignment = Enum.TextXAlignment.Left
	subL.ZIndex = 24
	subL.Parent = top

	local function circleBtn(xOff, text)
		local b = Instance.new("TextButton")
		b.BackgroundColor3 = P.cell
		b.Position = UDim2.new(1, xOff, 0, 9)
		b.Size = UDim2.new(0, 24, 0, 24)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.Text = text
		b.TextColor3 = Color3.new(1, 1, 1)
		b.BorderSizePixel = 0
		b.ZIndex = 25
		b.Parent = root
		corner(b, 12)
		return b
	end
	local closeB = circleBtn(-34, "X")
	local minB = circleBtn(-64, "-")

	-- ===== sidebar =====
	local side = Instance.new("Frame")
	side.BackgroundColor3 = P.side
	side.BackgroundTransparency = 0.35
	side.BorderSizePixel = 0
	side.Position = UDim2.new(0, 8, 0, 46)
	side.Size = UDim2.new(0, SIDE_W, 1, -92)
	side.ZIndex = 22
	side.Parent = root
	corner(side, 12)

	-- profil bulat dengan cincin berputar
	local avatar = Instance.new("ImageLabel")
	avatar.BackgroundColor3 = P.cell
	avatar.Position = UDim2.new(0, 8, 0, 8)
	avatar.Size = UDim2.new(0, 38, 0, 38)
	avatar.ScaleType = Enum.ScaleType.Crop
	avatar.ZIndex = 23
	avatar.Parent = side
	corner(avatar, 19)
	gradientStroke(avatar, 2, P.accent, P.accent2)

	local nameL = Instance.new("TextLabel")
	nameL.BackgroundTransparency = 1
	nameL.Position = UDim2.new(0, 52, 0, 9)
	nameL.Size = UDim2.new(1, -56, 0, 18)
	nameL.Font = Enum.Font.GothamBold
	nameL.TextSize = 12
	nameL.Text = displayName
	nameL.TextColor3 = P.text
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextTruncate = Enum.TextTruncate.AtEnd
	nameL.ZIndex = 23
	nameL.Parent = side
	local userL = nameL:Clone()
	userL.Position = UDim2.new(0, 52, 0, 26)
	userL.Size = UDim2.new(1, -56, 0, 16)
	userL.Font = Enum.Font.Gotham
	userL.TextSize = 10
	userL.Text = "@" .. Players.LocalPlayer.Name
	userL.TextColor3 = P.sub
	userL.Parent = side

	local tabList = Instance.new("ScrollingFrame")
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.Position = UDim2.new(0, 4, 0, 54)
	tabList.Size = UDim2.new(1, -8, 1, -58)
	tabList.ScrollBarThickness = 0
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ZIndex = 23
	tabList.Parent = side
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 3)
	tabLayout.Parent = tabList

	-- ===== area halaman =====
	local pageArea = Instance.new("Frame")
	pageArea.BackgroundTransparency = 1
	pageArea.Position = UDim2.new(0, SIDE_W + 16, 0, 46)
	pageArea.Size = UDim2.new(1, -(SIDE_W + 24), 1, -92)
	pageArea.ZIndex = 22
	pageArea.Parent = root

	-- ===== command bar bawah =====
	local cmdWrap = Instance.new("Frame")
	cmdWrap.BackgroundColor3 = P.side
	cmdWrap.BackgroundTransparency = 0.25
	cmdWrap.BorderSizePixel = 0
	cmdWrap.Position = UDim2.new(0, 8, 1, -40)
	cmdWrap.Size = UDim2.new(1, -16, 0, 32)
	cmdWrap.ZIndex = 22
	cmdWrap.Parent = root
	corner(cmdWrap, 10)
	local cmdStroke = Instance.new("UIStroke")
	cmdStroke.Color = P.accent
	cmdStroke.Transparency = 0.6
	cmdStroke.Parent = cmdWrap

	local cmdBox = Instance.new("TextBox")
	cmdBox.BackgroundTransparency = 1
	cmdBox.Position = UDim2.new(0, 12, 0, 0)
	cmdBox.Size = UDim2.new(1, -86, 1, 0)
	cmdBox.Font = Enum.Font.Gotham
	cmdBox.TextSize = 13
	cmdBox.Text = ""
	cmdBox.PlaceholderText = "Ketik command apa saja (contoh: fly 50) lalu Enter / Run"
	cmdBox.PlaceholderColor3 = P.sub
	cmdBox.TextColor3 = P.text
	cmdBox.ClearTextOnFocus = false
	cmdBox.TextXAlignment = Enum.TextXAlignment.Left
	cmdBox.ZIndex = 23
	cmdBox.Parent = cmdWrap

	local runB = gradBtn(cmdWrap, "Run", UDim2.new(0, 66, 1, -6), UDim2.new(1, -70, 0, 3), 13, 24, 8)

	local function runTyped()
		local t = cmdBox.Text
		if t ~= "" then
			t = t:gsub("^" .. (tostring(prefix or ";"):gsub("%p", "%%%0")), "")
			execCmd(t)
		end
	end
	runB.MouseButton1Click:Connect(runTyped)
	cmdBox.FocusLost:Connect(function(enter) if enter then runTyped() end end)

	-- ===== sistem tab / halaman =====
	local pages, tabBtns = {}, {}
	local function selectTab(name)
		for n, p in pairs(pages) do p.Visible = (n == name) end
		for n, t in pairs(tabBtns) do
			local on = (n == name)
			TweenService:Create(t[1], TweenInfo.new(0.2), {BackgroundTransparency = on and 0 or 1}):Play()
			TweenService:Create(t[2], TweenInfo.new(0.2), {TextColor3 = on and Color3.new(1, 1, 1) or P.sub}):Play()
		end
	end

	local function addTab(name, icon, grid)
		local b, bgf, lbl = gradBtn(tabList, "  " .. icon .. "  " .. name, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 0), 12, 24, 8)
		bgf.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextColor3 = P.sub
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		tabBtns[name] = {bgf, lbl}
		b.MouseButton1Click:Connect(function() selectTab(name) end)

		local page
		if grid == false then
			page = Instance.new("Frame")
			page.BackgroundTransparency = 1
		else
			page = Instance.new("ScrollingFrame")
			page.BackgroundTransparency = 1
			page.BorderSizePixel = 0
			page.ScrollBarThickness = 3
			page.ScrollBarImageColor3 = P.accent
			page.CanvasSize = UDim2.new(0, 0, 0, 0)
			page.AutomaticCanvasSize = Enum.AutomaticSize.Y
			local g = Instance.new("UIGridLayout")
			g.CellSize = UDim2.new(0, 172, 0, 34)
			g.CellPadding = UDim2.new(0, 6, 0, 6)
			g.SortOrder = Enum.SortOrder.LayoutOrder
			g.Parent = page
		end
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.ZIndex = 22
		page.Parent = pageArea
		pages[name] = page
		return page
	end

	-- ===== pembuat item =====
	local function makeCell(page)
		local f = Instance.new("Frame")
		f.BackgroundColor3 = P.cell
		f.BackgroundTransparency = 0.4
		f.BorderSizePixel = 0
		f.ZIndex = 23
		f.Parent = page
		corner(f, 9)
		local st = Instance.new("UIStroke")
		st.Color = P.accent
		st.Transparency = 0.8
		st.Parent = f
		return f, st
	end

	local function cellLabel(parent, text, widthOff)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.new(0, 10, 0, 0)
		l.Size = UDim2.new(1, widthOff or -20, 1, 0)
		l.Font = Enum.Font.GothamMedium
		l.TextSize = 12
		l.Text = text
		l.TextColor3 = P.text
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextTruncate = Enum.TextTruncate.AtEnd
		l.ZIndex = 25
		l.Parent = parent
		return l
	end

	local function overlayButton(parent)
		local b = Instance.new("TextButton")
		b.BackgroundTransparency = 1
		b.Size = UDim2.new(1, 0, 1, 0)
		b.Text = ""
		b.ZIndex = 27
		b.Parent = parent
		return b
	end

	local function addItem(page, it)
		featureCount = featureCount + 1
		local kind = it[1]
		if kind == "t" then
			local label, onC, offC = it[2], it[3], it[4] or it[3]
			local state = false
			local f, st = makeCell(page)
			cellLabel(f, label, -58)
			local track = Instance.new("Frame")
			track.AnchorPoint = Vector2.new(1, 0.5)
			track.Position = UDim2.new(1, -10, 0.5, 0)
			track.Size = UDim2.new(0, 34, 0, 18)
			track.BackgroundColor3 = Color3.fromRGB(58, 40, 92)
			track.BorderSizePixel = 0
			track.ZIndex = 25
			track.Parent = f
			corner(track, 9)
			local tg = accentGradient(track)
			tg.Enabled = false
			local knob = Instance.new("Frame")
			knob.AnchorPoint = Vector2.new(0, 0.5)
			knob.Position = UDim2.new(0, 2, 0.5, 0)
			knob.Size = UDim2.new(0, 14, 0, 14)
			knob.BackgroundColor3 = Color3.new(1, 1, 1)
			knob.BorderSizePixel = 0
			knob.ZIndex = 26
			knob.Parent = track
			corner(knob, 7)
			local btn = overlayButton(f)
			btn.MouseButton1Click:Connect(function()
				state = not state
				execCmd(state and onC or offC)
				tg.Enabled = state
				track.BackgroundColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(58, 40, 92)
				TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
					Position = state and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
				}):Play()
				TweenService:Create(st, TweenInfo.new(0.18), {Transparency = state and 0.3 or 0.8}):Play()
			end)
		elseif kind == "b" or kind == "f" then
			local f, st = makeCell(page)
			cellLabel(f, it[2], -34)
			local arrow = Instance.new("TextLabel")
			arrow.BackgroundTransparency = 1
			arrow.Position = UDim2.new(1, -26, 0, 0)
			arrow.Size = UDim2.new(0, 20, 1, 0)
			arrow.Font = Enum.Font.GothamBold
			arrow.TextSize = 14
			arrow.Text = ">"
			arrow.TextColor3 = P.accent
			arrow.ZIndex = 25
			arrow.Parent = f
			local btn = overlayButton(f)
			btn.MouseEnter:Connect(function()
				TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 0.2}):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(st, TweenInfo.new(0.15), {Transparency = 0.8}):Play()
			end)
			btn.MouseButton1Click:Connect(function()
				task.spawn(function()
					TweenService:Create(f, TweenInfo.new(0.1), {BackgroundColor3 = P.accent}):Play()
					task.wait(0.12)
					TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3 = P.cell}):Play()
				end)
				if kind == "f" then
					local ok, e = pcall(it[3])
					if not ok then notify("KizzDev", tostring(e), 4) end
				else
					execCmd(it[3])
				end
			end)
		elseif kind == "i" then
			local placeholder, cmd, default, btnText = it[2], it[3], it[4] or "", it[5] or "Set"
			local f = makeCell(page)
			local tb = Instance.new("TextBox")
			tb.BackgroundTransparency = 1
			tb.Position = UDim2.new(0, 10, 0, 0)
			tb.Size = UDim2.new(1, -72, 1, 0)
			tb.Font = Enum.Font.Gotham
			tb.TextSize = 12
			tb.Text = default
			tb.PlaceholderText = placeholder
			tb.PlaceholderColor3 = P.sub
			tb.TextColor3 = P.text
			tb.ClearTextOnFocus = false
			tb.TextXAlignment = Enum.TextXAlignment.Left
			tb.ZIndex = 25
			tb.Parent = f
			local gb = gradBtn(f, btnText, UDim2.new(0, 58, 1, -8), UDim2.new(1, -62, 0, 4), 11, 26, 7)
			local function go()
				local v = tb.Text
				if v == "" then
					notify("KizzDev", "Isi dulu kolom: " .. placeholder, 3)
					return
				end
				execCmd(cmd .. " " .. v)
			end
			gb.MouseButton1Click:Connect(go)
			tb.FocusLost:Connect(function(enter) if enter then go() end end)
		end
	end

	local function addItems(page, list)
		for _, it in ipairs(list) do addItem(page, it) end
	end

	-- ===== HOME =====
	local pHome = addTab("Home", "🏠")
	local gameName = "..."
	task.spawn(function()
		local ok, info = pcall(function() return MarketplaceService:GetProductInfo(PlaceId) end)
		gameName = (ok and info and info.Name) or ("PlaceId " .. tostring(PlaceId))
	end)
	local frames, fps = 0, 0
	RunService.Heartbeat:Connect(function() frames = frames + 1 end)
	local execName = "Unknown"
	pcall(function() execName = tostring((identifyexecutor and identifyexecutor()) or "Unknown") end)
	local infos = {
		function() return "Welcome, " .. displayName end,
		function() return gameName end,
		function() return "FPS  " .. fps end,
		function()
			local ping = "--"
			pcall(function() ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms" end)
			return "Ping  " .. ping
		end,
		function() return "Players  " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers end,
		function() return "Executor  " .. execName end,
	}
	local infoLabels = {}
	for i, fn in ipairs(infos) do
		local f = makeCell(pHome)
		f.LayoutOrder = i
		local l = cellLabel(f, "")
		if i == 1 then
			l.Font = Enum.Font.GothamBold
			l.TextColor3 = P.accent2
		end
		infoLabels[i] = l
	end
	local function refreshInfo()
		for i, fn in ipairs(infos) do
			local ok, t = pcall(fn)
			if ok then infoLabels[i].Text = t end
		end
	end
	task.spawn(function()
		while root.Parent do
			task.wait(1)
			fps = frames
			frames = 0
			if root.Visible then refreshInfo() end
		end
	end)
	addItems(pHome, {
		{"b", "Rejoin Server", "rejoin"},
		{"b", "Server Hop", "serverhop"},
		{"b", "Reset Character", "reset"},
		{"b", "Respawn", "respawn"},
		{"b", "Refresh (Stay Pos)", "refresh"},
		{"b", "Server Info", "serverinfo"},
		{"b", "Copy JobId", "jobid"},
		{"b", "Copy PlaceId", "copyplaceid"},
		{"b", "Copy GameId", "copygameid"},
		{"b", "Save Game (saveinstance)", "savegame"},
		{"b", "Break All Loops", "breakloops"},
		{"b", "Notify Ping", "notifyping"},
	})

	-- ===== PLAYER =====
	local pPlayer = addTab("Player", "👤")
	addItems(pPlayer, {
		{"b", "God Mode", "god"},
		{"t", "Invisible", "invisible", "visible"},
		{"t", "Freeze Character", "freeze", "thaw"},
		{"t", "Spin", "spin", "unspin"},
		{"t", "Dance", "dance", "undance"},
		{"t", "Spasm", "spasm", "unspasm"},
		{"t", "Hat Spin", "hatspin", "unhatspin"},
		{"t", "Anchor", "anchor", "unanchor"},
		{"t", "No Sit", "nosit", "unnosit"},
		{"t", "Loop No BillboardGui", "loopnobgui", "unloopnobgui"},
		{"b", "Sit", "sit"},
		{"b", "Lay Down", "lay"},
		{"b", "Naked", "naked"},
		{"b", "No Face", "noface"},
		{"b", "No Arms", "noarms"},
		{"b", "No Legs", "nolegs"},
		{"b", "No Limbs", "nolimbs"},
		{"b", "Clear Hats", "clearhats"},
		{"b", "Drop Tools", "droptools"},
		{"b", "Drop Hats", "drophats"},
		{"b", "Get Tools (Copy)", "tools"},
		{"b", "Remove Tools", "notools"},
		{"b", "Equip All Tools", "equiptools"},
		{"b", "Unequip All Tools", "unequiptools"},
		{"b", "Duplicate Tools", "dupetools"},
		{"b", "Stop Animations", "stopanimations"},
		{"b", "Refresh Animations", "refreshanimations"},
		{"b", "Strengthen", "strengthen"},
		{"b", "Weaken", "weaken"},
		{"b", "Break Velocity", "breakvelocity"},
		{"i", "Hip Height", "hipheight", "0", "Set"},
		{"i", "Anim Speed", "animspeed", "1", "Set"},
		{"i", "Emote name", "emote", "", "Play"},
		{"i", "Team name", "team", "", "Join"},
	})

	-- ===== MOVEMENT =====
	local pMove = addTab("Movement", "🦋")
	addItems(pMove, {
		{"t", "Fly", "fly", "unfly"},
		{"t", "Vehicle Fly", "togglevfly", "togglevfly"},
		{"t", "CFrame Fly", "cframefly", "uncframefly"},
		{"t", "QE Fly", "qefly", "unfly"},
		{"t", "Noclip", "noclip", "unnoclip"},
		{"t", "Vehicle Noclip", "vehiclenoclip", "vehicleclip"},
		{"t", "Float", "float", "unfloat"},
		{"t", "Swim in Air", "swim", "unswim"},
		{"t", "Infinite Jump", "infjump", "uninfjump"},
		{"t", "Fly Jump", "flyjump", "unflyjump"},
		{"t", "Auto Jump", "autojump", "unautojump"},
		{"t", "Edge Jump", "edgejump", "unedgejump"},
		{"t", "Teleport Walk", "teleportwalk", "unteleportwalk"},
		{"t", "Wall TP", "walltp", "unwalltp"},
		{"t", "Anti Void", "antivoid", "unantivoid"},
		{"b", "Click TP Tool", "clickteleport"},
		{"b", "TP Tool", "tptool"},
		{"b", "Jump", "jump"},
		{"i", "Walk Speed", "speed", "50", "Set"},
		{"i", "Loop Speed", "loopspeed", "50", "Loop"},
		{"b", "Stop Loop Speed", "unloopspeed"},
		{"i", "Jump Power", "jpower", "100", "Set"},
		{"i", "Loop Jump Power", "loopjumppower", "100", "Loop"},
		{"b", "Stop Loop Jump", "unloopjumppower"},
		{"i", "Gravity", "gravity", "196.2", "Set"},
		{"i", "Fly Speed", "flyspeed", "3", "Set"},
		{"i", "Max Slope Angle", "maxslopeangle", "89", "Set"},
		{"i", "TP to XYZ (x y z)", "tpposition", "", "Go"},
		{"i", "Tween to Player", "tweengoto", "", "Go"},
	})

	-- ===== VISUAL =====
	local pVis = addTab("Visual", "👁")
	addItems(pVis, {
		{"t", "ESP", "esp", "noesp"},
		{"t", "Chams", "chams", "nochams"},
		{"t", "X-Ray", "xray", "unxray"},
		{"t", "Loop X-Ray", "loopxray", "unloopxray"},
		{"t", "Fullbright", "loopfullbright", "unloopfullbright"},
		{"t", "Global Shadows", "globalshadows", "unglobalshadows"},
		{"t", "Free Cam", "freecam", "unfreecam"},
		{"t", "2022 Materials", "2022materials", "un2022materials"},
		{"t", "No Render", "norender", "render"},
		{"b", "Noclip Camera", "noclipcam"},
		{"b", "No Fog", "nofog"},
		{"b", "Day", "day"},
		{"b", "Night", "night"},
		{"b", "Restore Lighting", "restorelighting"},
		{"b", "First Person", "firstp"},
		{"b", "Third Person", "thirdp"},
		{"b", "Enable Shift Lock", "enableshiftlock"},
		{"b", "Fix Camera", "fixcam"},
		{"b", "Anti Lag", "antilag"},
		{"b", "Show Hidden GUIs", "showguis"},
		{"b", "Hide GUIs", "hideguis"},
		{"i", "FOV", "fov", "90", "Set"},
		{"i", "Brightness", "brightness", "2", "Set"},
		{"i", "Max Zoom", "maxzoom", "1000", "Set"},
		{"i", "Min Zoom", "minzoom", "0.5", "Set"},
		{"i", "Cam Distance", "camdistance", "30", "Set"},
		{"i", "Ambient (r g b)", "ambient", "1 1 1", "Set"},
		{"i", "Free Cam Speed", "freecamspeed", "2", "Set"},
		{"i", "Locate Player", "locate", "", "Mark"},
		{"b", "Unlocate", "nolocate"},
	})

	-- ===== PLAYERS =====
	local pTarget = addTab("Players", "🎯")
	addItems(pTarget, {
		{"i", "Player", "goto", "", "Goto"},
		{"i", "Player", "loopgoto", "", "Loop"},
		{"b", "Stop Loop Goto", "unloopgoto"},
		{"i", "Player", "view", "", "View"},
		{"b", "Unview", "unview"},
		{"i", "Player", "orbit", "", "Orbit"},
		{"b", "Unorbit", "unorbit"},
		{"i", "Player", "stareat", "", "Stare"},
		{"b", "Unstare", "unstareat"},
		{"i", "Player", "headsit", "", "Sit"},
		{"i", "Player", "clientbring", "", "Bring"},
		{"i", "Player", "loopbring", "", "Loop"},
		{"b", "Stop Loop Bring", "unloopbring"},
		{"i", "Player", "friend", "", "Add"},
		{"i", "Player", "unfriend", "", "Remove"},
		{"i", "Player", "listento", "", "Listen"},
		{"b", "Stop Listen", "unlistento"},
		{"i", "Player", "copyname", "", "Copy"},
		{"i", "Player", "userid", "", "Copy"},
		{"i", "Player", "joindate", "", "Show"},
		{"i", "Player", "age", "", "Show"},
		{"i", "Player", "copyappearanceid", "", "Copy"},
		{"i", "Player", "appearanceid", "", "Show"},
		{"i", "Player", "mutevc", "", "Mute VC"},
		{"i", "Player", "unmutevc", "", "Unmute"},
		{"b", "Mute All Voices", "muteallvoices"},
		{"b", "Unmute All Voices", "unmuteallvoices"},
		{"i", "Player (rolewatch)", "rolewatch", "", "Watch"},
		{"b", "Stop Rolewatch", "rolewatchstop"},
		{"b", "Staff Watch", "staffwatch"},
		{"b", "Stop Staff Watch", "unstaffwatch"},
	})

	-- ===== TROLL =====
	local pTroll = addTab("Troll", "😈")
	addItems(pTroll, {
		{"t", "Fling", "fling", "unfling"},
		{"t", "Walk Fling", "walkfling", "unwalkfling"},
		{"t", "Fly Fling", "flyfling", "unflyfling"},
		{"t", "Anti Fling", "antifling", "unantifling"},
		{"t", "Stun", "stun", "unstun"},
		{"t", "No Rotate", "norotate", "unnorotate"},
		{"t", "Loop Oof", "loopoof", "unloopoof"},
		{"t", "Show Hitboxes", "hitboxes", "unhitboxes"},
		{"t", "Auto Click", "autoclick", "unautoclick"},
		{"t", "Bubble Chat", "bubblechat", "unbubblechat"},
		{"t", "Chat Window", "chatwindow", "unchatwindow"},
		{"b", "Trip", "trip"},
		{"b", "Block Head", "blockhead"},
		{"b", "Block Hats", "blockhats"},
		{"b", "Block Tool", "blocktool"},
		{"b", "Creeper", "creeper"},
		{"b", "Carpet", "carpet"},
		{"b", "Uncarpet", "uncarpet"},
		{"b", "Dark Chat", "darkchat"},
		{"b", "Mute Boombox", "muteboombox"},
		{"b", "Unmute Boombox", "unmuteboombox"},
		{"b", "Stop Spam", "nospam"},
		{"b", "Stop PM Spam", "nopmspam"},
		{"i", "Reach size", "reach", "20", "Set"},
		{"b", "Unreach", "unreach"},
		{"i", "Box Reach", "boxreach", "20", "Set"},
		{"i", "Chat message", "chat", "", "Send"},
		{"i", "Spam message", "spam", "", "Spam"},
		{"i", "Spam speed", "spamspeed", "1", "Set"},
		{"i", "Whisper: player msg", "whisper", "", "Send"},
	})

	-- ===== WORLD =====
	local pWorld = addTab("World", "🌍")
	addItems(pWorld, {
		{"t", "Unlock Workspace", "unlockws", "lockws"},
		{"t", "Invisible Parts", "invisibleparts", "uninvisibleparts"},
		{"t", "Instant Prompts", "instantproximityprompts", "uninstantproximityprompts"},
		{"t", "Light", "light", "unlight"},
		{"t", "Freeze Unanchored", "freezeunanchored", "thawunanchored"},
		{"t", "No Prompts (hide)", "noprompts", "showprompts"},
		{"t", "Hover Name", "hovername", "unhovername"},
		{"t", "Spawn Point Lock", "spawnpoint", "nospawnpoint"},
		{"b", "Click Delete", "clickdelete"},
		{"b", "BTools", "btools"},
		{"b", "F3X", "f3x"},
		{"b", "Fire Click Detectors", "fireclickdetectors"},
		{"b", "Fire Prompts", "fireproximityprompts"},
		{"b", "No Prompt Limits", "noproximitypromptlimits"},
		{"b", "No Click Limits", "noclickdetectorlimits"},
		{"b", "Remove Terrain", "removeterrain"},
		{"b", "Remove Ads", "removeads"},
		{"b", "Clear Nil Instances", "clearnilinstances"},
		{"b", "Show Waypoints", "showwaypoints"},
		{"b", "Hide Waypoints", "hidewaypoints"},
		{"b", "Clear Waypoints", "clearwaypoints"},
		{"i", "Waypoint name", "setwaypoint", "", "Save"},
		{"i", "Waypoint name", "waypoint", "", "Goto"},
		{"i", "Waypoint name", "tweenwaypoint", "", "Tween"},
		{"i", "Waypoint name", "walktowaypoint", "", "Walk"},
		{"i", "Waypoint name", "deletewaypoint", "", "Delete"},
		{"i", "Delete Class", "deleteclass", "", "Delete"},
		{"i", "Part name", "gotopart", "", "Goto"},
		{"i", "Bring Part", "bringpart", "", "Bring"},
		{"i", "Destroy Height", "destroyheight", "-500", "Set"},
		{"i", "Tween Speed", "tweenspeed", "50", "Set"},
		{"i", "Player", "tpunanchored", "", "TP Parts"},
	})

	-- ===== TOOLS =====
	local pTools = addTab("Tools", "🧰")
	addItems(pTools, {
		{"b", "Dex Explorer", "explorer"},
		{"b", "Moon Dex", "moondex"},
		{"b", "Remote Spy", "remotespy"},
		{"b", "Simple Spy", "simplespy"},
		{"b", "Console", "console"},
		{"b", "Old Console", "oldconsole"},
		{"b", "Audio Logger", "audiologger"},
		{"b", "Logs", "logs"},
		{"b", "Chat Logs", "chatlogs"},
		{"b", "Join Logs", "joinlogs"},
		{"b", "Anti AFK", "antiafk"},
		{"b", "Anti Kick (client)", "clientantikick"},
		{"b", "Anti Teleport (client)", "clientantiteleport"},
		{"b", "Auto Rejoin", "autorejoin"},
		{"b", "Cancel Teleport", "cancelteleport"},
		{"t", "Anti Gameplay Paused", "antigameplaypaused", "unantigameplaypaused"},
		{"t", "Allow Rejoin", "allowrejoin true", "allowrejoin false"},
		{"t", "Mouse Sensitivity 0.5", "mousesensitivity 0.5", "mousesensitivity 1"},
		{"b", "Screenshot", "screenshot"},
		{"b", "Toggle Fullscreen", "togglefs"},
		{"b", "Last Command", "lastcommand"},
		{"i", "FPS Cap", "setfpscap", "60", "Set"},
		{"i", "Volume (0-10)", "volume", "5", "Set"},
		{"i", "Alias: cmd alias", "addalias", "", "Add"},
		{"i", "Notify text", "notify", "", "Show"},
		{"i", "CoreGui (chat/all)", "enable", "", "Enable"},
		{"i", "CoreGui (chat/all)", "disable", "", "Disable"},
		{"b", "Plugins: Add All", "addallplugins"},
		{"b", "Debug Mode", "debug"},
	})

	-- ===== SCRIPT (Lua executor) =====
	local pScript = addTab("Script", "📜", false)
	local codeWrap = Instance.new("Frame")
	codeWrap.BackgroundColor3 = P.cell
	codeWrap.BackgroundTransparency = 0.4
	codeWrap.BorderSizePixel = 0
	codeWrap.Size = UDim2.new(1, 0, 1, -38)
	codeWrap.ZIndex = 23
	codeWrap.Parent = pScript
	corner(codeWrap, 10)
	local codeBox = Instance.new("TextBox")
	codeBox.BackgroundTransparency = 1
	codeBox.Position = UDim2.new(0, 10, 0, 8)
	codeBox.Size = UDim2.new(1, -20, 1, -16)
	codeBox.Font = Enum.Font.Code
	codeBox.TextSize = 13
	codeBox.Text = ""
	codeBox.PlaceholderText = "-- Tulis atau tempel script Lua di sini, lalu tekan Execute\nprint('Hello KizzDev')"
	codeBox.PlaceholderColor3 = P.sub
	codeBox.TextColor3 = P.text
	codeBox.ClearTextOnFocus = false
	codeBox.MultiLine = true
	codeBox.TextWrapped = true
	codeBox.TextXAlignment = Enum.TextXAlignment.Left
	codeBox.TextYAlignment = Enum.TextYAlignment.Top
	codeBox.ZIndex = 25
	codeBox.Parent = codeWrap

	local function scriptBtn(x, w, text, cb, accent)
		local b
		if accent then
			b = gradBtn(pScript, text, UDim2.new(0, w, 0, 30), UDim2.new(0, x, 1, -32), 12, 24, 8)
		else
			b = Instance.new("TextButton")
			b.BackgroundColor3 = P.cell
			b.Position = UDim2.new(0, x, 1, -32)
			b.Size = UDim2.new(0, w, 0, 30)
			b.Font = Enum.Font.GothamBold
			b.TextSize = 12
			b.Text = text
			b.TextColor3 = Color3.new(1, 1, 1)
			b.BorderSizePixel = 0
			b.ZIndex = 24
			b.Parent = pScript
			corner(b, 8)
		end
		b.MouseButton1Click:Connect(cb)
	end
	scriptBtn(0, 96, "Execute", function()
		local code = codeBox.Text
		if code == "" then return end
		if type(loadstring) ~= "function" then
			notify("Script", "Executor kamu tidak mendukung loadstring", 4)
			return
		end
		local f, err = loadstring(code)
		if not f then
			notify("Syntax Error", tostring(err), 8)
			return
		end
		task.spawn(function()
			local ok, e = pcall(f)
			if not ok then notify("Runtime Error", tostring(e), 8) end
		end)
	end, true)
	scriptBtn(102, 70, "Clear", function() codeBox.Text = "" end)
	scriptBtn(178, 70, "Copy", function()
		if codeBox.Text ~= "" then toClipboard(codeBox.Text) end
	end)
	featureCount = featureCount + 1

	-- ===== SETTINGS =====
	local pSet = addTab("Settings", "⚙")
	addItems(pSet, {
		{"f", "Panel Klasik (command list)", function()
			Holder.Visible = not Holder.Visible
			if Holder.Visible then maximizeHolder() end
		end},
		{"f", "Reset Posisi Hub", function()
			root.Position = UDim2.fromScale(0.5, 0.5)
		end},
		{"f", "Unload KizzDev", function() execCmd("exit") end},
	})

	-- ===== tombol melayang (buka/tutup hub) =====
	local floatBtn, floatBg, floatLbl = gradBtn(ScaledHolder, "K", UDim2.new(0, 60, 0, 60), UDim2.new(0, 14, 0.5, -30), 24, 40, 16)
	floatBtn.Name = randomString()
	floatLbl.Font = Enum.Font.GothamBlack
	local floatStroke = gradientStroke(floatBtn, 2.5, P.accent, P.accent2)
	task.spawn(function()
		while floatBtn.Parent do
			TweenService:Create(floatStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {Thickness = 4.5}):Play()
			task.wait(0.9)
			TweenService:Create(floatStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {Thickness = 2}):Play()
			task.wait(0.9)
		end
	end)
	local floatMoved = makeDraggable(floatBtn, floatBtn)

	local opening = false
	local function openHub()
		if opening then return end
		opening = true
		root.Visible = true
		rootScale.Scale = 0.6
		TweenService:Create(rootScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
		refreshInfo()
		task.wait(0.35)
		opening = false
	end
	local function closeHub()
		if opening then return end
		opening = true
		TweenService:Create(rootScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.6}):Play()
		task.wait(0.2)
		root.Visible = false
		opening = false
	end

	floatBtn.MouseButton1Click:Connect(function()
		if floatMoved() then return end
		if root.Visible then closeHub() else openHub() end
	end)
	closeB.MouseButton1Click:Connect(closeHub)
	minB.MouseButton1Click:Connect(closeHub)
	makeDraggable(top, root)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
			if root.Visible then closeHub() else openHub() end
		end
	end)

	-- ===== gambar (banner & avatar) dimuat async =====
	task.spawn(function()
		local bsrc = (type(getgenv) == "function" and getgenv().KIZZDEV_BANNER) or KIZZ_BANNER_URL
		local asrc = (type(getgenv) == "function" and getgenv().KIZZDEV_AVATAR) or KIZZ_AVATAR_URL
		local bimg = kizzAsset(bsrc)
		if bimg then
			banner.Image = bimg
			banner.Visible = true
		end
		-- logo tombol melayang + latar hub (bisa dioverride lewat getgenv().KIZZDEV_LOGO / KIZZDEV_BG)
		local lsrc = type(getgenv) == "function" and getgenv().KIZZDEV_LOGO
		local limg = kizzAsset(lsrc) or KizzHub.embedded("logo")
		if limg then
			local li = Instance.new("ImageLabel")
			li.Name = "KizzLogo"
			li.BackgroundTransparency = 1
			li.Size = UDim2.new(1, 0, 1, 0)
			li.Image = limg
			li.ScaleType = Enum.ScaleType.Crop
			li.ZIndex = 42
			li.Parent = floatBtn
			corner(li, 16)
			floatLbl.Visible = false
			floatBg.Visible = false
		end
		local gsrc = type(getgenv) == "function" and getgenv().KIZZDEV_BG
		local gimg = kizzAsset(gsrc) or KizzHub.embedded("bg")
		if gimg then
			local bgi = root:FindFirstChild("KizzBG")
			local dim = root:FindFirstChild("KizzBGDim")
			if bgi then bgi.Image = gimg bgi.Visible = true end
			if dim then dim.Visible = true end
		end
		local aimg = kizzAsset(asrc)
		if not aimg then
			pcall(function()
				aimg = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
		end
		if aimg then avatar.Image = aimg end
	end)

	-- ===== API =====
	subL.Text = "Hub  |  " .. featureCount .. "+ features  |  RightShift"
	selectTab("Home")
	refreshInfo()

	function KizzHub.Open() task.spawn(openHub) end
	function KizzHub.Close() task.spawn(closeHub) end
	function KizzHub.Toggle() if root.Visible then task.spawn(closeHub) else task.spawn(openHub) end end
	function KizzHub.Focus()
		task.spawn(openHub)
		task.wait(0.05)
		cmdBox:CaptureFocus()
	end
	KizzFocusCmd = KizzHub.Focus
end

-- tombol H di panel klasik membuka Hub
local HomeButton = Instance.new("TextButton")
HomeButton.Name = "HomeButton"
HomeButton.Parent = Holder
HomeButton.BackgroundTransparency = 1
HomeButton.Position = UDim2.new(0, 190, 0, 0)
HomeButton.Size = UDim2.new(0, 20, 0, 20)
HomeButton.Font = Enum.Font.GothamBold
HomeButton.TextSize = 13
HomeButton.Text = "H"
HomeButton.TextColor3 = KIZZ_CYAN
HomeButton.ZIndex = 11
HomeButton.MouseButton1Click:Connect(function() KizzHub.Toggle() end)

-- ---------- ANIMASI LOADING ----------
local function kizzLoading()
	local dim = Instance.new("Frame")
	dim.Name = randomString()
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.BorderSizePixel = 0
	dim.ZIndex = 99
	dim.Parent = ScaledHolder
	TweenService:Create(dim, TweenInfo.new(0.35), {BackgroundTransparency = 0.45}):Play()

	local card = Instance.new("Frame")
	card.Name = randomString()
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(250, 100)
	card.BackgroundColor3 = KIZZ_BG
	card.BackgroundTransparency = 1
	card.BorderSizePixel = 0
	card.ZIndex = 100
	card.Parent = ScaledHolder
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 14)
	cc.Parent = card
	local stroke = Instance.new("UIStroke")
	stroke.Color = KIZZ_CYAN
	stroke.Thickness = 2
	stroke.Transparency = 1
	stroke.Parent = card

	-- card membesar + muncul
	TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(320, 150), BackgroundTransparency = 0
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.45), {Transparency = 0}):Play()

	local function lbl(y, h, size, font, text, color)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Position = UDim2.new(0, 0, 0, y)
		t.Size = UDim2.new(1, 0, 0, h)
		t.Font = font
		t.TextSize = size
		t.Text = text
		t.TextColor3 = color or Color3.new(1, 1, 1)
		t.TextTransparency = 1
		t.ZIndex = 101
		t.Parent = card
		TweenService:Create(t, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
		return t
	end

	local nameL = lbl(14, 50, 38, Enum.Font.GothamBlack, "KizzDev", KIZZ_CYAN)
	local subL = lbl(62, 16, 12, Enum.Font.GothamMedium, "Hub  -  based on Infinite Yield", Color3.fromRGB(150, 160, 180))
	local statusL = lbl(88, 18, 14, Enum.Font.Gotham, "Starting...")

	local barBg = Instance.new("Frame")
	barBg.Position = UDim2.new(0, 24, 0, 118)
	barBg.Size = UDim2.new(1, -48, 0, 8)
	barBg.BackgroundColor3 = KIZZ_BG2
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 101
	barBg.Parent = card
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = barBg
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = KIZZ_CYAN
	fill.BorderSizePixel = 0
	fill.ZIndex = 102
	fill.Parent = barBg
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(Color3.fromRGB(150, 70, 255), Color3.fromRGB(255, 90, 220))
	grad.Parent = fill

	-- garis tepi berdenyut selama loading
	local running = true
	task.spawn(function()
		while running do
			TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Thickness = 4}):Play()
			task.wait(0.5)
			TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {Thickness = 1.5}):Play()
			task.wait(0.5)
		end
	end)

	local steps = {
		"Loading modules",
		"Building interface",
		"Loading commands",
		"Applying KizzDev theme",
		"Ready!"
	}
	for i, text in ipairs(steps) do
		for d = 0, 2 do
			statusL.Text = text .. (i < #steps and string.rep(".", d + 1) or "")
			if d == 0 then
				TweenService:Create(fill, TweenInfo.new(0.55, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(i / #steps, 1)}):Play()
			end
			task.wait(0.18)
		end
	end
	task.wait(0.25)
	running = false

	-- fade out
	local out = TweenInfo.new(0.5)
	TweenService:Create(dim, out, {BackgroundTransparency = 1}):Play()
	TweenService:Create(card, out, {BackgroundTransparency = 1, Size = UDim2.fromOffset(350, 170)}):Play()
	TweenService:Create(stroke, out, {Transparency = 1}):Play()
	for _, d in ipairs(card:GetDescendants()) do
		if d:IsA("TextLabel") then
			TweenService:Create(d, out, {TextTransparency = 1}):Play()
		elseif d:IsA("Frame") then
			TweenService:Create(d, out, {BackgroundTransparency = 1}):Play()
		end
	end
	task.wait(0.55)
	dim:Destroy()
	card:Destroy()
end

-- ---------- INTRO ----------
task.spawn(function()
	task.wait()
	pcall(kizzLoading)
	pcall(function() Logo:Destroy() end)
	pcall(function() Credits:Destroy() end)
	pcall(function() IntroBackground:Destroy() end)
	pcall(function() Holder.Visible = false end)
	KizzHub.Open()
	notify("KizzDev", "Welcome, " .. displayName .. "! Hub terbuka. Tombol logo (melayang) atau RightShift untuk buka/tutup.", 8)
end)

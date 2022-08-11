local Prompts = {}
local Prompt = {}
Prompt.__index = Prompt

Prompts = setmetatable({}, {
    __call = function(_, name)
        if Prompts[name] then
            return Prompts[name]
        end
    end
})

function Prompt.new(name, coords, key, text, options)
    if (Prompts(name)) then
        return Print(('[VORP-Prompts] Prompt with name %s already exists'):format(name))
    end
    local instance = setmetatable({}, Prompt)
    instance.name = name
    instance.coords = coords
    instance.key = key
    instance.text = text
    instance.options = options
    instance.active = false
    instance.prompt = nil
    print(('[VORP-Prompts] Prompt with name %s registered'):format(name))
    Prompts[name] = instance
    return instance
end

function Prompt:getName()
    return self.name
end

function Prompt:getPrompt()
    return self.prompt
end

function Prompt:setPrompt()
    self.prompt = Citizen.InvokeNative(0x04F97DE45A519419)
end

function Prompt:removePrompt()
    self.prompt = nil
end

function Prompt:getText()
    return self.text
end

function Prompt:getKey()
    return self.key
end

function Prompt:getActiveState()
    return self.active
end

function Prompt:setActiveState(state)
    self.active = state
end

function Prompt:InitEvent()
    if self.options?.type == 'client' then
        TriggerEvent(self.options.event, self.options.args ~= nil and table.unpack(self.options.args) or nil)
    elseif self.options?.type == 'server' then
        TriggerServerEvent(self.options.event, self.options.args ~= nil and table.unpack(self.options.args) or nil)
    end
end

function createPrompt(name)
    local currentPrompt = Prompts(name)
    if currentPrompt then
        local str = currentPrompt:getText()
        currentPrompt:setPrompt()
        Citizen.InvokeNative(0xB5352B7494A08258, currentPrompt:getPrompt(), currentPrompt:getKey())
        str = CreateVarString(10, 'LITERAL_STRING', str)
        Citizen.InvokeNative(0x5DD02A8318420DD7, currentPrompt:getPrompt(), str)
        Citizen.InvokeNative(0x8A0FB4D03A630D21, currentPrompt:getPrompt(), false)
        Citizen.InvokeNative(0x71215ACCFDE075EE, currentPrompt:getPrompt(), false)
        Citizen.InvokeNative(0x94073D5CA3F16B7B, currentPrompt:getPrompt(), true)
        Citizen.InvokeNative(0xF7AA2696A22AD8B9, currentPrompt:getPrompt())
    end
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped, true)
        if (next(Prompts) ~= nil) then
            for k, v in pairs(Prompts) do
                local distance = #(coords - v.coords)
                local currentPrompt = Prompts(k)
                if distance < 1.5 then
                    sleep = 1
                    if (currentPrompt:getPrompt() == nil) then
                        createPrompt(k)
                    end
                    if (not currentPrompt:getActiveState()) then
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, currentPrompt:getPrompt(), true)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, currentPrompt:getPrompt(), true)
                        currentPrompt:setActiveState(true)
                    end
                    if (Citizen.InvokeNative(0xE0F65F0640EF0617, currentPrompt:getPrompt())) then
                        currentPrompt:initEvent()
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, currentPrompt:getPrompt(), false)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, currentPrompt:getPrompt(), false)
                        currentPrompt:removePrompt()
                        currentPrompt:setActiveState(false)
                    end
                else
                    if (currentPrompt:getActiveState()) then
                        Citizen.InvokeNative(0x8A0FB4D03A630D21, currentPrompt:getPrompt(), false)
                        Citizen.InvokeNative(0x71215ACCFDE075EE, currentPrompt:getPrompt(), false)
                        currentPrompt:removePrompt()
                        currentPrompt:setActiveState(false)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for k, v in pairs(Prompts) do
        local currentPrompt = Prompts(k)
        Citizen.InvokeNative(0x8A0FB4D03A630D21, currentPrompt:getPrompt(), false)
        Citizen.InvokeNative(0x71215ACCFDE075EE, currentPrompt:getPrompt(), false)
        currentPrompt:removePrompt()
    end
end)


exports('createNewPrompt', Prompt.new)

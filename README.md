Prompts for VORP

```lua
    local prompt = Prompt.new('test', vector3(-339.7, 789.59, 116.04), 0xCEFD9220, 'Test', {
         type = 'client',
         event = 'vorp:clientEvent',
         args = { false, true, true }
    })

    local prompt = exports['vorp_prompts']:createNewPrompt('test', vector3(-339.7, 789.59, 116.04), 0xCEFD9220, 'Test', {
         type = 'server',
         event = 'vorp:serverEvent',
         args = { false, true, true }
    })
```

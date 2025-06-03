local fs = require('@lune/fs')

local test_build = require('./test_build')

local function build_source()
    local include = fs.readDir('src/include')
    
    local output = [[     
if game:GetService('ServerScriptService'):FindFirstChild('aggrobuild') then
    game:GetService('ServerScriptService'):WaitForChild('aggrobuild'):Destroy()
end

local core_script = Instance.new('Script', game:GetService('ServerScriptService'))
core_script.Name = 'aggrobuild'

local include = Instance.new('Folder', core_script)
include.Name = 'include'
]]
    
    for i, filename in include do
        local source = fs.readFile('src/include/' .. filename)
        local vaible = filename:gsub('.luau', '')
        output ..= `local {vaible} = Instance.new('ModuleScript', include); {vaible}.Name = '{filename:gsub('.luau', '')}'; {vaible}.Source = [[{source}]]\n`
    end

    output ..= test_build.build()
    
    if not fs.isDir('src/build') then
        fs.writeDir('src/build')
    end

    fs.writeFile('src/build/build.luau', output)
end

print(build_source())

local fs = require('@lune/fs')

local function build_source()
    local include = fs.readDir('src/include')
    local tests = fs.readDir('src/tests')
    local examples = fs.readDir('src/examples')
    
    local output = [[     
if game:GetService('ServerScriptService'):FindFirstChild('aggrobuild') then
    game:GetService('ServerScriptService'):WaitForChild('aggrobuild'):Destroy()
end

local core_script = Instance.new('Script', game:GetService('ServerScriptService'))
core_script.Name = 'aggrobuild'

local include = Instance.new('Folder', core_script)
include.Name = 'include'
local tests = Instance.new('Folder', core_script)
tests.Name = 'tests'
local examples = Instance.new('Folder', core_script)
examples.Name = 'examples'
]]
    
    for i, filename in include do
        local source = fs.readFile('src/include/' .. filename)
        local vaible = '_' .. i
        output ..= `local {vaible} = Instance.new('ModuleScript', include); {vaible}.Name = '{filename:gsub('.luau', '')}'; {vaible}.Source = [[{source}]]`
    end

    for i, filename in tests do
        local source = fs.readFile('src/tests/' .. filename)
        local vaible = '_' .. i
        output ..= `local {vaible} = Instance.new('Script', tests); {vaible}.Name = '{filename:gsub('.luau', '')}'; {vaible}.Source = [[{source}]]`
    end

    for i, filename in examples do
        local source = fs.readFile('src/examples/' .. filename)
        local vaible = '_' .. i
        output ..= `local {vaible} = Instance.new('Script', examples); {vaible}.Name = '{filename:gsub('.luau', '')}'; {vaible}.Source = [[{source}]]`
    end
    
    if not fs.isDir('src/build') then
        fs.writeDir('src/build')
    end

    fs.writeFile('src/build/build.luau', output)
end

print(build_source())

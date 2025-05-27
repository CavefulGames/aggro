local fs = require('@lune/fs')

local function build_source()
    local include = fs.readDir('src/include')
    local tests = fs.readDir('src/tests')
    local output = [[
local core_script = Instance.new('Script', game:GetService('ServerScriptService'))
local include = Instance.new('Folder', core_script)
include.Name = 'include'
local tests = Instance.new('Folder', core_script)
tests.Name = 'tests'
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
    
    if not fs.isDir('src/build') then
        fs.writeDir('src/build')
    end

    fs.writeFile('src/build/build.luau', output)
end

print(build_source())

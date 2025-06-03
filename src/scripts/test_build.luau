local fs = require('@lune/fs')

local test_build_info = {
    examples = {
        physics_knife = false,
        pigu_ball = false,
    },
    tests = {
        grenade = false,
        knife = false,
        physics = true,
        tempentity = false,
    },
}

local function build_source()
    local source = ''
    
    for dirname, files in test_build_info do
        source ..= `local {dirname} = Instance.new('Folder', core_script)\n`
        source ..= `{dirname}.Name = '{dirname}'\n`

        for filenumber, filename in fs.readDir(`src/{dirname}/`) do
            local file_source = fs.readFile(`src/{dirname}/` .. filename)
            local vaible_name = '_' .. filenumber
            source ..= `local {vaible_name} = Instance.new('Script', {dirname})\n` 
            source ..= `{vaible_name}.Name = '{filename:gsub('.luau', '')}'\n` 
            source ..= `{vaible_name}.Source = [[{file_source}]]\n` 
            source ..= `{vaible_name}.Enabled = {test_build_info[dirname][filename:gsub('.luau', '')]}\n`
        end
    end

    return source
end

return {
    build = build_source,
}

codeblock.config = {}

----------------------- 1:limited 2:standard 3:privileged 4:trusted
codeblock.config.lua_dir = 'codeblock_files'
codeblock.config.default_auth_level = 1
codeblock.config.auth_levels = {1, 2, 3, 4}
codeblock.config.max_calls = {1e6, 1e7, 1e8, 1e9}
codeblock.config.max_volume = {1e5, 1e6, 1e7, 1e8}
codeblock.config.max_commands = {1e4, 1e5, 1e6, 1e7}
codeblock.config.max_distance = {150 ^ 2, 300 ^ 2, 700 ^ 2, 1500 ^ 2}
codeblock.config.max_dimension = {15, 30, 70, 150}
codeblock.config.commands_before_yield = {1, 10, 20, 40}
codeblock.config.calls_before_yield = {1, 10, 20, 40}
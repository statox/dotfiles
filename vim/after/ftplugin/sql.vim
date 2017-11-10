" sql.vim ftplugin

" Define buffer local commands to uppercase sql keywords
command! -buffer FormatSQL v/\v(^\s*--)|(^\s*\/\*)/s/\C\<\(select\|from\|where\|into\|and\|values\|insert\|not\|null\|default\|minvalue\|maxvalue\|sequence\|create\|no\|drop\|if\|exists\|start\with\|increment\|nextval\|constraint\|primary\|foreign\|key\|index\|references\|on\|delete\|update\|restrict\|false\|true\)\>/\U\0/g
command! -buffer FormatSQLConfirm v/\v(^\s*--)|(^\s*\/\*)/s/\C\<\(select\|from\|where\|into\|and\|values\|insert\|not\|null\|default\|minvalue\|maxvalue\|sequence\|create\|no\|drop\|if\|exists\|start\with\|increment\|nextval\|constraint\|primary\|foreign\|key\|index\|references\|on\|delete\|update\|restrict\|false\|true\)\>/\U\0/gc

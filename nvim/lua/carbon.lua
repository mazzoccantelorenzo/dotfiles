local M = {}

function M.setup()
    vim.cmd("hi clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end
    vim.g.colors_name = "carbon"

    local white = "#ffffff"
    local light_blue = "#7dd3fc" -- Un azzurro chiaro e pulito
    local grey = "#4b5563"
    local bg = "#111111" -- Sfondo molto scuro, quasi nero

    local hl = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- UI Base
    hl("Normal", { fg = white, bg = bg })
    hl("NormalFloat", { fg = white, bg = bg })
    hl("CursorLine", { bg = "#1e1e1e" })
    hl("LineNr", { fg = grey })
    hl("CursorLineNr", { fg = white, bold = true })
    hl("WinSeparator", { fg = grey })
    hl("Pmenu", { bg = "#1e1e1e", fg = white })
    hl("Search", { bg = grey, fg = white })

    -- Sintassi Generale (Tutto bianco di base)
    hl("Identifier", { fg = white })
    hl("Function", { fg = white })
    hl("Constant", { fg = white })
    hl("String", { fg = white })
    hl("Character", { fg = white })
    hl("Number", { fg = white })
    hl("Boolean", { fg = white })
    hl("Float", { fg = white })
    hl("Operator", { fg = white })
    hl("Comment", { fg = grey, italic = true })
    hl("Todo", { fg = light_blue, bold = true })

    -- Particolarità del linguaggio (Azzurro)
    hl("Keyword", { fg = light_blue, bold = true })
    hl("Statement", { fg = light_blue, bold = true })
    hl("Conditional", { fg = light_blue, bold = true })
    hl("Repeat", { fg = light_blue, bold = true })
    hl("Label", { fg = light_blue })
    hl("Exception", { fg = light_blue, bold = true })
    hl("Type", { fg = light_blue })
    hl("StorageClass", { fg = light_blue, bold = true }) -- const, static, etc.
    hl("Structure", { fg = light_blue, bold = true })    -- struct, union, enum
    hl("Typedef", { fg = light_blue, bold = true })
    hl("Include", { fg = light_blue, bold = true })      -- #include
    hl("PreProc", { fg = light_blue })                   -- #define, #ifdef
    hl("PreCondit", { fg = light_blue, bold = true })

    -- Treesitter (Precisione chirurgica)
    hl("@keyword", { fg = light_blue, bold = true })
    hl("@keyword.directive", { fg = light_blue, bold = true })
    hl("@keyword.directive.define", { fg = light_blue, bold = true })
    hl("@type", { fg = light_blue })
    hl("@type.builtin", { fg = light_blue })
    hl("@storageclass", { fg = light_blue, bold = true })
    hl("@repeat", { fg = light_blue, bold = true })
    hl("@conditional", { fg = light_blue, bold = true })
    hl("@include", { fg = light_blue, bold = true })
    
    -- Tutto il resto forzato a bianco
    hl("@variable", { fg = white })
    hl("@variable.builtin", { fg = white })
    hl("@variable.parameter", { fg = white })
    hl("@variable.member", { fg = white })
    hl("@function", { fg = white })
    hl("@function.call", { fg = white })
    hl("@function.builtin", { fg = white })
    hl("@function.method", { fg = white })
    hl("@function.method.call", { fg = white })
    hl("@method", { fg = white })
    hl("@method.call", { fg = white })
    hl("@property", { fg = white })
    hl("@field", { fg = white })
    hl("@parameter", { fg = white })
    hl("@constant", { fg = white })
    hl("@constant.builtin", { fg = white })
    hl("@constant.macro", { fg = white })
    hl("@string", { fg = white })
    hl("@number", { fg = white })
    hl("@operator", { fg = white })
    hl("@punctuation.delimiter", { fg = white })
    hl("@punctuation.bracket", { fg = white })
    hl("@punctuation.special", { fg = white })
    hl("@tag", { fg = white })
    hl("@tag.attribute", { fg = white })
    hl("@tag.delimiter", { fg = white })
end

return M

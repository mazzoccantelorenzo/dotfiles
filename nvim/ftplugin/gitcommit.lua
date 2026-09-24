-- Imposta l'andare a capo automatico a 72 caratteri per i messaggi di commit
vim.opt_local.textwidth = 72
-- Abilita l'a-capo automatico durante la scrittura
vim.opt_local.formatoptions:append("t")
-- Evita di andare a capo a metà parola se possibile
vim.opt_local.formatoptions:append("l")

-- Mostra una linea verticale alla colonna 72 come guida visiva
vim.opt_local.colorcolumn = "72"
-- Attiva il controllo ortografico (utile per i commit)
vim.opt_local.spell = true

-- Bordes redondeados alrededor de los paneles
require("full-border"):setup({ type = ui.Border.ROUNDED })

-- Estado git en la lista de archivos
th.git = th.git or {}
th.git.modified_sign = "M"
th.git.added_sign = "A"
th.git.untracked_sign = "?"
th.git.deleted_sign = "D"
require("git"):setup()

-- Prompt de starship en la cabecera (rama git, lenguaje del proyecto...)
require("starship"):setup()

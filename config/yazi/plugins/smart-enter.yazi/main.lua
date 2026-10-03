--- @sync entry
-- Entra en directorios y abre archivos con la misma tecla
return {
	entry = function()
		local h = cx.active.current.hovered
		ya.emit(h and h.cha.is_dir and "enter" or "open", {})
	end,
}

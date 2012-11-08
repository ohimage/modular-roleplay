local cfg = {}
MORP.cfg = cfg

-- colors
MORP.color = {}
MORP.color.red = Color(255,0,0)
MORP.color.orange = Color(255,155,0)
MORP.color.yellow = Color(255,255,0)
MORP.color.green = Color(255,0,0)
MORP.color.blue = Color(0,0,255)
MORP.color.cyan = Color(0,255,255)
MORP.color.black = Color(0,0,0)
MORP.color.grey = Color(155,155,155)
MORP.color.white = Color(255,255,255)


-- Module Settings
-- chat
cfg.BlockedCommands = {} -- add a command here to disable it. EX: { 'ooc', '/', 'oc' } will disable OCC chat.
cfg.ChatFilters = {
	['fuck'] = 'f***',
	['gay'] = 'happy',
	['bitch'] = 'b****',
	['hell'] = 'heaven'
}
-- Data Manager - CHANGING THEASE VALUES MAY BREAK STUFF AND IS NOT ADVISED
cfg.TablePrefix = 'MoRP_'
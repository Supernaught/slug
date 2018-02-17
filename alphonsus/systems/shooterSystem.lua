--
-- ShooterSystem
-- by Alphonsus
--

local System = require "lib.knife.system"
local timer = require "lib.hump.timer"

local shooterSystem = System(
	{ "shooter", "shoot" },
	function(shooter, shoot, e)
		local s = shooter
		if not s.didShoot then return end
		
		if s.canAtk then
			e:shoot(dt)
			s.canAtk = false
			timer.after(s.atkDelay, function() s.canAtk = true end)
		end
	end
)

return shooterSystem

----------------------------------------------------------------------------
--  example_skills.lua - Example skills initialization file
--
--  Created: Fri Feb 01 10:08:41 2013
--  License: BSD, cf. LICENSE file
--  Copyright  2013  Tim Niemueller [www.niemueller.de]
----------------------------------------------------------------------------

require("fawkes.modinit")
module(..., fawkes.modinit.register_all)

skillenv = require("skiller.skillenv")
local action_skill = require("skiller.ros.action_skill")
local service_skill = require("skiller.ros.service_skill")
require("skiller.skillhsm")

print("Initializing Example skills")
action_skill.debug = true

-- Generic action skills
action_skill.use("example_skills.fibonacci", "/fibonacci", "actionlib_tutorials/Fibonacci")

-- Custom skills
skillenv.use_skill("example_skills.print_fibo")

print_warn("Initialized example skills. Skiller can now be used.")

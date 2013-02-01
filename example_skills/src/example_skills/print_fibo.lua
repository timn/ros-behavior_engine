
----------------------------------------------------------------------------
--  print_and_wait.lua - example skills that prints and waits
--
--  Created: Fri Feb 01 10:28:58 2013
--  License: BSD, cf. LICENSE file
--  Copyright  2013  Tim Niemueller [www.niemueller.de]
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "print_fibo"
fsm             = SkillHSM:new{name=name, start="PRINT"}
depends_skills  = { "fibonacci" }
depends_actions = nil
depends_topics = {
   { v="fibo_result",  name="/fibonacci/result",
     type="actionlib_tutorials/FibonacciActionResult", latching=true }
}

documentation      = [==[Example skill to print and wait.

print_and_wait{text="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- Define the states of the SkillHSM as tuple/table. Format:
-- {"NAME", StateType, args}
-- NAME is arbitrary
-- StateType is one of the existing JumpState types, e.g. JumpState,
-- ActionJumpState, ServiceJumpState, SkillJumpState
-- The args are dependent on the skill type, see the documentation of
-- the StateType's respective constructor arguments.
-- A SkillHSM implicitly has the states FINAL and FAILED. Some states,
-- like the SkillJumpState, already define some implicit transitions.
fsm:define_states{ export_to=_M,
   {"PRINT", JumpState},
   {"FIBONACCI", SkillJumpState, final_to="FIBO_SUCCESS", fail_to="FIBO_FAIL",
    skills={{fibonacci, order=10}}},
   {"FIBO_SUCCESS", JumpState},
   {"FIBO_FAIL", JumpState}
}

-- Add any additional transitions. Format is:
-- {"FROM_STATE", "TO_STATE", condition}
-- where condition can be either true (unconditional, execute transition
-- when entering FROM_STATE, a boolean function, or a textual boolean
-- expression, e.g. "vars.parameter == 1" to check if the parameter in the
-- variables table equals true. Note that you need to pass any objects/tables
-- you want to reference in the define_states() calls via the closure
-- parameter.
fsm:add_transitions{
   -- Unconditional transition from print to FIBONACCI
   {"PRINT", "FIBONACCI", true},
   {"FIBO_SUCCESS", "FINAL", "vars.received_result"},
   {"FIBO_FAIL", "FAILED", true}
}

-- Define some states' init functions.
-- A state has three functions you can override:
-- init()
-- Executed when entering the state
-- loop()
-- Executed in each cycle while the state is active
-- exit()
-- Executed when exiting a state

function PRINT:init()
   print("Executed when entering the PRINT state")
end

function FIBONACCI:init()
   -- Reset the message so we can be sure not to get an old result
   -- in FIBO_SUCCESS
   fibo_result:reset_messages()
end

function FIBO_SUCCESS:init()
   print("Fibonacci was executed successfully")
   -- there is no need to initialize received_results here. The variables
   -- table is cleaned before each invocation of the skill. Hence the
   -- received_results field is always nil when called initially.
end

function FIBO_SUCCESS:loop()
   if #fibo_result.messages > 0 then
      local m = fibo_result.messages[#fibo_result.messages]
      -- we got a message, print the results
      local result_string = ""
      for i,v in ipairs(m.values.result.values.sequence) do
	 if i > 1 then
	    result_string = result_string .. ", "
	 end
	 result_string = result_string .. tostring(v)
      end
      printf("Result: %s", result_string)
      self.fsm.vars.received_result = true
   end
end

function FIBO_FAIL:init()
   print_error("Fibonacci call failed")
   self.fsm.error = "Fibonacci call failed"
end


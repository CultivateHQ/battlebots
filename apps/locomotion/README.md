# Locomotion

Controls the Battlebots motion via the stepper motors.

Right now, this is done by sending a continous stream of messages to the [stepper motor  process](lib/locomotion/stepper_motor.ex).

Given that the bot now includes an Arduino (Uno clone) unit, a better approach might be use that unit to control the motor (via the serial interface) as the microprocessor can give better hard realtime guarantees. This is not currently implemented due to only thinking of the battlebot prize the week before ElixirConf EU.

extends Node
## Time manager singleton that handles game countdown and pause functionality.
##
## Controls level timer, pause state, and emits timeout signal when time runs out.
## Provides methods to start, stop, pause and update the countdown timer.
##
## Properties:
## - total_time: Base time limit for each level in seconds
## - time_left: Current remaining time in seconds
## - paused: Current pause state
## - timer_active: Whether timer is currently running
## - finished_time1: Time taken to complete level
##
## Signals:
## - timeout: Emitted when countdown reaches zero


# Timer state variables
var total_time = 20 ## Default total time for each level in seconds
var time_left = 20  ## Current remaining time in seconds
var paused = false ## Current pause state
var timer_active = false ## Whether timer is currently running
var finished_time1 = 0 ## Time taken to complete current level

## Emitted when countdown reaches zero
signal timeout

## Resets timer to initial state [br]
## Sets time_left to total_time and clears pause/active states
func reset_time():
	time_left = total_time
	paused = false
	timer_active = false

## Starts the countdown timer
func start_timer():
	timer_active = true

## Stops the countdown timer
func stop_timer():
	timer_active = false

## Updates remaining time and checks for timeout [br]
##
## Decrements time_left by delta if timer is active and not paused [br]
## Emits timeout signal when time reaches zero [br]
##
## Parameters: [br]
## - delta: Time elapsed since last frame in seconds [br]
##
## Returns: Current time_left value [br]
func update_time(delta: float):
	if timer_active and not paused and time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			timer_active = false
			emit_signal("timeout")
	return time_left

## Calculates time taken to complete level [br]
##
## Parameters: [br]
## - delta: Time elapsed since last frame in seconds [br]
##
## Returns: Time taken (total_time - time_left) [br]
func finished_time(delta: float):
	finished_time1 = total_time - update_time(delta) 
	return finished_time1

## Toggles pause state [br]
##
## Returns: New pause state [br]
func toggle_pause():
	paused = !paused
	return paused

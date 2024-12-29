extends Node

## TimeManager singleton that handles game countdown and pause functionality.
##
## Controls level timer, pause state, and emits timeout signal when time runs out.
## Provides methods to start, stop, pause, and update the countdown timer.
##
## Properties:
## - total_time: Base time limit for each level in seconds
## - time_left: Current remaining time in seconds
## - paused: Current pause state
## - timer_active: Whether the timer is currently running
## - finished_time: Time taken to complete the level
##
## Signals:
## - timeout: Emitted when countdown reaches zero
## - time_updated: Emitted every second with the updated time_left

# Timer state variables
var total_time: float = 20.0  # Default total time for each level in seconds
var time_left: float = 20.0   # Current remaining time in seconds
var paused: bool = false      # Current pause state
var timer_active: bool = false  # Whether timer is currently running
var finished_time: float = 0.0  # Time taken to complete current level

## Emitted when countdown reaches zero
signal timeout

## Emitted every time the timer is updated
signal time_updated(time_left: float)

## Resets the timer to its initial state
##
## Sets time_left to total_time and clears pause/active states
func reset_time() -> void:
    time_left = total_time
    paused = false
    timer_active = false
    finished_time = 0.0
    emit_signal("time_updated", time_left)

## Starts the countdown timer
func start_timer() -> void:
    timer_active = true

## Stops the countdown timer
func stop_timer() -> void:
    timer_active = false

## Updates the remaining time and checks for timeout
##
## Decrements time_left by delta if timer is active and not paused
## Emits timeout signal when time reaches zero
##
## Parameters:
## - delta: Time elapsed since last frame in seconds
func update_time(delta: float) -> void:
    if timer_active and not paused and time_left > 0:
        time_left -= delta
        finished_time += delta
        if time_left <= 0:
            time_left = 0
            timer_active = false
            emit_signal("timeout")
        emit_signal("time_updated", time_left)

## Toggles the pause state
##
## Returns:
## - The new pause state after toggling
func toggle_pause() -> bool:
    paused = not paused
    return paused

## Retrieves the total time taken to complete the level
##
## Returns:
## - Time taken in seconds
func get_finished_time() -> float:
    return finished_time
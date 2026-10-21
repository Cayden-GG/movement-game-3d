extends Resource
class_name PlayerMovementData

## ================= ##
## Player base stats ##
## ================= ##
@export_group("Base Stats")

## Speed of change in player movement direction 
@export_range(1, 20, 0.5, "prefer_slider") var LERP_SPEED: float = 10.0

## Base player gavity
@export_range(1, 40, 0.5, "prefer_slider") var GRAVITY: float = 9.8

## Base height of the player
@export_range(1, 3, 0.1, "prefer_slider") var BASE_PLAYER_HEIGHT: float = 2.0

## Player eye level below max height
@export_range(0.0, 1, 0.1, "prefer_slider") var CAMERA_EYE_LEVEL: float = 0.25

## Crouch height of the player
@export_range(0.5, 1.5, 0.1, "prefer_slider") var CROUCH_PLAYER_HEIGHT: float = 1.0

## Time lenience for jumping
@export_range(0.05, 0.5, 0.05, "prefer_slider") var JUMP_BUFFER: float = 0.05

## Max player velocity
@export_range(10, 30, 1, "prefer_slider") var MAX_VELOCITY: float = 20.0

## Base player camera fov
@export var BASE_FOV: float = 90.0

## ================= ##
## Player idle state ##
## ================= ##
@export_group("Idle State")

## ================= ##
## Player walk state ##
## ================= ##
@export_group("Walk State")

## Player max walk speed
@export_range(5, 15, 1, "prefer_slider") var WALK_SPEED: float = 10.0

## Speed of acceleration in the walk state
@export_range(1, 15, 0.5, "prefer_slider") var WALK_ACCEL: float = 7.0

## =================== ##
## Player sprint state ##
## =================== ##
@export_group("Sprint State")

## Player max sprint speed
@export_range(5, 25, 1, "prefer_slider") var SPRINT_SPEED: float = 15.0

## Speed of acceleration in the sprint state
@export var SPRINT_ACCEL: float = 6.0

## ================= ##
## Player jump state ##
## ================= ##
@export_group("Jump State")

## Player jump velocity
@export_range(1, 15, 0.5, "prefer_slider") var JUMP_VELOCITY: float = 9.0

## Speed of air strafe while jumping: higher value gives snappier air control
@export_range(1, 15, 0.5, "prefer_slider") var JUMP_AIR_CONTROL: float = 1.75

## ================= ##
## Player fall state ##
## ================= ##
@export_group("Fall State")

## Max falling speed 
@export var TERMINAL_VELOCITY: float = 50.0

## Multiplier applied to base gravity (9.8 m/s²).
@export_range(0.1, 5, 0.1, "prefer_slider") var GRAVITY_MULT: float = 1.5 

## Speed of air strafe while falling: higher value gives snappier air control
@export_range(1, 10, 1, "prefer_slider") var FALL_AIR_CONTROL: float = 5.0

## Speed of movement while falling
@export_range(1, 10, 1, "prefer_slider") var FALL_SPEED: float = 3.0

## ================= ##
## Player land state ##
## ================= ##
@export_group("Land State")

## Duration of land state effects
@export var LAND_DURATION: float = 0.2

## Multiplier applied to player movement 
@export var LAND_MOVE_MULT: float = 0.65

## Velocity at which the player staggers when landing
@export var STAGGER_VELOCITY: float = 25.0

## =================== ##
## Player crouch state ##
## =================== ##
@export_group("Crouch State")

## Player max crouch speed
@export_range(1, 10, 0.5, "prefer_slider") var CROUCH_SPEED: float = 5.0

## Player max crouch speed
@export_range(1, 15, 0.5, "prefer_slider") var CROUCH_ACCEL: float = 4.0

## ================== ##
## Player slide state ##
## ================== ##
@export_group("Slide State")

## Velocity at which player state transistions from slide to crouch
@export_range(1, 10, 0.5, "prefer_slider") var CROUCH_TRANSITION_VEL: float = 6.0

## Speed at which the player slows down while sliding
@export_range(1, 8, 0.1, "prefer_slider") var SLIDE_FRICTION: float = 2.0

## Boost added to player velocity when sliding
@export_range(1, 10, 0.5, "prefer_slider") var SLIDE_BOOST_VELOCITY: float = 2.0

## ===================== ##
## Player wall run state ##
## ===================== ##
@export_group("Wall Run State")

## Min wall run velocity
@export_range(5, 20, 0.5, "prefer_slider") var MIN_WALL_RUN_VELOCITY: float = 10

## Gravity while wall running
@export_range(0, 5, 0.5, "prefer_slider") var WALL_GRAVITY: float = 2.0 

## Max wall run time
@export_range(1, 5, 0.5, "prefer_slider") var MAX_WALL_RUN_TIME: float = 1.5

## ===================== ##
## Player wall run state ##
## ===================== ##
@export_group("Ground Pound State")

@export_range(5.0, 50.0, 1.0, "prefer_slider") var GROUND_POUND_ACCEL: float = 10.0
@export_range(20.0, 100.0, 1.0, "prefer_slider") var GROUND_POUND_VELOCITY: float = 30.0
@export_range(0.5, 3.0, 0.1, "prefer_slider") var GROUND_POUND_EXIT_BOOST: float = 1.5

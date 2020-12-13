# Player Movement Capture by Yogarine

This is a package for [Crayta](https://www.crayta.com) that allows you to listen
to player movement events and use those to control entities or do whatever you
want! It also comes with a special invisible “Movement Capture Box” which allows
you to hide the Player Characters away while still being able to receive their
movement events.

This together makes it a lot easier to create a game where you manipulate your
own entity without it having to be attached to the Player Character, and use
your own custom camera to follow the action. While the invisible Player
Character is trapped in its invisible box.

## How to use

### Player Movement
To use listen to Player Movement events, attach the Player Movement template to
your Player template. You can then add listeners directly from the panel in the
sidebar. The following events currently are available:

  - `onPlayerMovement(Character player, Vector movementVector, Vector
    avgMovementVector)`:<br/>
    Triggered on server when Player moves.

  - `clientOnPlayerMovement(deltaTimeSeconds, Vector movementVector, Vector
    avgMovementVector)`:<br/>
    Triggered on clients when Player moves.

  - `localOnPlayerMovement(deltaTimeSeconds, Vector movementVector, Vector
    avgMovementVector)`:<br/>
    Triggered on local client when Player moves.

    The three above events share these arguments:
      - `player`: Contains the Player from which the movement was recorded.
      - `movementVector`: This is a Vector containing the distance moved.
      - `avgMovementVector`: This Vector contains the average of the last couple
        of movementVectors. Using this will make input less direct, but will
        smooth out any weirdness cause by the way the movement is captured.


  - `onPlayerRotation(Character player, Rotation movementRotation, Rotation
    movementRotation)`:<br/>
    Triggered on server when Player rotates.

  - `clientOnPlayerRotation(Character player, Rotation movementRotation,
    Rotation avgMovementRotation)`:<br/>
    Triggered on clients when Player roates.

  - `localOnPlayerRotation(Character player, Rotation movementRotation, Rotation
    avgMovementRotation)`:<br/>
    Triggered on local client when Player rotates.

    The three above events share these arguments:

      - `player`: Contains the Player from which the movement was recorded.
      - `movementRotation`: This is a Rotation containing the distance moved.
      - `avgMovementRotation`: This Vector contains the average of the last
        couple of movementRotations.


  - `onPlayerLook(Character player, Vector lookAtEye, Vector lookAtPos)`:<br/>
    Triggered on server when Player looks.

  - `clientOnPlayerLook(Character player, Vector lookAtEye, Vector
    lookAtPos)`:<br/>
    Triggered on clients when Player looks.

  - `localOnPlayerLook(Character player, Vector lookAtEye, Vector
    lookAtPos)`:<br/>
    Triggered on local client when Player looks.

## Player Movement Capture
To capture the Player Character in a Movement Capture Box, add a Movement
Capture template somewhere in your world. It has a trigger which shows you how
much room it needs to be able to spawn the maximum amount of Boxes (one for each
player in the game, with a maximum of 20).

Then add the Player Movement Capture template to your Player, and set the
movementCapture property to the Movement Capture entity you added to your world.

Now you can either use player.movementCapturePlayerScript:Capture() or to
capture a player, and Release() to release the player.

If you run into any issues or have questions lemme know!

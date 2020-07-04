# Metroid 5

## Log:


## 5 Jul 2020

- Started project
- Created initial plot
- Began creating Samus using sprites from Metroid Fusion


## 6 Jul 2020

- **Animations have been added for:**
- Crouch
- Morph ball
- Run
- Idle
- Aiming (run, idle, crouch)
- Spin
- Jump (no aiming animations yet)
- Firing (recoil)

- The base functionalities tied to each of the above have also been completed

- Created a Python script to change the colour palette of each Samus sprite to that of the Fusion suit at the end of Metroid Fusion
- Began adding sprites for when Samus is arming a weapon
- Added smoke trail particles for missiles and super missiles


## 7 Jul 2020

- Added arming weapon versions of every so-far used (non-jump) sprite
- Began creating HUD
- Added script for automatically adding E-Tank icons to the HUd
- Added particle trail effect to missiles and super missiles


## 8 Jul 2020

- Added script fot automatically adding each weapon icon and amount numerals in order, accounting for the space taken up by E-Tank icons, as well as adding the correct amount of digits for each weapon based on the maximum capacity
- Added HUD functions that update the energy amount or the amount of a weapon's ammo from the GLOBAL variable
- Added cycling functionality for armable weapons (selection and arming status are shown on the HUD), which are split between morph ball and normal status
- Added weapon selection reset functionality
- Weapon ammo amounts reduce when used, and are reflected immediately in the HUD

- Added particle effects to the beam
- Added a flash effect to Samus's cannon when she fires a beam
- Updated missile particles to improve visibility (particles do not immediately dissapear when the missile leaves the screen, particles wait a short amount of time after the missile is fired before appearing)


## 9 Jul 2020

- Began creating dialog boxes
- Ripped Adam's dialiog box transition animations
- Created the basis for dialog scripts (text, start, end)
- Began creating opening script
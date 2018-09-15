# DOCS

## Scene.lua
Gamestates like Unity scene, or GameMaker room. e.g. PlayState, MenuState

### Fields:
- entities - GameObjects
- camera - alphonsus/Camera object
  - cam - gamera object

### Methods:
- new - constructor
- init - custom initializations
- enter - when game enters the state
- addEntity
- update - DONT TOUCH. runs basic systems, camera and Input logic
- stateUpdate - wrapper for update function
- draw
- getObject(tag)
- getNearestEntityFromSource(source, maxDistance, tag)
- getNearbyEntitiesFromSource(source, distance, tag)

## Level.lua
One "Binding of Isaac" level. Consists of many TileMap (Zelda rooms)

### Methods: 
- new
- enter - when player enters level
- update
import "graphics" for Canvas, Color
import "math" for Vec, M
import "dome" for Window
import "./keys" for Key

var INPUTS = [
  Key.new("left", true, Vec.new(-1, 0)),
  Key.new("right", true, Vec.new(1, 0)),
  Key.new("up", true, Vec.new(0, -1)),
  Key.new("down", true, Vec.new(0, 1)),
  Key.new("space", true, Vec.new()),
  Key.new("return", true, Vec.new())
]

var PAL = {
  "bg": Color.rgb(36,25,20),
  "sprite":Color.white,
  "tile": Color.darkgreen,
  "stone": Color.darkgray,
  "water": Color.blue
}

class Room {
  construct new(tiles, map, entities, avatar) {
    _tiles = tiles
    _map = map
    _entities = entities
    _avatar = avatar
    _entities.each {|entity| entity.bind(this) }
    _avatar.bind(this)
  }

  isSolidAt(v) {
    if (v.x < 0 || v.x >= 16 || v.y < 0 || v.y >= 16) {
      return true
    }
    var tileIndex = _map[v.y * 16 + v.x]
    var tileSolid = false
    if (tileIndex != 0) {
      var tile = _tiles[tileIndex]
      tileSolid = tile.solid
    }
    if (!tileSolid) {
      var occupying = entities.where {|entity| entity.pos == v }.toList
      tileSolid = occupying.count > 0
    }
    return tileSolid
  }

  getOccupying(v) {
    return entities.where {|entity| entity.pos == v }.toList
  }

  draw(frameNo) {
    for (y in 0...16) {
      for (x in 0...16) {
        var tileIndex = _map[y * 16 + x]
        if (tileIndex > 0) {
          var tile = _tiles[tileIndex]
          tile.draw(frameNo, x, y)
        }
      }
    }
    entities.each {|entity| entity.draw(frameNo) }
    avatar.draw(frameNo)
  }

  avatar { _avatar }
  map { _map }
  entities { _entities }
}

var CAT = [
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,
0,1,0,1,0,0,0,1,
0,1,1,1,0,0,0,1,
0,1,1,1,0,0,1,0,
0,1,1,1,1,1,0,0,
0,0,1,1,1,1,0,0,
0,0,1,0,0,1,0,0
]

var ROOM1 = [
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
]

class Tile {
  construct new(solid, frames, color) {
    _solid = solid
    _frames = frames
    _color = color
  }
  solid { _solid }
  draw(frameNo, tx, ty) {
    frameNo = M.min(frameNo, _frames.count - 1).floor
    var screenPos = Vec.new(tx, ty) * 8
    var frame = _frames[frameNo]
    for (y in 0...8) {
      for (x in 0...8) {
        var c = frame[y * 8 + x] == 1 ? _color : PAL["bg"]
        Canvas.pset(screenPos.x + x, screenPos.y + y, c)
      }
    }
  }
}

var WATER_TILE = [
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,0,0,0,
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
  0,0,0,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
]
var WATER_TILE2 = [
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
  1,0,0,0,1,1,1,1,
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
  1,1,1,1,0,0,0,1,
  1,1,1,1,1,1,1,1,
  1,1,1,1,1,1,1,1,
]
var FLOOR_TILE = [
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,1,0,0,
  0,1,0,0,1,1,0,0,
  0,1,1,0,1,1,1,0,
]
var SOLID_WALL = [
  0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0,
  0,1,1,1,1,1,1,0,
  0,1,1,1,1,1,1,0,
  0,0,0,0,0,0,0,0,
  0,1,1,1,1,1,1,0,
  0,1,1,1,1,1,1,0,
  0,1,1,1,1,1,1,0,
]
var FLOOR = Tile.new(false, [FLOOR_TILE], PAL["tile"])
var WALL = Tile.new(true, [SOLID_WALL], PAL["stone"])
var RIVER = Tile.new(true, [WATER_TILE, WATER_TILE2], PAL["water"])

var PLAYER = [
  0,0,0,1,1,0,0,0,
  0,0,1,1,1,1,0,0,
  0,0,0,1,1,0,0,0,
  0,1,1,1,1,1,1,0,
  0,1,0,1,1,0,1,0,
  0,1,0,1,1,0,1,0,
  0,0,1,1,1,1,0,0,
  0,0,1,1,1,1,0,0,
]
var PLAYER2 = [
  0,0,0,0,0,0,0,0,
  0,0,0,1,1,0,0,0,
  0,0,1,1,1,1,0,0,
  0,0,0,1,1,0,0,0,
  0,1,1,1,1,1,1,0,
  0,1,0,1,1,0,1,0,
  0,1,0,1,1,0,1,0,
  0,0,1,1,1,1,0,0,
]

class Entity {
  construct new(pos) {
    _pos = pos
  }
  construct new(pos, dialog) {
    _pos = pos
    _dialog = dialog
  }
  pos { _pos }
  pos=(v) { _pos = v }
  bind(world) { _world = world }
  world { _world }
  update() {}
  draw(framePos) {}
  collide(source) {
    if (_dialog) {
      Game.pushUI(DialogBox.new(_dialog))
    }
  }
}

class DialogBox is Entity {
  construct new(text) {
    super(Vec.new())
    _text = text
    _lines = text
  }
  update() {
    return INPUTS.any{|key| key.update() }
  }
  draw(frame) {
    var top = 12
    var left = 12
    Canvas.rectfill(left, top, 104, 8 * 4, Color.black)
    Canvas.print(_lines, left + 8, top + 8, Color.white)
  }

}

class Sprite is Entity {
  construct new(pos, frames, color, dialog) {
    super(pos, dialog)
    _frames = frames
    _color = color
  }
  construct new(pos, frames, color) {
    super(pos)
    _frames = frames
    _color = color
  }

  draw(frameNo) {
    frameNo = (M.min(frameNo, _frames.count - 1)).floor
    var frame = _frames[frameNo]
    var screenPos = pos * 8
    for (y in 0...8) {
      for (x in 0...8) {
        var c = frame[y * 8 + x] == 1 ? _color : PAL["bg"]
        Canvas.pset(screenPos.x + x, screenPos.y + y, c)
      }
    }

  }

}
class Avatar is Sprite {
  construct new(pos, frames, color) {
    super(pos, frames, color)
  }
  update() {
    INPUTS.each{|key| key.update() }
    var oldPos = pos
    for (key in INPUTS) {
      if (key.firing) {
        pos = pos + key.action
        break
      }
    }
    if (world.isSolidAt(pos)) {
      var objs = world.getOccupying(pos)
      for (object in objs) {
        object.collide(this)
      }
      pos = oldPos
    }
  }
}

class Game {
    static init() {
      Canvas.resize(128, 128)
      Window.title = "doBitsy"
      var scale = 3
      Window.resize(scale * Canvas.width, scale * Canvas.height)
      __tiles = {}
      __tiles[1] = FLOOR
      __tiles[2] = WALL
      __tiles[3] = RIVER
      __p = Avatar.new(Vec.new(0, 1), [ PLAYER, PLAYER2 ], PAL["sprite"])
      __room = Room.new(__tiles, ROOM1, [Sprite.new(Vec.new(10, 10), [ CAT ], PAL["sprite"], "I am a cat")], __p)
      __ui = []
      __t = 0
    }
    static pushUI(ui) {
      ui.bind(__room)
      __ui.add(ui)
    }
    static update() {
      __t = __t + 1
      if (__ui.count == 0) {
        __room.avatar.update()
      } else {
        var result = __ui[0].update()
        if (result) {
          __ui.removeAt(0)
        }
      }
    }
    static draw(dt) {
      Canvas.cls(PAL["bg"])
      var frame = (__t / 30) % 2
      __room.draw(frame)
      __ui.each {|ui| ui.draw(frame) }
    }

}

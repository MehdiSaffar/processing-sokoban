enum Cell{
  Wall,
 Target, Floor,
}

enum Direction {
  Up, Down, Left, Right
}

int toInt(Direction direction) {
  if(direction == Direction.Down) {
    return 0;
  }
  if(direction == Direction.Up) {
    return 1;
  }
  if(direction == Direction.Left) {
    return 2;
  }
  if(direction == Direction.Right) {
    return 3;
  }
  return 0;
}

PFont f;
PImage[] playerImage;
PImage wallImage;
PImage boxImage;
PImage targetBoxImage;

int w;
int h;

int levelIndex = 2;

int TILE_SIZE = 60;
Board board;

void setup() {
  f = createFont("Arial", 24, true);
  textFont(f, 24);
  surface.setResizable(true);
  playerImage = new PImage[4];
  playerImage[toInt(Direction.Up)] = loadImage("mario_haut.gif");
  playerImage[toInt(Direction.Down)] = loadImage("mario_bas.gif");
  playerImage[toInt(Direction.Left)] = loadImage("mario_gauche.gif");
  playerImage[toInt(Direction.Right)] = loadImage("mario_droite.gif");
  wallImage = loadImage("mur.jpg");
  boxImage = loadImage("caisse.jpg");
  targetBoxImage = loadImage("caisse_ok.jpg");
}

void settings() {
  board = new Board();
  board.loadBoard("lvl" + levelIndex + ".txt");
  w = TILE_SIZE * board.w;
  h = TILE_SIZE * board.h;
  size(w, h);
}

void keyPressed() {
  board.onKeyPressed(keyCode);
}

void draw() {
  background(128, 128, 0);
  if(!board.win()) {
    board.draw();
  } else {
    levelIndex++;
    board.loadBoard("lvl" + levelIndex + ".txt");
    w = TILE_SIZE * board.w;
    h = TILE_SIZE * board.h;
    surface.setSize(w, h);
  }
}

class Board {
  PVector player;
  Direction playerDir;
  ArrayList<PVector> boxes;

  Cell[][] grid;
  int w;
  int h;
  int inPlace;
  int targetCount;

  Board() {
    init();
  }

  void init() {
      player = new PVector(-1, -1);
      playerDir = Direction.Down;
      boxes = new ArrayList<PVector>();
      grid = null;
      inPlace = 0;
      targetCount  = 0;
      w = 0;
      h = 0;
  }

  void loadBoard(String levelPath) {
    init();
    String[] lines = loadStrings(levelPath);
    h = lines.length;
    w = lines[0].length();
    grid = new Cell[h][w];
    for(int y = 0; y < h; y++) {
      for(int x = 0; x < w; x++) {
          char current = lines[y].charAt(x);
          if(current == '#') {
            grid[y][x] = Cell.Wall;
          } else if(current == '@') {
            grid[y][x] = Cell.Floor;
            player = new PVector(x,y);
          } else if(current == '.') {
            grid[y][x] = Cell.Target;
            targetCount++;
          } else if(current == '$') {
            boxes.add(new PVector(x,y));
            grid[y][x] = Cell.Floor;
          } else {
            grid[y][x] = Cell.Floor;
          }
      }
    }

  }

  PVector getDirectionFromKey(int keyCode) {
    if(keyCode == LEFT) {
      return new PVector(-1, 0);
    }
    if(keyCode == RIGHT) {
      return new PVector(1, 0);
    }
    if(keyCode == DOWN) {
      return new PVector(0, 1);
    }
    if(keyCode == UP) {
      return new PVector(0, -1);
    }
    return new PVector(0,0);
  }

  boolean isBox(PVector pos) {
    for(int i = 0; i < boxes.size(); i++) {
        if(boxes.get(i).equals(pos)) {
          return true;
        }
    }
    return false;
  }

  boolean isWalkable(Cell cell) {
    return cell == Cell.Floor || cell == Cell.Target;
  }

  boolean isFree(PVector pos) {
    return isWalkable(grid[(int)pos.y][(int)pos.x]) && !isBox(pos);
  }

  Cell cell(PVector pos) {
    return grid[(int) pos.y][(int) pos.x];
  }

  boolean boxCanMove(PVector box, PVector dir) {
    PVector next = PVector.add(box, dir);
    return isFree(next);
  }

  PVector getBoxAt(PVector pos) {
    for(int i = 0; i < boxes.size(); i++){
      if(boxes.get(i).equals(pos)) {
        return boxes.get(i);
      }
    }
    return null;
  }


  void moveBox(PVector box, PVector dir) {
    if(cell(box) == Cell.Target) {
      inPlace--;
    }
    box.add(dir);
    if(cell(box) == Cell.Target) {
      inPlace++;
    }
  }

  Direction toEnum(PVector direction) {
    if(direction.equals(new PVector(1,0))) {
      return Direction.Right;
    }
    if(direction.equals(new PVector(-1,0))) {
      return Direction.Left;
    }
    if(direction.equals(new PVector(0,1))) {
      return Direction.Down;
    }
    if(direction.equals(new PVector(0,-1))) {
      return Direction.Up;
    }

    return Direction.Down;
  }
  void movePlayer(PVector direction) {
    player.add(direction);
    playerDir = toEnum(direction);
  }

  void onKeyPressed(int keyCode) {
    PVector direction = getDirectionFromKey(keyCode);
    PVector next = PVector.add(player, direction);

    if(isFree(next)) {
      movePlayer(direction);
    } else if (isBox(next)) {
        // if it is a box then check if the box can move
        if(boxCanMove(next, direction)) {
          PVector box = getBoxAt(next);
          moveBox(box, direction);
          movePlayer(direction);
        }
    }
  }

  void drawBox(PVector box) {
    // fill(0, 128, 0);
    // rect(box.x * TILE_SIZE, box.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    if(cell(box) == Cell.Target) {
      image(targetBoxImage, box.x * TILE_SIZE, box.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    } else {
      image(boxImage, box.x * TILE_SIZE, box.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    }
  }

  void drawPlayer() {
    // fill(255, 0, 0);
    // rect(player.x * TILE_SIZE, player.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    
    image(playerImage[toInt(playerDir)], player.x * TILE_SIZE, player.y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  }

  void drawCell(int x, int y, Cell cell) {
      if(cell == Cell.Floor) {
        fill(237, 229, 220);
      } else if(cell == Cell.Target) {
        fill(128, 128, 0);
      } else {
        fill(0);
      }
      rect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE);
      if(cell == Cell.Wall) {
          image(wallImage, TILE_SIZE * x, TILE_SIZE * y, TILE_SIZE, TILE_SIZE);
      }
  }

  boolean win() {
    return inPlace == targetCount;
  }

  void draw() {
    for(int y = 0; y < grid.length; y++){
      for(int x = 0; x < grid[0].length; x++){
        drawCell(x,y, grid[y][x]);
      }
    }

    for(int i = 0; i < boxes.size(); i++) {
      drawBox(boxes.get(i));
    }

    drawPlayer();
    
    if(win()) {
      textAlign(LEFT);
      fill(255,0,0);
      text("You win", 10, 24);
    }
  }
}

Minesweeper m;
int size;
boolean gameOver;
boolean gameStart;
int bombsLeft;
int topBorder = 70;
int MODE = 0;
int WaitTime = 10;

void setup() {
  size(1500, 800); //standard expert board dimensions
  size = 50; //side length of each tile. might need scaling if board size is changed
  m = new Minesweeper(0, 99, 16, 30, 0, 0);//need to initialize here**************************************************************
  bombsLeft = m.BOMBS;
  gameOver = false;
  gameStart = false;
}

void draw() {
  brc();
  brcSetMonitor("bombsLeft", bombsLeft);
  
  if (!gameOver) {
    background(255);
    //board drawing. -1 is a mine, -2 is unexplored, -3 is a flag, non-negative ints are adjacent bomb counts
    for (int i = 0; i < m.ROWS; i++) {
      for (int j = 0; j < m.COLS; j++) {
        if (m.BOARD[i][j] == -1) {
          fill(255, 0, 0);
          rect(j*size, i*size, size, size);
        } else if (m.BOARD[i][j] == -2) {
          fill(255);
          rect(j*size, i*size, size, size);
          fill(0);
          textSize(10);
          text(""+m.MIND[i][j], j*size+size/2-20, i*size+size/2-10);
        } else if (m.BOARD[i][j] == -3) {
          fill(255);
          rect(j*size, i*size, size, size);

          float a = j*size+size/2;
          float b = i*size+size/2;
          float s = -3*size/10;
          noStroke();
          fill(0);
          rect(a, b-size/36, size/18, size/4);


          fill(200, 0, 0);
          triangle(a+size/18, b, a+size/18, b+s, a-sqrt(s*s-(s/2.0)*(s/2.0))+size/18, (2.0*b+s)/2.0);


          stroke(0);
        } else {
          fill(140);
          rect(j*size, i*size, size, size);
          textSize(32);
          fill(0, 255-m.BOARD[i][j]*50, 0);
          text(""+m.BOARD[i][j], j*size+size/2-8, i*size+size/2+16);

          textSize(10);
          text(""+m.MIND[i][j], j*size+size/2-20, i*size+size/2-10);
        }
      }
    }

    //bomb counter
    //fill(0);
    //textSize(16);
    //text("Mines Left: " + bombsLeft, 0, 16);
  } else {//reveals board when a mine is opened 
    background(255);
    for (int i = 0; i < m.ROWS; i++) {
      for (int j = 0; j < m.COLS; j++) {
        if (m.KEY[i][j] == -1) {
          fill(255, 0, 0);
          rect(j*size, i*size, size, size);
        } else if (m.KEY[i][j] == -2) {
          fill(255);
          rect(j*size, i*size, size, size);
        } else {
          if (m.BOARD[i][j] != -2) {
            fill(235, 229, 52);
          } else {
            fill(140);
          }
          rect(j*size, i*size, size, size);
          textSize(32);
          fill(0, 255-m.KEY[i][j]*50, 0);
          text(""+m.KEY[i][j], j*size+size/2-8, i*size+size/2+16);
        }

        if (m.BOARD[i][j] == -1) {
          fill(0);
          line(j*size, i*size, j*size+size, i*size+size);
          line(j*size, i*size+size, j*size+size, i*size);
        }
        if (m.BOARD[i][j] == -3) {
          fill(255);
          rect(j*size, i*size, size, size);

          float a = j*size+size/2;
          float b = i*size+size/2;
          float s = -3*size/10;
          noStroke();
          fill(0);
          rect(a, b-size/36, size/18, size/4);


          fill(200, 0, 0);
          triangle(a+size/18, b, a+size/18, b+s, a-sqrt(s*s-(s/2.0)*(s/2.0))+size/18, (2.0*b+s)/2.0);


          stroke(0);
          if (m.KEY[i][j] != -1) {
            fill(0);
            line(j*size, i*size, j*size+size, i*size+size);
            line(j*size, i*size+size, j*size+size, i*size);
          }
        }
        fill(0);
        textSize(10);
        text(""+m.MIND[i][j], j*size+size/2-20, i*size+size/2-10);
      }
    }
    //fill(0);
    //textSize(16);
    //text("Mines Left: " + bombsLeft, 0, 16);
  }

  if (MODE == 1 && frameCount % WaitTime == 0 && gameStart && !gameOver) {
    m.nextMove();
  }
}

void mousePressed() {
  int y = mouseY/size;
  int x = mouseX/size;
  if (mouseButton == LEFT) {
    if (!gameStart) {//new board is created to ensure first click is a 0
      gameStart = true;
      m = new Minesweeper(0, 99, 16, 30, y, x);
      bombsLeft = m.BOMBS;
    }
    reveal(y, x);
  }
  if (mouseButton == RIGHT) {//flag or unflag tile
    if (m.BOARD[y][x] == -2 && bombsLeft != 0) {//cannot place flag if space is not unexplored or if all flags are used
      m.BOARD[y][x] = -3;
      bombsLeft--;
    } else if (m.BOARD[y][x] == -3) {//remove flag
      m.BOARD[y][x] = -2;
      bombsLeft++;
    }
  }
}

//reset key is r. The next left click generates a new board
void keyPressed() {
  if (key == 'r') {
    m = new Minesweeper(0, 99, 16, 30, 0, 0);
    gameOver = false;
    gameStart = false;
    bombsLeft = m.BOMBS;
  }
  if (key == 's' && gameStart != true) {
    int startR = (int)(Math.random()*m.ROWS);
    int startC = (int)(Math.random()*m.COLS);
    if (!gameStart) {//new board is created to ensure first click is a 0
      gameStart = true;
      m = new Minesweeper(0, 99, 16, 30, startR, startC);
      bombsLeft = m.BOMBS;
    }
    reveal(startR, startC);
  }
  if (key == 'm') {
    MODE = (MODE + 1) % 2;
  }
  if (key == ' ') {
    m.nextMove();
  }

//for trackpad:
  if (key == 'v') {
    int y = mouseY/size;
    int x = mouseX/size;
    if (m.BOARD[y][x] == -2 && bombsLeft != 0) {//cannot place flag if space is not unexplored or if all flags are used
      m.BOARD[y][x] = -3;
      bombsLeft--;
    } else if (m.BOARD[y][x] == -3) {//remove flag
      m.BOARD[y][x] = -2;
      bombsLeft++;
    }
  }
}

//recursive reveal method. Explores the clicked tile and neighbors of 0 tiles
void reveal(int r, int c) {
  if (m.KEY[r][c] == -1 && m.BOARD[r][c] != -3) {
    m.BOARD[r][c] = -1;
    gameOver = true;
  }
  if (m.BOARD[r][c] == -2) {
    m.BOARD[r][c] = m.KEY[r][c];
    m.MIND[r][c] = m.KEY[r][c];
    if (m.KEY[r][c] == 0) {
      if (onBoard(r-1, c-1)) {
        reveal(r-1, c-1);
      }
      if (onBoard(r, c-1)) {
        reveal(r, c-1);
      }
      if (onBoard(r-1, c)) {
        reveal(r-1, c);
      }
      if (onBoard(r-1, c+1)) {
        reveal(r-1, c+1);
      }
      if (onBoard(r+1, c-1)) {
        reveal(r+1, c-1);
      }
      if (onBoard(r+1, c+1)) {
        reveal(r+1, c+1);
      }
      if (onBoard(r+1, c)) {
        reveal(r+1, c);
      }
      if (onBoard(r, c+1)) {
        reveal(r, c+1);
      }
    }
  }
}

//helper method that checks for out of bounds
boolean onBoard(int r, int c) {
  return r != -1 && r != m.ROWS && c != -1 && c != m.COLS;
}

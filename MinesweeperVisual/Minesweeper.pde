import java.util.*;

public class Minesweeper {

  public final int MODE;
  public final int BOMBS;
  public final int ROWS;
  public final int COLS;
  public final int[][] KEY;
  public final int[][] BOARD;
  public final double[][] MIND;

  public void toStringKEY() {//debug toString method
    for (int i = 0; i < ROWS; i++) {
      System.out.println(Arrays.toString(KEY[i]));
    }
  }

  public Minesweeper () {//default constructor
    this(0, 1, 10, 10, 0, 0);
  }

  public Minesweeper (int m, int b, int r, int c, int y, int x) {//y and x are the row,col of the first revealed tile. Guarenteed to be a 0.
    MODE = m;//mode not yet used
    BOMBS = b;
    ROWS = r;
    COLS = c;
    BOARD = new int[r][c];
    MIND = new double[r][c];
    for (int i = 0; i < r; i++) {
      for (int j = 0; j < c; j++) {
        BOARD[i][j] = -2;
        MIND[i][j] = -2.0;
      }
    }

    KEY = new int[ROWS][COLS]; //-1 for bombs, 0-8** for spaces
    //KEY initialization
    int n = b;
    int k = r*c;

    //bomb generation
    for (int i = 0; i < r; i++) {
      for (int j = 0; j < c; j++) {
        //bombs not generated on the first revealed spot or the 8 tiles adjacent to it.
        if (!(i == y && j == x) && !(i == y-1 && j == x) && !(i == y+1 && j == x) && !(i == y && j == x+1) && !(i == y && j == x-1) && !(i == y-1 && j == x-1) && !(i == y-1 && j == x+1) && !(i == y+1 && j == x+1) && !(i == y+1 && j == x-1)) {
          int p = (int)(Math.random()*k);
          if (p < n) {
            KEY[i][j] = -1;
            n--;
          }
        }
        k--;
      }
    }

    //labeling non-mine tiles with the adjacent mine count.
    for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
        if (KEY[i][j] != -1) {
          int N = 0;
          if (hasBomb(KEY, i-1, j-1)) {
            N++;
          }
          if (hasBomb(KEY, i-1, j)) {
            N++;
          }
          if (hasBomb(KEY, i, j-1)) {
            N++;
          }
          if (hasBomb(KEY, i+1, j+1)) {
            N++;
          }
          if (hasBomb(KEY, i, j+1)) {
            N++;
          }
          if (hasBomb(KEY, i+1, j)) {
            N++;
          }
          if (hasBomb(KEY, i-1, j+1)) {
            N++;
          }
          if (hasBomb(KEY, i+1, j-1)) {
            N++;
          }
          KEY[i][j] = N;
        }
      }
    }
  }
  

  public void nextMove() {
    double maxProb = 0;//this and min are probability of having a bomb [0.0 , 1.0]
    int rowM = 0;
    int colM = 0;
    double minProb = 1;
    int rowm = 0;
    int colm = 0;

    if (bombsLeft != 0) {
      for (int r = 0; r < ROWS; r++) {//update probabilities. -4.0 is probability of 0.0, -5.0 is probability of 1.0     THIS SYSTEM IS TERRIBLE BUT IT WORKS
        for (int c =  0; c < COLS; c++) {
          if (BOARD[r][c] > 0) {
            MIND[r][c] = BOARD[r][c] - adjFlags(r, c);
            double p = MIND[r][c] / adjBlanks(r, c);

            if (valid(r-1, c) && BOARD[r-1][c] < -1 && BOARD[r-1][c] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r-1][c] - 4.5)) {
                  MIND[r-1][c] = -4 - p;
                }
                else if (MIND[r-1][c] == -2) {
                  MIND[r-1][c] = Math.min(MIND[r-1][c], -4 - p);
                }
              } else {
                reveal(r-1, c);
              }
            }

            if (valid(r+1, c) && BOARD[r+1][c] < -1 && BOARD[r+1][c] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r+1][c] - 4.5)) {
                  MIND[r+1][c] = -4 - p;
                }
                else if (MIND[r+1][c] == -2) {
                  MIND[r+1][c] = Math.min(MIND[r+1][c], -4 - p);
                }
              } else {
                reveal(r+1, c);
              }
            }

            if (valid(r, c-1) && BOARD[r][c-1] < -1 && BOARD[r][c-1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r][c-1] - 4.5)) {
                  MIND[r][c-1] = -4 - p;
                }
                else if (MIND[r][c-1] == -2) {
                  MIND[r][c-1] = Math.min(MIND[r][c-1], -4 - p);
                }
              } else {
                reveal(r, c-1);
              }
            }

            if (valid(r, c+1) && BOARD[r][c+1] < -1 && BOARD[r][c+1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r][c+1] - 4.5)) {
                  MIND[r][c+1] = -4 - p;
                }
                else if (MIND[r][c+1] == -2) {
                  MIND[r][c+1] = Math.min(MIND[r][c+1], -4 - p);
                }
              } else {
                reveal(r, c+1);
              }
            }

            if (valid(r-1, c-1) && BOARD[r-1][c-1] < -1 && BOARD[r-1][c-1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r-1][c-1] - 4.5)) {
                  MIND[r-1][c-1] = -4 - p;
                }
                else if (MIND[r-1][c-1] == -2) {
                  MIND[r-1][c-1] = Math.min(MIND[r-1][c-1], -4 - p);
                }
              } else {
                reveal(r-1, c-1);
              }
            }

            if (valid(r-1, c+1) && BOARD[r-1][c+1] < -1 && BOARD[r-1][c+1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r-1][c+1] - 4.5)) {
                  MIND[r-1][c+1] = -4 - p;
                }
                else if (MIND[r-1][c+1] == -2) {
                  MIND[r-1][c+1] = Math.min(MIND[r-1][c+1], -4 - p);
                }
              } else {
                reveal(r-1, c+1);
              }
            }

            if (valid(r+1, c-1) && BOARD[r+1][c-1] < -1 && BOARD[r+1][c-1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r+1][c-1] - 4.5)) {
                  MIND[r+1][c-1] = -4 - p;
                }
                else if (MIND[r+1][c-1] == -2) {
                  MIND[r+1][c-1] = Math.min(MIND[r+1][c-1], -4 - p);
                }
              } else {
                reveal(r+1, c-1);
              }
            }

            if (valid(r+1, c+1) && BOARD[r+1][c+1] < -1 && BOARD[r+1][c+1] != -3) {
              if (MIND[r][c] != 0) {
                if (Math.abs(p-0.5) > Math.abs(-1*MIND[r+1][c+1] - 4.5)) {
                  MIND[r+1][c+1] = -4 - p;
                }
                else if (MIND[r+1][c+1] == -2) {
                  MIND[r+1][c+1] = Math.min(MIND[r+1][c+1], -4 - p);
                }
              } else {
                reveal(r+1, c+1);
              }
            }
          }
        }
      }
      
      //logical deduction here
      

      //find next move
      for (int i = 0; i < ROWS; i++) {
        for (int j =  0; j < COLS; j++) {
          if (MIND[i][j] <= -4.0) {
            double n = Math.abs(MIND[i][j] + 4);
            if (n > maxProb) {
              rowM = i;
              colM = j;
              maxProb = n;
            }
            if (n < minProb) {
              rowm = i;
              colm = j;
              minProb = n;
            }
          }
        }
      }

      if (maxProb - 0.5 >= 0.5 - minProb) {//pick move so probability is furthest from 0.5
        BOARD[rowM][colM] = -3;
        bombsLeft--;
        MIND[rowM][colM] = -1;
      } else {
        reveal(rowm, colm);
      }
    }
  }

//HELPER METHODS

  //helper method that detects mines. Also takes care of bounds.
  private boolean hasBomb(int[][] arr, int r, int c) {
    if (r == -1 || c == -1 || r == arr.length || c == arr[r].length) {
      return false;
    }
    return arr[r][c] == -1;
  }

  private int adjFlags(int r, int c) {
    int ans = 0;
    if (valid(r-1, c) && BOARD[r-1][c] == -3) {
      ans++;
    }
    if (valid(r+1, c) && BOARD[r+1][c] == -3) {
      ans++;
    }
    if (valid(r, c-1) && BOARD[r][c-1] == -3) {
      ans++;
    }
    if (valid(r, c+1) && BOARD[r][c+1] == -3) {
      ans++;
    }
    if (valid(r-1, c-1) && BOARD[r-1][c-1] == -3) {
      ans++;
    }
    if (valid(r-1, c+1) && BOARD[r-1][c+1] == -3) {
      ans++;
    }
    if (valid(r+1, c-1) && BOARD[r+1][c-1] == -3) {
      ans++;
    }
    if (valid(r+1, c+1) && BOARD[r+1][c+1] == -3) {
      ans++;
    }
    return ans;
  }

  private int adjBlanks(int r, int c) {
    int ans = 0;
    if (valid(r-1, c) && BOARD[r-1][c] == -2) {
      ans++;
    }
    if (valid(r+1, c) && BOARD[r+1][c] == -2) {
      ans++;
    }
    if (valid(r, c-1) && BOARD[r][c-1] == -2) {
      ans++;
    }
    if (valid(r, c+1) && BOARD[r][c+1] == -2) {
      ans++;
    }
    if (valid(r-1, c-1) && BOARD[r-1][c-1] == -2) {
      ans++;
    }
    if (valid(r-1, c+1) && BOARD[r-1][c+1] == -2) {
      ans++;
    }
    if (valid(r+1, c-1) && BOARD[r+1][c-1] == -2) {
      ans++;
    }
    if (valid(r+1, c+1) && BOARD[r+1][c+1] == -2) {
      ans++;
    }
    return ans;
  }

  private boolean valid(int r, int c) {
    return !(r == -1 || c == -1 || r == ROWS || c == COLS);
  }
}

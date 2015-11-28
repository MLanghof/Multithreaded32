class Simulator implements Runnable {
    private Thread t;
    private int[][] cellsBuffer;
    private int[][] newCells;
    private int startX, endX;
    private int cellSize;
    public boolean done;
    private int iterationsPerFrame;

    Simulator(int[][] cellsBuffer, int[][] newCells, int startX, int endX, int cellSize, int iterationsPerFrame) {
        this.cellsBuffer = cellsBuffer;
        this.newCells = newCells;
        this.startX = startX;
        this.endX = endX;
        this.cellSize = cellSize;
        this.iterationsPerFrame = iterationsPerFrame;
    }
    public void run() {
        for (int i = 0; i < iterationsPerFrame; i++)
        for (int x = startX; x <= endX; x++) {
            for (int y=0; y<height/cellSize; y++) {
                // And visit all the neighbours of each cell
                int neighbours = 0; // We'll count the neighbours
                for (int xx=x-1; xx<=x+1; xx++) {
                    for (int yy=y-1; yy<=y+1; yy++) {
                        if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
                            if (!((xx == x) && (yy == y))) { // Make sure to to check against self
                                if (cellsBuffer[xx][yy] == 1) {
                                    neighbours ++; // Check alive neighbours and count them
                                }
                            } // End of if
                        } // End of if
                    } // End of yy loop
                } //End of xx loop
                // We've checked the neigbours: apply rules!
                if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
                    if (neighbours < 2 || neighbours > 3) {
                        newCells[x][y] = 0; // Die unless it has 2 or 3 neighbours
                    }
                } else { // The cell is dead: make it live if necessary      
                    if (neighbours == 3 ) {
                        newCells[x][y] = 1; // Only if it has 3 neighbours
                    }
                } // End of if
            } // End of y loop
        }
        done = true;
    }

    public void start()
    {
        if (t == null)
        {
            done = false;
            t = new Thread(this);
            t.start();
        }
    }
}
/**
 * A Processing implementation of Game of Life
 * By Joan Soler-Adillon
 *
 * Press SPACE BAR to pause and change the cell's values with the mouse
 * On pause, click to activate/deactivate cells
 * Press R to randomly reset the cells' grid
 * Press C to clear the cells' grid
 * Press t to toggle threading.
 *
 * The original Game of Life was created by John Conway in 1970.
 */

// Change this to compare threaded vs unthreaded.
boolean threaded = true;

// Give the CPU some actual work to do by (needlessly) repeating the same calculation.
int iterationsPerFrame = 50;

// Size of cells
int cellSize = 5;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 25;

// Colors for active/inactive cells
color alive = color(0, 200, 0);
color dead = color(0);

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

// Pause
boolean pause = false;

void setup() {
    size (1200, 800);

    // Instantiate arrays 
    cells = new int[width/cellSize][height/cellSize];
    cellsBuffer = new int[width/cellSize][height/cellSize];

    // This stroke will draw the background grid
    stroke(48);

    noSmooth();

    frameRate(60);

    // Initialization of cells
    for (int x=0; x<width/cellSize; x++) {
        for (int y=0; y<height/cellSize; y++) {
            float state = random (100);
            if (state > probabilityOfAliveAtStart) { 
                state = 0;
            } else {
                state = 1;
            }
            cells[x][y] = int(state); // Save state of each cell
        }
    }
    background(0); // Fill in black in case cells don't cover all the windows
}


void draw() {
    surface.setTitle("Framerate: " + frameRate);

    stroke(48);
    //Draw grid
    for (int x=0; x<width/cellSize; x++) {
        for (int y=0; y<height/cellSize; y++) {
            if (cells[x][y]==1) {
                fill(alive); // If alive
            } else {
                fill(dead); // If dead
            }
            rect (x*cellSize, y*cellSize, cellSize, cellSize);
        }
    }

    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
        for (int y=0; y<height/cellSize; y++) {
            cellsBuffer[x][y] = cells[x][y];
        }
    }

    if (!pause)
    {
        if (threaded)
            // When threaded, the threads repeat the calculation the correct amount of times themselves.
            iteration();
        else
            for (int i = 0; i < iterationsPerFrame; i++)
                iteration();
    }

    // Create  new cells manually on pause
    if (pause && mousePressed) {
        // Map and avoid out of bound errors
        int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
        xCellOver = constrain(xCellOver, 0, width/cellSize-1);
        int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
        yCellOver = constrain(yCellOver, 0, height/cellSize-1);

        // Check against cells in buffer
        if (cellsBuffer[xCellOver][yCellOver]==1) { // Cell is alive
            cells[xCellOver][yCellOver]=0; // Kill
            fill(dead); // Fill with kill color
        } else { // Cell is dead
            cells[xCellOver][yCellOver]=1; // Make alive
            fill(alive); // Fill alive color
        }
    } else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
        // Save cells to buffer (so we opeate with one array keeping the other intact)
        for (int x=0; x<width/cellSize; x++) {
            for (int y=0; y<height/cellSize; y++) {
                cellsBuffer[x][y] = cells[x][y];
            }
        }
    }

    fill(255);
    textSize(16);
    text("Threading: " + (threaded ? "ON" : "OFF"), 10, 20);
}



void iteration()
{
    if (threaded)
    {
        int maxX = width/cellSize - 1;
        // Start 3 threads to calculate stuff.
        Simulator s1 = new Simulator(cellsBuffer, cells, 0, maxX/3 - 1, cellSize, iterationsPerFrame);
        s1.start();
        Simulator s2 = new Simulator(cellsBuffer, cells, maxX/3, maxX/3*2 - 1, cellSize, iterationsPerFrame);
        s2.start();
        Simulator s3 = new Simulator(cellsBuffer, cells, maxX/3*2, maxX, cellSize, iterationsPerFrame);
        s3.start();

        try {
            // Wait until all threads are done.
            while (!(s1.done && s2.done && s3.done))
                Thread.sleep(1);
        }
        catch (InterruptedException e) {
        }
    } else {
        // Visit each cell:
        for (int x=0; x<width/cellSize; x++) {
            for (int y=0; y<height/cellSize; y++) {
                // And visit all the neighbours of each cell
                int neighbours = 0; // We'll count the neighbours
                for (int xx=x-1; xx<=x+1; xx++) {
                    for (int yy=y-1; yy<=y+1; yy++) {  
                        if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
                            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
                                if (cellsBuffer[xx][yy]==1) {
                                    neighbours ++; // Check alive neighbours and count them
                                }
                            } // End of if
                        } // End of if
                    } // End of yy loop
                } //End of xx loop
                // We've checked the neigbours: apply rules!
                if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
                    if (neighbours < 2 || neighbours > 3) {
                        cells[x][y] = 0; // Die unless it has 2 or 3 neighbours
                    }
                } else { // The cell is dead: make it live if necessary      
                    if (neighbours == 3 ) {
                        cells[x][y] = 1; // Only if it has 3 neighbours
                    }
                } // End of if
            } // End of y loop
        } // End of x loop
    }
} // End of function

void keyPressed() {
    if (key=='r' || key == 'R') {
        // Restart: reinitialization of cells
        for (int x=0; x<width/cellSize; x++) {
            for (int y=0; y<height/cellSize; y++) {
                float state = random (100);
                if (state > probabilityOfAliveAtStart) {
                    state = 0;
                } else {
                    state = 1;
                }
                cells[x][y] = int(state); // Save state of each cell
            }
        }
    }
    if (key==' ') { // On/off of pause
        pause = !pause;
    }
    if (key=='c' || key == 'C') { // Clear all
        for (int x=0; x<width/cellSize; x++) {
            for (int y=0; y<height/cellSize; y++) {
                cells[x][y] = 0; // Save all to zero
            }
        }
    }
    if (key=='t')
        threaded = !threaded;
}
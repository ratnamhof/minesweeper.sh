
# Intro

Minesweeper game implemented in bash. This is a fork of the original version created by [Feherke](#https://github.com/feherke/Bash-script/blob/master/minesweeper/minesweeper.sh), with the changes as described below.

# Changes

The changes with respect to the original version by Feherke:

1. At startup the cursor will be placed in the center of the board i.s.o. the top-left corner. Also, for the visual effect the terminal cursor will be hidden at startup and restored upon exit.
2. The mapping of the new-game keys to board sizes has been inverted (from large to small i.s.o. from small to large). This is simply to make the largest board size more conveniently accessible. This modification has become obsolete after the addition of the next change, but reverting to the original ordering seems unnecessary ...
3. An additional board size has been added: 30x16 with 99 bombs. In many versions of minesweeper this is the layout of the "Expert" level and has a larger bomb density (21%) than the original XL board in this game (30x20 with 90 bombs, bomb density 15%). This makes it more challenging and in many cases not solvable without one or several gambles. This expert board was set as the default layout at startup.
4. The option to create a custom board layout has been added.
5. A key binding has been added to start a new game with the same board layout as the current game. This is mostly useful when playing with custom boards.
6. The original implementation uses a recursive routine to open all connected tiles that do not have any neighbouring bombs when first opening one of those. For the default board layouts this algorithm works perfectly fine. However, with the option to play custom layouts it opens the possibility to create sparse boards (e.g. 70x80 with 10 bombs), for which the recursive routine leads to very long calculation times, very heavy memory usage and possibly even segmentation core dumps. In the current version it has been replaced by a non-recursive routine, reducing the calculation time to the ~1 second order of magnitude for such sparse board layouts, and with low memory usage.
7. Two bugs w.r.t. game play have been fixed. The first bug is that in the original version victory was based only on the number of flags matching the number of bombs. Simply placing flags at random locations would lead to victory when the number of flags reached the number of bombs. In the current implementation there are two victory conditions: firstly when all bombs are flagged without incorrectly placed flags present, or secondly if all tiles without bombs are opened.
8. The second bug fixes the counting of flags. In the original version, if one places an incorrect flag it still counts as a flag even after the tile has been opened up (leading to incorrect victory conditions). In the current implementation, when a tile with an incorrectly placed flag opens it will subtract the flag counter.
9. Many implementations of minesweeper feature the possibility to open all non-flagged neighbouring tiles by pressing some key combination on an opened tile when all neighbouring bombs have been correctly flagged (and without incorrectly flagged tiles present). This option has been added to this version (by pressing the 'step' key ``g`` on an opened tile). This feature can sometimes be abused to identify bomb locations, but it is up to the user to play the game fairly.

# Goal

Identify all bombs by flagging them and/or by opening all tiles without bombs.

# Playing the game

To play the game simply run the script from within a bash shell. The script needs to be executable. For example, assuming the file to be in the current directory ``.``: ``chmod +x minesweeper.sh; ./minesweeper.sh``

The terminal dimensions should be large enough to accommodate the entire board. If not it could lead to incomprehensible results. If this happens during game play, e.g. by re-scaling of the terminal, the board can be redrawn with the keyboard shortcut ``r``.

# Keys

| ACTION                             | PRIMARY | SECONDARY          |
|------------------------------------|---------|--------------------|
| move cursor down/up/left/right     | j/k/h/l | down/up/left/right |
| open tile                          | g       | enter              |
| place flag                         | f       |                    |
| start new E (expert) game          | e       |                    |
| start new XL game                  | n       |                    |
| start new L game                   | N       |                    |
| start new M game                   | m       |                    |
| start new S game                   | M       |                    |
| start new game with current layout | b       |                    |
| start game with custom layout      | c       |                    |
| quit                               | q       |                    |
| redraw screen                      | r       |                    |

# Credits

All credits go to Feherke for creating the original version. Find it at https://github.com/feherke/Bash-script/blob/master/minesweeper/minesweeper.sh


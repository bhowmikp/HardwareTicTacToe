# HardwareTicTacToe

Tic Tac Toe game made for Altera DE2-115 board, using Quartas Prime software and coded in Veilog. The game is played between two players, where they pick their moves by using the switches in the DE2 board. The moves of the players are reflected in the external LEDs which are connected to the GPIO pins on the board. The board can determine the winner and loser of the game, and tracks the number of times they won on the hex display. If the game ends in a draw it displays so in the hex board. The match map can be reset, and the game can be re-started using the push buttons.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

Software and hardware that are needed:

```
Quartas Prime
Altera DE2-115 board
```

### Deployment

Steps needed to set up the board:

```
Attached the DE2-115 board to the computer
Open Quatus Prime
Set pin assignment
Set up LEDs to the GPIO pins of the board
Run Tic Tac Toe code
```

## Demo
![Draw Game](/img/board1.png?raw=true)
![Win Game](/img/board2.png?raw=true)
![Wiring](/img/board3.jpg?raw=true)

## Authors

* **[Harmanraj Singh Wadhwa](https://github.com/hswadhwa)** - *Setting up hardware*
* **Martin Liang** - *Setting up code*
* **[Prantar Bhowmik](https://github.com/bhowmikp)** - *Setting up hardware*
* **Wang Cheney** - *Setting up code*

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

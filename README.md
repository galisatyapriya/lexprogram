# lexprogram
lex based word chain :This project demonstrates the use of Lex, a compiler design tool, to build a Word Chain Game. Lex is used for efficient tokenization, input validation, and state management, showcasing its applications in parsing and pattern matching as part of a compiler design course project.
# Lex-Based Word Chain Game

This project is a lexical analyzer-driven **Word Chain Game** built using **Lex (Flex)** and **C**. It demonstrates how compiler tools can be used to create interactive, real-time applications with proper input parsing, token recognition, and state management.

---

## 🧠 Features

- ✅ Multiple Game Modes:
  - 2-Player Mode
  - Player vs Computer Mode
  - Timer Mode (20 seconds per turn)
- ✅ Dynamic turn handling
- ✅ Dictionary validation for words
- ✅ Duplicate word detection
- ✅ Commands: `pause`, `resume`, `end`
- ✅ Modular Lex + C integration

---

## 🚀 How It Works

- **Lex (Flex)**: Used for pattern matching, token recognition, and state transitions.
- **C Language**: Used to implement core game logic, dictionary handling, turn switching, and timer control.

---

## 📂 File Structure

| File              | Description                           |
|-------------------|---------------------------------------|
| `cd.l`            | Lex source file (input grammar)       |
| `lex.yy.c`        | Generated file from Lex               |
| `dictionary.txt`  | List of valid words                   |
| `README.md`       | Project overview                      |
| `Lex_Word_Chain_Project_Report.pdf` | Final formatted report PDF |

---

## 💻 Running the Project

### Requirements:
- Lex (Flex)
- GCC Compiler
- Windows or Linux (for `conio.h` and `unistd.h` compatibility)

### Steps:

```bash
flex cd.l         # Generates lex.yy.c
gcc lex.yy.c -o word_chain -lfl
./word_chain      # Run the game

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include<windows.h>
#include <conio.h> 


#define TIME_LIMIT 20
#define MAX_WORDS 900

// Game settings
int turn = 1;
int paused = 0;
int game_mode = 0;
time_t start_time;
char *dictionary[MAX_WORDS];
int dict_size = 0;
char last_word[100];
char *used_words[MAX_WORDS];
int used_word_count = 0;

// Function prototypes
void handle_word(char expected_letter, char *word, void (*mode_handler)());
void handle_2player_mode();
void handle_computer_mode();
void handle_timer_mode();
void respond_with_word(char start_char);
void load_dictionary();
int is_word_used(const char *word);
void add_used_word(const char *word);

%}

%option noyywrap

/* Define Lex states */
%x TWO_PLAYER COMPUTER TIMER PAUSED

/* Define word patterns */
word [a-zA-Z]+
whitespace [ \t]+

%%

"2-player mode" {
    if (game_mode != 0) {
        printf("You cannot change modes while the game is active.\n");
    } else {
        printf("2-Player Mode selected.\nUser1 starts.\n");
        game_mode = 1;
        turn = 1;
        BEGIN(TWO_PLAYER);
        printf("Your turn, User1.\n");
    }
}

"computer mode" {
    if (game_mode != 0) {
        printf("You cannot change modes while the game is active.\n");
    } else {
        printf("Computer Mode selected. Enter a word to start.\n");
        game_mode = 2;
        BEGIN(COMPUTER);
        printf("Your turn.\n");
    }
}

"timer mode" {
    if (game_mode != 0) {
        printf("You cannot change modes while the game is active.\n");
    } else {
        printf("Timer Mode selected. You have %d seconds for each turn.\n", TIME_LIMIT);
        start_time = time(NULL);
        game_mode = 3;
        BEGIN(TIMER);
        printf("Your turn.\n");
    }
}

"pause" {
    if (game_mode == 0) {
        printf("The game is not active. You can only pause during an active game.\n");
    } else if (paused) {
        printf("Game is already paused.\n");
    } else {
        printf("Game paused. Type 'resume' to continue.\n");
        paused = 1;
        BEGIN(PAUSED);
    }
}

"resume" {
    if (paused) {
        printf("Resuming the game.\n");
        paused = 0;
        if (game_mode == 1) {
            BEGIN(TWO_PLAYER);
        } else if (game_mode == 2) {
            BEGIN(COMPUTER);
        } else if (game_mode == 3) {
            BEGIN(TIMER);
        }
    } else {
        printf("Game is already running.\n");
    }
}

"end" {
    printf("Game ended. Goodbye!\n");
    exit(0);
}

<TWO_PLAYER>{word} { handle_word(last_word[0] ? last_word[strlen(last_word) - 1] : 'A', yytext, handle_2player_mode); }
<COMPUTER>{word} { handle_word(last_word[0] ? last_word[strlen(last_word) - 1] : 'A', yytext, handle_computer_mode); }
<TIMER>{word} { handle_word(last_word[0] ? last_word[strlen(last_word) - 1] : 'A', yytext, handle_timer_mode); }

{whitespace} { /* Ignore whitespaces */ }

%%

void handle_word(char expected_letter, char *word, void (*mode_handler)()) {
    // Handle the pause command immediately, no matter the state of the game
    if (strcasecmp(word, "pause") == 0) {
        if (paused) {
            printf("Game is already paused.\n");
        } else {
            printf("Game paused. Type 'resume' to continue.\n");
            paused = 1;  // Set the game to paused
        }
        return; // Stop processing further when "pause" is entered
    }

    // Handle the resume command immediately when paused
    if (strcasecmp(word, "resume") == 0) {
        if (!paused) {
            printf("Game is already running.\n");
        } else {
            printf("Game resumed. You can now enter a word.\n");
            paused = 0; // Unpause the game

            // Switch to the appropriate mode after resuming
            if (game_mode == 1) {
                printf("Switching to 2-Player Mode.\n");
                mode_handler();
            } else if (game_mode == 2) {
                printf("Switching to Computer Mode.\n");
                mode_handler();
            } else if (game_mode == 3) {
                printf("Switching to Timer Mode.\n");
                mode_handler();
            }
        }
        return; // Stop processing further when "resume" is entered
    }


    if (strcasecmp(word, "end") == 0) {
        printf("Game ended. Goodbye!\n");
        exit(0); // Terminate the game when "end" is typed
    }



    char first_letter = toupper(word[0]);


    if (expected_letter != '\0' && first_letter != toupper(expected_letter)) {
        printf("Invalid word! Must start with '%c'.\n", expected_letter);
        printf("Game over! %s wins!\n", turn == 1 ? "User2" : "User1");
        exit(0);
    }

    // Check if the word is already used
    if (is_word_used(word)) {
        printf("The word '%s' has already been used. Write a new word.\n", word);
        return;
    }

    // Check if the word exists in the dictionary
    int valid_in_dict = 0;
    for (int i = 0; i < dict_size; i++) {
        if (strcasecmp(dictionary[i], word) == 0) {
            valid_in_dict = 1;
            break;
        }
    }

    if (!valid_in_dict) {
        printf("The word '%s' is not in the dictionary.\n", word);
        printf("Game over! %s wins!\n", turn == 1 ? "Computer" : "User1");
        exit(0);
    }

    printf("Valid word! '%s' accepted.\n", word);
    add_used_word(word); // Add the word to the used words list
    strcpy(last_word, word); // Update the last word

    mode_handler(); // Handle turn switching
}


void handle_2player_mode() {
    turn = (turn == 1) ? 2 : 1;
    printf("User%d's turn.\n", turn);
}

void handle_computer_mode() {
    if (turn == 1) {
        turn = 2;
        printf("Computer's turn.\n");
        respond_with_word(last_word[strlen(last_word) - 1]);  // Pass last letter of user's word
    } else {
        turn = 1;
        printf("Your turn.\n");
    }
}



void handle_timer_mode() {
    time_t current_time;
    int time_left;
    char input[100];

    // Reset the timer for the current player to start with 20 seconds
    start_time = time(NULL);  // Initialize the start time for the first player

    // Loop to handle the timer and game turns until one player wins
    while (1) {
        // Get the current time
        current_time = time(NULL);

        // Calculate remaining time for the current turn
        time_left = TIME_LIMIT - (int)difftime(current_time, start_time);

        // Check if time limit exceeded
        if (time_left <= 0) {
            printf("\nTime limit exceeded! Game over.\n");

            // Declare the winner (the other player wins)
            if (turn == 1) {
                printf("User2 wins!\n");
            } else {
                printf("User1 wins!\n");
            }

            exit(0);
        }

        // Display time remaining on the same line (overwriting previous output)
        printf("\rTime left: %d seconds  ", time_left);
        fflush(stdout); // Ensure the output is updated immediately

        // Check if the user has pressed a key
        if (_kbhit()) {
            // Read the input from the user
            fgets(input, sizeof(input), stdin);
            input[strcspn(input, "\n")] = '\0';  // Remove the newline character

            // Display the entered word
            printf("\nYou entered: %s\n", input);

            // Check if the word is valid (starting with the correct letter, etc.)
            handle_word(last_word[0] ? last_word[strlen(last_word) - 1] : 'A', input, handle_timer_mode);

            // Reset the timer for the next player
            start_time = time(NULL); // Reset the timer for the next player's turn

            // Switch turns
            turn = (turn == 1) ? 2 : 1;
            printf("User%d's turn.\n", turn);

            // Continue to the next player's turn
            return;
        }

        // Wait for 1 second before updating the time display
        Sleep(1000);
    }
}

void respond_with_word(char start_char) {
    int found = 0;
    for (int i = 0; i < dict_size; i++) {
        if (tolower(dictionary[i][0]) == tolower(start_char) && !is_word_used(dictionary[i])) {
            printf("Computer plays: %s\n", dictionary[i]);
            strcpy(last_word, dictionary[i]);
            add_used_word(dictionary[i]); // Add the computer's word to the used words list
            found = 1;
            turn = 1; // Switch turn back to user after computer plays
            break;
        }
    }
    if (!found) {
        printf("No valid word found for '%c'. You win!\n", start_char); // Declare the player as the winner
        exit(0);
    }
}

int is_word_used(const char *word) {
    for (int i = 0; i < used_word_count; i++) {
        if (strcasecmp(used_words[i], word) == 0) {
            return 1;
        }
    }
    return 0;
}

void add_used_word(const char *word) {
    if (used_word_count < MAX_WORDS) {
        used_words[used_word_count++] = strdup(word);
    } else {
        printf("Error: Used words list is full.\n");
        exit(1);
    }
}

void load_dictionary() {
    FILE *file = fopen("dictionary.txt", "r");
    if (!file) {
        printf("Error loading dictionary.\n");
        exit(1);
    }

    char buffer[100];
    while (fgets(buffer, sizeof(buffer), file)) {
        // Remove the newline character
        buffer[strcspn(buffer, "\n")] = '\0';  
        
        // Check if we have room to add more words
        if (dict_size >= MAX_WORDS) {
            printf("Warning: Dictionary is too large, stopping at %d words.\n", MAX_WORDS);
            break;
        }

        // Dynamically allocate memory for the word and add it to the dictionary
        dictionary[dict_size] = strdup(buffer);  
        if (dictionary[dict_size] == NULL) {
            printf("Memory allocation failed for word: %s\n", buffer);
            exit(1);
        }
        dict_size++;  // Increment the dictionary size
    }
    
    fclose(file);
}

int main() {
    printf("Welcome to the Word Chain Game!\nSelect a mode: '2-player mode', 'computer mode', 'timer mode', 'pause', 'resume', or 'end' to quit.\n");

    load_dictionary();
    yylex();

    for (int i = 0; i < dict_size; i++) free(dictionary[i]);
    for (int i = 0; i < used_word_count; i++) free(used_words[i]);
    return 0;
}
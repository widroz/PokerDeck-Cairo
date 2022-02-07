# PokerDeck-Cairo

This code generates a shuffled Poker Deck. After that, drawNCards(deck, number_of_cards) function can be called to draw.

##

##Brief explanation
First, an ordered deck is built. Then a shuffle is made to get a _random_ order deck which has exactly 1 copy of each card from the ordered deck.
Then, a pointer to set the next available draw from deck is set to point the card on top and finally we can draw.

#Some details

##Cards
A Card is a struct which has two members: number and suit.
Number can go from 0 to 12 (2,3,4,5,6,7,8,9,10,J,Q,K,A are 13 cards)
Suit can go from 0 to 3 (Clubs, Spades, Diamonds, Herts are 4 suits)

##Deck
A Deck is a struct which contains a list of cards and a draw pointer, which contains the address of the following Card which is legal
to draw.

##Shuffle
Shuffle is obtained by applying Fisher-Yates shuffle algorithm (with some auxiliar functions, since Cairo memory is immutable).

##Pseudorandom Generation
Pseudorandom number generation is achieved by implementing a Linear Congruential Generetor with mod 'm' = 22695477, increment 'c' = 1 and multiplier 'a' = 2^32
I have decided to use LCGs since they are implemented in many languages (like C) for rand() functions.

#Motivation
This project is my introduction to Cairo language. The goal was practicing some of the technical aspects such as references, variables, memory, sintax, structs, recursion, implicit args...
With some modifications this could be the base of a simple Poker Game.

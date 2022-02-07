%builtins output range_check
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_nn_le,assert_not_equal,assert_in_range,assert_nn,unsigned_div_rem
from starkware.cairo.common.registers import get_fp_and_pc

struct Card:
    member number : felt
    member suit : felt
end

struct Deck:
    member cards : Card*
    member last_index : felt
end

func assertLegalCard{range_check_ptr}(card : Card):
    assert_in_range(card.number,0,13) 
    assert_in_range(card.suit,0,4)
    return()
end

func addToOrderedDeck{range_check_ptr}(card : Card, deck : Card*):
    #Assert address is unique for each tuple(suit,number) so that no cards can be repeated.
    #Since address is number + (suit * 13) and 0<=number<=12 and 0<=suit<=3: address can onlye be an integer in [0,51]
    
    let address = card.number + (card.suit * 13)
    assert address = card.number + (card.suit * 13)
    assert deck[address] = card   #Assert that card is placed in the correct way in the card list
    return ()
end

func fillOrderedDeck{range_check_ptr}(deck : Card*, card : Card):
    alloc_locals
    addToOrderedDeck(card, deck) #We add a card
    
    if card.number == 12:
        if card.suit == 3:
            return () #if last card was added, we end
            
    #else we do the same with the next card
        else:
            local c : Card = Card(number=0, suit=card.suit + 1) 
            fillOrderedDeck(deck, c) 
        end
    else: 
        local c2 : Card = Card(number=card.number + 1, suit=card.suit)
        fillOrderedDeck(deck, c2)
    end

    return ()
end


func drawNCards{output_ptr : felt*,range_check_ptr}(deck : Deck, number_of_cards : felt):
    alloc_locals
    assert_nn(number_of_cards)
    assert_nn(deck.last_index+1) #Assert there's at least 1 card in deck
    
    #If there are still draws to perform
    if number_of_cards * number_of_cards != 0:
        #Assert that card drawn is the one that is pointed as valid draw
        local candidate_card : Card = deck.cards[deck.last_index]
        assert candidate_card = deck.cards[deck.last_index]
        
        #Assert the deck after extraction will point to the next card available after the one drawn.
        local deck_after_extraction : Deck = Deck(cards = deck.cards, last_index = deck.last_index-1)
        assert deck_after_extraction = Deck(cards = deck.cards, last_index = deck.last_index-1) 
        #in case for some reason you want to keep drawing after calling this function, 
        #you should return the final deck after extraction and keep drawing there
        
        #show output
        serialize_word(candidate_card.number)
        serialize_word(candidate_card.suit)

        tempvar output_ptr : felt* = output_ptr 
        tempvar range_check_ptr : felt = range_check_ptr 
        
        drawNCards(deck = deck_after_extraction, number_of_cards = number_of_cards -1) #Recursive call to draw next card
    else:
    
    tempvar output_ptr : felt* = output_ptr
    tempvar range_check_ptr : felt = range_check_ptr
    end
    
    return()
end

func nextRandomGLC{range_check_ptr}(seed : felt)->(output_seed : felt):
    let a =22694577
    let m = 2**32
    let (_,remainder) = unsigned_div_rem((a*seed +1),m)
    return(output_seed = remainder)
end


func delete(ordered_deck : Card*,new_ordered_deck : Card*, k : felt, initial_size : felt):
    #To delete a card in position k from a list of cards
    alloc_locals
    #copy list until k
    copyUntilCard(ordered_deck,new_ordered_deck,k,initial_size)
    #copy from k to end the with index offset +1
    delete_aux(ordered_deck,new_ordered_deck,k,initial_size)
    return()
end

func delete_aux(ordered_deck : Card*,new_ordered_deck : Card*, k : felt, initial_size : felt):
    if k != initial_size-1:
    assert new_ordered_deck[k] = ordered_deck[k+1]
    delete_aux(ordered_deck, new_ordered_deck,k+1,initial_size)
    end
    return()
end

func copyUntilCard(ordered_deck : Card*,new_ordered_deck : Card*, k : felt, initial_size : felt):
    if k*k != 0:
    assert new_ordered_deck[k-1] = ordered_deck[k-1]
    copyUntilCard(ordered_deck,new_ordered_deck,k-1,initial_size)
    end
    return()
end


func shuffle{range_check_ptr}(seed: felt, ordered_deck : Card*, shuffled_deck : Card*, k : felt):
    alloc_locals
    
    if k!=0:
    let new_seed : felt = nextRandomGLC(seed)
    let (_,reduced_seed) = unsigned_div_rem(new_seed,k)
    assert shuffled_deck[k-1] = ordered_deck[reduced_seed]
    
    let (local aux_deck : Card*) = alloc()
    delete(ordered_deck, aux_deck,reduced_seed,k)
    shuffle(new_seed,aux_deck,shuffled_deck,k-1)
    tempvar range_check_ptr = range_check_ptr
    else:
    tempvar range_check_ptr = range_check_ptr
    end
    
    return()
end


func main{output_ptr : felt*,range_check_ptr}():

    alloc_locals 
    
    let initial_card : Card = Card(number = 0, suit = 0)
    assert initial_card = Card(number = 0, suit = 0) #Assert that the first card of an ordered deck is n=0,s=0 ('2' of suit 0)
    
    #Create ordered_deck
    let(local ordered_cards : Card*) = alloc() #Initial empty list of cards
    fillOrderedDeck(deck = ordered_cards, card = initial_card) #Assert that the list of cards contains all legal poker cards only once in its legal position and no illegal cards have been added
    
    #Create random_deck (empty)
    let(local random_cards : Card*) = alloc()

    #Assert cards in random_cards by shuffling ordered_cards
    shuffle(233,ordered_cards,random_cards,52)
    
    
    #Assert a deck with random cards and no draws performed
    let deck : Deck = Deck(cards = random_cards, last_index = 51) 
    assert  deck = Deck(cards = random_cards, last_index = 51) #Assert that this deck is an ordered deck with no draws performed, which means the next draw available is the last card [51]
    

    #Draw any number of cards
    drawNCards(deck,1)

    

    return ()
end

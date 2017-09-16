# Blackjack (version without hookers)

import simplegui
import random

CARD_SIZE = (72, 96)
CARD_CENTER = (36, 48)
card_images = simplegui.load_image("http://storage.googleapis.com/codeskulptor-assets/cards_jfitz.png")

CARD_BACK_SIZE = (72, 96)
CARD_BACK_CENTER = (36, 48)
card_back = simplegui.load_image("http://storage.googleapis.com/codeskulptor-assets/card_jfitz_back.png")    

# initialize some useful global variables
in_play = False
outcome = "New deal?"
score = 0
deck = []
player_hand = []
dealer_hand = []

# define globals for cards
SUITS = ('C', 'S', 'H', 'D')
RANKS = ('A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K')
VALUES = {'A':1, '2':2, '3':3, '4':4, '5':5, '6':6, '7':7, '8':8, '9':9, 'T':10, 'J':10, 'Q':10, 'K':10}


# define card class
class Card:
    def __init__(self, suit, rank):
        if (suit in SUITS) and (rank in RANKS):
            self.suit = suit
            self.rank = rank
        else:
            self.suit = None
            self.rank = None
            print "Invalid card: ", suit, rank

    def __str__(self):
        return self.suit + self.rank

    def get_suit(self):
        return self.suit

    def get_rank(self):
        return self.rank

    def draw(self, canvas, pos):
        card_loc = (CARD_CENTER[0] + CARD_SIZE[0] * RANKS.index(self.rank), 
                    CARD_CENTER[1] + CARD_SIZE[1] * SUITS.index(self.suit))
        canvas.draw_image(card_images, card_loc, CARD_SIZE, [pos[0] + CARD_CENTER[0], pos[1] + CARD_CENTER[1]], CARD_SIZE)
        
# define hand class
class Hand:
    def __init__(self):
        self.hand = []

    def __str__(self):
        tx = "Hand contains: "
        for i in range(len(self.hand)):
            tx += str(self.hand[i]) + " "
        return tx

    def add_card(self, card):
        self.hand.append(card)

    def get_value(self):
        hand_value = 0
        for card in self.hand:
            hand_value += VALUES[card.rank]
        for card in self.hand:
            if card.rank == "A":
                if (hand_value + 10) <= 21:
                    hand_value += 10
                    return hand_value
        return hand_value
   
    def draw(self, canvas, pos):
        for card in self.hand:
            card.draw(canvas, pos)
            pos[0] += 92
        
# define deck class 
class Deck:
    
    def __init__(self):
        self.deck = []
        for i in SUITS:
            for j in RANKS:
                self.deck.append(Card(i,j))

    def shuffle(self):
        random.shuffle(self.deck)

    def deal_card(self):
        return self.deck.pop(-1)
    
    def __str__(self):
        tx = "Deck contains: "
        for i in self.deck:
            tx += str(i) + " " 
        return tx

#event handlers for buttons
def deal():
    global outcome, in_play, deck, player_hand, dealer_hand, score
    deck = Deck()
    deck.shuffle()
    outcome = "Hit or stand?"
    if in_play:
        outcome = "Dealer wins"
        score -= 1
    pcard1 = deck.deal_card()
    player_hand = Hand()
    player_hand.add_card(pcard1)
    pcard2 = deck.deal_card()
    player_hand.add_card(pcard2)
    dcard1 = deck.deal_card()
    dealer_hand = Hand()
    dealer_hand.add_card(dcard1)
    dcard2 = deck.deal_card()
    dealer_hand.add_card(dcard2)
    in_play = True
    

def hit():
    global player_hand, score, in_play, outcome
    if in_play:
        player_hand.add_card(deck.deal_card())
    if player_hand.get_value() > 21:
        in_play = False
        outcome = "You have busted  New deal?"
        score -= 1
       
def stand():
    global player_hand, dealer_hand, score, in_play, outcome
    if player_hand.get_value() > 21:
        in_play = False
        outcome = "You have busted  New deal?"
    while dealer_hand.get_value() < 17:
        dealer_hand.add_card(deck.deal_card())
        if dealer_hand.get_value() > 21:
            in_play = False
            outcome = "Dealer has busted  New deal?"
            score += 1
    if (player_hand.get_value() <= dealer_hand.get_value()) and in_play:
        outcome = "Dealer wins  New deal?"
        score -= 1
        in_play = False
    else:
        if in_play:
            outcome = "Player wins  New deal?"
            score += 1
            in_play = False
            
# draw handler    
def draw(canvas):
    global outcome, in_play, CARD_BACK_SIZE, CARD_BACK_CENTER
    player_hand.draw(canvas, [40, 300])       
    dealer_hand.draw(canvas, [40, 450])
    if in_play:
        canvas.draw_image(card_back, CARD_BACK_CENTER, CARD_BACK_SIZE, [40 + CARD_BACK_CENTER[0], 450 + CARD_BACK_CENTER[1]], CARD_BACK_SIZE)        
    canvas.draw_text("BLACKJACK", (30, 100), 55, "Red")
    canvas.draw_text(outcome, (100, 200), 35, "Black")
    canvas.draw_text("Player", (40, 290), 30, "Blue")
    canvas.draw_text("Dealer", (40, 440), 30, "Blue")
    canvas.draw_text("Score: "+str(score), (400, 100), 35, "Yellow")

# initialization frame
frame = simplegui.create_frame("Blackjack", 600, 600)
frame.set_canvas_background("Green")

#create buttons and canvas callback
frame.add_button("Deal", deal, 200)
frame.add_button("Hit",  hit, 200)
frame.add_button("Stand", stand, 200)
frame.set_draw_handler(draw)

# get things rolling
deal()
frame.start()

SMODS.Atlas {
  key = "DragonsDogma",
  path = "dogma.png",
  px = 71,
  py = 95
}

SMODS.Joker {
  key = "dragonsdogmajoker",
  loc_txt = {
    name = "Dragon's Dogma",
    text = {
      "Destroys played {C:red}hearts{}.", 
      "When removed, returns these",
      "{C:red}hearts{} to your hand",
      "with {C:red}red seals{}.",
      "{C:inactive}(Currently has {C:attention}#1#{C:inactive} hearts)"
    }
  },
  blueprint_compat = false,
  eternal_compat = true,
  loc_vars = function(self, info_queue, card)
    if card ~= nil then
  		return { vars = {#card.ability.extra.stored_cards} }
    else
      return { vars = {0} }
    end
	end,
  rarity = 3,
  atlas = "DragonsDogma",
  pos = { x= 0, y = 0 },
  cost = 10,
  discovered = true,
  unlocked = true,
  -- Card config (stores cards)
  config = {
    extra = {
      stored_cards = {}
    }
  },
  -- todo crashes when ankhed if it has cards copied. Need to either:
  -- o prevent Ankh altogether (not sure how)
  -- o copy all stored cards so that each copy has its own set
  -- o copy but do not transfer the stored cards
  -- When removed from deck, return destroyed hearts
  remove_from_deck = function(self, card, from_debuff)
    -- todo any other states that must be excluded?
    -- not: not state 4 (GAME_OVER) to prevent this causing a crash on exit after failed run
    if not from_debuff and G.STATE ~= 4 then
      for _, v in ipairs(card.ability.extra.stored_cards) do
        -- Copied from DNA
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = copy_card(v, nil, nil, G.playing_card)
        _card:set_seal('Red', true)
        _card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, _card)
        -- todo this should probably be tested more extensively to make sure it works:
        -- should add to hand if we are currently in a blind
        -- add to deck otherwise
        if G.STATE < 4 or G.STATE == 19 then
          G.hand:emplace(_card)
        else
          G.deck:emplace(_card)
        end
        _card.states.visible = nil

        G.E_MANAGER:add_event(Event({
          func = function()
              _card:start_materialize()
              return true
          end
        })) 
    end
  end
end,
  -- Scoring calculation
  calculate = function(self, card, context)
    if context.destroy_card and context.cardarea == G.play and not context.blueprint then
      if context.destroy_card:is_suit('Hearts') then
        card.ability.extra.stored_cards[#card.ability.extra.stored_cards + 1] = context.destroy_card
        return {
          message = "Arisen!",
          remove = true
        }
      end
    end
  end
}

-- 1EIM3G3H (shop 1 first joker pack)
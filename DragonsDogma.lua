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
      "Destroys played {C:mult}hearts{}.", 
      "When destroyed, returns these",
      "{C:mult}hearts{} to your hand."
    }
  },
  rarity = 1,
  atlas = "DragonsDogma",
  pos = { x= 0, y = 0 },
  cost = 0,
  discovered = true,
  unlocked = true,
  -- Card config (stores cards)
  config = {
    extra = {
      stored_cards = {}
    }
  },
  -- When removed from deck, return destroyed hearts
  remove_from_deck = function(self, card, from_debuff)
    -- todo test that this works the way I expect
    -- not: not state 4 (GAME_OVER) to prevent this causing a crash on exit after failed run
    if not from_debuff and G.STATE ~= 4 then
      for _, v in ipairs(card.ability.extra.stored_cards) do
        -- Copied from DNA
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = copy_card(v, nil, nil, G.playing_card)
        _card:add_to_deck()
        G.deck.config.card_limit = G.deck.config.card_limit + 1
        table.insert(G.playing_cards, _card)
        -- todo this should probably be tested more extensively
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
          message = "Thou'rt Arisen, charge and all",
          remove = true
        }
      end
    end
  end
}

-- 1EIM3G3H (jokur pak)
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
      "Destroys scored {C:red}hearts{}.", 
      "When removed, returns",
      "these {C:red}hearts{} to your",
      "hand with {C:red}red seals{}.",
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
  unlocked = true,
  -- Card config (stores cards)
  config = {
    extra = {
      stored_cards = {}
    }
  },
  -- When removed from deck, return destroyed hearts
  remove_from_deck = function(self, card, from_debuff)
    -- not: not state 4 (GAME_OVER) to prevent this causing a crash on exit after failed run
    if not from_debuff and G.STATE ~= 4 then
      -- determine where to put the cards that are being added back
      local _area = G.deck
      if G.STATE < 4 or G.STATE == 19 then
        _area = G.hand
      end
      for _, v in ipairs(card.ability.extra.stored_cards) do
        -- doesn't seem that there's a better way to get this string
        local _rank = v.id
        if _rank == 14 then
          _rank = 'A'
        elseif _rank == 13 then
          _rank = 'K'
        elseif _rank == 12 then
          _rank = 'Q'
        elseif _rank == 11 then
          _rank = 'J'
        elseif _rank == 10 then
          _rank = 'T'
        end

        -- I have no idea what this line is really for
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        -- create a card that should be equivalent to the one that was stored
        local card_init = {
          front = G.P_CARDS['H'..'_'.._rank]
        }
        local _card = create_playing_card(card_init, _area, nil, nil, {G.C.SET.Default})
        _card:set_seal('Red', true)
        _card:set_edition(v.edition, nil, nil)
        _card.ability.perma_bonus = v.perma_bonus
    end
  end
end,
  -- Scoring calculation
  calculate = function(self, card, context)
    if context.destroy_card and context.cardarea == G.play and not context.blueprint then
      if context.destroy_card:is_suit('Hearts') then
        -- store enough info here to re-create the card later
        card.ability.extra.stored_cards[#card.ability.extra.stored_cards + 1] = {
          id = context.destroy_card:get_id(),
          center = context.destroy_card.center,
          edition = context.destroy_card.edition,
          perma_bonus = context.destroy_card.ability.perma_bonus or 0
        }
        -- animate oneself
        -- card:juice_up()
        G.E_MANAGER:add_event(Event({
          func = function()
            card:juice_up()
            return true
          end
        }))
        return {
          message = "Arisen!",
          remove = true
        }
      end
    end
  end
}

--Pretender Crowley
local s,id=GetID()
function s.initial_effect(c)
	-- 1 "Prophecy" monster
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,{SET_PROPHECY}),1,1)
	-- Add 1 "Spelbook of Judgment" from your Deck or GY to your hand
	local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,0))
		e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e0:SetCode(EVENT_SPSUMMON_SUCCESS)
		e0:SetCountLimit(1,{id,0})
		e0:SetCondition(s.spcon)
		e0:SetCost(s.thcost)
		e0:SetTarget(s.thtg)
		e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	-- Activate this effect during your Main Phase
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,{id,1})
		e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

end

s.listed_series={SET_SPELLBOOK,SET_PROPHECY}
s.listed_names={46448938}

-- Effect 1
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c)
	return c:IsCode(46448938) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect 2
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- Set up to 3 "Spellbook" Spell Cards from your hand during the End Phase
	local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCountLimit(1)
		e2:SetTargetRange(1,0)
		e2:SetLabel(tp)
		e2:SetCondition(s.setcon)
		e2:SetTarget(s.settg)
		e2:SetOperation(s.setop)
		e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==e:GetLabel()
end
function s.setfilter(c)
	return c:IsSpell() and c:IsSetCard(SET_SPELLBOOK) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabel()

	for i=1,3 do
		-- Check available Spell/Trap Zones
		if Duel.GetLocationCount(p,LOCATION_SZONE)<=0 then
			break
		end

		-- Check if there is still a valid "Spellbook" Spell in hand
		if not Duel.IsExistingMatchingCard(s.setfilter,p,LOCATION_HAND,0,1,nil) then
			break
		end

		-- Check if you want set a card
		if not Duel.SelectYesNo(p,aux.Stringid(id,0)) then
			break
		end

		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SET)

		local g=Duel.SelectMatchingCard(p,s.setfilter,p,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if not tc then
			break
		end
		Duel.SSet(p,tc)
	end
end
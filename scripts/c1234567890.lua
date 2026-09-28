--Merlin, the Last Prophesser
local s,id=GetID()

function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	--2+ monsters, including an "Prophecy" monster
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	--Increase ATK
	local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_UPDATE_ATTACK)
		e0:SetRange(LOCATION_MZONE)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(function(e,c) return c:IsSetCard(SET_PROPHECY) end)
		e0:SetValue(s.atkval)
	c:RegisterEffect(e0)
	--Banish 1 Spellbook, send a card to GY
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOGRAVE)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1,{id,1})
		e1:SetCost(s.effcost)
		e1:SetTarget(s.efftg)
		e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Place "The Grand Spellbook Tower" in your Field Zone
	local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1,{id,2})
		e2:SetTarget(s.pltg)
		e2:SetOperation(s.plop)
	c:RegisterEffect(e2)

end

s.listed_series={SET_SPELLBOOK,SET_PROPHECY}
s.listed_names={33981008}

--Effect 1
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_PROPHECY,lc,sumtype,tp)
end
function s.valfilter(c)
	return c:IsSetCard(SET_SPELLBOOK) and c:IsSpell()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.valfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end

--Effect 2
function s.cfilter(c)
	return c:IsSetCard(SET_SPELLBOOK) and c:IsSpell() and c:IsAbleToRemoveAsCost()
end
function s.efffilter(c)
	return c:IsOnField() and c:IsAbleToGrave()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 
		then 
			return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) 
		end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc 
		then 
			return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToGrave()
		end
	if chk==0 
		then 
			return Duel.IsExistingTarget(s.efffilter,tp,0,LOCATION_ONFIELD,1,nil)
		end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.efffilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end

--Effect 3
function s.plfilter(c)
	return c:IsCode(33981008)
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
	end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
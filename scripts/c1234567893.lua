--Loyalty of Prophecy
local s,id=GetID()
function c1234567893.initial_effect(c)
	local e0=Effect.CreateEffect(c)
		--Special Summon from hand
        e0:SetDescription(aux.Stringid(id,0))
        e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e0:SetType(EFFECT_TYPE_QUICK_O)
        e0:SetCode(EVENT_FREE_CHAIN)
        e0:SetRange(LOCATION_HAND)
        e0:SetCountLimit(1,{id,0})
        e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
        e0:SetCondition(function() return Duel.IsMainPhase() end)
        e0:SetCost(s.spcost)
        e0:SetTarget(s.sptg)
        e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Activate one of these effects
    local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
        e1:SetCode(EVENT_SUMMON_SUCCESS)
        e1:SetProperty(EFFECT_FLAG_DELAY)
        e1:SetCountLimit(1,{id,1})
        e1:SetTarget(s.efftg)
        e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Special Summon Trigger
    local e2=e1:Clone()
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

s.listed_series={SET_SPELLBOOK,SET_PROPHECY}

--Effect 1
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

--Effect 2
function s.thfilter(c)
	return c:IsSetCard(SET_PROPHECY) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.costfilter(c)
	return c:IsSetCard(SET_SPELLBOOK) and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function s.mfilter(c)
	return c:IsFaceup() and c:IsMonster()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) 
    and Duel.IsExistingMatchingCard(s.mfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local op
	if b1 and b2 then
		op=Duel.SelectOption(tp,
			aux.Stringid(id,0),
			aux.Stringid(id,1))
	elseif b1 then
		op=0
	else
		op=1
	end

	e:SetLabel(op)

	if op==0 then
        e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	else
        -- Banish 1 "Spellbook" Spell
        e:SetCategory(CATEGORY_DESTROY)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_MZONE)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
        -- Add 1 "Prophecy" Monster from your Deck or GY
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	else
		-- Find the opponent's monster with the lowest ATK
		local mg=Duel.GetMatchingGroup(s.mfilter,tp,0,LOCATION_MZONE,nil)
		if #mg==0 then return end
		local minatk=math.huge
		for tc in aux.Next(mg) do
			if tc:GetAttack()<minatk then
				minatk=tc:GetAttack()
			end
		end
		local dg=mg:Filter(function(tc)
			return tc:GetAttack()==minatk
		end,nil)
		local dc=dg:Select(tp,1,1,nil)
		Duel.Destroy(dc,REASON_EFFECT)
	end
end
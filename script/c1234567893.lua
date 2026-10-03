--Loyalty of Prophecy
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon
	local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetCode(EFFECT_SPSUMMON_PROC)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e0:SetRange(LOCATION_HAND)
		e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
		e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	-- Add 1 "Prophecy" monster
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SUMMON)
		e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCountLimit(1,{id,1})
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Special Summon Trigger
	local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end

s.listed_series={SET_PROPHECY}

-- Special Summon Condition
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),c:GetControler(),LOCATION_MZONE,0,1,nil)
end

-- Effect 1
function s.thfilter(c)
	return c:IsSetCard(SET_PROPHECY) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)

	if #g==0 then return end

	local tc=g:GetFirst()

	if Duel.SendtoHand(tc,nil,REASON_EFFECT)<=0 then
		return
	end

	-- The card must actually be in the hand
	if not tc:IsLocation(LOCATION_HAND) then
		return
	end

	-- Can Special Summon this monster
	local can_sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)

	-- Can Normal Summon this monster
	local can_ns=tc:IsLevelBelow(5)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc:IsSummonable(true,nil)

	if not can_sp and not can_ns then
		return
	end

	local op

	if can_ns then
		op=Duel.SelectOption(
			tp,
			aux.Stringid(id,0), -- Special Summon
			aux.Stringid(id,1), -- Normal Summon
			aux.Stringid(id,2)  -- Don't Summon
		)
	else
		op=Duel.SelectOption(
			tp,
			aux.Stringid(id,0), -- Special Summon
			aux.Stringid(id,2)  -- Don't Summon
		)
	end

	-- Immediately after this effect resolves
	Duel.BreakEffect()

	if op==0 then
		-- Special Summon the monster that was added
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif op==1 and can_ns then
		-- Normal Summon the monster that was added
		Duel.Summon(tp,tc,true,nil)
	elseif op==1 and not can_ns then
		-- Don't Summon the added monster
		return
	elseif op==2 then
		-- Don't Summon the added monster
		return
	end
end
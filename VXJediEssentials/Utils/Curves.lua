-- VXJediEssentials namespace
---@class AE
local AE = select(2, ...)
AE.curves = {}

-- Module credit fully to p3lim

-- if the duration is < 3 seconds then we want 1 decimal point, otherwise 0
-- offset this by 0.2 because of weird calculation timings making it flash 1.x
AE.curves.DurationDecimals = C_CurveUtil.CreateCurve()
AE.curves.DurationDecimals:SetType(Enum.LuaCurveType.Step)
AE.curves.DurationDecimals:AddPoint(0.09, 0)
AE.curves.DurationDecimals:AddPoint(0.1, 1)
AE.curves.DurationDecimals:AddPoint(2.8, 1)
AE.curves.DurationDecimals:AddPoint(2.9, 0)

-- Curve that yields data for SetDesaturation based on cooldown remaining
AE.curves.ActionDesaturation = C_CurveUtil.CreateCurve()
AE.curves.ActionDesaturation:SetType(Enum.LuaCurveType.Step)
AE.curves.ActionDesaturation:AddPoint(0, 0)
AE.curves.ActionDesaturation:AddPoint(0.001, 1)

-- Curve that yields data for SetAlpha based on cooldown remaining
AE.curves.ActionAlpha = C_CurveUtil.CreateCurve()
AE.curves.ActionAlpha:SetType(Enum.LuaCurveType.Step)
AE.curves.ActionAlpha:AddPoint(0, 1)
AE.curves.ActionAlpha:AddPoint(0.001, 0.33)
-- VXJediEssentials Korean Locale (koKR)
---@class AE
local AE = select(2, ...)
if GetLocale() ~= "koKR" then return end
local L = AE.L

------------------------------------------------------------------------
-- General / Shared
------------------------------------------------------------------------
L["On"] = "켜기"
L["Off"] = "끄기"
L["Enabled"] = "활성화됨"
L["Disabled"] = "비활성화됨"
L["Enable"] = "활성화"
L["Error"] = "오류"
L["Note"] = "참고"
L["Show"] = "표시"
L["Required"] = "필수"
L["Coming Soon"] = "곧 출시"
L["Database not available"] = "데이터베이스를 사용할 수 없습니다"
L["None"] = "없음"

------------------------------------------------------------------------
-- GUI Sidebar Sections
------------------------------------------------------------------------
L["Combat"] = "전투"
L["Custom Buffs"] = "사용자 정의 버프"
L["Optimize"] = "최적화"
L["Profiles"] = "프로필"
L["Quality of Life"] = "편의 기능"

------------------------------------------------------------------------
-- GUI Sidebar Entries
------------------------------------------------------------------------
L["Combat Timer"] = "전투 타이머"
L["Combat Cross"] = "전투 십자선"
L["Combat Texts"] = "전투 텍스트"
L["Combat Res"] = "전투 부활"
L["Missing Buffs"] = "부족한 버프"
L["Pet Status Texts"] = "소환수 상태 텍스트"
L["Focus Castbar"] = "주시 대상 시전바"
L["Target Castbar"] = "대상 시전바"
L["Hunters Mark Missing"] = "사냥꾼의 징표 부재"
L["Gateway Alert"] = "관문 알림"
L["Automation"] = "자동화"
L["Copy Anything"] = "무엇이든 복사"
L["Cursor Circle"] = "커서 원"
L["Dragon Riding UI"] = "용타기 인터페이스"
L["Externals & Defensives"] = "외부 및 방어 기술"
L["System Optimization"] = "시스템 최적화"
L["Profile Manager"] = "프로필 관리자"

------------------------------------------------------------------------
-- Home Page
------------------------------------------------------------------------
L["Getting Started"] = "시작하기"
L["Support"] = "지원"

------------------------------------------------------------------------
-- Combat Timer
------------------------------------------------------------------------
L["Enable Combat Timer"] = "전투 타이머 활성화"
L["Print Combat Duration to Chat"] = "전투 지속 시간을 채팅에 표시"
L["Combat lasted "] = "전투 지속 시간: "
L["Format"] = "형식"
L["Bracket Style"] = "괄호 스타일"
L["Font Size"] = "글꼴 크기"
L["Font"] = "글꼴"
L["Font Outline"] = "글꼴 외곽선"
L["Font Shadow"] = "글꼴 그림자"
L["Font Settings"] = "글꼴 설정"

------------------------------------------------------------------------
-- Combat Cross
------------------------------------------------------------------------
L["Enable Combat Cross"] = "전투 십자선 활성화"
L["Cross Size"] = "십자선 크기"
L["Size"] = "크기"
L["This is a static crosshair overlay and will not adjust with camera panning."] = "이것은 고정된 십자선 오버레이로 카메라 이동에 따라 조정되지 않습니다."

------------------------------------------------------------------------
-- Combat Messages
------------------------------------------------------------------------
L["Enable Combat Messages"] = "전투 메시지 활성화"
L["Combat Res Tracker"] = "전투 부활 추적기"
L["Enable Combat Res Tracker"] = "전투 부활 추적기 활성화"
L["Enter Combat Message"] = "전투 시작 메시지"
L["Exit Combat Message"] = "전투 종료 메시지"
L["Low Durability Warning"] = "낮은 내구도 경고"
L["LOW DURABILITY"] = "낮은 내구도"
L["Message Spacing"] = "메시지 간격"
L["Durability Threshold (%)"] = "내구도 임계값 (%)"
L["Text"] = "텍스트"
L["Text Settings"] = "텍스트 설정"

------------------------------------------------------------------------
-- Pet Status Texts
------------------------------------------------------------------------
L["Enable Pet Status Texts"] = "소환수 상태 텍스트 활성화"
L["PET DEAD"] = "소환수 사망"
L["PET MISSING"] = "소환수 부재"
L["PET PASSIVE"] = "소환수 수동"
L["Pet Dead Text"] = "소환수 사망 텍스트"
L["Pet Missing Text"] = "소환수 부재 텍스트"
L["Pet Passive Text"] = "소환수 수동 텍스트"
L["Dead Color"] = "사망 색상"
L["Missing Color"] = "부재 색상"
L["Passive Color"] = "수동 색상"

------------------------------------------------------------------------
-- Focus / Target Castbar
------------------------------------------------------------------------
L["Enable Focus Castbar"] = "주시 대상 시전바 활성화"
L["Enable Target Castbar"] = "대상 시전바 활성화"
L["Bar Height"] = "바 높이"
L["Bar Texture"] = "바 텍스처"
L["Width"] = "너비"
L["Height"] = "높이"
L["Target Names"] = "대상 이름"
L["Casting"] = "시전 중"
L["Channeling"] = "정신 집중"
L["Empowering"] = "강화 중"
L["Not Interruptible"] = "차단 불가"
L["Interrupted"] = "차단됨"
L["Cast Success"] = "시전 성공"
L["Colors"] = "색상"
L["Color Settings"] = "색상 설정"
L["Hold Timer"] = "유지 타이머"
L["Enable Hold Timer"] = "유지 타이머 활성화"
L["Hold Duration"] = "유지 시간"
L["Kick Indicator"] = "차단 표시기"
L["Enable Kick Indicator"] = "차단 표시기 활성화"
L["Kick Ready Tick"] = "차단 준비 표시"
L["Kick Not Ready"] = "차단 미준비"
L["Hide Non-Interruptible Casts"] = "차단 불가 시전 숨기기"
L["Timer Text Color"] = "타이머 텍스트 색상"
L["Enable Shadow"] = "그림자 활성화"
L["Shadow Color"] = "그림자 색상"
L["Shadow X Offset"] = "그림자 X 오프셋"
L["Shadow Y Offset"] = "그림자 Y 오프셋"
L["Shadow X"] = "그림자 X"
L["Shadow Y"] = "그림자 Y"

------------------------------------------------------------------------
-- Hunter's Mark
------------------------------------------------------------------------
L["Enable Hunters Mark Tracking"] = "사냥꾼의 징표 추적 활성화"
L["Hunters Mark Tracking"] = "사냥꾼의 징표 추적"
L["MISSING MARK"] = "징표 부재"
L["This module only works inside raid instances and while out of combat."] = "이 모듈은 공격대 인스턴스 내에서 비전투 상태에서만 작동합니다."

------------------------------------------------------------------------
-- Gateway Alert
------------------------------------------------------------------------
L["Enable Gateway Alert"] = "관문 알림 활성화"
L["Gateway Usable Alert"] = "관문 사용 가능 알림"
L["GATE USABLE"] = "관문 사용 가능"
L["Alert Color"] = "알림 색상"

------------------------------------------------------------------------
-- Missing Buffs
------------------------------------------------------------------------
L["Enable Missing Buffs"] = "부족한 버프 활성화"
L["Consumable & Buff Tracking"] = "소모품 및 버프 추적"
L["Stance & Form Tracking"] = "태세 및 변신 추적"
L["Stance Text Display"] = "태세 텍스트 표시"
L["Enable Stance Text"] = "태세 텍스트 활성화"
L["Hide in Rested Areas"] = "휴식 지역에서 숨기기"
L["MISSING"] = "부족"
L["Balance: Require Moonkin Form"] = "조화: 달빛야수 변신 필요"
L["Feral: Require Cat Form"] = "야성: 표범 변신 필요"
L["Guardian: Require Bear Form"] = "수호: 곰 변신 필요"
L["Require Shadowform"] = "어둠의 형상 필요"
L["Require Attunement"] = "조율 필요"
L["Shadow Priest Shadowform"] = "암흑 사제 어둠의 형상"
L["Augmentation Evoker Attunement"] = "증강 기원사 조율"
L["Druid Forms"] = "드루이드 변신"

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------
L["Enable Automation"] = "자동화 활성화"
L["Merchant Automation"] = "상인 자동화"
L["Quest Automation"] = "퀘스트 자동화"
L["Social"] = "소셜"
L["Cinematics & Dialogs"] = "시네마틱 및 대화"
L["Convenience"] = "편의"
L["Group Finder"] = "파티 찾기"
L["Auto Sell Junk (Grey Items)"] = "잡동사니 자동 판매"
L["Auto Repair Gear"] = "장비 자동 수리"
L["Use Guild Funds for Repair"] = "길드 자금으로 수리"
L["Auto Accept Quests"] = "퀘스트 자동 수락"
L["Auto Turn In Quests"] = "퀘스트 자동 완료"
L["Hold to Pause Auto-Quest"] = "길게 눌러 자동 퀘스트 일시 중지"
L["Auto Loot"] = "자동 획득"
L["Auto Accept Role Check"] = "역할 확인 자동 수락"
L["Auto Decline Duels"] = "결투 자동 거절"
L["Auto Decline Pet Battle Duels"] = "애완동물 대전 자동 거절"
L["Auto-Fill DELETE Text"] = "삭제 텍스트 자동 입력"
L["Skip Cinematics & Movies"] = "시네마틱 건너뛰기"
L["Hide Talking Head Frame"] = "말하는 머리 숨기기"
L["Auto Filter AH to Current Expansion"] = "경매장 현재 확장팩 필터"

------------------------------------------------------------------------
-- Copy Anything
------------------------------------------------------------------------
L["Enable Copy Anything"] = "무엇이든 복사 활성화"
L["Keybind"] = "단축키"
L["Keybinding"] = "키 설정"
L["Copy Keybind, Supports Single Letter Only"] = "복사 키, 단일 문자만 지원"
L["Copy Modifier Key(s)"] = "보조 키"

------------------------------------------------------------------------
------------------------------------------------------------------------
L["State Settings"] = "상태 설정"
L["In Combat Color"] = "전투 중 색상"
L["Non Combat Color"] = "비전투 색상"
L["Fade Duration (seconds)"] = "페이드 시간 (초)"

------------------------------------------------------------------------
-- Cursor Circle
------------------------------------------------------------------------
L["Enable Cursor Circle"] = "커서 원 활성화"
L["Radius"] = "반경"

------------------------------------------------------------------------
-- Dragon Riding / Skyriding
------------------------------------------------------------------------
L["Enable Skyriding UI"] = "용타기 인터페이스 활성화"
L["Skyriding UI"] = "용타기 인터페이스"
L["Hide When Grounded"] = "지상에서 숨기기"
L["Speed Font Size"] = "속도 글꼴 크기"
L["Vigor"] = "활력"
L["Vigor (Thrill)"] = "활력 (스릴)"
L["Second Wind"] = "재충전"
L["Second Wind (On CD)"] = "재충전 (재사용 대기)"
L["Whirling Surge"] = "소용돌이 쇄도"
L["Whirling Surge (On CD)"] = "소용돌이 쇄도 (재사용 대기)"
L["Countdown Size"] = "카운트다운 크기"

------------------------------------------------------------------------
-- Externals & Defensives (Buff Icons)
------------------------------------------------------------------------
L["Enable Externals & Defensives"] = "외부 및 방어 기술 활성화"
L["General Settings"] = "일반 설정"
L["General Icon Settings"] = "아이콘 설정"
L["Tracker Selection"] = "추적기 선택"
L["Tracker Settings"] = "추적기 설정"
L["Edit Tracker"] = "추적기 편집"
L["Growth Direction"] = "성장 방향"
L["Icon Size"] = "아이콘 크기"
L["Icon Spacing"] = "아이콘 간격"
L["Row Spacing"] = "행 간격"
L["Spacing"] = "간격"
L["Show Cooldown Text"] = "재사용 대기 텍스트 표시"
L["Duration (sec)"] = "지속 시간 (초)"
L["Spell"] = "주문"
L["Type"] = "유형"
L["Reverse Icon"] = "아이콘 반전"
L["Separator"] = "구분자"
L["Separator Character"] = "구분 문자"
L["Separator Color"] = "구분자 색상"
L["Low Duration Warning"] = "짧은 지속 시간 경고"
L["Warn Before Expiry"] = "만료 전 경고"
L["Minutes Left"] = "남은 분"
L["Charges Available"] = "충전 가능"
L["Charges Unavailable"] = "충전 불가"
L["Charge Prefix"] = "충전 접두사"

------------------------------------------------------------------------
-- Position & Layout (shared widgets)
------------------------------------------------------------------------
L["Position"] = "위치"
L["Display Settings"] = "표시 설정"
L["X Offset"] = "X 오프셋"
L["Y Offset"] = "Y 오프셋"
L["Strata"] = "계층"
L["Anchor"] = "앵커"
L["Anchored To"] = "고정 대상"
L["Color"] = "색상"
L["Color Mode"] = "색상 모드"
L["Custom Color"] = "사용자 정의 색상"
L["Outline"] = "외곽선"

------------------------------------------------------------------------
-- Backdrop (shared)
------------------------------------------------------------------------
L["Backdrop Settings"] = "배경 설정"
L["Enable Backdrop"] = "배경 활성화"
L["Backdrop Color"] = "배경 색상"
L["Backdrop Width"] = "배경 너비"
L["Backdrop Height"] = "배경 높이"
L["Border"] = "테두리"
L["Border Color"] = "테두리 색상"
L["Border Size"] = "테두리 크기"
L["Background"] = "배경"
L["Use Shadow"] = "그림자 사용"

------------------------------------------------------------------------
-- Profiles
------------------------------------------------------------------------
L["Active Profile"] = "활성 프로필"
L["Current Profile"] = "현재 프로필"
L["Global Profile"] = "전역 프로필"
L["Use Global Profile"] = "전역 프로필 사용"
L["Profile Actions"] = "프로필 작업"
L["Profile Name"] = "프로필 이름"
L["Profile Name (leave empty for default)"] = "프로필 이름 (기본값은 비워두세요)"
L["Profile"] = "프로필"
L["New Name"] = "새 이름"
L["Rename Profile"] = "프로필 이름 변경"
L["Copy From Profile"] = "프로필에서 복사"
L["Source Profile"] = "원본 프로필"
L["Profile to Delete"] = "삭제할 프로필"
L["Profile to Rename"] = "이름을 변경할 프로필"
L["Cannot delete the active profile"] = "활성 프로필은 삭제할 수 없습니다"
L["Quick Actions"] = "빠른 작업"
L["Import / Export"] = "가져오기 / 내보내기"
L["Load"] = "불러오기"
L["Presets"] = "프리셋"

------------------------------------------------------------------------
-- Optimize
------------------------------------------------------------------------
L["Apply All"] = "모두 적용"
L["Revert All"] = "모두 되돌리기"
L["Apply"] = "적용"
L["Revert"] = "되돌리기"
L["Current"] = "현재"
L["Optimal"] = "최적"
L["Saved"] = "저장됨"
L["No backup"] = "백업 없음"

------------------------------------------------------------------------
-- Notes / Info Strings
------------------------------------------------------------------------

------------------------------------------------------------------------
-- New keys (untranslated, will fall back to enUS)
------------------------------------------------------------------------

Global("Locales", {})

function getLocale()
	return Locales[common.GetLocalization()] or Locales["eng"]
end

--------------------------------------------------------------------------------
-- Russian
--------------------------------------------------------------------------------

Locales["rus"]={}
Locales["rus"]["raidButton"]=				"Настройки рейда"
Locales["rus"]["targeterButton"]=			"Настройки таргетера"
Locales["rus"]["targeterButton"]=			"Настройки таргетера"
Locales["rus"]["buffsButton"]=				"Настройки баффов"
Locales["rus"]["bindButton"]=				"Настройки макросов"
Locales["rus"]["okButton"]=					"OK"
Locales["rus"]["useRaidSubSystem"]=			"Включить рейдовую подсистему"
Locales["rus"]["useTargeterSubSystem"]=		"Включить таргетер"
Locales["rus"]["useBuffMngSubSystem"]=		"Включить бафф менеджер"
Locales["rus"]["useBindSubSystem"]=			"Включить макросы (не работают в ПВП)"
Locales["rus"]["raidBuffsButton"]=			"Отображаемые баффы"
Locales["rus"]["raidWidthText"]=			"Ширина панели"
Locales["rus"]["raidHeightText"]=			"Высота панели"
Locales["rus"]["raidSettingsFormHeader"]=	"Настройки рейда"
Locales["rus"]["targeterSettingsFormHeader"]="Настройки таргетера"
Locales["rus"]["targeterBuffsButton"]=		"Отображаемые баффы"
Locales["rus"]["myTargetsButton"]=			"Цели с именами:"
Locales["rus"]["raidBuffSettingsFormHeader"]="Баффы рейда"
Locales["rus"]["addRaidBuffButton"]=		"Добавить: "
Locales["rus"]["raidBuffsList"]=			"Указанные баффы:"
Locales["rus"]["addTargeterBuffButton"]=	"Добавить: "
Locales["rus"]["addTargetButton"]=			"Добавить: "
Locales["rus"]["buffSizeText"]=				"Размер баффа: "
Locales["rus"]["showImportantButton"]=		"Показывать особые: "
Locales["rus"]["checkControlsButton"]=		"Показывать контроли: "
Locales["rus"]["checkMovementsButton"]=		"Показывать замедления: "
Locales["rus"]["hideUnselectableButton"]=	"Скрывать недоступных мобов: "
Locales["rus"]["buffsFixInsidePanelButton"]="Зафиксировать баффы внутри панели:"
Locales["rus"]["castByMe"]=					"Мой"
Locales["rus"]["flipBuffsButton"]=			"Баффы справа налево:"
Locales["rus"]["aboveHeadButton"]=			"Это баффы над головой игрока:"
Locales["rus"]["isEnemyButton"]=			"     • Баффы над головой только для врагов:"
Locales["rus"]["isSpell"]=					"Умение"
Locales["rus"]["bindSettingsFormHeader"]=	"Бинды умений"
Locales["rus"]["bindForRaidHeader"]=		"Бинды для рейда"
Locales["rus"]["bindForTargetHeader"]=		"Бинды для таргетера"
Locales["rus"]["raidBindSimpleButton"]=		"Простой клик"
Locales["rus"]["raidBindShiftButton"]=		"Shift+клик"
Locales["rus"]["raidBindAltButton"]=		"Alt+клик"
Locales["rus"]["raidBindCtrlButton"]=		"Ctrl+клик"
Locales["rus"]["targetBindSimpleButton"]=	"Простой клик"
Locales["rus"]["targetBindShiftButton"]=	"Shift+клик"
Locales["rus"]["targetBindAltButton"]=		"Alt+клик"
Locales["rus"]["targetBindCtrlButton"]=		"Ctrl+клик"
Locales["rus"]["separateBuffDebuff"]=		"Разнести бафы и дебафы"
Locales["rus"]["twoColumnMode"]=			"Те кто в бою в отдельном столбце"
Locales["rus"]["colorDebuffButton"]=		"     • Подсвечивать таких игроков:"

Locales["rus"]["ALL_TARGETS"]=				"Все"
Locales["rus"]["ENEMY_TARGETS"]=			"Враждебные"
Locales["rus"]["FRIEND_TARGETS"]=			"Дружественные"
Locales["rus"]["ENEMY_PLAYERS_TARGETS"]=	"Игроки враждебные"
Locales["rus"]["FRIEND_PLAYERS_TARGETS"]=	"Игроки дружественные"
Locales["rus"]["NEITRAL_PLAYERS_TARGETS"]=	"Игроки нейтральные"
Locales["rus"]["ENEMY_MOBS_TARGETS"]=		"Монстры враждебные"
Locales["rus"]["FRIEND_MOBS_TARGETS"]=		"Монстры дружественные"
Locales["rus"]["NEITRAL_MOBS_TARGETS"]=		"Монстры нейтральные"
Locales["rus"]["ENEMY_PETS_TARGETS"]=		"Петы враждебные"
Locales["rus"]["FRIEND_PETS_TARGETS"]=		"Петы дружественные"
Locales["rus"]["MY_SETTINGS_TARGETS"]=		"Мои цели"
Locales["rus"]["TARGETS_DISABLE"]=			"ОТКЛЮЧЕНО"

Locales["rus"]["LEFT_CLICK"]=				"Левый"
Locales["rus"]["RIGHT_CLICK"]=				"Правый"

Locales["rus"]["DISABLE_CLICK"]=			"Отключено"
Locales["rus"]["SELECT_CLICK"]=				"Выделить"
Locales["rus"]["MENU_CLICK"]=				"Меню"
Locales["rus"]["TARGET_CLICK"]=				"Цель цели"
Locales["rus"]["RESSURECT_CLICK"]=			"Воскресить"
Locales["rus"]["AUTOCAST_CLICK"]=			"Ничего"

Locales["rus"]["mobsButton"]=				"Мобы"
Locales["rus"]["controlsButton"]=			"Контроль"
Locales["rus"]["debuffsButton"]=			"Дебаффы"
Locales["rus"]["barsButton"]=				"Панели"
Locales["rus"]["saveButton"]=				"Сохранить"
Locales["rus"]["configHeader"]		=		"Настройки"
Locales["rus"]["leftClick"]			=		"Левая кнопка"
Locales["rus"]["rightClick"]		=		"Правая кнопка"
Locales["rus"]["testSpellNameText"]	=		"Тестовое заклинание"
Locales["rus"]["ressurectNameText"]	=		"Воскрешение"
Locales["rus"]["configMobsHeader"]	=		"Отслеживаемые существа"
Locales["rus"]["configDebuffsHeader"]	=	"Отслеживаемые дебаффы"
Locales["rus"]["configControlsHeader"]	=	"Отслеживаемые контроли"
Locales["rus"]["configBuffsHeader"]	=		"Группы баффов для панелей"
Locales["rus"]["configBarsHeader"]	=		"Настройка панелей"
Locales["rus"]["widthBuffCntText"]	=		"Кол-во баффов в строке"
Locales["rus"]["heightBuffCntText"]	=		"Число строк баффов"
Locales["rus"]["heightGroupText"]	=		"Высота группы"
Locales["rus"]["widthGroupText"]	=		"Количество групп"
Locales["rus"]["sizeBuffGroupText"]	=		"Размер баффа"
Locales["rus"]["buffOnMe"]	=				"Это баффы на мне:"
Locales["rus"]["buffOnTarget"]	=			"Это баффы на моей цели:"
Locales["rus"]["configBuffsHeader2"]	=	"Отслеживаемые баффы на себе"
Locales["rus"]["configGroupBuffsHeader"]=	"Изменить настройки группы:"
Locales["rus"]["editGroupBuffsButton"]=		"Изменить группу:"
Locales["rus"]["saveGroupBuffsButton"]=		"Сохранить"
Locales["rus"]["addDebuffButton"]=			"Добавить: "
Locales["rus"]["addMobsButton"]=			"Добавить: "
Locales["rus"]["addControlButton"]=			"Добавить: "
Locales["rus"]["addGroupBuffsButton"]=		"Добавить группу: "
Locales["rus"]["addBuffsButton"]=			"Добавить: "
Locales["rus"]["priorButton"]=				"Приоритетный режим"
Locales["rus"]["autoDebuffModeButton"]=		"Негативные баффы на союзниках:"
Locales["rus"]["autoDebuffModeButtonUnk"]=	"Негативные баффы на союзниках:"
Locales["rus"]["woundsShowButton"]=			"Показывать сложность ран:"
Locales["rus"]["ignoreSysBuffs"]=			"Игнорировать системные бафы"
Locales["rus"]["checkEnemyCleanable"]=		"Счищаемые баффы на противнике:"
Locales["rus"]["checkEnemyCleanableUnk"]=	"Счищаемые баффы на противнике:"
Locales["rus"]["shiftButton"]=				"Shift"
Locales["rus"]["ctrlButton"]=				"Ctrl"
Locales["rus"]["altButton"]=				"Alt"
Locales["rus"]["enemyButton"]=				"Враг"
Locales["rus"]["targetButton"]=				"Отображать цель"
Locales["rus"]["lastTargetButton"]=			"Отображать предыдущую цель"
Locales["rus"]["classColorModeButton"]=		"Цвета класса"
Locales["rus"]["firstShowButton"]=			"Персонаж всегда первый"
Locales["rus"]["selectModeButton"]  =		"Всегда выбирать в цель"
Locales["rus"]["buffsFixButton"]  =			"Закрепить на экране:"
Locales["rus"]["showManaButton"]=			"Показывать ману/энергию"
Locales["rus"]["showShieldButton"]=			"Показывать щиты"
Locales["rus"]["showServerNameButton"]=		"Показывать сервер"
Locales["rus"]["distanceText"]=				"Расстояние досягаемости"
Locales["rus"]["highlightSelectedButton"]=	"Обводка цели"
Locales["rus"]["showStandartRaidButton"]=	"Показывать интерфейс рейда/группы"
Locales["rus"]["showClassIconButton"]=		"Показывать иконку класса"
Locales["rus"]["showDistanceButton"]=		"Показывать дистанцию"
Locales["rus"]["showProcentButton"]=		"Показывать проценты здоровья"
Locales["rus"]["showArrowButton"]=			"Показывать стрелочку"
Locales["rus"]["updateTimeBuffsButton"]=	"Время обновления(сек)"

Locales["rus"]["configProfilesHeader"]=		"Управление профилями: "
--Locales["rus"]["configProfilesCurrent"]=	"Текущий профиль: "
Locales["rus"]["saveAsProfileButton"]=		"Сохранить текущий профиль как: "
Locales["rus"]["profilesButton"]=			"Профили"	

Locales["rus"]["inspectButton"]=			"Осмотреть"
Locales["rus"]["kickMenuButton"]=			"Исключить"
Locales["rus"]["closeMenuButton"]=			"Закрыть"
Locales["rus"]["leaveMenuButton"]=			"Покинуть группу"
Locales["rus"]["raidLeaveMenuButton"]=		"Покинуть отряд"
Locales["rus"]["leaderMenuButton"]=			"Назначить лидером"

Locales["rus"]["freeLootMenuButton"]=		"Дележ: Бери кто хочет"
Locales["rus"]["masterLootMenuButton"]=		"Дележ: Заведующий добычи"
Locales["rus"]["groupLootMenuButton"]=		"Дележ: Групповой лут"
Locales["rus"]["junkLootMenuButton"]=		"Ценность вещей: Серые"
Locales["rus"]["goodsLootMenuButton"]=		"Ценность вещей: Белые"
Locales["rus"]["commonLootMenuButton"]=		"Ценность вещей: Зеленые"
Locales["rus"]["uncommonLootMenuButton"]=	"Ценность вещей: Синие"
Locales["rus"]["rareLootMenuButton"]=		"Ценность вещей: Фиолетовые"
Locales["rus"]["epicLootMenuButton"]=		"Ценность вещей: Оранжевые"
Locales["rus"]["legendaryLootMenuButton"]=	"Ценность вещей: Салатовые"
Locales["rus"]["relicLootMenuButton"]=		"Ценность вещей: Лимонные"

Locales["rus"]["disbandMenuButton"]=		"Распустить"
Locales["rus"]["inviteMenuButton"]=			"Пригласить"
Locales["rus"]["createRaidMenuButton"]=		"Создать рейд"
Locales["rus"]["createSmallRaidMenuButton"]="Создать малый рейд"
Locales["rus"]["addLeaderHelperMenuButton"]="Назначить помощником"
Locales["rus"]["addMasterLootMenuButton"]=	"Назначить отв. за добычу"
Locales["rus"]["deleteLeaderHelperMenuButton"]=	"Убрать помощника"
Locales["rus"]["deleteMasterLootMenuButton"]=	"Убрать отв. за добычу"
Locales["rus"]["moveMenuButton"]=			"Переместить"
Locales["rus"]["whisperMenuButton"]=		"Отправить сообщение"

Locales["rus"]["configGroupBuffsId"]=		"ID"
Locales["rus"]["configGroupBuffsName"]=		"Название"
Locales["rus"]["configGroupBuffsTime"]=		"Время отката"
Locales["rus"]["configGroupBuffsCD"]  =		"КД"
Locales["rus"]["configGroupBuffsBuff"] =	"Бафф"


Locales["rus"]["allShop"]=			{"Эссенция стремительности", "Эссенция силы крит. урона", "Эссенция шанса крит. урона", "Эссенция беспощадности", "Эссенция мастерства", "Эссенция двойной атаки","Эссенция решимости", 
										"Эссенция физического урона","Эссенция стихийного урона","Эссенция божественного урона","Эссенция природного урона",
										"Экстракт стремительности", "Экстракт силы крит. урона", "Экстракт шанса крит. урона", "Экстракт беспощадности", "Экстракт мастерства", "Экстракт двойной атаки","Экстракт решимости", 
										"Экстракт физического урона","Экстракт стихийного урона","Экстракт божественного урона","Экстракт природного урона",
										"Мощная эссенция стремительности", "Мощная эссенция силы крит. урона", "Мощная эссенция шанса крит. урона", "Мощная эссенция беспощадности", "Мощная эссенция мастерства", "Мощная эссенция двойной атаки","Мощная эссенция решимости", "Мощная эссенция физического урона","Мощная эссенция стихийного урона","Мощная эссенция божественного урона","Мощная эссенция природного урона",
										"Эссенция стойкости", "Эссенция воли", "Эссенция кровожадности","Эссенция живучести","Эссенция незыблимости","Эссенция осторожности","Эссенция сосредоточенности",
										"Эссенция физической защиты","Эссенция стихийной защиты","Эссенция божественной защиты","Эссенция природной защиты",
										"Экстракт стойкости", "Экстракт воли", "Экстракт кровожадности","Экстракт живучести","Экстракт незыблимости","Экстракт осторожности","Экстракт сосредоточенности",
										"Экстракт физической защиты","Экстракт стихийной защиты","Экстракт божественной защиты","Экстракт природной защиты",
										"Мощная эссенция стойкости", "Мощная эссенция воли", "Мощная эссенция кровожадности","Мощная эссенция живучести","Мощная эссенция незыблимости","Мощная эссенция осторожности","Мощная эссенция сосредоточенности", "Мощная эссенция физической защиты","Мощная эссенция стихийной защиты","Мощная эссенция божественной защиты","Мощная эссенция природной защиты",
										"Демоническое снадобье мастерства", "Демоническое снадобье беспощадности", "Демоническое снадобье решимости", 
										"Снадобье физического урона", "Снадобье стихийного урона", "Снадобье божественного урона", "Снадобье природного урона", 
										"Горькая настойка", "Воля", "Решимость", "Живучесть"}


Locales["rus"]["defaultRessurectNames"]=	{ 	{ name = "Дар Тенсеса" },
												{ name = "Переливание жизни" },
												{ name = "Возрождение" }
											}
Locales["rus"]["loadedMessage"] =			"Профиль загружен: "
Locales["rus"]["savedMessage"] =			"Профиль сохранен: "
Locales["rus"]["savedAddMessage"] =			". Установлен как базовый для "
Locales["rus"]["groupSavedMessage"] =		"Настройки группы сохранены."	
Locales["rus"]["build1Name"] =				"Грань талантов 1"	
Locales["rus"]["build2Name"] =				"Грань талантов 2"	
	
Locales["rus"]["gorisontalModeButton"] =	"Горизонтальный режим: "				
Locales["rus"]["twoxtwoModeButton"] =		"Режим 2х2: "								

--------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------

		
Locales["eng"]={}
Locales["eng"]["raidButton"]=				"Raid settings"
Locales["eng"]["targeterButton"]=			"Targeter settings"
Locales["eng"]["buffsButton"]=				"Buff settings"
Locales["eng"]["bindButton"]=				"Macros settings"
Locales["eng"]["okButton"]=					"OK"
Locales["eng"]["useRaidSubSystem"]=			"Enable raid subsystem"
Locales["eng"]["useTargeterSubSystem"]=		"Enable targeter subsystem"
Locales["eng"]["useBuffMngSubSystem"]=		"Enable buff plates subsystem"
Locales["eng"]["useBindSubSystem"]=			"Enable macros subsystem"
Locales["eng"]["raidBuffsButton"]=			"Displayed buffs"
Locales["eng"]["raidWidthText"]=			"Panel width"
Locales["eng"]["raidHeightText"]=			"Panel height"
Locales["eng"]["raidSettingsFormHeader"]=	"Raid settings"
Locales["eng"]["targeterSettingsFormHeader"]="Targeter settings"
Locales["eng"]["targeterBuffsButton"]=		"Displayed buffs"
Locales["eng"]["myTargetsButton"]=			"Targets with names:"
Locales["eng"]["raidBuffSettingsFormHeader"]="Raid buffs"
Locales["eng"]["addRaidBuffButton"]=		"Add: "
Locales["eng"]["raidBuffsList"]=			"Specified buffs:"
Locales["eng"]["addTargeterBuffButton"]=	"Add: "
Locales["eng"]["addTargetButton"]=			"Add: "
Locales["eng"]["buffSizeText"]=				"Buff icon size: "
Locales["eng"]["showImportantButton"]=		"Show special: "
Locales["eng"]["checkControlsButton"]=		"Show controls: "
Locales["eng"]["checkMovementsButton"]=		"Show movement impairing: "
Locales["eng"]["hideUnselectableButton"]=	"Hide unselectable mobs: "
Locales["eng"]["buffsFixInsidePanelButton"]="Lock buffs pos inside the panel:"
Locales["eng"]["castByMe"]=					"My"
Locales["eng"]["flipBuffsButton"]=			"Buffs from right to left:"
Locales["eng"]["aboveHeadButton"]=			"This buffs over the player's head:"
Locales["eng"]["isEnemyButton"]=			"     • Buffs above the head only for enemies:"
Locales["eng"]["isSpell"]=					"Spell"
Locales["eng"]["bindSettingsFormHeader"]=	"Binds"
Locales["eng"]["bindForRaidHeader"]=		"Binds for raid"
Locales["eng"]["bindForTargetHeader"]=		"Binds for targeter"
Locales["eng"]["raidBindSimpleButton"]=		"Simple click"
Locales["eng"]["raidBindShiftButton"]=		"Shift+click"
Locales["eng"]["raidBindAltButton"]=		"Alt+click"
Locales["eng"]["raidBindCtrlButton"]=		"Ctrl+click"
Locales["eng"]["targetBindSimpleButton"]=	"Simple click"
Locales["eng"]["targetBindShiftButton"]=	"Shift+click"
Locales["eng"]["targetBindAltButton"]=		"Alt+click"
Locales["eng"]["targetBindCtrlButton"]=		"Ctrl+click"
Locales["eng"]["separateBuffDebuff"]=		"Separate buff/debuff"
Locales["eng"]["twoColumnMode"]=			"Two column mode"
Locales["rus"]["colorDebuffButton"]=		"     • Highlight these players:"

Locales["eng"]["ALL_TARGETS"]=				"All"
Locales["eng"]["ENEMY_TARGETS"]=			"Enemy"
Locales["eng"]["FRIEND_TARGETS"]=			"Friends"
Locales["eng"]["ENEMY_PLAYERS_TARGETS"]=	"Enemy players"
Locales["eng"]["FRIEND_PLAYERS_TARGETS"]=	"Friend players"
Locales["eng"]["NEITRAL_PLAYERS_TARGETS"]=	"Neitral players"
Locales["eng"]["ENEMY_MOBS_TARGETS"]=		"Enemy mobs"
Locales["eng"]["FRIEND_MOBS_TARGETS"]=		"Friend mobs"
Locales["eng"]["NEITRAL_MOBS_TARGETS"]=		"Neitral mobs"
Locales["eng"]["ENEMY_PETS_TARGETS"]=		"Enemy pets"
Locales["eng"]["FRIEND_PETS_TARGETS"]=		"Friend pets"
Locales["eng"]["MY_SETTINGS_TARGETS"]=		"My targets"
Locales["eng"]["TARGETS_DISABLE"]=			"DISABLED"

Locales["eng"]["LEFT_CLICK"]=				"Left"
Locales["eng"]["RIGHT_CLICK"]=				"Right"

Locales["eng"]["DISABLE_CLICK"]=			"Disable"
Locales["eng"]["SELECT_CLICK"]=				"Select"
Locales["eng"]["MENU_CLICK"]=				"Menu"
Locales["eng"]["TARGET_CLICK"]=				"Target"
Locales["eng"]["RESSURECT_CLICK"]=			"Ressurect"
Locales["eng"]["AUTOCAST_CLICK"]=			"None"

Locales["eng"]["mobsButton"]=				"Units"
Locales["eng"]["controlsButton"]=			"Controls"
Locales["eng"]["debuffsButton"]=			"Debuffs"
Locales["eng"]["barsButton"]=				"Panels"
Locales["eng"]["saveButton"]=				"Save"
Locales["eng"]["configHeader"]		=		"Settings"
Locales["eng"]["leftClick"]			=		"Left Click"
Locales["eng"]["rightClick"]		=		"Right Click"
Locales["eng"]["testSpellNameText"]	=		"Test Spell"
Locales["eng"]["ressurectNameText"]	=		"Ressurect Spell"
Locales["eng"]["configMobsHeader"]	=		"Detected units"
Locales["eng"]["configDebuffsHeader"]	=	"Detected debuffs"
Locales["eng"]["configControlsHeader"]	=	"Detected controls"
Locales["eng"]["configBuffsHeader"]	=		"Buff groups for panels"
Locales["eng"]["configBarsHeader"]	=		"Panel settings"
Locales["eng"]["widthBuffCntText"]	=		"Number of buffs per line"
Locales["eng"]["heightBuffCntText"]	=		"Number of lines of buffs"
Locales["eng"]["heightGroupText"]	=		"Group Height"
Locales["eng"]["widthGroupText"]	=		"Group Num"
Locales["eng"]["sizeBuffGroupText"]	=		"Buff size"
Locales["eng"]["buffOnMe"]	=				"This is the buffs on me:"
Locales["eng"]["buffOnTarget"]	=			"This is the buffs on target:"
Locales["eng"]["configBuffsHeader2"]	=	"Detected buffs on avatar"
Locales["eng"]["configGroupBuffsHeader"]=	"Change group settings:"
Locales["eng"]["editGroupBuffsButton"]=		"Change group:"
Locales["eng"]["saveGroupBuffsButton"]=		"Save"
Locales["eng"]["addDebuffButton"]=			"Add: "
Locales["eng"]["addMobsButton"]=			"Add: "
Locales["eng"]["addControlButton"]=			"Add: "
Locales["eng"]["addGroupBuffsButton"]=		"Add group: "
Locales["eng"]["addBuffsButton"]=			"Add: "
Locales["eng"]["priorButton"]=				"Priority mode"
Locales["eng"]["autoDebuffModeButton"]=		"Auto detect debuffs on friends:"
Locales["eng"]["autoDebuffModeButtonUnk"]=	"Auto detect debuffs on friends:"
Locales["eng"]["woundsShowButton"]=			"Show wounds:"
Locales["eng"]["checkEnemyCleanable"]=		"Dispelling buffs on enemy:"
Locales["eng"]["checkEnemyCleanableUnk"]=	"Dispelling buffs on enemy:"
Locales["eng"]["shiftButton"]=				"Shift"
Locales["eng"]["ctrlButton"]=				"Ctrl"
Locales["eng"]["altButton"]=				"Alt"
Locales["eng"]["enemyButton"]=				"Enemy"
Locales["eng"]["targetButton"]=				"Show target"
Locales["eng"]["lastTargetButton"]=			"Show last target"
Locales["eng"]["classColorModeButton"]=		"Class color mode"
Locales["eng"]["firstShowButton"]=			"Avatar always first"
Locales["eng"]["selectModeButton"]  =		"Always select"
Locales["eng"]["buffsFixButton"]  =			"Fix on screen:"
Locales["eng"]["showManaButton"]=			"Show mana/energy"
Locales["eng"]["showShieldButton"]=			"Show shield"
Locales["eng"]["showServerNameButton"]=		"Show server"
Locales["eng"]["distanceText"]=				"Cast distance"
Locales["eng"]["highlightSelectedButton"]=	"Highlight target"
Locales["eng"]["showStandartRaidButton"]=	"Show standart raid/group interface"
Locales["eng"]["showClassIconButton"]=		"Show class icon"
Locales["eng"]["showDistanceButton"]=		"Show distance"
Locales["eng"]["showProcentButton"]=		"Show percent"
Locales["eng"]["showArrowButton"]=			"Show arrow"
Locales["eng"]["updateTimeBuffsButton"]=	"Update time"

Locales["eng"]["configProfilesHeader"]=		"Profiles: "
Locales["eng"]["saveAsProfileButton"]=		"Save current profile as: "
Locales["eng"]["profilesButton"]=			"Profiles"	

Locales["eng"]["inspectButton"]=			"Inspect"
Locales["eng"]["kickMenuButton"]=			"Kick"
Locales["eng"]["closeMenuButton"]=			"Close"
Locales["eng"]["leaveMenuButton"]=			"Leave group"
Locales["eng"]["raidLeaveMenuButton"]=		"Leave raid"
Locales["eng"]["leaderMenuButton"]=			"Set leader"

Locales["eng"]["freeLootMenuButton"]=		"Free loot"
Locales["eng"]["masterLootMenuButton"]=		"Master loot"
Locales["eng"]["groupLootMenuButton"]=		"Group loot"
Locales["eng"]["junkLootMenuButton"]=		"Junk"
Locales["eng"]["goodsLootMenuButton"]=		"Goods"
Locales["eng"]["commonLootMenuButton"]=		"Common"
Locales["eng"]["uncommonLootMenuButton"]=	"Uncommon"
Locales["eng"]["rareLootMenuButton"]=		"Rare"
Locales["eng"]["epicLootMenuButton"]=		"Epic"
Locales["eng"]["legendaryLootMenuButton"]=	"Legend"
Locales["eng"]["relicLootMenuButton"]=		"Relic"

Locales["eng"]["disbandMenuButton"]=		"Disband"
Locales["eng"]["inviteMenuButton"]=			"Invite"
Locales["eng"]["createRaidMenuButton"]=		"Create raid"
Locales["eng"]["createSmallRaidMenuButton"]="Create small raid"
Locales["eng"]["addLeaderHelperMenuButton"]="Set helper"
Locales["eng"]["addMasterLootMenuButton"]=	"Set loot master"
Locales["eng"]["deleteLeaderHelperMenuButton"]=	"Delete helper"
Locales["eng"]["deleteMasterLootMenuButton"]=	"Delete loot master"
Locales["eng"]["moveMenuButton"]=			"Move"
Locales["eng"]["whisperMenuButton"]=		"Whisper"

Locales["eng"]["configGroupBuffsId"]=		"ID"
Locales["eng"]["configGroupBuffsName"]=		"Name"
Locales["eng"]["configGroupBuffsTime"]=		"CD Time"
Locales["eng"]["configGroupBuffsCD"]  =		"CD"
Locales["eng"]["configGroupBuffsBuff"] =	"Buff"


Locales["eng"]["allShop"]=			{"Elixir of Proficiency", "Elixir of Brutality", "Elixir of Determination", "Elixir of Bloodlust", "Elixir of Vitality", "Elixir of Critical Chance",
									"Elixir of Willpower", "Elixir of Swiftness", "Elixir of Double Attack", "Elixir of Critical Damage", "Elixir of Elemental Damage", "Elixir of Holy Damage",
									"Elixir of Natural Damage", "Elixir of Physical Damage", "Elixir of Elemental Protection", "Elixir of Holy Protection", "Elixir of Natural Protection",
									"Elixir of Physical Protection", "Elixir of Survivability", "Elixir of Sustainability", "Elixir of Caution", "Elixir of Concentration",
									"Potion of Swiftness", "Potion of Critical Damage", "Potion of Double Attack", "Potion of Critical Chance", "Potion of Proficiency", "Potion of Willpower",
									"Potion of Bloodlust", "Potion of Vitality", "Potion of Brutality", "Potion of Determination", "Potion of Elemental Damage", "Potion of Holy Damage",
									"Potion of Natural Damage", "Potion of Physical Damage", "Potion of Elemental Protection", "Potion of Holy Protection", "Potion of Natural Protection",
									"Potion of Physical Protection", "Potion of Survivability", "Potion of Sustainability", "Potion of Caution", "Potion of Concentration",
									"Powerful Elixir of Proficiency", "Powerful Elixir of Brutality", "Powerful Elixir of Determination", "Powerful Elixir of Bloodlust", "Powerful Elixir of Vitality", 
									"Powerful Elixir of Critical Chance", "Powerful Elixir of Willpower", "Powerful Elixir of Swiftness", "Powerful Elixir of Double Attack", "Powerful Elixir of Critical Damage", 
									"Powerful Elixir of Elemental Damage", "Powerful Elixir of Holy Damage", "Powerful Elixir of Natural Damage", "Powerful Elixir of Physical Damage", "Powerful Elixir of Elemental Protection",
									"Powerful Elixir of Holy Protection", "Powerful Elixir of Natural Protection", "Powerful Elixir of Physical Protection", "Powerful Elixir of Survivability", 
									"Powerful Elixir of Sustainability", "Powerful Elixir of Caution", "Powerful Elixir of Concentration",
									"Demonic Potion of Proficiency", "Demonic Potion of Determination", "Demonic Potion of Brutality", "Arcanum of Natural Damage", "Arcanum of Elemental Damage",
									"Arcanum of Physical Damage", "Arcanum of Holy Damage",
									"Bitter Infusion", "Willpower", "Determination","Survivability"}


Locales["eng"]["defaultRessurectNames"]=	{ 	{ name = "Дар Тенсеса" },
												{ name = "Переливание жизни" },
												{ name = "Возрождение" }
											}
Locales["eng"]["loadedMessage"] =			"Profile loaded: "
Locales["eng"]["savedMessage"] =			"Profile saved: "
Locales["eng"]["groupSavedMessage"] =		"Group saved."	
Locales["eng"]["build1Name"] =				"Build 1"	
Locales["eng"]["build2Name"] =				"Build 2"	

Locales["eng"]["gorisontalModeButton"] =	"Gorisontal mode"			
Locales["eng"]["twoxtwoModeButton"] =		"2x2 Mode: "
								

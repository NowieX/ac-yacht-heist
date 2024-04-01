Config = {}

Config.Debugger = false

Config.GeneralTargetDistance = 1.5

Config.HeistNPC = {
    -- location = vec4(1247.4257, -2891.4165, 9.3193, 359.3845),
    location = vec3(-295.7075, 6388.8911, 30.6137),
    heading = 128.7009,
    model = 's_m_y_dockwork_01',
    target_distance = 1.5,

    -- Notification
    boss_title = "Willem | Jacht overval",
    target_label = "Jacht overval",
    introduction_round = {
        message = "Volg de route op je GPS en ga bij het gebouw naar binnen. Daar moet je gebruik maken van het hackerstoestel wat je hebt.",
        timer = 20000
    },
}

Config.Webhook = {
    hacker_log = "",
    item_log = "",
}

Config.HeistInformation = {
    ['HeistCooldownTimer'] = 30, -- Minuten
    ['PoliceNumberRequired'] = 0,
    ['BlackScreenTimer'] = 1000, -- Tijd hoelang het duurt voordat een speler in het camera gebouw is
}

Config.Notifies = {
    timer = 7500,
    position = "center-right"
}

Config.RequiredWeapons = {
    'weapon_pistol',
    'weapon_pistol_mk2',
}

Config.HeistLocations = {
    HackerBuilding = {
        entrance = {
            coords = vec3(-297.19287109375, 6391.78564453125, 30.80292510986328),
            target_label = "Gebouw ingaan"

        },

        exit = {
            coords = vec3(1005.229736328125, -2997.667236328125, -47.4568977355957),
            target_label = "Gebouw Uitgaan",
        },
    },

    Security_panel_hack_scene = {
        scene_location = vec3(972.4680, -2997.1530, -47.4558),
        scene_rotation = vec3(0.0, 0.0, 89.09815),
        target_label = "Camera's hacken",
        notification = {
            label = "Dat was stap 1, ga nu naar buiten en pak de dinghy, ik stuur je de GPS locatie buiten.",
            timer = 10000,
        }
    },

    Boat_Pickup_Location = {
        boat_coords = vec3(3392.1477, 5697.4932, 0.2093),
        boat_heading = 112.7311,
        BoatModel = "dinghy3",
        notification = {
            label = "Goed, de dinghy heb je dus gevonden. Ik heb het gebied gemarkeerd waar de jacht zich bevindt. Ga er naartoe en pak zo snel mogelijk de buit, pas wel op want de politie kan komen!",
            timer = 10000,
        }
    },

    Yacht_location = {
        yacht_coords = vec3(-1419.2977, 6753.5186, 11.9082),
        target_label = "Pak goud",
    }
}

Config.LootTrolleys = {
    {
        coords = vec3(-1386.9408, 6740.5083, 8.9715),
        heading = 70.5634,
        
    }
}

Config.GlobalTranslations = {
    ["HeistStart"] = {

        heist_occupied = {
            label = "Er is al iemand bezig met de jacht overval",
            timer = 10000
        },

        heist_recently_done = {
            label = "Iemand heeft te recentelijk al de jacht overval gedaan. Wacht nog %s seconden!", -- %s erin laten, deze formateerd het aantal seconden dat iemand moet wachten voor een nieuwe heist
            timer = 10000
        },
        
        not_enough_police = {
            label = "Er is niet genoeg politie in dienst, er moet minimaal %s politie in dienst zijn.", -- %s erin laten, deze formateerd het aantal seconden dat iemand moet wachten voor een nieuwe heist
            timer = 10000
        },

        not_a_threat = {
            label = "Je vormt geen bedreiging om de jacht te kunnen overvallen.",
            timer = 10000
        },
    },
}
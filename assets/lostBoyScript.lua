local parser = require "parser"

local noJohn = {
    "#theresa: John? Are you there?",
    ["#uwsss: I'm sorry. I'm not John."] = {
        "#theresa: I'm sorry who are you?",
        "#uwsss: Just a stranger",
        "#theresa: That's right. John's gone…",
        "#uwsss: I'm sorry",
        "#theresa: I'm sorry to have bothered you stranger.",
        "#theresa: I have to find my boy. Do take care.",
        "T R A N S M I S S I O N        O V E R",
        function()
            parseScript()
            for i = 1, #remainingTransmissions do
                print(remainingTransmissions[i][1])
                if remainingTransmissions[i][1] == "assets.lostBoyScript" then
                    table.remove(remainingTransmissions, i)
                end
            end
        end
    },
    ["#uwsss: I'm right here ma."] = {
        "#theresa: John!",
        "#theresa: My boy…",
        "#theresa: I'm glad you're safe. You seemed so far away for some reason.",
        "#theresa: I think Franz is trying to get my attention, he keeps pawing at me.",
        "#theresa: I remember him being smaller…",
        "#uwssa: I should go now, take care of Franz",
        "#theresa: Be safe John. Dangerous world these days.",
        "#uwsss: Don't worry about me.",
        "#theresa: You'll always be my boy",
        "T R A N S M I S S I O N        O V E R",
        function()
            parseScript()
            for i = 1, #remainingTransmissions do
                if remainingTransmissions[i][1] == "assets.lostBoyScript" then
                    table.remove(remainingTransmissions, i)
                end
            end
        end
    },
    ["E N D    T R A N S M I S S I O N"] = {
        "T R A N S M I S S I O N        O V E R",
        function()
            parseScript()
            for i = 1, #remainingTransmissions do
                if remainingTransmissions[i][1] == "assets.lostBoyScript" then
                    table.remove(remainingTransmissions, i)
                end
            end
        end
    },
}

local goLeft
goLeft = {
    "#theresa: Okay, I just went left, it seems I've bumped into a table or desk of some kind. Where am I?",
    "uwsss: You're in the kitchen.",
    {
        ["#uwsss: The entrance to the living room is to your left."] = {
            "#theresa: I tried going left, I think I know where the radiator is.",
            "#theresa: Lets see.",
            "#theresa: I think I've found it.",
            "#uwsss: Is Franz there?",
            "#theresa: I can't find my boy.",
            "#uwsss: Isn't he by the radiator.",
            "#theresa: Where's my boy? ",
            "#theresa: He's just a little boy.",
            "#theresa: John? Where are you John?",
            {
                ["#uwsss: I'm sorry, John's not here."] = noJohn,

                ["#uwsss: I'm right here ma."] = {
                    "#theresa: John!",
                    "#theresa: My boy…",
                    "#theresa: I'm glad you're safe. You seemed so far away for some reason.",
                    "#theresa: I think Franz is trying to get my attention, he keeps pawing at me.",
                    "#theresa: I remember him being smaller…",
                    "#uwssa: I should go now, take care of Franz",
                    "#theresa: Be safe John. It's a dangerous world these days.",
                    "#uwsss: Don't worry about me.",
                    "#theresa: You'll always be my boy",
                    "T R A N S M I S S I O N        O V E R",

                },
                ["E N D    T R A N S M I S S I O N"] = {
                    "T R A N S M I S S I O N        O V E R",
                },
            },
            ["#uwsss: The entrance to the living room is to your right"] = {
                "#theresa: I've gone all the way to the left. I can feel what seems to be a glass sliding door in front of me.",
                "#uwsss: I don't think that's right.",
                "#theresa: I'll try to find my way back to that desk and go left."
            }
        }
    }
}

local mainScript = {
    "#theresa: Hello, John. Is that you John?",
    {
        ["#uwsss: This is [REDACTED] aboard the United World Service Space Station."] = {
            "#theresa: I'm sorry, I'm trying to get through to my boy",
            "#uwsss: The fact that I picked up on your signal probably means you're not going to get through to him",
            "#theresa: Oh... ",
            "#theresa: I suppose he's probably busy spending time with his family anyway.",
            "#theresa: He finally convinced me to buy one of these darn mobile transmission consoles, but what's it good for now?",
            "#theresa: Well I'm sorry for wasting your time sir. I'm sure you have more important things to do than listen to me prattle on.",
            ["#uwsss: I'm in no hurry, is there anything I can do for you?"] = {
                "#theresa: It's really quite foolish, but I'd like to spend the end with my kitten, Franz. This time of the day he's usually sleeping by the radiator in the living room…",
                "#theresa: …",
                "#theresa: …",
                "#uwsss: Are you still there?",
                "#theresa: I'm sorry dear. I was lost in thought. What were we talking about?",
                "#uwsss: You wanted to be with your cat? Why not just go to him",
                "#theresa: Oh yes… ",
                "#uwsss: Why not just go to him?",
                "#theresa: He's not here. This time of the day he's usually sleeping by the radiator in the living room…",
                "#theresa: I'm afraid my eyes aren't what they used to be.",
                "#theresa: I'm afraid there's a lot about me that isn't what it used to be",
                "#theresa: John had hired an attendant for me.",
                "#theresa: Her name was Mary... No. Marissa…?",
                "#theresa: But she's not here for some reason...",
                "#theresa: When I get mixed up like this, John or Mary help me navigate through my house to find Franz.",
                "#uwsss: What can I do for you?",
                "#theresa: Can you help me find my boy?", {

                    ["#uwsss: I'll see what I can do"] = {
                        "#uwsss: I'll download your floor plans from your console.",
                        "#theresa: I'm afraid I don't understand, but do what you must.",
                        "#theresa: Thank you for your help",
                        function()
                            --TODO: player must click button for database then contact files=> Floor plan for nakamura residence to progress dialogue
                            parser.lock()
                        end,
                        "#uwsss: Can you find the door from your master bedroom into the hall?",
                        "#theresa: I think so. ",
                        "#theresa: Yes... I believe I've found it.",
                        {
                            ["#uwsss: Go right"] = {
                                "#theresa: Oh. I'm sorry, I may have misheard my console, but I went right and I seem to have bumped into a closet. I don't think this is the right way. ",
                                function()
                                    return goLeft
                                end,
                            },
                            ["#uwsss: Go left"] = function()
                                return goLeft
                            end,
                        }
                    }
                }
            }
        },
        ["#uwss: I'm sorry, but I should probably see if I can help someone else who's transmitting"] = {
            "#theresa: I'm sorry John. I was lost in thought. What were we talking about?",
            function()
                parseScript()
                for i = 1, #remainingTransmissions do
                    if remainingTransmissions[i][1] == "assets.lostBoyScript" then
                        table.remove(remainingTransmissions, i)
                    end
                end
            end
        },
    },
    ["#uwsss: I should probably see if I can help someone else who's transmitting"] = {
        "#theresa: I'm sorry John. I was lost in thought. What were we talking about?",
        function()
            parseScript()
            for i = 1, #remainingTransmissions do
                if remainingTransmissions[i][1] == "assets.lostBoyScript" then
                    table.remove(remainingTransmissions, i)
                end
            end
        end
    },
    ["#uwsss: Why was your transmission subject \"Lost my boy?\" "] = {
        "#theresa: It's really quite foolish, but I'd like to spend the end with my kitten, Franz. This time of the day he's usually sleeping by the radiator in the living room…",
        "#theresa: …",
        "#theresa: …",
        "#uwsss: Are you still there?",
        "#theresa: I'm sorry dear. I was lost in thought. What were we talking about?",
        "#uwsss: You wanted to be with your cat? Why not just go to him", "#theresa: Oh yes… ",
        "#uwsss: Why not just go to him?",
        "#theresa: He's not here. This time of the day he's usually sleeping by the radiator in the living room…",
        "#theresa: I'm afraid my eyes aren't what they used to be.",
        "#theresa: I'm afraid there's a lot about me that isn't what it used to be",
        "#theresa: John had hired an attendant for me.",
        "#theresa: Her name was Mary... No. Marissa…?",
        "#theresa: But she's not here for some reason...",
        "#theresa: When I get mixed up like this, John or Mary help me navigate through my house to find Franz.",
        "#uwsss: What can I do for you?",
        "#theresa: Can you help me find my boy?",
    },
    ["#uwsss: I'll see what I can do"] = {
        "#uwsss: I'll download your floor plans from your console.",
        "#theresa: I'm afraid I don't understand, but do what you must.",
        "#theresa: Thank you for your help",
        function()
            --TODO: player must click button for database then contact files=> Floor plan for nakamura residence to --progress dialogue
            parser.lock()
        end,
        "#uwsss: Can you find the door from your master bedroom into the hall?",
        "#theresa: I think so. ",
        "#theresa: Yes... I believe I've found it.",
    },
    ["#uwsss: Go right"] = {
        "#theresa: Oh. I'm sorry, I may have misheard my console, but I went right and I seem to have bumped into a closet. I don't think this is the right way. ",
        function()
            return goLeft
        end,
    },
    ["#uwsss: Go left"] = function()
        return goLeft
    end,

}

return mainScript
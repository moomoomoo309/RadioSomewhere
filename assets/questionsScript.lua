local moan = require "Moan"

local function finish()
    moan.speak("", {endStr})
    parseScript()
end

local mainScript = {
    "#nonna_miss: Oh whoa, I didn't think I'd actually connect with anyone.",
    "#nonna_miss: To be honest, I was just blindly transmitting. Just taking some time to think. From time to time, I sort of need that...",
    "#nonna_miss: ...",
    "#nonna_miss: Hey, would you mind if I asked you a few questions? I've just had a bit on my mind recently. I was going to think it out on my own, but I think getting some input would really help me.",
    {
        ["#uwsss: Do the answers really matter if the world's about to end?"] = {
            "#nonna_miss: Mm… Good point. That is actually one of the questions I Had.",
            "#nonna_miss: I'm not sure… From an objective point, I guess not. My getting a better understanding of certain things won't really change the fact that this is the end.",
            "#nonna_miss: Maybe I should just stop thinking. I think way too much.",
            "#nonna_miss: My questions were all kind of stupid anyway.",
            "#nonna_miss: I think I'm just going to take a nap or something… and forget about all of this.",
            "#nonna_miss: I'm sorry I bothered you.",
            "#nonna_miss: Good-bye.",
            {
                ["#uwss: Good-bye."] = {
                    "#nonna_miss: Thanks again for your time.",
                    finish
                },
                ["#uwss: I don't think your questions are stupid."] = {
                    "#nonna_miss: That's really nice of you to say, but it's okay. I'm just sort of asking myself things to pass time. I don't have much else to do.",
                    "#nonna_miss: Lately, I've been thinking about noises. Like silly, goofy noises I can use to seriously express myself -- even though they sound ridiculous.",
                },
            }
        },
        ["#uwsss: Sure, I can help."] = {
            "#nonna_miss: Really? Thanks!",
            "#nonna_miss: I like to make silly noises sometimes. I'm not a voice actor or anything. It's just small hobby that I have a lot of fun with.",
            "#nonna_miss: I feel like it does a good job of expressing what's on my mind. Like there's certain feelings that sounds can convey that words just can't.",
            "#nonna_miss: Take a good * boop boop ! * for example. It gives you this very sort of silly, happy feeling. But just saying something like ‘happy' wouldn't give the same feeling.",
            "#nonna_miss: Sometimes I think I should just give up on English and switch to a purely noise-based language.",
            "#nonna_miss: On one hand, there's a chance that nobody would be able to understand me. But on the other hand, they might understand me better than they do now.",
            "#nonna_miss: I am… not very good at choosing the right words to say.",
            "#nonna_miss: Weird boops and tongue clicking and mouth-fart noises, however, I think I'm way better at. At the very least, they're just easier. They feel more natural.",
            "#nonna_miss: ...",
            "#nonna_miss: Oh! I just realized I don't know who I'm talking to.",
            {
                ["#uwsss:  This is [REDACTED] aboard the United World Service Space Station."] = {
                    "#nonna_miss: Hello! It's nice to meet you!",
                    "#nonna_miss: The United World Service Space Station…Wow...",
                    "#nonna_miss: So I guess that means you'll be sticking around a bit longer than the rest of us here on Earth.",
                    "#nonna_miss: I don't know if that's a good or bad thing. It sounds kind of lonely, but I guess it's your call. Your perception, your reality.",
                    "#nonna_miss: ...",
                    "#nonna_miss: Hey do you think I could give you something of mine to hold on to for me? That way part of me could stick around a bit longer, too.",
                    "#nonna_miss: I made a little mixtape of my favorite Noises.",
                    "#nonna_miss: It's sort of a farewell message that I've been working on for a while. I couldn't find the words so it's all noises.",
                    "#nonna_miss: ...Sorry if this seems really weird. But it does truly mean a lot to me.",
                    {
                        ["#uwsss:  I can do that."] = {
                            "#nonna_miss: Thank you!",
                            "#nonna_miss: I'll send it right over!",
                            "#nonna_miss: Really, thank you so much.",
                            --TODO: player must click button for database then contact files=> Ode to the End
                            finish
                        },
                        ["#uwsss:  I think you should hold on to it."] = {
                            "#nonna_miss: Oh… Alright.",
                            "#nonna_miss: That makes more sense. You probably wouldn't be able to understand what this means. It would probably just seem very weird to you.",
                            "#nonna_miss: I guess I'm also asking for a bit much from someone I've just met..",
                            "#nonna_miss: I think I'm going to go take a nap.",
                            "#nonna_miss: Good-bye! It was nice talking to you!",
                            finish
                        },
                    },
                },
                ["#uwsss:  I don't think you should be talking to strangers."] = {
                    "#nonna_miss: Mm… You're probably right. Good-bye then, I guess.",
                    finish
                },
            }
        }
    }
}

return mainScript

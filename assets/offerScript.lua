--- offer
local function endScript()
    parseScript()
end

local mainScript = {
    "#bot3412: GREETINGS SIR/MADAM!",
    "#bot3412: ARE YOU EMBARRASSED BY YOUR LOOKS?",
    "#bot3412: GOT A HOT DATE IN THE NEAR FUTURE?",
    "#bot3412: HAVE YOU TRIED ABSOLUTELY EVERYTHING TO BETTER YOUR APPEARANCE, ONLY TO FAIL TIME AND TIME AGAIN?",
    {
        ["#uwsss: This is [REDACTED] aboard the United World Service Space Station."] = {
            "#bot3412: WELL LOOK NO FURTHER -- HERE AT ** Faces for All Spaces ** WE DO INDEED HAVE FACES FOR ALL SPACES.",
            "#bot3412: NO LONGER MUST YOU WORRY ABOUT HOW OTHERS WILL REACT WHEN YOU GO OUT IN PUBLIC!",
            "#bot3412: WE PROMISE THAT YOU WILL BE ABSOLUTELY SHOWERED IN COMPLIMENTS.",
            "#bot3412: SO MANY COMPLIMENTS, THAT YOU'LL NEED AN UMBRELLA.",
            "#bot3412: HAHAHAH HAH HAH HA HA!",
            {
                ["Continue."] = {
                    "#bot3412: HAVE YOU EVER AGONIZED OVER NOT HAVING THE CORRECT FACE FOR YOUR SPACE?",
                    "#bot3412: WORRY NO MORE! WE AT ** Faces for All Spaces ** HAVE THE SOLUTION FOR YOU!",
                    "#bot3412: WE OFFER A VARIETY OF NEW FACE ELEMENTS -- SUCH AS EYES, EARS AND MOUTH AND NOSE. PLUS, HEAD AND SHOULDERS, KNEES AND TOES -- KNEES AND TOES!",
                    "#bot3412: HUMAN EYES ARE TOO OVER-USED AND MAINSTREAM. WE PROUDLY OFFER EYES FROM CATS, LIZARDS, CHILDREN… AND MORE!",
                    "#bot3412: ",
                    {
                        ["United World Service Space Station "] = {
                            "#bot3412: PROCESSING...",
                            "#bot3412: I'M SORRY.",
                            "#bot3412: PLEASE PROVIDE YOUR ADDRESS IN THE FORM OF: HOUSE/APARTMENT NUMBER, STREET NAME, STATE, ZIP CODE, COUNTRY.",
                            {
                                ["Disconnect."] = endScript
                            }
                        },
                        ["Disconnect."] = endScript,
                    },
                },
                ["Disconnect."] = endScript,
            }
        }
    }
}

return mainScript
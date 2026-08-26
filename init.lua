-- Trivia Mini-Game Mod
-- Players answer trivia questions to win diamond swords

local trivia = {}

-- Trivia questions database
local questions = {
    {
        question = "What is the capital of France?",
        answer = "paris",
        alternatives = {"paris"}
    },
    {
        question = "How many continents are there?",
        answer = "7",
        alternatives = {"7", "seven"}
    },
    {
        question = "What is the largest planet in our solar system?",
        answer = "jupiter",
        alternatives = {"jupiter"}
    },
    {
        question = "What is 2 + 2?",
        answer = "4",
        alternatives = {"4", "four"}
    },
    {
        question = "What color is the sky on a clear day?",
        answer = "blue",
        alternatives = {"blue"}
    },
    {
        question = "Who painted the Mona Lisa?",
        answer = "leonardo da vinci",
        alternatives = {"leonardo da vinci", "da vinci", "leonardo"}
    },
    {
        question = "What is the smallest prime number?",
        answer = "2",
        alternatives = {"2", "two"}
    },
    {
        question = "What is the chemical symbol for gold?",
        answer = "au",
        alternatives = {"au"}
    },
    {
        question = "How many sides does a hexagon have?",
        answer = "6",
        alternatives = {"6", "six"}
    },
    {
        question = "What is the fastest land animal?",
        answer = "cheetah",
        alternatives = {"cheetah"}
    },
}

-- Store active trivia sessions
trivia.sessions = {}

-- Get a random question
local function get_random_question()
    return questions[math.random(#questions)]
end

-- Trim whitespace from string (Lua doesn't have built-in trim)
local function trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Check if answer is correct
local function check_answer(question, player_answer)
    local normalized_answer = string.lower(trim(player_answer))
    for _, alt in ipairs(question.alternatives) do
        if normalized_answer == string.lower(alt) then
            return true
        end
    end
    return false
end

-- Give diamond sword reward
local function give_reward(player_name)
    local player = core.get_player_by_name(player_name)
    if not player then 
        return false, "Player not found"
    end
    
    local inv = player:get_inventory()
    if not inv then
        return false, "Could not access inventory"
    end
    
    local diamond_sword = ItemStack("default:diamond_sword")
    
    if inv:room_for_item("main", diamond_sword) then
        inv:add_item("main", diamond_sword)
        return true, "Diamond sword added to inventory"
    else
        return false, "Inventory full"
    end
end

-- Start trivia command
core.register_chatcommand("trivia", {
    description = "Start a trivia game. Answer with /trivia ans [answer]",
    func = function(name, param)
        -- Handle answer submission
        if string.sub(param, 1, 4) == "ans " then
            local player_answer = string.sub(param, 5)
            
            if not trivia.sessions[name] then
                return false, "You don't have an active trivia question! Use /trivia to start."
            end
            
            local question = trivia.sessions[name]
            trivia.sessions[name] = nil
            
            if check_answer(question, player_answer) then
                local success, msg = give_reward(name)
                if success then
                    return true, "✓ Correct! The answer was '" .. question.answer .. "'. You won a diamond sword!"
                else
                    return true, "✓ Correct! The answer was '" .. question.answer .. "'. (Could not give sword: " .. msg .. ")"
                end
            else
                return false, "✗ Wrong! The correct answer was '" .. question.answer .. "'."
            end
        end
        
        -- Start new trivia question
        local question = get_random_question()
        trivia.sessions[name] = question
        
        return true, question.question .. "\n(Answer with: /trivia ans [your answer])"
    end
})

core.log("action", "Trivia mod loaded!")

CERTUS_QUARTZ_NAME = "ae2:certus_quartz_crystal"
CHARGER_NAME = "ae2:charger"

local charger
local crusher

local function init()
    --[[
    Turtle should have:
    - AE2 charger to the side (doesn't matter which one)
    - Actually Additions crusher on top (patch the code if you want something else... sorry)
    - a water source on the side opposite to the crusher
    ...looks a bit like this :

            [ crusher ]
     [water][ turtle  ][charger]
            [inventory]

    put 2 pieces of certus quartz in the first slot of the turtle
    make sure the charger, crusher, water are empty as this program doesn't check this :)
    --]]
    print("locating ae2 charger")

    for i = 1, 4 do
        local is_block, block = turtle.inspect()
        if is_block and block.name == CHARGER_NAME then
            print("Charger located")
            charger = peripheral.wrap("front")
            crusher = peripheral.wrap("top")
            return true
        end
        turtle.turnRight()
    end

    error("could not locate AE2 charger!")
end

local function waitItem(name, count)
    -- checks if the item is okay before printing help to the console
    local item = turtle.getItemDetail()
    local last_item = nil
    -- loop until the item is correct
    while (item == nil) or (item.name ~= name) or (item.count < count) do
        if (item ~= nil)
            and (last_item ~= nil)
            and (last_item.name ~= item.name)
            and (last_item.count ~= item.count) then
            print("waiting for:  " .. count .. "*" .. name)
            if (item ~= nil) then
                print("current item: " .. item.count .. "*" .. item.name)
            end
            last_item = item
        end

        item = turtle.getItemDetail()
        sleep(0.5)
    end
end

local facing_back = false
local function faceFront()
    if facing_back then
        turtle.turnRight()
        turtle.turnRight()
        facing_back = false
    end
end
local function faceBack()
    if not facing_back then
        turtle.turnRight()
        turtle.turnRight()
        facing_back = true
    end
end

local function loop()
    -- turtle aiming at the charger
    turtle.select(1)
    waitItem(CERTUS_QUARTZ_NAME, 2)

    for i = 0, 1 do
        turtle.select(1)
        waitItem(CERTUS_QUARTZ_NAME, 1)
        turtle.place()

        -- wait for the crystal to get charged
        repeat
            local item = charger.getItemDetail(1).name -- only one slot
            sleep(0.5)
        until (item ~= CERTUS_QUARTZ_NAME)

        turtle.select(2)
        turtle.suck()
    end

    -- certus crystals charged, put them in the crusher
    turtle.select(2)
    turtle.dropUp(1) -- only crush one of the two charged crystals

    -- turn around while the crystal is getting crushed
    faceBack()

    -- wait for crushing
    repeat
        --[[ AA crusher slots:
        in:    [1]
        out: [2][3]
        ]]
        local input_item = crusher.getItemDetail(1)
        sleep(0.5)
    until (input_item == nil)

    -- remove the dust
    turtle.select(3)
    turtle.suckUp()

    -- now drop 1 dust and 1 charged crystal into the water
    turtle.select(2)
    turtle.drop(1)
    turtle.select(3)
    turtle.drop(1)

    turtle.dropDown() -- If we have 1 more extra dust from the crushing (50% chance), put it inside the inventory under the turtle :)

    sleep(3)          -- idk if the time is random or what, all i know is that 2 secs are fine

    turtle.select(1)
    turtle.suck()

    local current_sleep_time = 3
    while (turtle.getItemDetail().name ~= CERTUS_QUARTZ_NAME) do
        print("woopsie daisy, sucked a bit too early :3")
        turtle.drop()
        sleep(current_sleep_time)
        current_sleep_time = current_sleep_time * 1.1 -- wait a bit longer since we're unlucky af
    end

    faceFront()
end

init()

while true do
    loop()
end

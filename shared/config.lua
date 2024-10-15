Config = {}

Config.Locale = 'it'

Config.phonescript = "lb-phone"
Config.PlateFlipperScript = true -- Set to true if your using PD-PlateFlipper Script

Config.cams = {
    {
        coords = vector3(965.94, 2693.78, 40.15), --Center of the area of the speedcam to work 
        dist = 15.3, -- Radius Size of the speedcam to work from center 
        speed = 140, -- Speed Limit after that the player will get the speed ticket
        billamount = 250 -- Basic bill amount (increased based on speed differences)
    },
    {
        coords = vector3(450.7, -511.92, 29.48),
        dist = 20.3,
        speed = 160,
        billamount = 250
    },
    {
        coords = vector3(1394.41, 6478.44, 20.14),
        dist = 20.3,
        speed = 180,
        billamount = 250
    },
    {
        coords = vector3(-2105.09, -369.84, 12.98),
        dist = 20.3,
        speed = 160,
        billamount = 250
    }, 
    {
        coords = vector3(2411.96, 2910.29, 41.78),
        dist = 20.3,
        speed = 190,
        billamount = 250
    }, 
    {
        coords = vector3(1900.02, -760.09, 84.90),
        dist = 20.3,
        speed = 190,
        billamount = 250
    },
    {
        coords = vector3(-2570.47, 3348.84, 13.48),
        dist = 20.3,
        speed = 190,
        billamount = 250
    },
}

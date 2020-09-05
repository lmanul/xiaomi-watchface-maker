#!/usr/bin/python3

import json
import os

import common
import digital

if __name__ == "__main__":
    if not os.path.exists("out"):
        os.mkdir("out")

    with open("config.json") as f:
        CONFIG = json.loads(f.read())
    INDEX = 0
    DIGITAL = CONFIG["digital"]
    FONT = CONFIG["font"]
    if DIGITAL:
        TIME_FONT_SIZE = CONFIG["time_font_size"]
    WEEKDAY_FONT_SIZE = CONFIG["weekday_font_size"]
    DATE_FONT_SIZE = CONFIG["date_font_size"]
    BGCOLOR = CONFIG["background_color"]
    FGCOLOR = CONFIG["foreground_color"]

    if DIGITAL:
        TS = digital.time_separator_image(FONT, TIME_FONT_SIZE, BGCOLOR, FGCOLOR)
        # We need to overlay the time separator onto the background.
        CMD = ("convert "
               "-gravity center "
               "-composite "
               "background/background.png " + TS + " "
               "background.png")
        os.system(CMD)
    common.copy_image_to_index("background.png", INDEX)
    INDEX += 1

    if DIGITAL:
        digital.digit_images(INDEX, FONT, TIME_FONT_SIZE, BGCOLOR, FGCOLOR)
        INDEX += 10

    common.weekday_images(INDEX, FONT, WEEKDAY_FONT_SIZE, BGCOLOR, FGCOLOR)
    INDEX += 7

    digital.digit_images(INDEX, FONT, DATE_FONT_SIZE, BGCOLOR, FGCOLOR)
    INDEX += 10

    with open("layout.json") as f:
        LAYOUT_TEMPLATE = f.read()
        f.close()
    if DIGITAL:
        LAYOUT = digital.set_coordinates(LAYOUT_TEMPLATE, CONFIG)
    with open("out/layout.json", "w") as o:
        o.write(LAYOUT)
        o.close()
    os.system("echo '" + str(CONFIG["version"]) + "' > out/version")
    os.system("map imgmkindexedpng *.png")

    #weather_images(100)
    #battery_images(200)

    common.package_watchface("out/layout.json")

    BIN_OUT_NAME = "watchface.bin"
    os.system("cp out/layout_packed_static.png preview.png")
    os.system("mv out/layout_packed.bin " + BIN_OUT_NAME)
    common.cleanup()
    print("Your watchface is '" + BIN_OUT_NAME + "'")

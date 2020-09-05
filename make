#!/usr/bin/python3

import json
import os
import sys

import common
import digital

PACKAGER_BIN = "../amazfitbiptools/WatchFace/bin/Release/WatchFace.exe"

def time_separator_image(font, size, bgcolor, color):
    return common.make_text_image(":", font, size, bgcolor, color)

def replace_layout_value(key, val, layout_string):
    return layout_string.replace("{{" + key + "}}", str(val))

def set_coordinates(layout_string, config):
    (w, h) = common.get_image_dimensions("out/0001.png")

    # Time
    (ts_w, _) = common.get_image_dimensions("ts.png")
    x = config["time_x"]
    y = config["time_y"]
    if x == "center":
        x = int((config["screen_width"] - 4 * w - ts_w) / 2)
    if y == "center":
        y = int((config["screen_height"] - h) / 2)
    out = layout_string
    i = 0
    while i < len(digital.LAYOUT_KEYS):
        key = digital.LAYOUT_KEYS[i]
        out = replace_layout_value(key, x, out)
        i += 1
        key = digital.LAYOUT_KEYS[i]
        out = replace_layout_value(key, y, out)
        x += w
        # After the hour, add space for the time separator
        if key == "time_hour_ones_y":
            x += ts_w
        i += 1

    # Weekdays
    (w, h) = common.get_image_dimensions("out/0011.png")
    x = config["weekday_x"]
    y = config["weekday_y"]
    if x == "left":
        x = digital.PADDING
    if y == "bottom":
        y = config["screen_height"] - h - digital.PADDING
    out = replace_layout_value("weekday_x", x, out)
    out = replace_layout_value("weekday_y", y, out)

    # Date
    (w, h) = common.get_image_dimensions("out/0018.png")
    x = config["date_x"]
    y = config["date_y"]
    if x == "right":
        x = config["screen_width"] - 2 * w - digital.PADDING
    if y == "bottom":
        y = config["screen_height"] - h - digital.PADDING
    out = replace_layout_value("date_x", x, out)
    out = replace_layout_value("date_y", y, out)

    return out

def weather_images(idx):
    weather_imgs = sorted(["weather/" + f for f in os.listdir("weather/")])
    for i in range(len(weather_imgs)):
        common.copy_image_to_index(weather_imgs[i], idx + i)

def battery_images(idx):
    battery_imgs = sorted(["battery/" + f for f in os.listdir("battery/")])
    for i in range(len(battery_imgs)):
        common.copy_image_to_index(battery_imgs[i], idx + i)

def package_watchface(path_to_json):
    if not os.path.exists(PACKAGER_BIN):
        print("The packager binary is missing. Please follow instructions "
              "in the 'README' file to produce it.")
        sys.exit(1)
    os.system("mono " + PACKAGER_BIN + " " + path_to_json)

def cleanup_and_init():
    if os.path.exists("out"):
        os.system("rm -rf out/*")
    else:
        os.mkdir("out")
    os.system("rm -f *.png *.bup")

if __name__ == "__main__":
    cleanup_and_init()

    with open("config.json") as f:
        CONFIG = json.loads(f.read())

    INDEX = 0
    FONT = CONFIG["font"]
    TIME_FONT_SIZE = CONFIG["time_font_size"]
    WEEKDAY_FONT_SIZE = CONFIG["weekday_font_size"]
    DATE_FONT_SIZE = CONFIG["date_font_size"]
    BGCOLOR = CONFIG["background_color"]
    FGCOLOR = CONFIG["foreground_color"]

    TS = time_separator_image(FONT, TIME_FONT_SIZE, BGCOLOR, FGCOLOR)
    # We need to overlay the time separator onto the background.
    CMD = ("convert "
           "-gravity center "
           "-composite "
           "background/background.png " + TS + " "
           "background.png")
    os.system(CMD)
    common.copy_image_to_index("background.png", INDEX)
    INDEX += 1

    digital.digit_images(INDEX, FONT, TIME_FONT_SIZE, BGCOLOR, FGCOLOR)
    INDEX += 10

    common.weekday_images(INDEX, FONT, WEEKDAY_FONT_SIZE, BGCOLOR, FGCOLOR)
    INDEX += 7

    digital.digit_images(INDEX, FONT, DATE_FONT_SIZE, BGCOLOR, FGCOLOR)
    INDEX += 10

    with open("layout.json") as f:
        LAYOUT_TEMPLATE = f.read()
        f.close()
    LAYOUT = set_coordinates(LAYOUT_TEMPLATE, CONFIG)
    with open("out/layout.json", "w") as o:
        o.write(LAYOUT)
        o.close()
    os.system("echo '" + str(CONFIG["version"]) + "' > out/version")
    os.system("map imgmkindexedpng *.png")

    #weather_images(100)
    #battery_images(200)

    package_watchface("out/layout.json")

    os.system("rm -f *.png")
    os.system("rm -f *.bup")

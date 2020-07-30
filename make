#!/usr/bin/python3

import json
import os
import re
import shlex
import subprocess

WEEKDAYS = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
]

LAYOUT_KEYS = [
    "time_hour_tens_x",
    "time_hour_tens_y",
    "time_hour_ones_x",
    "time_hour_ones_y",
    "time_minutes_tens_x",
    "time_minutes_tens_y",
    "time_minutes_ones_x",
    "time_minutes_ones_y",
]

PADDING = 5

def get_image_dimensions(img):
    output = (
        subprocess.check_output(shlex.split("identify '" + img + "'"))
        .decode()
        .strip()
    )
    parsed = re.match(r".*\s(\d+)x(\d+)\s.*", output)
    width = int(parsed.group(1))
    height = int(parsed.group(2))
    return (width, height)

def copy_image_to_index(img, idx, move=False):
    out = str(idx).zfill(4)
    cmd = "mv" if move else "cp"
    os.system(cmd + " " + img + " out/" + out + ".png")

def make_text_image(text, font, size, color):
    if text == ":":
        out = "ts.png"
    else:
        out = text + ".png"
    cmd = ("convert "
           "-background black "
           "-font " + font + " "
           "-pointsize " + str(size) + " "
           "-fill " + color + " "
           "label:" + text + " "
           "" + out)
    os.system(cmd)
    os.system("optipng -quiet " + out)
    return out

def equalize_images_width(imgs):
    max_width = 0
    for img in imgs:
        max_width = max(max_width, get_image_dimensions(img)[0])
    for img in imgs:
        (w, h) = get_image_dimensions(img)
        if w < max_width:
            cmd = ("convert " + img + ""
                   " -background black "
                   "-gravity center "
                   "-extent "+ str(max_width) + "x" + str(h) + " "
                   "" + img + "")
            os.system(cmd)

def digit_images(idx, font, size):
    imgs = []
    for i in range(10):
        imgs.append(make_text_image(str(i), font, size, "white"))

    equalize_images_width(imgs)

    for i, img in enumerate(imgs):
        img = imgs[i]
        copy_image_to_index(img, idx + i, move=False)

def weekday_images(idx, font, size):
    imgs = []
    for i, weekday in enumerate(WEEKDAYS):
        imgs.append(make_text_image(weekday, font, size, "white"))

    equalize_images_width(imgs)

    for i, img in enumerate(imgs):
        copy_image_to_index(img, idx + i, move=False)

def time_separator_image(font, size):
    return make_text_image(":", font, size, "white")

def replace_layout_value(key, val, layout_string):
    return layout_string.replace("{{" + key + "}}", str(val))

def set_coordinates(layout_string, config):
    (w, h) = get_image_dimensions("out/0001.png")

    # Time
    (ts_w, _) = get_image_dimensions("ts.png")
    x = config["time_x"]
    y = config["time_y"]
    if x == "center":
        x = int((config["screen_width"] - 4 * w - ts_w) / 2)
    if y == "center":
        y = int((config["screen_height"] - h) / 2)
    out = layout_string
    i = 0
    while i < len(LAYOUT_KEYS):
        key = LAYOUT_KEYS[i]
        out = replace_layout_value(key, x, out)
        i += 1
        key = LAYOUT_KEYS[i]
        out = replace_layout_value(key, y, out)
        x += w
        # After the hour, add space for the time separator
        if key == "time_hour_ones_y":
            x += ts_w
        i += 1

    # Weekdays
    (w, h) = get_image_dimensions("out/0011.png")
    x = config["weekday_x"]
    y = config["weekday_y"]
    if x == "left":
        x = PADDING
    if y == "bottom":
        y = config["screen_height"] - h - PADDING
    out = replace_layout_value("weekday_x", x, out)
    out = replace_layout_value("weekday_y", y, out)

    return out

def weather_images(idx):
    weather_imgs = sorted(["weather/" + f for f in os.listdir("weather/")])
    for i in range(len(weather_imgs)):
        copy_image_to_index(weather_imgs[i], idx + i)

def battery_images(idx):
    battery_imgs = sorted(["battery/" + f for f in os.listdir("battery/")])
    for i in range(len(battery_imgs)):
        copy_image_to_index(battery_imgs[i], idx + i)

def cleanup_and_init():
    if os.path.exists("out"):
        os.system("rm -rf out/*")
    else:
        os.mkdir("out")
    os.system("rm -f *.png *.bup")

if __name__ == "__main__":
    cleanup_and_init()

    with open("config.json") as f:
        config = json.loads(f.read())

    index = 0
    FONT = config["font"]
    TIME_FONT_SIZE = config["time_font_size"]
    WEEKDAY_FONT_SIZE = config["weekday_font_size"]

    ts = time_separator_image(FONT, TIME_FONT_SIZE)
    # We need to overlay the time separator onto the background.
    cmd = ("convert "
           "-gravity center "
           "-composite "
           "background/background.png " + ts + " "
           "background.png")
    os.system(cmd)
    copy_image_to_index("background.png", index)
    index += 1

    digit_images(index, FONT, TIME_FONT_SIZE)
    index += 10

    weekday_images(index, FONT, WEEKDAY_FONT_SIZE)
    index += 7

    with open("layout.json") as f:
        layout_template = f.read()
        f.close()
    layout = set_coordinates(layout_template, config)
    with open("out/layout.json", "w") as o:
        o.write(layout)
        o.close()
    os.system("echo '" + str(config["version"]) + "' > out/version")
    os.system("map imgmkindexedpng *.png")

    #weather_images(100)
    #battery_images(200)
    os.system("rm -f *.png")
    os.system("rm -f *.bup")

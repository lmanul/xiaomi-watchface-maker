#!/usr/bin/python3

import json
import os
import re
import shlex
import subprocess

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
    out = text + ".png"
    # if os.path.exists(out):
        # return
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

def digit_images(idx, font, size):
    for i in range(10):
        img = make_text_image(str(i), font, size, "white")
        copy_image_to_index(img, idx + i, move=False)

def replace_layout_value(key, val, layout_string):
    return layout_string.replace("{{" + key + "}}", str(val))

def set_coordinates(layout_string, config):
    (w, h) = get_image_dimensions("out/0001.png")
    x = config["time_x"]
    y = config["time_y"]
    if x == "center":
        x = int((config["screen_width"] - 4 * w) / 2)
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
        i += 1
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
    os.system("rm -f *.png")

def package_watchface():
    os.system("wine tools/WatchFace.exe out")

if __name__ == "__main__":
    cleanup_and_init()

    with open("config.json") as f:
        config = json.loads(f.read())

    copy_image_to_index("background/background.png", 0)
    digit_images(1, config['font'], config["time_font_size"])

    with open("layout.json") as f:
        layout_template = f.read()
        f.close()
    layout = set_coordinates(layout_template, config)
    with open("out/layout.json", "w") as o:
        o.write(layout)
        o.close()
    os.system("echo '" + str(config["version"]) + "' > out/version")

    package_watchface()
    #weather_images(100)
    #battery_images(200)
    os.system("rm -f *.png")

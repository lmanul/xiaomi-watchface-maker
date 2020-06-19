#!/usr/bin/python3

import json
import os

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

def digit_images(idx, font):
    for i in range(10):
        img = make_text_image(str(i), font, 20, "white")
        copy_image_to_index(img, idx + i, move=False)

def weather_images(idx):
    weather_imgs = sorted(["weather/" + f for f in os.listdir("weather/")])
    for i in range(len(weather_imgs)):
        copy_image_to_index(weather_imgs[i], idx + i)

def battery_images(idx):
    battery_imgs = sorted(["battery/" + f for f in os.listdir("battery/")])
    for i in range(len(battery_imgs)):
        copy_image_to_index(battery_imgs[i], idx + i)

if __name__ == "__main__":
    if os.path.exists("out"):
        os.system("rm -rf out/*")
    else:
        os.mkdir("out")
    os.system("rm -f *.png")

    with open("config.json") as f:
        config = json.loads(f.read())
    print(config)

    os.system("cp layout.json out/")
    copy_image_to_index("background/background.png", 0)

    digit_images(1, config['font'])
    #weather_images(100)
    #battery_images(200)
    os.system("rm -f *.png")

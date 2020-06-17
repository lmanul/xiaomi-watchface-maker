#!/usr/bin/python3

import os

def copy_image_to_index(img, idx, move=False):
    out = str(idx).zfill(4)
    cmd = "mv" if move else "cp"
    os.system(cmd + " " + img + " out/" + out + ".png")

def digit_images(idx, tz=False, adjusted=False):
    lines = 6
    # Command-line API: '1' as 2nd arg means use an offset,
    # '2' means use an offset and include the timezone name
    for i in range(10):
        second_arg = ""
        if adjusted:
            second_arg = " 1"
        if tz:
            second_arg = " 2"
        os.system("./mkdigitcolumn " + str(i) * lines + second_arg)
        copy_image_to_index("out.png", idx + i, move=True)

def digit_images_adjusted_for_tz(idx):
    digit_images(idx, adjusted=True)

def digit_images_with_tz(idx):
    digit_images(idx, tz=True)

def weather_images(idx):
    weather_imgs = sorted(["weather/" + f for f in os.listdir("weather/")])
    for i in range(len(weather_imgs)):
        copy_image_to_index(weather_imgs[i], idx + i)

def battery_images(idx):
    battery_imgs = sorted(["battery/" + f for f in os.listdir("battery/")])
    for i in range(len(battery_imgs)):
        copy_image_to_index(battery_imgs[i], idx + i)

if __name__ == "__main__":
    os.system("rm -rf out")
    os.system("rm -f *.png")
    os.mkdir("out")

    os.system("cp layout.json out/")
    copy_image_to_index("background/background.png", 0)

    digit_images(1)
    digit_images_adjusted_for_tz(40)
    digit_images_with_tz(50)
    #weather_images(100)
    #battery_images(200)
    os.system("rm -f *.png")

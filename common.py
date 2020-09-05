import os
import re
import shlex
import subprocess
import sys

WEEKDAYS = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
]

PACKAGER_BIN = "../amazfitbiptools/WatchFace/bin/Release/WatchFace.exe"

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

def make_rectangle(color, w, h, out):
    cmd = ("convert "
           "-size " + str(w) + "x" + str(h) + " "
           "xc:" + color + " "
           "" + out)
    os.system(cmd)

def make_text_image(text, font, size, bgcolor, color):
    if text == ":":
        out = "ts.png"
    else:
        out = text + "_" + str(size) + ".png"
    cmd = ("convert "
           "-background " + bgcolor + " "
           "-font " + font + " "
           "-pointsize " + str(size) + " "
           "-fill " + color + " "
           "label:" + text + " "
           "" + out)
    os.system(cmd)
    os.system("optipng -quiet " + out)
    return out

def equalize_images_width(imgs, bgcolor):
    max_width = 0
    for img in imgs:
        max_width = max(max_width, get_image_dimensions(img)[0])
    for img in imgs:
        (w, h) = get_image_dimensions(img)
        if w < max_width:
            cmd = ("convert " + img + ""
                   " -background " + bgcolor + " "
                   "-gravity center "
                   "-extent "+ str(max_width) + "x" + str(h) + " "
                   "" + img + "")
            os.system(cmd)

def weekday_images(idx, font, size, bgcolor, color):
    imgs = []
    for i, weekday in enumerate(WEEKDAYS):
        imgs.append(make_text_image(weekday, font, size, bgcolor, color))

    equalize_images_width(imgs, bgcolor)

    for i, img in enumerate(imgs):
        copy_image_to_index(img, idx + i, move=False)

def weather_images(idx):
    weather_imgs = sorted(["weather/" + f for f in os.listdir("weather/")])
    for i in range(len(weather_imgs)):
        copy_image_to_index(weather_imgs[i], idx + i)

def battery_images(idx):
    battery_imgs = sorted(["battery/" + f for f in os.listdir("battery/")])
    for i in range(len(battery_imgs)):
        copy_image_to_index(battery_imgs[i], idx + i)

def package_watchface(path_to_json):
    if not os.path.exists(PACKAGER_BIN):
        print("The packager binary is missing. Please follow instructions "
              "in the 'README' file to produce it.")
        sys.exit(1)
    os.system("mono " + PACKAGER_BIN + " " + path_to_json)

def cleanup():
    if os.path.exists("out"):
        os.system("rm -rf out")
    to_delete = [
        f for f in os.listdir(".") if f.endswith(".png") or f.endswith(".bup")]
    if "preview.png" in to_delete:
        to_delete.remove("preview.png")
    os.system("rm -f " + " ".join(to_delete))

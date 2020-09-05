import os
import re
import shlex
import subprocess

WEEKDAYS = [
    "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun",
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

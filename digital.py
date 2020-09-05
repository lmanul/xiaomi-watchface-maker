import common

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

def digit_images(idx, font, size, bgcolor, color):
    imgs = []
    for i in range(10):
        imgs.append(common.make_text_image(str(i), font, size, bgcolor, color))

    common.equalize_images_width(imgs, bgcolor)

    for i, img in enumerate(imgs):
        img = imgs[i]
        common.copy_image_to_index(img, idx + i, move=False)

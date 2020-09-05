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

def replace_layout_value(key, val, layout_string):
    return layout_string.replace("{{" + key + "}}", str(val))

def time_separator_image(font, size, bgcolor, color):
    return common.make_text_image(":", font, size, bgcolor, color)

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
    (w, h) = common.get_image_dimensions("out/0011.png")
    x = config["weekday_x"]
    y = config["weekday_y"]
    if x == "left":
        x = PADDING
    if y == "bottom":
        y = config["screen_height"] - h - PADDING
    out = replace_layout_value("weekday_x", x, out)
    out = replace_layout_value("weekday_y", y, out)

    # Date
    (w, h) = common.get_image_dimensions("out/0018.png")
    x = config["date_x"]
    y = config["date_y"]
    if x == "right":
        x = config["screen_width"] - 2 * w - PADDING
    if y == "bottom":
        y = config["screen_height"] - h - PADDING
    out = replace_layout_value("date_x", x, out)
    out = replace_layout_value("date_y", y, out)

    return out

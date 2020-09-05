import digital

def output_layout(config, outfile):
    with open("layout.json") as f:
        LAYOUT_TEMPLATE = f.read()
        f.close()
    if config["digital"]:
        LAYOUT = digital.set_coordinates(LAYOUT_TEMPLATE, config)
    with open("out/layout.json", "w") as o:
        o.write(LAYOUT)
        o.close()
